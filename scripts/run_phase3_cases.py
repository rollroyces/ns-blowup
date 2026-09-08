"""Phase 3: push the M4 GPU further.

Case A: N=192, nu=0.0005, T_final=0.04, dt=2e-5  (2000 steps, larger grid, half viscosity)
Case B: N=128, nu=0.00025, T_final=0.04, dt=2e-5  (2000 steps, quarter viscosity)

Hou-Luo prediction: at finer grids AND smaller nu, the resolution-scaling
ratio should grow UNBOUNDED if blowup is forming.  Previous data
plateaued at ratio=2.16 for (N=128/N=64) at nu=0.001 -- we now push both
axes to discriminate.

Run:
    source /Users/hermes/.hermes/projects/ns_blowup/venv/bin/activate
    cd /Users/hermes/.hermes/projects/ns_blowup
    python scripts/run_phase3_cases.py --case A
    python scripts/run_phase3_cases.py --case B
    python scripts/run_phase3_cases.py --case both
"""
import argparse, sys, time, os
import numpy as np
import torch

sys.path.insert(0, "/Users/hermes/.hermes/projects/ns_blowup/benchmarks")
from hou_louo_ic import hou_luo_style_ic
from taylor_green_mps import (
    make_k_grids, make_dealias_mask, rk4_step, energy, max_vorticity,
    DEVICE, DTYPE,
)

L = 2 * np.pi
AMP = 10.0
SIGMA_Z = 0.5
LOG_EVERY = 200


def run_case(label, N, nu, T_final, dt, out_path):
    n_steps = int(round(T_final / dt))
    print(f"[{label}] === N={N}, nu={nu}, dt={dt}, T_final={T_final}, steps={n_steps} ===")
    print(f"[{label}] Device: {DEVICE}, dtype: {DTYPE}")

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
    max_om_track = om0
    cfl_max = 0.0
    blew_up = False
    for step in range(n_steps):
        uhat = rk4_step(uhat, kx, ky, kz, ksq, nu, dt, dealias_mask)
        times[step + 1] = (step + 1) * dt
        max_om[step + 1] = max_vorticity(uhat, kx, ky, kz)

        # NaN/Inf check
        if not np.isfinite(max_om[step + 1]):
            print(f"[{label}] *** NaN/Inf at step {step+1}, t={times[step+1]:.5f}")
            times = times[: step + 2]
            max_om = max_om[: step + 2]
            blew_up = True
            break

        if max_om[step + 1] > max_om_track:
            max_om_track = max_om[step + 1]
        cfl = dt * max_om_track
        if cfl > cfl_max:
            cfl_max = cfl

        if (step + 1) % LOG_EVERY == 0 or step == n_steps - 1:
            torch.mps.synchronize()
            elapsed = time.time() - t0
            rate = elapsed / (step + 1)
            eta = rate * (n_steps - step - 1)
            print(f"[{label}] step {step+1:4d}/{n_steps}: t={times[step+1]:.5f}  "
                  f"max|omega|={max_om[step+1]:.4e}  elapsed={elapsed:.1f}s  "
                  f"ETA={eta:.1f}s  CFL={cfl:.3e}", flush=True)

    torch.mps.synchronize()
    wall = time.time() - t0
    om_T = float(max_om[-1])
    growth = om_T / om0
    cfl_final = dt * max_om_track

    print()
    print(f"[{label}] FINAL max|omega| at T={T_final}: {om_T:.6e}")
    print(f"[{label}] Initial max|omega|:             {om0:.6e}")
    print(f"[{label}] Growth factor:                  {growth:.4f}x")
    print(f"[{label}] Peak CFL:                       {cfl_final:.3e}")
    print(f"[{label}] Wall-clock:                     {wall:.2f}s for {len(times)-1} steps "
          f"({wall/max(1,len(times)-1)*1000:.2f} ms/step)")
    print(f"[{label}] Stability: {'BLOWUP/NaN detected' if blew_up else 'smooth (no NaN/Inf)'}")

    os.makedirs(os.path.dirname(out_path), exist_ok=True)
    np.savez(out_path,
             times=times,
             max_omega=max_om,
             E0=E0,
             wall=wall,
             N=N, nu=nu, dt=dt, T_final=T_final,
             amplitude=AMP, sigma_z=SIGMA_Z,
             blew_up=blew_up,
             cfl_max=cfl_max)
    print(f"[{label}] Saved: {out_path}")
    return {"om0": om0, "om_T": om_T, "growth": growth, "wall": wall,
            "times": times, "max_om": max_om, "path": out_path,
            "blew_up": blew_up}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--case", choices=["A", "B", "both"], default="both")
    args = parser.parse_args()

    DATA = "/Users/hermes/.hermes/projects/ns_blowup/data"

    if args.case in ("A", "both"):
        # Case A: N=192, nu=0.0005, T=0.04 (2000 steps with dt=2e-5)
        print("=" * 70)
        print("CASE A: N=192, nu=0.0005, T_final=0.04, dt=2e-5 (2000 steps)")
        print("=" * 70)
        a = run_case("A", N=192, nu=0.0005, T_final=0.04, dt=2e-5,
                     out_path=f"{DATA}/ns_run_N192_nu0.0005_T04.npz")

    if args.case in ("B", "both"):
        print()
        print("=" * 70)
        print("CASE B: N=128, nu=0.00025, T_final=0.04, dt=2e-5 (2000 steps)")
        print("=" * 70)
        b = run_case("B", N=128, nu=0.00025, T_final=0.04, dt=2e-5,
                     out_path=f"{DATA}/ns_run_N128_nu0.00025_T04.npz")

    print()
    print("=" * 70)
    print("PHASE 3 SUMMARY")
    print("=" * 70)
    if args.case in ("A", "both"):
        a_om = a["om_T"]; a_g = a["growth"]; a_w = a["wall"]
        print(f"Case A (N=192, nu=0.0005, T=0.04):  max|omega|_T={a_om:.4e}, "
              f"growth={a_g:.4f}x, wall={a_w:.1f}s, blew_up={a['blew_up']}")
    if args.case in ("B", "both"):
        b_om = b["om_T"]; b_g = b["growth"]; b_w = b["wall"]
        print(f"Case B (N=128, nu=0.00025, T=0.04): max|omega|_T={b_om:.4e}, "
              f"growth={b_g:.4f}x, wall={b_w:.1f}s, blew_up={b['blew_up']}")


if __name__ == "__main__":
    main()