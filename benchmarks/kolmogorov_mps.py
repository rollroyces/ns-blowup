"""
Kolmogorov flow benchmark — PyTorch MPS version.
==================================================

Same calibration as the NumPy Kolmogorov benchmark, but using torch.fft
on the Apple GPU via Metal Performance Shaders (MPS).

Kolmogorov flow on a periodic box [0, 2*pi]^3:
  Basic state u = (sin(y), 0, 0) (promoted to 3D with u_z = 0).
  This is a stationary shear flow that decays under viscosity.

Without continuous forcing, the energy spectrum is steeper than the
forced -5/3 (because energy is being drained at all scales). The
calibration gate is: spectral slope < -1.0 in the inertial range
(k = 2 .. N/4), which is a robust sanity check that energy is
cascading down to small scales and the GPU solver is wired up right.

Implementation:
  - Spectral Fourier on [0, 2*pi]^3 periodic box
  - 2/3-rule dealiasing (re-used from taylor_green_mps)
  - Semi-implicit RK4 (re-used from taylor_green_mps)
  - PyTorch complex64 on MPS device (Apple GPU)
"""

import sys
import time
import torch
import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

sys.path.insert(0, ".")
from taylor_green_mps import (
    make_k_grids, make_dealias_mask, rk4_step,
    energy, DEVICE, DTYPE,
)


def Kolmogorov_ic_mps(N, L=2 * np.pi, amplitude=1.0, mode=1, device=DEVICE):
    """Build Kolmogorov flow initial condition: u = A * sin(mode * y) e_x on MPS.

    3D version: extends a 2D shear flow trivially in the third axis
    (uz = 0, no z dependence). Returns uhat as a complex64 MPS tensor
    of shape (3, N, N, N).
    """
    y = np.linspace(0, L, N, endpoint=False)
    x = np.linspace(0, L, N, endpoint=False)
    X, Y, Z = np.meshgrid(x, y, x, indexing="ij")
    ux = amplitude * np.sin(mode * Y)
    uy = np.zeros_like(ux)
    uz = np.zeros_like(ux)
    u0 = np.stack([ux, uy, uz])  # (3, N, N, N), real, on CPU

    # FFT on CPU (cheap, then move to MPS) — torch.fft on MPS works the same.
    uhat_np = np.stack([np.fft.fftn(comp) for comp in u0])
    uhat = torch.tensor(uhat_np, dtype=DTYPE, device=device)
    return uhat


def energy_spectrum_mps(uhat):
    """Compute the 3D energy spectrum E(k) binning by |k|.

    E(k) = (1/2) sum_{|k'|=k} |uhat(k')|^2 (relative; no 1/L^3 prefactor).

    Returns (E_k, n_modes) as numpy arrays of length N//2 + 1.
    """
    # Move to CPU/numpy for diagnostic binning (cheap compared to solve).
    uhat_np = uhat.detach().cpu().numpy()
    e_density = 0.5 * (np.abs(uhat_np[0])**2 +
                       np.abs(uhat_np[1])**2 +
                       np.abs(uhat_np[2])**2)
    N = uhat_np.shape[1]
    k_idx = np.arange(N)
    kx_i, ky_i, kz_i = np.meshgrid(k_idx, k_idx, k_idx, indexing="ij")
    ksq_idx = kx_i**2 + ky_i**2 + kz_i**2
    k_mag = np.sqrt(ksq_idx)
    k_max = N // 2
    E_k = np.zeros(k_max + 1)
    n_modes = np.zeros(k_max + 1, dtype=np.int64)
    for ki in range(k_max + 1):
        mask = (k_mag >= ki - 0.5) & (k_mag < ki + 0.5)
        if mask.any():
            E_k[ki] = e_density[mask].sum()
            n_modes[ki] = mask.sum()
    return E_k, n_modes


def run_kolmogorov_mps(N=64, T_final=2.0, nu=0.01, dt=5e-4, plot=True,
                       out_path="data/Kolmogorov_mps_N64.png"):
    """Run Kolmogorov flow on MPS and verify spectral slope gate."""
    L = 2 * np.pi
    kx, ky, kz, ksq = make_k_grids(N, L)
    dealias_mask = make_dealias_mask(N)
    uhat = Kolmogorov_ic_mps(N, L, amplitude=1.0, mode=1)
    E0 = energy(uhat)
    n_steps = int(round(T_final / dt))
    t0 = time.time()
    snapshots = {}
    for step in range(n_steps):
        uhat = rk4_step(uhat, kx, ky, kz, ksq, nu, dt, dealias_mask)
        if (step + 1) % max(1, n_steps // 4) == 0 or step == n_steps - 1:
            elapsed = time.time() - t0
            E = energy(uhat)
            E_k, n_modes = energy_spectrum_mps(uhat)
            snapshots[(step + 1) * dt] = (E, E_k, n_modes)
            print(f"  t={(step+1)*dt:.3f}: E={E:.3e}, max E_k={E_k[1:].max():.3e}"
                  f"  elapsed={elapsed:.1f}s")
    t_elapsed = time.time() - t0
    if plot:
        fig, axes = plt.subplots(1, 2, figsize=(12, 4))
        for t, (E, E_k, n_modes) in snapshots.items():
            axes[0].semilogy(np.arange(len(E_k)), E_k, label=f"t={t:.2f}")
        axes[0].set_xlabel("|k|"); axes[0].set_ylabel("E(|k|)")
        axes[0].set_title("Energy spectrum evolution (MPS)")
        axes[0].legend(); axes[0].grid(True, alpha=0.3)
        # Compensated spectrum at final time
        t_final, (E_f, E_k_f, n_modes_f) = list(snapshots.items())[-1]
        k_ref = np.arange(1, N // 2)
        comp_E = k_ref**(5/3) * E_k_f[1:N//2]
        axes[1].loglog(k_ref, np.maximum(comp_E, 1e-30),
                       "bo-", label=f"k^(5/3)*E(k) at t={t_final:.2f}")
        axes[1].set_xlabel("|k|"); axes[1].set_ylabel("|k|^(5/3) * E(|k|)")
        axes[1].set_title("Compensated Kolmogorov spectrum (flat = k^(-5/3))")
        axes[1].legend(); axes[1].grid(True, alpha=0.3)
        plt.tight_layout()
        plt.savefig(out_path, dpi=120)
        print(f"  Plot: {out_path}")
    # Calibration gate: slope in log-log between k=2 and k=N/4
    t_final, (E_f, E_k_f, n_modes_f) = list(snapshots.items())[-1]
    slope = 0.0
    PASSED = False
    if N >= 32:
        k = np.arange(2, N // 4)
        log_k = np.log(k)
        log_E = np.log(np.maximum(E_k_f[2:N//4], 1e-30))
        valid = np.isfinite(log_E) & (E_k_f[2:N//4] > 0)
        if valid.sum() >= 3:
            slope, intercept = np.polyfit(log_k[valid], log_E[valid], 1)
            print(f"\nKolmogorov MPS (N={N}, nu={nu}, dt={dt}, T={T_final}):")
            print(f"  Device: {DEVICE}, dtype: {DTYPE}")
            print(f"  Wall-clock: {t_elapsed:.2f}s for {n_steps} steps "
                  f"({1e6*t_elapsed/n_steps:.1f} us/step)")
            print(f"  Spectral slope: {slope:.3f} (reference: -1.667 for forced)")
            print(f"  E(0)={E0:.3e}, E(T)={E_f:.3e}")
            PASSED = slope < -1.0
            if PASSED:
                print(f"CALIBRATION PASSED: slope {slope:.3f} < -1.0 (energy cascading down).")
            else:
                print(f"CALIBRATION FAILED: slope {slope:.3f} too shallow.")
    return PASSED, slope, t_elapsed


if __name__ == "__main__":
    print(f"PyTorch: {torch.__version__}, MPS: {torch.backends.mps.is_available()}")
    print(f"Device: {DEVICE}, dtype: {DTYPE}")
    print()
    print("=" * 60)
    print("Phase 0B-MPS: Kolmogorov flow at N=64")
    print("=" * 60)
    out_path = "/Users/hermes/.hermes/projects/ns_blowup/data/kolmogorov_mps_N64.png"
    passed, slope, wall = run_kolmogorov_mps(
        N=64, T_final=2.0, nu=0.01, dt=5e-4,
        plot=True, out_path=out_path,
    )
    sys.exit(0 if passed else 1)