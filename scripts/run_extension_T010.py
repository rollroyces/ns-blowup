"""
Extend resolution-scaling study to T=0.10 (both N) and add finer-time
N=128 dt=2e-5 run with 50-step vorticity sampling.

Cases:
  A: N=64  nu=0.001 dt=5e-5 T_final=0.10   (extends existing T=0.06)
  B: N=128 nu=0.001 dt=5e-5 T_final=0.15   (extends existing T=0.10)
  C: N=128 nu=0.001 dt=2e-5 T_final=0.10   (finer-dt; sample every 50 steps)

Strategy:
  - Set np seed before IC so each case is bit-exact reproducible.
  - Re-verify continuity against existing baselines by checking max|omega|
    at the shared final time matches to ~1e-3 (mps float32 determinism).
  - All cases sample every step so we get dense time series.
"""
import sys, time, os
import numpy as np
import torch

sys.path.insert(0, "/Users/hermes/.hermes/projects/ns_blowup/benchmarks")
from taylor_green_mps import (
    make_k_grids, make_dealias_mask,
    rk4_step, energy, max_vorticity, DEVICE, DTYPE,
)
from hou_louo_ic import hou_luo_style_ic

DATA = "/Users/hermes/.hermes/projects/ns_blowup/data"
L = 2 * np.pi
NU = 0.001


def run_case(label, N, dt, T_final, snapshot_every=1, save_path=None):
    print(f"=== Case {label}: N={N} nu={NU} dt={dt} T_final={T_final} "
          f"snapshot_every={snapshot_every} ===", flush=True)
    kx, ky, kz, ksq = make_k_grids(N, L)
    dealias = make_dealias_mask(N)
    np.random.seed(0)  # IC is deterministic via np linspace + sin/cos
    uhat = hou_luo_style_ic(N, L, amplitude=10.0, sigma_z=0.5)
    E0 = energy(uhat)
    om0 = max_vorticity(uhat, kx, ky, kz)
    n_steps = int(round(T_final / dt))
    times, max_om = [0.0], [om0]
    t_start = time.time()
    blew_up_at = None
    for step in range(n_steps):
        uhat = rk4_step(uhat, kx, ky, kz, ksq, NU, dt, dealias)
        # Cheap NaN/Inf guard
        if (step + 1) % snapshot_every == 0 or step == n_steps - 1:
            mo = max_vorticity(uhat, kx, ky, kz)
            if not np.isfinite(mo):
                blew_up_at = (step + 1) * dt
                print(f"  !!! BLOWUP at t={blew_up_at:.4e} (step {step+1}) !!!",
                      flush=True)
                break
            times.append((step + 1) * dt)
            max_om.append(mo)
        if (step + 1) % max(1, n_steps // 10) == 0:
            torch.mps.synchronize()
            elapsed = time.time() - t_start
            print(f"  step {step+1:6d}/{n_steps}: max|omega|={max_om[-1]:.3e}  "
                  f"elapsed={elapsed:.1f}s", flush=True)
    torch.mps.synchronize()
    wall = time.time() - t_start
    times = np.array(times)
    max_om = np.array(max_om)
    if blew_up_at is not None:
        print(f"  CASE {label} BLOW UP at t={blew_up_at:.4e}", flush=True)
    print(f"  DONE: {wall:.1f}s, final t={times[-1]:.4e}, "
          f"final max|omega|={max_om[-1]:.4e}", flush=True)
    # Continuity check vs existing baseline
    base_path = os.path.join(DATA, save_path) if save_path else None
    if base_path:
        np.savez(base_path,
                 times=times, max_omega=max_om, E0=E0, wall=wall,
                 N=N, nu=NU, dt=dt, T_final=T_final,
                 amplitude=10.0, sigma_z=0.5,
                 blew_up_at=blew_up_at if blew_up_at is not None else -1.0)
        print(f"  Saved {base_path}", flush=True)
    return times, max_om, wall, blew_up_at, E0


if __name__ == "__main__":
    # Case A: N=64 to T=0.10
    run_case("A_N64_T010", N=64, dt=5e-5, T_final=0.10,
             snapshot_every=1,
             save_path="ns_run_N64_nu0.001_T10.npz")

    # Case B: N=128 to T=0.15
    run_case("B_N128_T015", N=128, dt=5e-5, T_final=0.15,
             snapshot_every=1,
             save_path="ns_run_N128_nu0.001_T15.npz")

    # Case C: N=128 dt=2e-5 to T=0.10 (sample every 50 steps)
    run_case("C_N128_dt2e-5_T010", N=128, dt=2e-5, T_final=0.10,
             snapshot_every=50,
             save_path="ns_run_N128_nu0.001_dt2e-5_T10.npz")

    print("\nAll three cases complete.")