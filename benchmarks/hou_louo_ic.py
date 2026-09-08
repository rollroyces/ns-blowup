"""
Hou-Luo-style axisymmetric-with-swirl IC for resolution scaling study.
====================================================================

The Hou-Luo 2014 axisymmetric Navier-Stokes blowup candidate uses an IC
of the form

  u_theta(r, z, 0) = sin(pi r) * some_z_profile * amplitude
  u_r(r, z, 0)    = small perturbation
  u_z(r, z, 0)    = small perturbation

We don't reproduce the exact published contour (that requires their
specific choice of parameters) but we use a similar axisymmetric-with-swirl
structure that has been studied as a candidate for finite-time blowup.

The construction (matching the Hou-Luo family, simplified):

  In cylindrical coords (r, theta, z) with axisymmetry:
    u_r(r, z, 0) = 0
    u_z(r, z, 0) = 0
    u_theta(r, z, 0) = (r / (1 + r^2)) * sin(pi r) * exp(-z^2 / 2)

  We promote to 3D Cartesian (x, y, z) via
    r = sqrt(x^2 + y^2),  theta = atan2(y, x)
    u_x = -sin(theta) * u_theta
    u_y = cos(theta) * u_theta
    u_z = 0

This has a swirling vortex along the z-axis with amplitude peaking at r=1.
The axial profile is a Gaussian, giving a "vortex ring" topology.

We will run this IC at N = 64, 128, 256 (the largest feasible on MPS) and
measure max |omega| as a function of time and grid spacing.
"""

import sys
import time
import numpy as np
import torch
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

sys.path.insert(0, ".")
from taylor_green_mps import (
    make_k_grids, make_dealias_mask, project_divergence_free,
    rk4_step, energy, max_vorticity, DEVICE, DTYPE,
)


def hou_luo_style_ic(N, L=2 * np.pi, amplitude=10.0, sigma_z=0.5,
                     device=DEVICE):
    """Hou-Luo-style axisymmetric-with-swirl IC.

    In Cartesian: u_theta = (r / (1 + r^2)) * sin(pi r) * exp(-z^2/2)
    with r = sqrt(x^2 + y^2).

    This is a swirling vortex tube along z-axis with finite total circulation.
    The amplitude parameter controls how strong the swirl is.
    """
    x = np.linspace(-L / 2, L / 2, N, endpoint=False)
    y = np.linspace(-L / 2, L / 2, N, endpoint=False)
    z = np.linspace(-L / 2, L / 2, N, endpoint=False)
    X, Y, Z = np.meshgrid(x, y, z, indexing="ij")
    r = np.sqrt(X * X + Y * Y)
    sin_theta = np.where(r > 1e-10, Y / r, 0.0)
    cos_theta = np.where(r > 1e-10, X / r, 1.0)
    u_theta_mag = (r / (1 + r * r)) * np.sin(np.pi * r / 2.0) * \
                  np.exp(-Z * Z / (2 * sigma_z * sigma_z)) * amplitude
    ux = -sin_theta * u_theta_mag
    uy = cos_theta * u_theta_mag
    uz = np.zeros_like(ux)
    # Take FFT, dealias-friendly
    u0 = np.stack([ux, uy, uz])
    uhat = np.stack([np.fft.fftn(comp) for comp in u0])
    return torch.tensor(uhat, dtype=DTYPE, device=device)


def run_resolution_study(N_list=(64, 128, 256), T_final=0.10, nu=0.001,
                         dt=5e-5, plot=True):
    """Run the Hou-Luo IC at multiple grid resolutions and compare
    max|omega|(t) trajectories.

    Goal: detect whether max|omega| grows without bound as h -> 0
    (suggesting genuine singularity) or saturates (suggesting numerics).
    """
    L = 2 * np.pi
    print(f"Resolution scaling study: N in {N_list}, T_final={T_final}, "
          f"nu={nu}, dt={dt}")
    print(f"Device: {DEVICE}, dtype: {DTYPE}")
    print()
    results = {}
    for N in N_list:
        print(f"--- N={N} ---")
        kx, ky, kz, ksq = make_k_grids(N, L)
        dealias_mask = make_dealias_mask(N)
        uhat = hou_luo_style_ic(N, L)
        E0 = energy(uhat)
        om0 = max_vorticity(uhat, kx, ky, kz)
        print(f"  Initial E = {E0:.3e}, max|omega| = {om0:.3e}")
        n_steps = int(round(T_final / dt))
        times = [0.0]
        max_om = [om0]
        t0 = time.time()
        snapshot_every = max(1, n_steps // 20)
        for step in range(n_steps):
            uhat = rk4_step(uhat, kx, ky, kz, ksq, nu, dt, dealias_mask)
            if (step + 1) % snapshot_every == 0 or step == n_steps - 1:
                times.append((step + 1) * dt)
                max_om.append(max_vorticity(uhat, kx, ky, kz))
                if (step + 1) % (snapshot_every * 5) == 0:
                    torch.mps.synchronize()
                    elapsed = time.time() - t0
                    print(f"  step {step+1:6d}/{n_steps}: max|omega|={max_om[-1]:.3e}  "
                          f"elapsed={elapsed:.1f}s")
        t_elapsed = time.time() - t0
        print(f"  Total wall-clock: {t_elapsed:.1f}s")
        results[N] = {"times": np.array(times), "max_omega": np.array(max_om),
                      "wall_clock": t_elapsed, "E0": E0}

    # Resolution scaling analysis
    print()
    print("=" * 60)
    print("Resolution scaling analysis")
    print("=" * 60)
    print(f"{'N':>4}  {'h (grid spacing)':>16}  {'max|omega| at T':>16}  "
          f"{'h^{-beta} fit':>16}")
    final_max = []
    hs = []
    for N in N_list:
        h = L / N
        max_final = results[N]["max_omega"][-1]
        print(f"{N:>4}  {h:>16.4e}  {max_final:>16.3e}")
        final_max.append(max_final)
        hs.append(h)
    if len(N_list) >= 3:
        # Estimate scaling: max_final ~ h^{-beta} as h -> 0
        log_h = np.log(hs)
        log_max = np.log(final_max)
        beta, log_A = np.polyfit(log_h, log_max, 1)
        beta = -beta  # because we expect max_final to grow as h decreases (beta > 0)
        print()
        print(f"  Scaling fit: max|omega|(T) ~ h^(-{beta:.3f})  (negative beta "
              f"means no growth, positive beta means growth as h -> 0)")
        if beta > 0.1:
            verdict = f"max|omega| GROWS as h -> 0 with exponent {beta:.3f}. " \
                      "Consistent with genuine singularity formation."
        elif beta < -0.1:
            verdict = f"max|omega| DECREASES as h -> 0 (exponent {beta:.3f}). " \
                      "Suggests apparent blowup is a numerical artifact at coarse grids."
        else:
            verdict = (f"max|omega| is approximately h-INDEPENDENT "
                       f"(exponent {beta:.3f}). Resolution study inconclusive "
                       "at this range; need larger grids to discriminate.")

    if plot:
        fig, axes = plt.subplots(1, 2, figsize=(13, 5))
        for N in N_list:
            axes[0].semilogy(results[N]["times"], results[N]["max_omega"],
                             label=f"N={N}")
        axes[0].set_xlabel("t"); axes[0].set_ylabel("max |omega|(t)")
        axes[0].set_title(f"Max vorticity evolution (nu={nu})")
        axes[0].legend(); axes[0].grid(True, alpha=0.3)
        # Resolution plot
        axes[1].loglog(hs, final_max, "bo-", label="max|omega| at T_final")
        if len(N_list) >= 3:
            fit_x = np.array([min(hs) / 2, max(hs) * 2])
            fit_y = np.exp(log_A) * fit_x ** (-beta)
            axes[1].loglog(fit_x, fit_y, "r--",
                           label=f"h^(-{beta:.2f}) fit")
        axes[1].set_xlabel("h = L/N"); axes[1].set_ylabel("max |omega| at T")
        axes[1].set_title("Resolution scaling")
        axes[1].legend(); axes[1].grid(True, alpha=0.3)
        plt.tight_layout()
        out = f"data/resolution_study_nu{nu}.png"
        plt.savefig(out, dpi=120)
        print(f"  Plot: {out}")

    return results


if __name__ == "__main__":
    # Quick study: N=64 and N=128 first
    res = run_resolution_study(N_list=(64, 128), T_final=0.10,
                                nu=0.001, dt=5e-5, plot=True)
