"""Viscosity sensitivity sweep at N=128.

Case A: extend existing T=0.04 nu=0.001 run to T=0.06 (400 more steps).
Case B: fresh run at nu=0.0005 (half viscosity) to T=0.04.

Hou-Luo prediction: smaller nu -> smaller blowup time T*.
"""
import sys, time
import numpy as np
import torch

sys.path.insert(0, "benchmarks")
from hou_louo_ic import hou_luo_style_ic
from taylor_green_mps import (
    make_k_grids, make_dealias_mask, rk4_step, energy, max_vorticity,
    DEVICE, DTYPE,
)

N = 128
L = 2 * np.pi
DT = 5e-5
AMP = 10.0
SIGMA_Z = 0.5

print(f"Device: {DEVICE}, dtype: {DTYPE}")
print(f"N={N}, dt={DT}, IC: amp={AMP}, sigma_z={SIGMA_Z}")


def run_case(label, nu, T_final, out_path, skip_steps=0, log_every=100):
    """Run (or extend) a case to T_final, return arrays.

    skip_steps: if >0, skip the first skip_steps steps (handled by the
                caller's extend logic — unused here; this fn always runs
                from IC for clarity).  Left in for API symmetry.
    """
    n_steps_total = int(round(T_final / DT))
    # We always restart from IC and run for n_steps_total; this is simpler
    # and matches the existing data file convention.
    n_steps = n_steps_total

    kx, ky, kz, ksq = make_k_grids(N, L)
    dealias_mask = make_dealias_mask(N)
    uhat = hou_luo_style_ic(N, L, amplitude=AMP, sigma_z=SIGMA_Z)
    E0 = energy(uhat)
    om0 = max_vorticity(uhat, kx, ky, kz)
    print(f"[{label}] IC: E0={E0:.6e}, max|omega|={om0:.6e}")

    times = np.zeros(n_steps + 1, dtype=np.float64)
    max_om = np.zeros(n_steps + 1, dtype=np.float64)
    times[0] = 0.0
    max_om[0] = om0

    t0 = time.time()
    last_print = 0
    max_om_track = om0  # track running max for CFL check
    for step in range(n_steps):
        uhat = rk4_step(uhat, kx, ky, kz, ksq, nu, DT, dealias_mask)
        times[step + 1] = (step + 1) * DT
        max_om[step + 1] = max_vorticity(uhat, kx, ky, kz)
        if max_om[step + 1] > max_om_track:
            max_om_track = max_om[step + 1]
        if (step + 1) % log_every == 0 or step == n_steps - 1:
            torch.mps.synchronize()
            elapsed = time.time() - t0
            rate = elapsed / (step + 1)
            eta = rate * (n_steps - step - 1)
            cfl = DT * max_om_track
            print(f"[{label}] step {step+1:4d}/{n_steps}: t={times[step+1]:.5f}  "
                  f"max|omega|={max_om[step+1]:.4e}  elapsed={elapsed:.1f}s  "
                  f"ETA={eta:.1f}s  CFL={cfl:.3e}")
            last_print = step + 1

    wall = time.time() - t0
    torch.mps.synchronize()
    om_T = float(max_om[-1])
    growth = om_T / om0

    print()
    print(f"[{label}] FINAL max|omega| at T={T_final}: {om_T:.6e}")
    print(f"[{label}] Initial max|omega|:             {om0:.6e}")
    print(f"[{label}] Growth factor:                  {growth:.4f}x")
    print(f"[{label}] Wall-clock:                     {wall:.2f}s for {n_steps} steps "
          f"({wall/n_steps*1000:.2f} ms/step)")

    np.savez(out_path,
             times=times,
             max_omega=max_om,
             E0=E0,
             wall=wall,
             N=N, nu=nu, dt=DT, T_final=T_final,
             amplitude=AMP, sigma_z=SIGMA_Z)
    print(f"[{label}] Saved: {out_path}")
    return {"om0": om0, "om_T": om_T, "growth": growth, "wall": wall,
            "times": times, "max_om": max_om, "path": out_path}


if __name__ == "__main__":
    # Case A: extend T=0.04 -> T=0.06 at nu=0.001 (400 extra steps from T=0.04 state).
    # For simplicity & reproducibility, re-run from IC to T=0.06 (1200 steps).
    # This supersedes the existing T=0.04 file with a longer trajectory.
    print("=" * 60)
    print("Case A: N=128, nu=0.001, T=0.06")
    print("=" * 60)
    res_a = run_case("A", nu=0.001, T_final=0.06,
                     out_path="data/ns_run_N128_nu0.001_T06.npz")

    # Case B: fresh run at half viscosity, T=0.04.
    print()
    print("=" * 60)
    print("Case B: N=128, nu=0.0005, T=0.04 (HALF viscosity)")
    print("=" * 60)
    res_b = run_case("B", nu=0.0005, T_final=0.04,
                     out_path="data/ns_run_N128_nu0.0005_T04.npz")

    # Summary
    print()
    print("=" * 60)
    print("SUMMARY")
    print("=" * 60)
    print(f"Case A (nu=0.001,  T=0.06): max|omega|_T = {res_a['om_T']:.4e}, "
          f"growth = {res_a['growth']:.4f}x, wall = {res_a['wall']:.1f}s")
    print(f"Case B (nu=0.0005, T=0.04): max|omega|_T = {res_b['om_T']:.4e}, "
          f"growth = {res_b['growth']:.4f}x, wall = {res_b['wall']:.1f}s")
    print()
    # Compare same T (T=0.04) — we already have Case A's T=0.04 trajectory inside it
    idx_T04_A = int(round(0.04 / DT))
    om_T04_A = float(res_a['max_om'][idx_T04_A])
    om_T04_B = res_b['om_T']
    print(f"At T=0.04:")
    print(f"  nu=0.001  -> max|omega| = {om_T04_A:.4e}  (growth {om_T04_A/80.376:.4f}x)")
    print(f"  nu=0.0005 -> max|omega| = {om_T04_B:.4e}  (growth {om_T04_B/80.376:.4f}x)")
    delta_pct = (om_T04_B - om_T04_A) / om_T04_A * 100
    print(f"  Delta: smaller nu -> {delta_pct:+.2f}% max|omega| at T=0.04")