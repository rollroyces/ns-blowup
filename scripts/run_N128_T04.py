"""Extend the N=128 Hou-Luo IC run to T=0.04 (800 steps) and save.

Reuses hou_luo_style_ic() and the MPS rk4_step / energy / max_vorticity
helpers. Records (times, max_omega) at every step so the T=0.02 slice
matches the prior ns_run_N128_nu0.001.npz trajectory exactly.

Run:
    source /Users/hermes/.hermes/projects/ns_blowup/venv/bin/activate
    cd /Users/hermes/.hermes/projects/ns_blowup
    python benchmarks/run_N128_T04.py
"""
import sys
import time
import os
import numpy as np
import torch

sys.path.insert(0, "/Users/hermes/.hermes/projects/ns_blowup/benchmarks")
from hou_louo_ic import hou_luo_style_ic
from taylor_green_mps import (
    make_k_grids, make_dealias_mask, rk4_step, max_vorticity, DEVICE, DTYPE,
)


def main():
    N = 128
    L = 2 * np.pi
    nu = 0.001
    dt = 5e-5
    T_final = 0.04
    n_steps = int(round(T_final / dt))  # 800
    out_path = "/Users/hermes/.hermes/projects/ns_blowup/data/ns_run_N128_nu0.001_T04.npz"

    print(f"Device: {DEVICE}, dtype: {DTYPE}")
    print(f"N={N}, nu={nu}, dt={dt}, T_final={T_final}, n_steps={n_steps}")

    kx, ky, kz, ksq = make_k_grids(N, L)
    dealias_mask = make_dealias_mask(N)
    uhat = hou_luo_style_ic(N, L, amplitude=10.0, sigma_z=0.5, device=DEVICE)

    om0 = max_vorticity(uhat, kx, ky, kz)
    print(f"Initial max|omega| = {om0:.6e}")

    times = np.zeros(n_steps + 1, dtype=np.float64)
    max_om = np.zeros(n_steps + 1, dtype=np.float64)
    times[0] = 0.0
    max_om[0] = om0

    t0 = time.time()
    report_every = 100
    for step in range(n_steps):
        uhat = rk4_step(uhat, kx, ky, kz, ksq, nu, dt, dealias_mask)
        times[step + 1] = (step + 1) * dt
        max_om[step + 1] = max_vorticity(uhat, kx, ky, kz)
        if (step + 1) % report_every == 0 or step == n_steps - 1:
            torch.mps.synchronize()
            elapsed = time.time() - t0
            rate = elapsed / (step + 1)
            eta = rate * (n_steps - step - 1)
            print(f"  step {step+1:4d}/{n_steps}  max|omega|={max_om[step+1]:.4e}  "
                  f"elapsed={elapsed:.1f}s  ETA={eta:.1f}s")
    wall = time.time() - t0
    print(f"Total wall-clock: {wall:.1f}s for {n_steps} steps "
          f"({1e6*wall/n_steps:.0f} us/step)")

    os.makedirs(os.path.dirname(out_path), exist_ok=True)
    np.savez(out_path, times=times, max_omega=max_om, E0=0.0, wall=wall,
             N=N, nu=nu, dt=dt, T_final=T_final)
    print(f"Saved: {out_path}")

    # Comparison readout
    om_T04 = float(max_om[-1])
    growth = om_T04 / om0
    print()
    print("=" * 60)
    print("Results")
    print("=" * 60)
    print(f"  Initial max|omega|          = {om0:.6e}")
    print(f"  Final max|omega| at T=0.04  = {om_T04:.6e}")
    print(f"  Growth factor (T=0.04/init) = {growth:.6f}x")
    # T=0.02 slice: index = 0.02/dt = 400
    idx_T02 = int(round(0.02 / dt))
    om_T02 = float(max_om[idx_T02])
    growth_T02 = om_T02 / om0
    print()
    print("  --- Comparison at T=0.02 (existing file baseline) ---")
    print(f"  max|omega| at T=0.02 = {om_T02:.6e}  (growth {growth_T02:.6f}x)")
    print(f"  max|omega| at T=0.04 = {om_T04:.6e}  (growth {growth:.6f}x)")
    print(f"  ratio T=0.04 / T=0.02 = {om_T04/om_T02:.6f}x")


if __name__ == "__main__":
    main()