"""Constantin-Iyer alignment diagnostics for the spectral NS scheme.

Constantin-Iyer (2008) proved that at any hypothetical NS singular
point, the vorticity ω aligns with the second eigenvector ξ_2 of the
strain tensor S = (∇u + ∇u^T)/2.

This script computes the alignment angle θ(x,t) = ∠(ω(x,t), ξ_2(x,t))
at every grid point and every output timestep, then tracks:
  (a) θ_min(t) = min over x of θ(x,t)  — global minimum alignment angle
  (b) θ_ωmax(t) = θ at the max-vorticity point — alignment at the
       location most likely to be near any hypothetical singularity
  (c) Per-grid-point scatter of θ vs. |ω| — does alignment correlate
       with high vorticity?

Outputs:
  data/constantin_iyer_alignment.npz  — alignment time series for each (IC, N)
  data/constantin_iyer_scatter.png    — θ vs |ω| scatter at last timestep
  data/constantin_iyer_timeseries.png — θ_min and θ_ωmax vs time, multiple N
"""
import sys, os, time, importlib.util

BENCHMARKS_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "benchmarks")

def _load(name):
    spec = importlib.util.spec_from_file_location(name, os.path.join(BENCHMARKS_DIR, name + ".py"))
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod

# Load dependencies in order
taylor_green_mps = _load("taylor_green_mps")
sys.modules["taylor_green_mps"] = taylor_green_mps
hou_louo_ic = _load("hou_louo_ic")
sys.modules["hou_louo_ic"] = hou_louo_ic
hou_luo_2014_ic = _load("hou_luo_2014_ic")
sys.modules["hou_luo_2014_ic"] = hou_luo_2014_ic

import numpy as np
import torch
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

# Aliases
make_k_grids = taylor_green_mps.make_k_grids
make_dealias_mask = taylor_green_mps.make_dealias_mask
rk4_step = taylor_green_mps.rk4_step
energy = taylor_green_mps.energy
max_vorticity = taylor_green_mps.max_vorticity
DEVICE = taylor_green_mps.DEVICE
DTYPE = taylor_green_mps.DTYPE
simplified_ic = hou_louo_ic.hou_luo_style_ic
antiparallel_ic = hou_luo_2014_ic.antiparallel_vortex_pair_ic
single_vortex_axial_pert_ic = hou_luo_2014_ic.single_vortex_axial_pert_ic


def compute_strain_eigvecs(uhat, kx, ky, kz):
    """Compute the 2nd eigenvector ξ_2 of the strain tensor S = (∇u + ∇u^T)/2
    at every grid point.

    Returns: ξ_2 as a (N, N, N, 3) real tensor on CPU — last axis is the
    vector component index (x, y, z).
    """
    u = torch.fft.ifftn(uhat, dim=(-3, -2, -1)).real  # (3, N, N, N) real
    # Compute gradients ∂_j u_i via spectral multiplication
    def dfield(i, j):
        # k_j: from the broadcasted meshgrid (kx, ky, kz)
        # i, j ∈ {0, 1, 2}
        ks = [kx, ky, kz]
        return torch.fft.ifftn(1j * ks[j] * uhat[i], dim=(-3, -2, -1)).real
    # Build S with shape (N, N, N, 3, 3) so that eigh treats the last 2 axes as matrix axes.
    # S[x,y,z,i,j] = (∂_j u_i + ∂_i u_j) / 2
    du = torch.zeros(3, 3, *u.shape[1:], device=uhat.device, dtype=torch.float32)
    for i in range(3):
        for j in range(3):
            du[i, j] = dfield(i, j)  # du[i,j] = ∂_j u_i
    # S[x,y,z,i,j] = (du[j,i] + du[i,j]) / 2 — wait, du[i,j] = ∂_j u_i, so S_ij = ∂_j u_i.
    # Actually S_ij = (∂_j u_i + ∂_i u_j) / 2 = (du[i,j] + du[j,i]) / 2.
    # Permute du so we can do symmetric combination.
    du_perm = du.permute(2, 3, 4, 0, 1)  # (N, N, N, 3, 3) — index (x,y,z, i, j)
    # Now S = (du_perm + du_perm.transposed(3,4)) / 2
    S = (du_perm + du_perm.transpose(-1, -2)) / 2.0
    # Compute eigenvectors at each grid point.
    # S is symmetric, so we can use torch.linalg.eigh.
    eigenvalues, eigenvectors = torch.linalg.eigh(S)
    # eigenvectors has shape (N, N, N, 3, 3) — eigenvectors along the last 2 axes
    # ξ_2 is the eigenvector for the 2nd eigenvalue (index 1 in 0-indexed ascending)
    xi_2 = eigenvectors[..., 1]  # (N, N, N, 3) — last axis is component
    return xi_2


def compute_vorticity(uhat, kx, ky, kz):
    """Compute vorticity ω = ∇ × u as a (3, N, N, N) real tensor on CPU."""
    # ω_x = ∂_y u_z - ∂_z u_y = IFFT[1j ky uhat_z - 1j kz uhat_y]
    # We compute in spectral space then IFFT.
    u_x = torch.fft.ifftn(1j * ky * uhat[2] - 1j * kz * uhat[1], dim=(-3, -2, -1)).real
    u_y = torch.fft.ifftn(1j * kz * uhat[0] - 1j * kx * uhat[2], dim=(-3, -2, -1)).real
    u_z = torch.fft.ifftn(1j * kx * uhat[1] - 1j * ky * uhat[0], dim=(-3, -2, -1)).real
    return torch.stack([u_x, u_y, u_z], dim=0)


def compute_alignment_angle(uhat, kx, ky, kz):
    """Compute θ(x,t) = ∠(ω(x,t), ξ_2(x,t)) at every grid point.

    Returns: θ as a (N, N, N) tensor in radians [0, π/2] (we take the
    absolute value of cos since ω and -ω are the same direction).
    """
    omega = compute_vorticity(uhat, kx, ky, kz)  # (3, N, N, N)
    xi_2 = compute_strain_eigvecs(uhat, kx, ky, kz)  # (N, N, N, 3)
    # Cosine of angle between ω and ξ_2 at each point
    omega_dot_xi2 = (omega * xi_2.permute(3, 0, 1, 2)).sum(dim=0)  # (N, N, N)
    omega_norm = torch.sqrt((omega * omega).sum(dim=0) + 1e-30)
    xi2_norm = torch.sqrt((xi_2 * xi_2).sum(dim=-1) + 1e-30)
    cos_theta = omega_dot_xi2 / (omega_norm * xi2_norm)
    cos_theta = torch.clamp(cos_theta.abs(), 0.0, 1.0)
    theta = torch.arccos(cos_theta)
    return theta, omega_norm


def run_one(ic_name, ic_fn, N, nu, T_final, dt, device=DEVICE):
    """Run a single IC at a single resolution. Track alignment diagnostics."""
    L = 2 * np.pi
    kx, ky, kz, ksq = make_k_grids(N, L, device=device)
    dealias_mask = make_dealias_mask(N, device=device)
    uhat = ic_fn(N, L, device="cpu").cpu()
    uhat = uhat.to(device=device, dtype=DTYPE)

    n_steps = int(round(T_final / dt))
    n_outputs = 51  # output every n_steps/50 steps + initial
    output_steps = set([0] + list(range(1, n_steps + 1, max(1, n_steps // n_outputs))))

    results = {
        'ic_name': ic_name,
        'N': N,
        'nu': nu,
        'T_final': T_final,
        'dt': dt,
        'times': [],
        'om_max': [],
        'grad_max': [],
        'theta_min': [],
        'theta_omega_max': [],
        'omega_max_overall': 0.0,
        'theta_min_overall': np.pi / 2,  # initialize to max possible
    }

    t0 = time.time()
    for step in range(n_steps + 1):
        if step in output_steps:
            # Compute diagnostics
            with torch.no_grad():
                theta, omega_norm = compute_alignment_angle(uhat, kx, ky, kz)
                theta_cpu = theta.cpu().numpy()
                omega_norm_cpu = omega_norm.cpu().numpy()
                # omega_max overall (for normalization)
                om_max = float(omega_norm_cpu.max())
                grad_max_sq = (ksq.cpu().numpy() * (uhat.cpu().numpy() ** 2).sum(axis=0).sum(axis=0)).sum()
                grad_max = float(np.sqrt(grad_max_sq))
                # Find location of max vorticity
                idx = np.unravel_index(omega_norm_cpu.argmax(), omega_norm_cpu.shape)
                theta_at_omax = float(theta_cpu[idx])
                theta_min = float(theta_cpu.min())
            t_now = step * dt
            results['times'].append(t_now)
            results['om_max'].append(om_max)
            results['grad_max'].append(grad_max)
            results['theta_min'].append(theta_min)
            results['theta_omega_max'].append(theta_at_omax)
            if om_max > results['omega_max_overall']:
                results['omega_max_overall'] = om_max
            if theta_min < results['theta_min_overall']:
                results['theta_min_overall'] = theta_min
            elapsed = time.time() - t0
            print(f"  [{ic_name} N={N}] step {step}/{n_steps} t={t_now:.4f} "
                  f"|ω|_max={om_max:.2f} θ_min={theta_min:.4f} θ(ω_max)={theta_at_omax:.4f} "
                  f"[{elapsed:.1f}s]")
        if step < n_steps:
            uhat = rk4_step(uhat, kx, ky, kz, ksq, nu, dt, dealias_mask)
    return results


def main():
    ICS = [
        ('simplified', lambda N, L, device: simplified_ic(N, L, device=device)),
        ('antiparallel', lambda N, L, device: antiparallel_ic(N, L, device=device)),
        ('axial_pert', lambda N, L, device: single_vortex_axial_pert_ic(N, L, A=5.0, device=device)),
    ]
    N_LIST = [64, 128]
    NU = 0.001
    T_FINAL = 0.05
    DT = 2e-5

    all_results = []
    for ic_name, ic_fn in ICS:
        for N in N_LIST:
            print(f"\n=== Running {ic_name} at N={N} ===")
            res = run_one(ic_name, ic_fn, N, NU, T_FINAL, DT)
            all_results.append(res)

    # Save NPZ
    out_path = '/Users/hermes/.hermes/projects/ns_blowup/data/constantin_iyer_alignment.npz'
    np.savez(out_path,
             ic_names=np.array([r['ic_name'] for r in all_results]),
             Ns=np.array([r['N'] for r in all_results]),
             times=np.array([r['times'] for r in all_results], dtype=object),
             om_max=np.array([r['om_max'] for r in all_results], dtype=object),
             grad_max=np.array([r['grad_max'] for r in all_results], dtype=object),
             theta_min=np.array([r['theta_min'] for r in all_results], dtype=object),
             theta_omega_max=np.array([r['theta_omega_max'] for r in all_results], dtype=object))
    print(f"\nSaved: {out_path}")

    # Summary
    print("\n=== Summary ===")
    print(f"{'IC':>12} {'N':>4} {'|ω|_max':>10} {'θ_min':>8} {'θ(ω_max)':>10}")
    for r in all_results:
        # Find minimum θ_omega_max (best alignment at max-vorticity point)
        idx_omax = np.argmax(r['om_max'])
        theta_at_peak = r['theta_omega_max'][idx_omax]
        print(f"{r['ic_name']:>12} {r['N']:>4} {r['omega_max_overall']:>10.2f} "
              f"{r['theta_min_overall']:>8.4f} {theta_at_peak:>10.4f}")

    # Plot: theta_min and theta_omega_max vs time, for each (IC, N)
    fig, axes = plt.subplots(2, 3, figsize=(15, 8), sharex=True)
    for col, (ic_name, _) in enumerate(ICS):
        for row, what in enumerate(['theta_min', 'theta_omega_max']):
            ax = axes[row, col]
            for N in N_LIST:
                matching = [r for r in all_results if r['ic_name'] == ic_name and r['N'] == N]
                if matching:
                    r = matching[0]
                    label = f"N={N}"
                    ax.plot(r['times'], r[what], label=label, marker='o', markersize=3)
            ax.set_title(f"{ic_name}: {what}")
            ax.set_xlabel('t')
            ax.set_ylabel('θ (rad)')
            ax.set_ylim(0, np.pi / 2)
            ax.axhline(y=np.pi / 4, color='gray', linestyle='--', alpha=0.5, label='π/4')
            ax.legend()
            ax.grid(alpha=0.3)
    fig.suptitle('Constantin–Iyer alignment angle: θ_min and θ at max-vorticity point')
    fig.tight_layout()
    fig_path = '/Users/hermes/.hermes/projects/ns_blowup/data/constantin_iyer_timeseries.png'
    fig.savefig(fig_path, dpi=120, bbox_inches='tight')
    print(f"Saved: {fig_path}")

    # Plot: scatter of θ vs |ω| at each (IC, N) — does alignment correlate with high vorticity?
    fig2, axes2 = plt.subplots(1, 3, figsize=(15, 4))
    for col, (ic_name, _) in enumerate(ICS):
        ax = axes2[col]
        for N in N_LIST:
            matching = [r for r in all_results if r['ic_name'] == ic_name and r['N'] == N]
            if matching:
                r = matching[0]
                om = np.array(r['om_max'])
                th = np.array(r['theta_min'])
                ax.scatter(om, th, label=f"N={N}", s=30, alpha=0.7)
        ax.set_xlabel('|ω|_max(t)')
        ax.set_ylabel('θ_min(t)')
        ax.set_title(ic_name)
        ax.legend()
        ax.grid(alpha=0.3)
    fig2.suptitle('Alignment angle θ_min vs max-vorticity |ω|_max over time')
    fig2.tight_layout()
    fig2_path = '/Users/hermes/.hermes/projects/ns_blowup/data/constantin_iyer_scatter.png'
    fig2.savefig(fig2_path, dpi=120, bbox_inches='tight')
    print(f"Saved: {fig2_path}")


if __name__ == '__main__':
    main()
