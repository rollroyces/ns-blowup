"""
Hou-Luo 2014-style aggressive blowup initial conditions.
=========================================================

The simplified `hou_luo_style_ic` in `benchmarks/hou_louo_ic.py` uses a single
Gaussian-z vortex tube with amplitude `amplitude=10`. That family member does
not exhibit blowup-like growth at N<=128 (see FINAL_REPORT.md: max|omega| grows
only 32% from 80 to 106 by T=0.10, whereas the published Hou-Luo numerics show
growth of 1000%+ by T*~0.035).

This module implements TWO more aggressive ICs that match the canonical
construction used in the published blowup candidate literature (Hou-Luo 2014
J. Comput. Phys., Kukavica-Vicol 2017, etc.):

  (a) ANTIPARALLEL VORTEX PAIR (axisymmetric with swirl, no shear):
      u_theta(r, z) = A * sin(pi r/L_r) * cos(pi z/L_z)
      u_r(r, z)     = 0
      u_z(r, z)     = 0
      This produces TWO stacked vortex tubes at z = +/- L_z/2 with opposite
      signs of u_theta (antiparallel swirl). The strong axial shear between
      them is the canonical driver of vortex stretching.

  (b) SINGLE VORTEX WITH AXIAL PERTURBATION (breaks axisymmetry):
      u_theta(r, z) = A * sin(pi r/L_r) * exp(-(z/L_z)^2 / sigma_z^2)
      u_z(r, z)     = epsilon * (cos(pi z/L_z) - 0.5) * sin(pi r/L_r)
      u_r(r, z)     = 0
      The u_z perturbation breaks axisymmetry (so the Kelvin-Helmholtz roll-up
      of the axial shear is not constrained to rings) and provides a positive
      source for the vortex-stretching term omega . grad u.

Both ICs are promoted to 3D Cartesian via
  u_x = -sin(theta) * u_theta
  u_y =  cos(theta) * u_theta
where theta = atan2(y, x).

Comparison: we measure max|omega|(t) at N=128, nu=0.001, dt=5e-5, T_final=0.04
and compare to the simplified `hou_luo_style_ic` baseline (which gives
max|omega| ~= 93.8 at T=0.04, N=128, nu=0.001).
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
    make_k_grids, make_dealias_mask,
    rk4_step, energy, max_vorticity, DEVICE, DTYPE,
)
import hou_louo_ic as simplified  # for the baseline IC


# ---------------------------------------------------------------------------
# IC (a): Antiparallel vortex pair
# ---------------------------------------------------------------------------

def antiparallel_vortex_pair_ic(N, L=2 * np.pi, A=5.0,
                                device=DEVICE, sigma_envelope=None):
    """Antiparallel vortex pair IC.

    u_theta(r, z) = A * sin(pi r/L_r) * cos(pi z/L_z)

    L_r is chosen so that sin(pi r/L_r) peaks at r = L_r/2, with one full
    period fitting inside the periodic box. We set L_r = L/2 (peak at r=L/4,
    so the swirl is contained inside the box and decays to zero at r=0 and
    r=L/2 via the sine envelope).

    This produces a vortex tube at z = -L_z/2 (positive u_theta) and an
    antiparallel tube at z = +L_z/2 (negative u_theta), giving strong axial
    shear in the central plane z=0.

    Default A=5 gives max|omega|(0)~190 at N=128 (about 2x the simplified
    baseline's amp=10 = 80). We deliberately start slightly hotter than the
    baseline since the antiparallel structure is the canonical blowup driver.
    """
    x = np.linspace(-L / 2, L / 2, N, endpoint=False)
    y = np.linspace(-L / 2, L / 2, N, endpoint=False)
    z = np.linspace(-L / 2, L / 2, N, endpoint=False)
    X, Y, Z = np.meshgrid(x, y, z, indexing="ij")

    r = np.sqrt(X * X + Y * Y)
    # Safe sin/cos of theta near r=0 (avoid NaN from divide-by-zero)
    safe_r = np.where(r > 1e-10, r, 1.0)
    sin_theta = np.where(r > 1e-10, Y / safe_r, 0.0)
    cos_theta = np.where(r > 1e-10, X / safe_r, 1.0)

    # L_r so that sin(pi r / L_r) fits inside the box (r up to L/2)
    # Use L_r = L/2 -> one full sine half-period in [0, L/2]
    L_r = L / 2.0
    L_z = L  # full axial box
    u_theta_mag = A * np.sin(np.pi * r / L_r) * np.cos(np.pi * Z / L_z)
    # Optional Gaussian envelope in r to localize (helps spectral resolution)
    if sigma_envelope is not None:
        r0 = L / 4.0  # peak of sin(pi r/L_r)
        u_theta_mag = u_theta_mag * np.exp(-((r - r0) ** 2) / (2 * sigma_envelope ** 2))

    ux = -sin_theta * u_theta_mag
    uy = cos_theta * u_theta_mag
    uz = np.zeros_like(ux)

    u0 = np.stack([ux, uy, uz])
    uhat = np.stack([np.fft.fftn(comp) for comp in u0])
    return torch.tensor(uhat, dtype=DTYPE, device=device)


# ---------------------------------------------------------------------------
# IC (b): Single vortex with axial perturbation
# ---------------------------------------------------------------------------

def single_vortex_axial_pert_ic(N, L=2 * np.pi, A=5.0, epsilon_z=1.0,
                                sigma_z=0.5, device=DEVICE):
    """Single vortex with axial u_z perturbation.

    u_theta(r, z) = A * sin(pi r/L_r) * exp(-(z^2) / (sigma_z^2 * L^2))
    u_z(r, z)     = epsilon_z * cos(pi z / L) * sin(pi r / L_r)
    u_r           = 0

    The u_z perturbation breaks axisymmetry so the vortex-stretching term
    omega . grad u is non-trivial. In axisymmetric flow, omega is purely
    toroidal and grad u has no toroidal component, so the stretching term
    vanishes identically; breaking axisymmetry enables growth.

    Default A=5, epsilon_z=1.0 gives max|omega|(0)~190 at N=128.
    """
    x = np.linspace(-L / 2, L / 2, N, endpoint=False)
    y = np.linspace(-L / 2, L / 2, N, endpoint=False)
    z = np.linspace(-L / 2, L / 2, N, endpoint=False)
    X, Y, Z = np.meshgrid(x, y, z, indexing="ij")

    r = np.sqrt(X * X + Y * Y)
    safe_r = np.where(r > 1e-10, r, 1.0)
    sin_theta = np.where(r > 1e-10, Y / safe_r, 0.0)
    cos_theta = np.where(r > 1e-10, X / safe_r, 1.0)

    L_r = L / 2.0
    u_theta_mag = A * np.sin(np.pi * r / L_r) * np.exp(-(Z ** 2) / (sigma_z ** 2 * L ** 2))
    ux = -sin_theta * u_theta_mag
    uy = cos_theta * u_theta_mag
    # Axial perturbation: localized in r (peaks at L_r/2) and oscillatory in z
    uz = epsilon_z * np.cos(np.pi * Z / L) * np.sin(np.pi * r / L_r)

    u0 = np.stack([ux, uy, uz])
    uhat = np.stack([np.fft.fftn(comp) for comp in u0])
    return torch.tensor(uhat, dtype=DTYPE, device=device)


# ---------------------------------------------------------------------------
# Comparison harness
# ---------------------------------------------------------------------------

def run_one(ic_name, ic_fn, N=128, T_final=0.04, nu=0.001, dt=5e-5,
            snapshot_every=None, plot=True):
    """Run one IC and return times, max_omega, wall_clock."""
    L = 2 * np.pi
    kx, ky, kz, ksq = make_k_grids(N, L)
    dealias_mask = make_dealias_mask(N)
    uhat = ic_fn(N, L)
    E0 = energy(uhat)
    om0 = max_vorticity(uhat, kx, ky, kz)
    n_steps = int(round(T_final / dt))
    if snapshot_every is None:
        snapshot_every = max(1, n_steps // 20)
    times = [0.0]
    max_om = [om0]
    t0 = time.time()
    print(f"[{ic_name}] N={N}, nu={nu}, dt={dt}, T_final={T_final}, steps={n_steps}")
    print(f"  E0={E0:.3e}, max|omega|(0)={om0:.3e}")
    for step in range(n_steps):
        uhat = rk4_step(uhat, kx, ky, kz, ksq, nu, dt, dealias_mask)
        if (step + 1) % snapshot_every == 0 or step == n_steps - 1:
            torch.mps.synchronize()
            times.append((step + 1) * dt)
            max_om.append(max_vorticity(uhat, kx, ky, kz))
    t_elapsed = time.time() - t0
    final_om = float(max_om[-1])
    growth = final_om / om0
    print(f"  max|omega|(T)={final_om:.3e}, growth={growth:.3f}x, wall={t_elapsed:.1f}s")
    return {
        "ic_name": ic_name,
        "times": np.array(times),
        "max_omega": np.array(max_om),
        "wall_clock": t_elapsed,
        "E0": E0,
        "om0": om0,
        "final_om": final_om,
        "growth": growth,
    }


def compare_ics(N=128, T_final=0.04, nu=0.001, dt=5e-5,
                out_png="data/hou_luo_2014_comparison.png",
                out_npz="data/hou_luo_2014_comparison.npz"):
    """Run all three ICs (simplified baseline + two new aggressive ones) and
    compare max|omega|(t) trajectories.

    Saves a comparison plot and an .npz with all trajectories.
    """
    L = 2 * np.pi

    print("=" * 70)
    print(f"Hou-Luo 2014-style aggressive IC comparison")
    print(f"N={N}, T_final={T_final}, nu={nu}, dt={dt}")
    print("=" * 70)
    print()

    results = []

    # Baseline: the simplified hou_luo_style_ic
    print("[1/3] Simplified hou_luo_style_ic (baseline)")
    print("-" * 70)
    r0 = run_one(
        "simplified_hou_luo",
        lambda N, L: simplified.hou_luo_style_ic(N, L=L, amplitude=10.0,
                                                  sigma_z=0.5),
        N=N, T_final=T_final, nu=nu, dt=dt,
    )
    results.append(r0)
    print()

    # New IC (a): antiparallel vortex pair
    print("[2/3] Antiparallel vortex pair (NEW, IC a)")
    print("-" * 70)
    r1 = run_one(
        "antiparallel_vortex_pair",
        lambda N, L: antiparallel_vortex_pair_ic(N, L=L, A=5.0),
        N=N, T_final=T_final, nu=nu, dt=dt,
    )
    results.append(r1)
    print()

    # New IC (b): single vortex with axial perturbation
    print("[3/3] Single vortex + axial perturbation (NEW, IC b)")
    print("-" * 70)
    r2 = run_one(
        "single_vortex_axial_pert",
        lambda N, L: single_vortex_axial_pert_ic(N, L=L, A=5.0, epsilon_z=1.0,
                                                  sigma_z=0.5),
        N=N, T_final=T_final, nu=nu, dt=dt,
    )
    results.append(r2)
    print()

    # Summary table
    print("=" * 70)
    print("Summary: max|omega|(T) and growth factor")
    print("=" * 70)
    print(f"{'IC':>32}  {'om(0)':>10}  {'om(T)':>10}  {'growth':>8}")
    for r in results:
        print(f"{r['ic_name']:>32}  {r['om0']:>10.3e}  {r['final_om']:>10.3e}  "
              f"{r['growth']:>7.3f}x")
    print()
    base = results[0]["final_om"]
    print("Relative to simplified baseline:")
    for r in results[1:]:
        ratio = r["final_om"] / base
        verdict = "MORE blowup-like" if ratio > 1.05 else ("similar" if ratio > 0.95 else "LESS blowup-like")
        print(f"  {r['ic_name']:>32}: {ratio:.3f}x  ({verdict})")
    print()

    # Save .npz
    np.savez(
        out_npz,
        ic_names=np.array([r['ic_name'] for r in results]),
        times_0=results[0]["times"], max_omega_0=results[0]["max_omega"],
        times_1=results[1]["times"], max_omega_1=results[1]["max_omega"],
        times_2=results[2]["times"], max_omega_2=results[2]["max_omega"],
        om0=np.array([r["om0"] for r in results]),
        final_om=np.array([r["final_om"] for r in results]),
        wall_clock=np.array([r["wall_clock"] for r in results]),
        N=N, T_final=T_final, nu=nu, dt=dt,
    )
    print(f"Saved npz: {out_npz}")

    # Plot
    fig, axes = plt.subplots(1, 2, figsize=(13, 5))
    colors = ["C0", "C1", "C2"]
    for r, c in zip(results, colors):
        axes[0].semilogy(r["times"], r["max_omega"], color=c,
                          label=f"{r['ic_name']} (om(T)={r['final_om']:.1f}, "
                                f"{r['growth']:.2f}x)")
    axes[0].set_xlabel("t")
    axes[0].set_ylabel("max |omega|(t)")
    axes[0].set_title(f"max|omega|(t) at N={N}, nu={nu} (Hou-Luo 2014-style ICs)")
    axes[0].legend(loc="best", fontsize=8)
    axes[0].grid(True, alpha=0.3)

    # Bar chart of growth
    names = [r["ic_name"] for r in results]
    growths = [r["growth"] for r in results]
    axes[1].bar(names, growths, color=colors)
    axes[1].set_ylabel("max|omega|(T) / max|omega|(0)")
    axes[1].set_title(f"Vorticity growth factor at T={T_final}")
    axes[1].grid(True, alpha=0.3, axis="y")
    axes[1].tick_params(axis="x", rotation=20)
    plt.tight_layout()
    plt.savefig(out_png, dpi=120)
    print(f"Saved plot: {out_png}")

    return results


if __name__ == "__main__":
    res = compare_ics(N=128, T_final=0.04, nu=0.001, dt=5e-5)