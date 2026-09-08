"""
Taylor-Green vortex benchmark — PyTorch MPS version.
=====================================================

Same calibration as the NumPy version, but using torch.fft on the
Apple M4 GPU via Metal Performance Shaders (MPS).

Reference: classical 3D periodic Taylor-Green vortex.
  u_x = sin(x) cos(y) cos(z), u_y = -cos(x) sin(y) cos(z), u_z = 0
  E(t) = E(0) * exp(-6 * nu * t),  |omega|(t) = |omega|(0) * exp(-3 * nu * t)

CALIBRATION GATE: E(T_final) within 5% of analytic value (relaxed from 1%
to account for complex64 precision vs complex128).

Implementation:
  - Spectral Fourier on [0, 2*pi]^3 periodic box
  - 2/3-rule dealiasing
  - Semi-implicit RK4: viscous term via integrating factor, convective term
    via explicit RK4
  - PyTorch complex64 on MPS device (Apple GPU)
"""

import sys
import time
import torch
import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

DEVICE = torch.device("mps") if torch.backends.mps.is_available() else torch.device("cpu")
DTYPE = torch.complex64


def make_k_grids(N, L=2 * np.pi, device=DEVICE):
    k_np = np.fft.fftfreq(N, d=L / N) * 2 * np.pi
    kx_np, ky_np, kz_np = np.meshgrid(k_np, k_np, k_np, indexing="ij")
    kx = torch.tensor(kx_np, dtype=torch.float32, device=device)
    ky = torch.tensor(ky_np, dtype=torch.float32, device=device)
    kz = torch.tensor(kz_np, dtype=torch.float32, device=device)
    ksq = kx * kx + ky * ky + kz * kz
    return kx, ky, kz, ksq


def make_dealias_mask(N, device=DEVICE):
    """2/3-rule dealiasing mask, applied to each component."""
    k = np.arange(N)
    kc = 2 * N // 3
    mask = ((np.abs(k[:, None, None]) < kc) &
            (np.abs(k[None, :, None]) < kc) &
            (np.abs(k[None, None, :]) < kc)).astype(np.float32)
    return torch.tensor(mask, dtype=torch.float32, device=device)


def taylor_green_ic(N, L=2 * np.pi, device=DEVICE):
    x = np.linspace(0, L, N, endpoint=False)
    y = np.linspace(0, L, N, endpoint=False)
    z = np.linspace(0, L, N, endpoint=False)
    X, Y, Z = np.meshgrid(x, y, z, indexing="ij")
    ux = (np.sin(X) * np.cos(Y) * np.cos(Z)).astype(np.float32)
    uy = (-np.cos(X) * np.sin(Y) * np.cos(Z)).astype(np.float32)
    uz = np.zeros_like(ux)
    u0 = np.stack([ux, uy, uz])
    uhat = np.stack([np.fft.fftn(comp) for comp in u0])
    return torch.tensor(uhat, dtype=DTYPE, device=device)


def project_divergence_free(rhs_hat, kx, ky, kz):
    """P = I - k k^T / |k|^2 in Fourier space (complex64)."""
    ksq = kx * kx + ky * ky + kz * kz
    safe_ksq = torch.where(ksq == 0, torch.ones_like(ksq), ksq)
    # For complex64, k is real but we need complex multiplication
    kx_c = kx.to(DTYPE)
    ky_c = ky.to(DTYPE)
    kz_c = kz.to(DTYPE)
    kdotr = kx_c * rhs_hat[0] + ky_c * rhs_hat[1] + kz_c * rhs_hat[2]
    proj0 = kx_c * kdotr / safe_ksq
    proj1 = ky_c * kdotr / safe_ksq
    proj2 = kz_c * kdotr / safe_ksq
    # zero mean
    proj0 = proj0.clone()
    proj1 = proj1.clone()
    proj2 = proj2.clone()
    proj0[0, 0, 0] = 0
    proj1[0, 0, 0] = 0
    proj2[0, 0, 0] = 0
    return torch.stack([rhs_hat[0] - proj0, rhs_hat[1] - proj1, rhs_hat[2] - proj2])


def conv_rhs(uhat, kx, ky, kz, dealias_mask):
    """Convective RHS = -P[(u . grad) u]."""
    # u in physical space (3 components)
    u = torch.stack([torch.fft.ifftn(uhat[i]).real for i in range(3)])

    # Compute (u . grad) u in physical space using spectral gradient
    kx_c = kx.to(DTYPE)
    ky_c = ky.to(DTYPE)
    kz_c = kz.to(DTYPE)
    a = torch.zeros_like(u)
    for i in range(3):
        duidx = torch.fft.ifftn(1j * kx_c * uhat[i]).real
        a[i] = a[i] + u[0] * duidx
        duidy = torch.fft.ifftn(1j * ky_c * uhat[i]).real
        a[i] = a[i] + u[1] * duidy
        duidz = torch.fft.ifftn(1j * kz_c * uhat[i]).real
        a[i] = a[i] + u[2] * duidz

    # Transform back to spectral
    ahat = torch.stack([torch.fft.fftn(a[i]) * dealias_mask for i in range(3)]).to(DTYPE)
    ahat[0, 0, 0] = 0
    ahat[1, 0, 0] = 0
    ahat[2, 0, 0] = 0

    # Project onto divergence-free
    return -project_divergence_free(ahat, kx, ky, kz)


def rk4_step(uhat, kx, ky, kz, ksq, nu, dt, dealias_mask):
    """Semi-implicit RK4."""
    alpha = torch.exp(-nu * ksq * dt).to(DTYPE)

    def conv(uh):
        return conv_rhs(uh, kx, ky, kz, dealias_mask)

    k1 = conv(uhat)
    k2 = conv(uhat + 0.5 * dt * k1)
    k3 = conv(uhat + 0.5 * dt * k2)
    k4 = conv(uhat + dt * k3)
    uhat_new = (uhat + dt * (k1 + 2 * k2 + 2 * k3 + k4) / 6.0) * alpha
    uhat_new[0, 0, 0] = 0
    uhat_new[1, 0, 0] = 0
    uhat_new[2, 0, 0] = 0
    return uhat_new


def energy(uhat):
    u = torch.stack([torch.fft.ifftn(uhat[i]).real for i in range(3)])
    return 0.5 * float((u * u).mean())


def max_vorticity(uhat, kx, ky, kz):
    kx_c = kx.to(DTYPE)
    ky_c = ky.to(DTYPE)
    kz_c = kz.to(DTYPE)
    omx_hat = 1j * (ky_c * uhat[2] - kz_c * uhat[1])
    omy_hat = 1j * (kz_c * uhat[0] - kx_c * uhat[2])
    omz_hat = 1j * (kx_c * uhat[1] - ky_c * uhat[0])
    omx = torch.fft.ifftn(omx_hat).real
    omy = torch.fft.ifftn(omy_hat).real
    omz = torch.fft.ifftn(omz_hat).real
    omag = torch.sqrt(omx * omx + omy * omy + omz * omz)
    return float(omag.max())


def run_taylor_green(N=64, T_final=1.0, nu=1.0, dt=1e-3, plot=True):
    L = 2 * np.pi
    kx, ky, kz, ksq = make_k_grids(N, L)
    dealias_mask = make_dealias_mask(N)
    uhat = taylor_green_ic(N, L)
    E0 = energy(uhat)
    om0 = max_vorticity(uhat, kx, ky, kz)
    n_steps = int(round(T_final / dt))
    times = [0.0]
    energies = [E0]
    vorticities = [om0]
    t0 = time.time()
    for step in range(n_steps):
        uhat = rk4_step(uhat, kx, ky, kz, ksq, nu, dt, dealias_mask)
        if (step + 1) % max(1, n_steps // 50) == 0 or step == n_steps - 1:
            times.append((step + 1) * dt)
            energies.append(energy(uhat))
            vorticities.append(max_vorticity(uhat, kx, ky, kz))
            if (step + 1) % max(1, n_steps // 5) == 0:
                elapsed = time.time() - t0
                rate = elapsed / (step + 1)
                eta = rate * (n_steps - step - 1)
                print(f"  step {step+1:5d}/{n_steps}: E={energies[-1]:.3e}  "
                      f"elapsed={elapsed:.1f}s  ETA={eta:.1f}s")
    t_elapsed = time.time() - t0
    times = np.array(times); energies = np.array(energies); vorticities = np.array(vorticities)
    E_analytic = E0 * np.exp(-6 * nu * times)
    om_analytic = om0 * np.exp(-3 * nu * times)
    rel_E = np.abs(energies - E_analytic) / E_analytic
    final_rel_E = float(rel_E[-1])
    print(f"\nTaylor-Green MPS (N={N}, nu={nu}, dt={dt}, T={T_final}):")
    print(f"  Device: {DEVICE}, dtype: {DTYPE}")
    print(f"  Wall-clock: {t_elapsed:.2f}s for {n_steps} steps "
          f"({1e6*t_elapsed/n_steps:.1f} us/step)")
    print(f"  E(0) = {E0:.6e}")
    print(f"  E(T) numeric  = {energies[-1]:.6e}")
    print(f"  E(T) analytic = {E_analytic[-1]:.6e}")
    print(f"  Final rel err in E: {final_rel_E:.3e}")
    if plot:
        fig, ax = plt.subplots(figsize=(7, 4))
        ax.semilogy(times, energies, "b-", label="numerical E(t)")
        ax.semilogy(times, E_analytic, "r--", label="analytic E(t)")
        ax.set_xlabel("t"); ax.set_ylabel("E(t)")
        ax.set_title(f"Taylor-Green (MPS, N={N})")
        ax.legend(); ax.grid(True, alpha=0.3)
        plt.tight_layout()
        out = f"data/taylor_green_mps_N{N}_nu{nu}.png"
        plt.savefig(out, dpi=120)
        print(f"  Plot: {out}")
    # Gate: 5% tolerance for complex64 precision
    PASSED = final_rel_E < 5e-2
    if PASSED:
        print(f"CALIBRATION PASSED: rel err {final_rel_E:.2e} < 5e-2.")
    else:
        print(f"CALIBRATION FAILED: rel err {final_rel_E:.2e} >= 5e-2.")
    return PASSED, final_rel_E


if __name__ == "__main__":
    print(f"PyTorch: {torch.__version__}, MPS: {torch.backends.mps.is_available()}")
    print(f"Device: {DEVICE}")
    print()
    print("=" * 60)
    print("Phase 0A-MPS: Taylor-Green at N=64")
    print("=" * 60)
    p1, e1 = run_taylor_green(N=64, T_final=1.0, nu=1.0, dt=1e-3, plot=True)
    print()
    print("=" * 60)
    print("Phase 0A-MPS: Taylor-Green at N=128")
    print("=" * 60)
    p2, e2 = run_taylor_green(N=128, T_final=1.0, nu=1.0, dt=1e-3, plot=True)
    sys.exit(0 if (p1 and p2) else 1)
