"""Quick smoke: re-run N=64 to T=0.06 (1200 steps) and N=128 to T=0.10
(2000 steps) with same seed and confirm matches existing baselines."""
import sys, time, numpy as np, torch
sys.path.insert(0, "/Users/hermes/.hermes/projects/ns_blowup/benchmarks")
from taylor_green_mps import (
    make_k_grids, make_dealias_mask,
    rk4_step, energy, max_vorticity, DEVICE, DTYPE,
)
from hou_louo_ic import hou_luo_style_ic

L = 2 * np.pi
NU = 0.001


def run(N, dt, T_final):
    print(f"--- smoke N={N} dt={dt} T={T_final} ---")
    kx, ky, kz, ksq = make_k_grids(N, L)
    dealias = make_dealias_mask(N)
    np.random.seed(0)
    uhat = hou_luo_style_ic(N, L, amplitude=10.0, sigma_z=0.5)
    n = int(round(T_final / dt))
    om_prev = None
    t0 = time.time()
    last_om = None
    for step in range(n):
        uhat = rk4_step(uhat, kx, ky, kz, ksq, NU, dt, dealias)
        if (step + 1) == n:
            last_om = max_vorticity(uhat, kx, ky, kz)
    wall = time.time() - t0
    print(f"  wall={wall:.1f}s final max|omega|={last_om:.6e}")
    return last_om

om64 = run(64, 5e-5, 0.06)
om128 = run(128, 5e-5, 0.10)
# Load baselines
d64 = np.load("/Users/hermes/.hermes/projects/ns_blowup/data/ns_run_N64_nu0.001_T06.npz")
d128 = np.load("/Users/hermes/.hermes/projects/ns_blowup/data/ns_run_N128_nu0.001_T10.npz")
print(f"\nN=64 T=0.06 baseline: {d64['max_omega'][-1]:.6e}, "
      f"diff={abs(om64 - d64['max_omega'][-1]):.3e}")
print(f"N=128 T=0.10 baseline: {d128['max_omega'][-1]:.6e}, "
      f"diff={abs(om128 - d128['max_omega'][-1]):.3e}")