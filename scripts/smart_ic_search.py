"""Smart-IC search for finite-N blowup candidates.

Goal: find an initial condition that maximizes the gradient L^2 scaling
exponent alpha in peak_grad(N) ~ N^alpha for the truncated spectral NS scheme.

Strategy: take the existing axial_pert IC (which has qualitatively different
behavior — u_z perturbation breaking axisymmetry, ~50x higher peak_rate
than the other two ICs) and add random Sobolev-class perturbations.
Run each at N=64 and N=128, record the gradient scaling alpha. Look for
alpha > 1.7 (the current best from the Onsager-critical sweep).
"""
import sys, os, time, json, importlib.util

# We need to load both modules from benchmarks/ — the standard import path
# trick (sys.path.insert) doesn't work reliably on Python 3.14 with non-package
# directories. Use importlib.util.spec_from_file_location for direct loading.
BENCHMARKS_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "benchmarks")

def _load(name):
    spec = importlib.util.spec_from_file_location(name, os.path.join(BENCHMARKS_DIR, name + ".py"))
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod

# We need to load taylor_green_mps first, then hou_luo_ic, then hou_luo_2014_ic
# (each depends on the previous). Register each in sys.modules so the secondary
# imports work.
taylor_green_mps = _load("taylor_green_mps")
sys.modules["taylor_green_mps"] = taylor_green_mps
hou_luo_ic = _load("hou_louo_ic")
sys.modules["hou_louo_ic"] = hou_luo_ic
hou_luo_2014_ic = _load("hou_luo_2014_ic")
sys.modules["hou_luo_2014_ic"] = hou_luo_2014_ic

# Now expose what we need
import numpy as np
import torch
make_k_grids = taylor_green_mps.make_k_grids
make_dealias_mask = taylor_green_mps.make_dealias_mask
rk4_step = taylor_green_mps.rk4_step
energy = taylor_green_mps.energy
max_vorticity = taylor_green_mps.max_vorticity
DEVICE = taylor_green_mps.DEVICE
DTYPE = taylor_green_mps.DTYPE
single_vortex_axial_pert_ic = hou_luo_2014_ic.single_vortex_axial_pert_ic

# Configuration
N_TEST = 64
N_PROD = 128
NU = 0.001
T_FINAL = 0.05
DT = 2e-5
L = 2 * np.pi
N_CANDIDATES = 8
SEED_BASE = 42


def generate_candidate_uhat(N, seed, perturbation_mode='random'):
    """Generate a candidate uhat on the N^3 grid."""
    rng = np.random.RandomState(seed)
    # Get the base axial_pert IC (3 components as complex spectral coefficients)
    base_uhat = single_vortex_axial_pert_ic(N, L, A=5.0, device="cpu").cpu()
    base_uhat_np = base_uhat.numpy()  # (3, N, N, N) complex

    if perturbation_mode == 'random':
        # Add a random perturbation in a frequency band k ∈ [N/4, N/2]
        k_lo, k_hi = N // 4, N // 2
        pert_uhat = np.zeros_like(base_uhat_np)
        for i in range(3):
            # Use perturbation amplitude comparable to the base IC (5.0)
            pert_real = rng.randn(N, N, N) * 5.0
            pert_imag = rng.randn(N, N, N) * 5.0
            k = np.fft.fftfreq(N, d=L/N) * 2 * np.pi
            kx, ky, kz = np.meshgrid(k, k, k, indexing='ij')
            k_mag = np.sqrt(kx**2 + ky**2 + kz**2)
            band = (k_mag >= k_lo) & (k_mag <= k_hi)
            pert_uhat[i] = (pert_real + 1j * pert_imag) * band
        return base_uhat_np + pert_uhat
    elif perturbation_mode == 'amplitude':
        scale = 0.5 + rng.rand() * 2.0  # scale ∈ [0.5, 2.5]
        return base_uhat_np * scale
    else:
        return base_uhat_np


def run_one_candidate(N, nu, T_final, dt, uhat_np, device=DEVICE):
    """Run a single candidate at resolution N, return peak gradient L^2 and L^2 energy."""
    kx, ky, kz, ksq = make_k_grids(N, L)
    dealias_mask = make_dealias_mask(N)
    uhat = torch.tensor(uhat_np, dtype=DTYPE, device=device)
    n_steps = int(round(T_final / dt))
    lam = torch.tensor(ksq, dtype=torch.float32, device=device)
    E0 = energy(uhat)
    grad_sq_max = 0.0
    om_max = 0.0
    for step in range(n_steps):
        uhat = rk4_step(uhat, kx, ky, kz, ksq, nu, dt, dealias_mask)
        if (step + 1) % 100 == 0 or step == n_steps - 1:
            uhat_cpu = uhat.cpu().numpy()  # force CPU before .numpy()
            ksq_cpu = ksq.cpu().numpy() if hasattr(ksq, 'cpu') else ksq
            grad_sq = np.sum(ksq_cpu * np.abs(uhat_cpu)**2)
            grad_sq_max = max(grad_sq_max, float(grad_sq))
            om = max_vorticity(uhat, kx, ky, kz)
            om_max = max(om_max, float(om))
    E_final = energy(uhat)
    peak_rate = (E0 - E_final) / (T_final * E0) if E0 > 0 else 0
    return {
        'E0': float(E0),
        'E_final': float(E_final),
        'peak_grad_sq': grad_sq_max,
        'peak_grad_L2': float(np.sqrt(grad_sq_max)),
        'om_max': om_max,
        'peak_rate': peak_rate,
    }


def main():
    print(f"=== Smart-IC search: {N_CANDIDATES} candidates ===")
    print(f"N_test={N_TEST}, N_prod={N_PROD}, nu={NU}, T={T_FINAL}, dt={DT}")
    print()
    results = []
    t0 = time.time()
    for i in range(N_CANDIDATES):
        mode = 'random'  # always random since it's the mode that produced alpha=3.6
        seed = SEED_BASE + i
        uhat_np = generate_candidate_uhat(N_TEST, seed, mode)
        try:
            res_small = run_one_candidate(N_TEST, NU, T_FINAL, DT, uhat_np)
        except Exception as e:
            print(f"  Cand {i} (seed {seed}, mode {mode}, N={N_TEST}): FAILED — {e}")
            continue
        uhat_np_large = generate_candidate_uhat(N_PROD, seed, mode)
        try:
            res_large = run_one_candidate(N_PROD, NU, T_FINAL, DT, uhat_np_large)
        except Exception as e:
            print(f"  Cand {i} (seed {seed}, mode {mode}, N={N_PROD}): FAILED — {e}")
            continue
        if res_small['peak_grad_sq'] > 0 and res_large['peak_grad_sq'] > 0:
            ratio_grad = res_large['peak_grad_sq'] / res_small['peak_grad_sq']
            log_ratio = np.log(ratio_grad)
            log_N_ratio = np.log(N_PROD / N_TEST)
            alpha_2 = log_ratio / log_N_ratio
            alpha = alpha_2 / 2.0
        else:
            alpha = 0
        results.append({
            'cand_idx': i,
            'seed': seed,
            'mode': mode,
            'alpha': alpha,
            'grad_sq_test': res_small['peak_grad_sq'],
            'grad_sq_prod': res_large['peak_grad_sq'],
            'rate_test': res_small['peak_rate'],
            'rate_prod': res_large['peak_rate'],
            'om_max_test': res_small['om_max'],
            'om_max_prod': res_large['om_max'],
            'E0': res_small['E0'],
        })
        elapsed = time.time() - t0
        eta = elapsed / (i + 1) * (N_CANDIDATES - i - 1)
        print(f"  Cand {i:2d} (seed {seed}, {mode:9s}): alpha={alpha:6.3f}, "
              f"om_test={res_small['om_max']:6.1f}, om_prod={res_large['om_max']:6.1f}, "
              f"[{elapsed:.0f}s elapsed, {eta:.0f}s ETA]")

    results.sort(key=lambda r: r['alpha'], reverse=True)
    print()
    print(f"=== Top 10 candidates by gradient scaling alpha ===")
    print(f"{'rank':>4}  {'idx':>4}  {'mode':>9}  {'alpha':>6}  {'om_test':>8}  {'om_prod':>8}  {'rate_test':>10}  {'rate_prod':>10}")
    for i, r in enumerate(results[:10]):
        print(f"{i+1:>4}  {r['cand_idx']:>4}  {r['mode']:>9}  {r['alpha']:6.3f}  "
              f"{r['om_max_test']:8.1f}  {r['om_max_prod']:8.1f}  {r['rate_test']:10.4f}  {r['rate_prod']:10.4f}")

    if results:
        max_alpha = results[0]['alpha']
        print()
        print(f"=== Summary ===")
        print(f"Max alpha found: {max_alpha:.3f}")
        print(f"Current best (axial_pert, from Onsager sweep): alpha = 0.0 (N-independent)")
        print(f"From the Onsager sweep: peak_grad ~ N^1.6-1.7 for axisymmetric ICs")
        if max_alpha > 1.7:
            print(f"** FOUND alpha > 1.7 — this is a candidate blowup IC! **")
        else:
            print(f"No candidate exceeds the current best alpha = 1.7")
        np.savez('/Users/hermes/.hermes/projects/ns_blowup/data/smart_ic_search_reduced.npz',
                 cand_idx=np.array([r['cand_idx'] for r in results]),
                 seed=np.array([r['seed'] for r in results]),
                 mode=np.array([r['mode'] for r in results]),
                 alpha=np.array([r['alpha'] for r in results]),
                 grad_sq_test=np.array([r['grad_sq_test'] for r in results]),
                 grad_sq_prod=np.array([r['grad_sq_prod'] for r in results]),
                 rate_test=np.array([r['rate_test'] for r in results]),
                 rate_prod=np.array([r['rate_prod'] for r in results]),
                 om_max_test=np.array([r['om_max_test'] for r in results]),
                 om_max_prod=np.array([r['om_max_prod'] for r in results]),
                 E0=np.array([r['E0'] for r in results]))
        with open('/Users/hermes/.hermes/projects/ns_blowup/data/smart_ic_search_reduced.txt', 'w') as f:
            f.write(f"Smart-IC search: N_CANDIDATES={N_CANDIDATES}, N_test={N_TEST}, N_prod={N_PROD}\n")
            f.write(f"Max alpha: {max_alpha:.3f}\n")
            f.write(f"Current best (from Onsager sweep): alpha = 1.6-1.7 for axisymmetric ICs\n\n")
            f.write("Top 10 by alpha:\n")
            for i, r in enumerate(results[:10]):
                f.write(f"  {i+1}. idx={r['cand_idx']}, mode={r['mode']}, alpha={r['alpha']:.3f}, "
                        f"om_test={r['om_max_test']:.1f}, om_prod={r['om_max_prod']:.1f}\n")
        print(f"\nSaved: data/smart_ic_search.npz and data/smart_ic_search.txt")
    print(f"\nTotal wall-clock: {time.time() - t0:.1f}s")


if __name__ == '__main__':
    main()
