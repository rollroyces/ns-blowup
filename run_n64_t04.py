"""Extend N=64 nu=0.001 Hou-Luo IC run to T_final=0.04.

Matches the existing ns_run_N64_nu0.001.npz data:
  - IC: amplitude=10.0, sigma_z=0.5
  - nu=0.001, dt=5e-5
  - snapshot every step (401 snapshots covers T=0..0.02 at dt=5e-5)
  - For T=0.04 we need 801 snapshots covering T=0..0.04

Reuses hou_luo_style_ic() and the spectral helpers from taylor_green_mps.
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

N = 64
L = 2 * np.pi
NU = 0.001
DT = 5e-5
T_FINAL = 0.04
AMP = 10.0
SIGMA_Z = 0.5
N_STEPS = int(round(T_FINAL / DT))   # 800 steps

OUT = "data/ns_run_N64_nu0.001_T04.npz"

print(f"Device: {DEVICE}, dtype: {DTYPE}")
print(f"N={N}, nu={NU}, dt={DT}, T_final={T_FINAL}, steps={N_STEPS}")
print(f"IC: Hou-Luo axisymmetric-with-swirl, amplitude={AMP}, sigma_z={SIGMA_Z}")

kx, ky, kz, ksq = make_k_grids(N, L)
dealias_mask = make_dealias_mask(N)

uhat = hou_luo_style_ic(N, L, amplitude=AMP, sigma_z=SIGMA_Z)
E0 = energy(uhat)
om0 = max_vorticity(uhat, kx, ky, kz)
print(f"Initial E={E0:.6e}, max|omega|={om0:.6e}")

# Record every step (matches existing data cadence)
times = np.zeros(N_STEPS + 1, dtype=np.float64)
max_om = np.zeros(N_STEPS + 1, dtype=np.float64)
times[0] = 0.0
max_om[0] = om0

t0 = time.time()
for step in range(N_STEPS):
    uhat = rk4_step(uhat, kx, ky, kz, ksq, NU, DT, dealias_mask)
    times[step + 1] = (step + 1) * DT
    max_om[step + 1] = max_vorticity(uhat, kx, ky, kz)
    if (step + 1) % 100 == 0 or step == N_STEPS - 1:
        torch.mps.synchronize()
        elapsed = time.time() - t0
        rate = elapsed / (step + 1)
        eta = rate * (N_STEPS - step - 1)
        print(f"  step {step+1:4d}/{N_STEPS}: t={times[step+1]:.5f}  "
              f"max|omega|={max_om[step+1]:.4e}  elapsed={elapsed:.1f}s  ETA={eta:.1f}s")

wall = time.time() - t0
torch.mps.synchronize()

om_T04 = float(max_om[-1])
growth = om_T04 / om0

# Find max_om at T=0.02 for cross-check against existing data
idx_T02 = int(round(0.02 / DT))   # 400
om_T02 = float(max_om[idx_T02])

print()
print(f"FINAL max|omega| at T=0.04: {om_T04:.6e}")
print(f"Initial max|omega|:         {om0:.6e}")
print(f"Growth factor (T=0.04 / T=0): {growth:.4f}x")
print(f"max|omega| at T=0.02 (this run, step {idx_T02}): {om_T02:.6e}")
print(f"Wall-clock: {wall:.2f}s for {N_STEPS} steps ({wall/N_STEPS*1000:.2f} ms/step)")

np.savez(OUT,
         times=times,
         max_omega=max_om,
         E0=E0,
         wall=wall,
         N=N, nu=NU, dt=DT, T_final=T_FINAL,
         amplitude=AMP, sigma_z=SIGMA_Z)
print(f"\nSaved: {OUT}")