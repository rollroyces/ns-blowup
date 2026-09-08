"""Extend N=128 nu=0.001 Hou-Luo IC run to T_final=0.10 (2000 steps).

Reuses hou_luo_style_ic() and the spectral helpers. Records (times,
max_omega) every step. The T=0.04 and T=0.06 slices will match the
existing data exactly (same IC, same dt).

Wall-clock estimate: ~432 ms/step * 2000 steps = ~864s (~14.4 min).

Run:
    source /Users/hermes/.hermes/projects/ns_blowup/venv/bin/activate
    cd /Users/hermes/.hermes/projects/ns_blowup
    python scripts/run_N128_T10.py
"""
import sys, time, os
import numpy as np
import torch

sys.path.insert(0, "/Users/hermes/.hermes/projects/ns_blowup/benchmarks")
from hou_louo_ic import hou_luo_style_ic
from taylor_green_mps import (
    make_k_grids, make_dealias_mask, rk4_step, energy, max_vorticity,
    DEVICE, DTYPE,
)

N = 128
L = 2 * np.pi
NU = 0.001
DT = 5e-5
T_FINAL = 0.10
AMP = 10.0
SIGMA_Z = 0.5
N_STEPS = int(round(T_FINAL / DT))   # 2000

OUT = "/Users/hermes/.hermes/projects/ns_blowup/data/ns_run_N128_nu0.001_T10.npz"

print(f"Device: {DEVICE}, dtype: {DTYPE}")
print(f"N={N}, nu={NU}, dt={DT}, T_final={T_FINAL}, steps={N_STEPS}")
print(f"IC: Hou-Luo axisymmetric-with-swirl, amplitude={AMP}, sigma_z={SIGMA_Z}")

kx, ky, kz, ksq = make_k_grids(N, L)
dealias_mask = make_dealias_mask(N)

uhat = hou_luo_style_ic(N, L, amplitude=AMP, sigma_z=SIGMA_Z)
E0 = energy(uhat)
om0 = max_vorticity(uhat, kx, ky, kz)
print(f"Initial E={E0:.6e}, max|omega|={om0:.6e}")

times = np.zeros(N_STEPS + 1, dtype=np.float64)
max_om = np.zeros(N_STEPS + 1, dtype=np.float64)
times[0] = 0.0
max_om[0] = om0

t0 = time.time()
report_every = 200
for step in range(N_STEPS):
    uhat = rk4_step(uhat, kx, ky, kz, ksq, NU, DT, dealias_mask)
    times[step + 1] = (step + 1) * DT
    max_om[step + 1] = max_vorticity(uhat, kx, ky, kz)

    # Detect blowup
    if not np.isfinite(max_om[step + 1]):
        print(f"  *** BLOWUP at step {step+1}, t={times[step+1]:.5f}")
        times = times[: step + 2]
        max_om = max_om[: step + 2]
        break

    if (step + 1) % report_every == 0 or step == N_STEPS - 1:
        torch.mps.synchronize()
        elapsed = time.time() - t0
        rate = elapsed / (step + 1)
        eta = rate * (N_STEPS - step - 1)
        print(f"  step {step+1:4d}/{N_STEPS}: t={times[step+1]:.5f}  "
              f"max|omega|={max_om[step+1]:.4e}  elapsed={elapsed:.1f}s  ETA={eta:.1f}s")

torch.mps.synchronize()
wall = time.time() - t0
om_T = float(max_om[-1])
growth = om_T / om0

idx_T02 = int(round(0.02 / DT))
idx_T04 = int(round(0.04 / DT))
idx_T06 = int(round(0.06 / DT))
om_T02 = float(max_om[idx_T02])
om_T04 = float(max_om[idx_T04])
om_T06 = float(max_om[idx_T06])

print()
print("=" * 60)
print("Results — Case B: N=128, nu=0.001")
print("=" * 60)
print(f"  Initial max|omega|          = {om0:.6e}")
print(f"  Final max|omega| at T={T_FINAL:.2f}    = {om_T:.6e}")
print(f"  Growth factor (T/T0)        = {growth:.6f}x")
print(f"  max|omega| at T=0.02        = {om_T02:.6e}")
print(f"  max|omega| at T=0.04        = {om_T04:.6e}")
print(f"  max|omega| at T=0.06        = {om_T06:.6e}")
print(f"  Wall-clock: {wall:.2f}s for {N_STEPS} steps "
      f"({1e6*wall/max(1,len(times)-1):.0f} us/step)")

os.makedirs(os.path.dirname(OUT), exist_ok=True)
np.savez(OUT,
         times=times,
         max_omega=max_om,
         E0=E0,
         wall=wall,
         N=N, nu=NU, dt=DT, T_final=T_FINAL,
         amplitude=AMP, sigma_z=SIGMA_Z)
print(f"\nSaved: {OUT}")