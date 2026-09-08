"""
Onsager-critical sub-problem: scaling of the peak dissipation rate D_N(T) vs N.

For a 3D Navier-Stokes solution on a periodic box of side L=2pi with N grid
points per direction:

  E(t)         = (1/2) < |u|^2 >                  (L^2 energy per unit volume)
  gradient_L2  = < |grad u|^2 > = sum_k |k|^2 |u_hat(k)|^2
  D_N(t)       = E(0) - E(t)                     (cumulative energy dissipated)

We focus on the "Onsager-critical" regime (nu small, T short) where the
question is whether gradient_L2 stays bounded (smooth / Kolmogorov-like) or
blows up like N^{2 alpha} with alpha > 0 (rough / Onsager-singular).

Conjecture: gradient_L2(N, T) ~ N^{2 alpha} with alpha <= 1 (Leray bound).
Equivalent to peak_D_N ~ N^{alpha} when normalized by (t * E(0)).

Sweep: 3 ICs x 3 grids (N=64, 96, 128) x 2 viscosities (nu=0.005, 0.002)
       = 18 runs total.

Outputs:
  /Users/hermes/.hermes/projects/ns_blowup/data/onsager_sweep.npz
  /Users/hermes/.hermes/projects/ns_blowup/data/onsager_sweep.png
  /Users/hermes/.hermes/projects/ns_blowup/data/onsager_scaling.txt
"""
import sys, os, time, json
import numpy as np
import torch
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

ROOT = "/Users/hermes/.hermes/projects/ns_blowup"
sys.path.insert(0, os.path.join(ROOT, "benchmarks"))

from taylor_green_mps import (
    make_k_grids, make_dealias_mask, rk4_step,
    energy, max_vorticity, DEVICE, DTYPE,
)
import hou_louo_ic as ic0          # simplified (single Gaussian-z vortex tube)
import hou_luo_2014_ic as ic1      # antiparallel + single-vortex-axial-pert

# ------------------------------------------------------------------ helpers

def gradient_L2_sq(uhat, ksq):
    """< |grad u|^2 > = sum_k |k|^2 |u_hat(k)|^2, normalized by N^3.

    Parseval: sum_k |f_hat(k)|^2 = N^3 * mean(|f|^2). So <|grad u|^2> =
    (1/N^3) sum_k |k|^2 |u_hat(k)|^2.
    """
    return float((ksq * (uhat[0].abs() ** 2 + uhat[1].abs() ** 2 + uhat[2].abs() ** 2)).mean())


def cumulative_dissipation(uhat, E0):
    """D_N(t) = E(0) - E(t)"""
    return E0 - energy(uhat)


# ------------------------------------------------------------------ ICs

def make_ic(name, N, L=2 * np.pi):
    """Build the 3 ICs that match the existing hou-luo module signatures."""
    if name == "simplified":
        return ic0.hou_luo_style_ic(N, L=L, amplitude=10.0)
    if name == "antiparallel":
        return ic1.antiparallel_vortex_pair_ic(N, L=L, A=5.0)
    if name == "axial_pert":
        return ic1.single_vortex_axial_pert_ic(N, L=L, A=5.0, epsilon_z=1.0, sigma_z=0.5)
    raise ValueError(f"unknown IC {name}")


# ------------------------------------------------------------------ driver

def run_one(ic_name, N, nu, T=0.05, dt=2e-5):
    L = 2 * np.pi
    kx, ky, kz, ksq = make_k_grids(N, L)
    dealias_mask = make_dealias_mask(N)
    uhat = make_ic(ic_name, N, L)
    E0 = energy(uhat)
    om0 = max_vorticity(uhat, kx, ky, kz)
    n_steps = int(round(T / dt))
    # Subsample at ~50 frames per run
    sample_every = max(1, n_steps // 50)

    times = [0.0]
    energies = [E0]
    grad_L2s = [gradient_L2_sq(uhat, ksq)]
    diss = [0.0]

    t0 = time.time()
    for step in range(n_steps):
        uhat = rk4_step(uhat, kx, ky, kz, ksq, nu, dt, dealias_mask)
        if (step + 1) % sample_every == 0 or step == n_steps - 1:
            t_now = (step + 1) * dt
            E_now = energy(uhat)
            times.append(t_now)
            energies.append(E_now)
            grad_L2s.append(gradient_L2_sq(uhat, ksq))
            diss.append(E0 - E_now)
    elapsed = time.time() - t0

    times = np.asarray(times); grad_L2s = np.asarray(grad_L2s)
    diss = np.asarray(diss)
    # peak dissipation rate normalized: max_t D_N(t) / (t * E(0))
    # Avoid t=0: take max over t > 0.
    mask = times > 0
    peak_rate = float((diss[mask] / (times[mask] * E0)).max())
    # Also the raw peak of grad_L2 over time
    peak_grad = float(grad_L2s.max())
    final_grad = float(grad_L2s[-1])
    final_diss_rate = float(diss[-1] / (times[-1] * E0)) if times[-1] > 0 else 0.0

    return {
        "ic": ic_name, "N": int(N), "nu": float(nu),
        "T": float(T), "dt": float(dt),
        "n_steps": int(n_steps),
        "E0": float(E0),
        "om0": float(om0),
        "times": times,
        "grad_L2": grad_L2s,
        "dissipation": diss,
        "peak_dissipation_rate": peak_rate,
        "final_dissipation_rate": final_diss_rate,
        "peak_grad_L2": peak_grad,
        "final_grad_L2": final_grad,
        "elapsed_s": float(elapsed),
    }


# ------------------------------------------------------------------ main

def main():
    ICs = ["simplified", "antiparallel", "axial_pert"]
    NS = [64, 96, 128]
    NUS = [0.005, 0.002]
    T = 0.05
    dt = 2e-5

    results = []
    wall0 = time.time()
    for ic in ICs:
        for N in NS:
            for nu in NUS:
                print(f"\n=== IC={ic}  N={N}  nu={nu}  T={T}  dt={dt} ===")
                try:
                    rec = run_one(ic, N, nu, T=T, dt=dt)
                    print(f"  E0={rec['E0']:.3e}  om0={rec['om0']:.3f}  "
                          f"peak_rate={rec['peak_dissipation_rate']:.3e}  "
                          f"peak_grad={rec['peak_grad_L2']:.3e}  "
                          f"elapsed={rec['elapsed_s']:.1f}s")
                    results.append(rec)
                except Exception as e:
                    print(f"  ERROR: {e}")
                    results.append({
                        "ic": ic, "N": int(N), "nu": float(nu),
                        "T": float(T), "dt": float(dt),
                        "error": repr(e),
                    })
    total_elapsed = time.time() - wall0
    print(f"\n[total wall-clock] {total_elapsed:.1f}s "
          f"= {total_elapsed/60:.2f} min")

    # ---------------- save data ----------------
    data_dir = os.path.join(ROOT, "data")
    os.makedirs(data_dir, exist_ok=True)
    npz_path = os.path.join(data_dir, "onsager_sweep.npz")
    # Flatten per-run time series into structured arrays
    save_kwargs = dict(
        ic_names=np.array(ICs),
        Ns=np.array(NS),
        nus=np.array(NUS),
        T=T, dt=dt,
        total_elapsed_s=total_elapsed,
    )
    for k in ("peak_dissipation_rate", "final_dissipation_rate",
              "peak_grad_L2", "final_grad_L2",
              "E0", "om0", "elapsed_s"):
        save_kwargs[k] = np.array([r.get(k, np.nan) for r in results])
    np.savez(npz_path, **save_kwargs)
    print(f"[saved] {npz_path}")

    # ---------------- scaling fit ----------------
    # For each (IC, nu), fit peak_rate ~ N^alpha via log-log OLS on N in NS.
    lines = []
    lines.append("Onsager-critical sub-problem: scaling of peak dissipation rate")
    lines.append("=" * 60)
    lines.append(f"IC names: {ICs}")
    lines.append(f"N grid:   {NS}")
    lines.append(f"viscosity: {NUS}")
    lines.append(f"T = {T}, dt = {dt}")
    lines.append(f"total wall-clock = {total_elapsed:.1f}s = {total_elapsed/60:.2f} min")
    lines.append("")
    lines.append("For each (IC, nu), fit log(peak_rate) = alpha * log(N) + c.")
    lines.append("Leray bound predicts alpha <= 1 (D_N ~ N^alpha).")
    lines.append("")
    header = f"{'IC':<14}{'nu':<10}{'alpha':>10}{'c':>12}{'R^2':>10}  raw peak rates"
    lines.append(header)
    lines.append("-" * len(header))
    summary_rows = []
    logN = np.log(np.asarray(NS, dtype=float))

    for ic in ICs:
        for nu in NUS:
            yvals = []
            for N in NS:
                for r in results:
                    if r["ic"] == ic and int(r["N"]) == int(N) and abs(float(r["nu"]) - nu) < 1e-12:
                        yvals.append(r["peak_dissipation_rate"])
                        break
            y = np.asarray(yvals)
            if np.any(~np.isfinite(y)) or len(y) < 2:
                lines.append(f"{ic:<14}{nu:<10}{'NA':>10}{'NA':>12}{'NA':>10}")
                continue
            mask = y > 0
            if mask.sum() < 2:
                lines.append(f"{ic:<14}{nu:<10}{'NA':>10}{'NA':>12}{'NA':>10}")
                continue
            x = logN[mask]; ly = np.log(y[mask])
            slope, intercept = np.polyfit(x, ly, 1)
            # R^2
            ss_res = float(((ly - (slope * x + intercept)) ** 2).sum())
            ss_tot = float(((ly - ly.mean()) ** 2).sum())
            r2 = 1.0 - ss_res / ss_tot if ss_tot > 0 else float("nan")
            raw = "  ".join(f"{v:.2e}" for v in y)
            lines.append(f"{ic:<14}{nu:<10}{slope:>10.3f}{intercept:>12.3f}{r2:>10.3f}  {raw}")
            summary_rows.append({
                "ic": ic, "nu": nu, "alpha": float(slope),
                "c": float(intercept), "R2": float(r2),
                "peak_rates": y.tolist(),
            })

    lines.append("")
    lines.append("Interpretation:")
    lines.append("  alpha ~ 0  : dissipation independent of N (could indicate singular blowup)")
    lines.append("  alpha ~ 1  : Leray bound tight (regularity borderline)")
    lines.append("  alpha ~ 2  : smooth Kolmogorov-like (gradient grows as N^2)")
    lines.append("")

    txt_path = os.path.join(data_dir, "onsager_scaling.txt")
    with open(txt_path, "w") as f:
        f.write("\n".join(lines) + "\n")
    print(f"[saved] {txt_path}")

    # ---------------- plot ----------------
    fig, axes = plt.subplots(2, 2, figsize=(13, 9))
    colors = {"simplified": "C0", "antiparallel": "C1", "axial_pert": "C2"}
    linestyles = {0.005: "-", 0.002: "--"}

    # Panel 1: peak rate vs N for each IC, fixed nu
    ax = axes[0, 0]
    for ic in ICs:
        for nu in NUS:
            xs, ys = [], []
            for N in NS:
                for r in results:
                    if r["ic"] == ic and int(r["N"]) == int(N) and abs(float(r["nu"]) - nu) < 1e-12:
                        xs.append(N); ys.append(r["peak_dissipation_rate"])
                        break
            if not xs: continue
            ax.plot(xs, ys, marker="o",
                    color=colors[ic], linestyle=linestyles[nu],
                    label=f"{ic}, ν={nu}")
    ax.set_xlabel("N")
    ax.set_ylabel("peak dissipation rate (normalized)")
    ax.set_yscale("log"); ax.set_xscale("log")
    ax.set_title("Peak D_N / (T·E(0))  vs  N")
    ax.legend(fontsize=7, ncol=2)
    ax.grid(True, alpha=0.3, which="both")

    # Panel 2: peak rate vs nu for each N, fixed IC (one line per IC, x = nu)
    ax = axes[0, 1]
    for ic in ICs:
        for N in NS:
            xs, ys = [], []
            for nu in NUS:
                for r in results:
                    if r["ic"] == ic and int(r["N"]) == int(N) and abs(float(r["nu"]) - nu) < 1e-12:
                        xs.append(nu); ys.append(r["peak_dissipation_rate"])
                        break
            if not xs: continue
            ax.plot(xs, ys, marker="o",
                    color=colors[ic], linestyle="-",
                    label=f"{ic}, N={N}")
    ax.set_xlabel("ν")
    ax.set_ylabel("peak dissipation rate (normalized)")
    ax.set_yscale("log"); ax.set_xscale("log")
    ax.set_title("Peak D_N / (T·E(0))  vs  ν")
    ax.legend(fontsize=7, ncol=2)
    ax.grid(True, alpha=0.3, which="both")

    # Panel 3: time evolution of dissipation rate, one curve per N (simplified IC, nu=0.005)
    ax = axes[1, 0]
    ic_pick = "simplified"; nu_pick = 0.005
    for N in NS:
        for r in results:
            if r["ic"] == ic_pick and abs(float(r["nu"]) - nu_pick) < 1e-12 and int(r["N"]) == int(N):
                E0 = r["E0"]
                rate = r["dissipation"] / np.where(r["times"] > 0, r["times"] * E0, 1.0)
                ax.plot(r["times"], rate, label=f"N={N}")
                break
    ax.set_xlabel("t")
    ax.set_ylabel("D_N(t) / (t·E(0))")
    ax.set_title(f"Dissipation rate evolution, IC={ic_pick}, ν={nu_pick}")
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Panel 4: log-log scaling, one fit line per (IC, nu) with markers
    ax = axes[1, 1]
    for s in summary_rows:
        ys = np.asarray(s["peak_rates"])
        xs = np.asarray(NS, dtype=float)
        mask = ys > 0
        ax.scatter(xs[mask], ys[mask],
                   color=colors[s["ic"]],
                   marker=("o" if abs(s["nu"] - 0.005) < 1e-12 else "s"))
        if mask.sum() >= 2:
            xline = np.linspace(min(xs), max(xs), 50)
            yline = np.exp(s["c"]) * xline ** s["alpha"]
            ax.plot(xline, yline,
                    color=colors[s["ic"]],
                    linestyle=linestyles[s["nu"]],
                    label=f"{s['ic']}, ν={s['nu']}: α={s['alpha']:.2f}")
    ax.set_xlabel("N")
    ax.set_ylabel("peak dissipation rate")
    ax.set_xscale("log"); ax.set_yscale("log")
    ax.set_title("Scaling fits  D_N ~ N^α  (α reported in legend)")
    ax.legend(fontsize=7, ncol=2)
    ax.grid(True, alpha=0.3, which="both")

    fig.suptitle(f"Onsager-critical sweep: 3 ICs × {len(NS)} grids × {len(NUS)} ν "
                 f"= {len(results)} runs, T={T}, dt={dt}, "
                 f"wall={total_elapsed/60:.2f} min")
    fig.tight_layout(rect=[0, 0, 1, 0.96])
    png_path = os.path.join(data_dir, "onsager_sweep.png")
    fig.savefig(png_path, dpi=130)
    print(f"[saved] {png_path}")

    # also dump a JSON-friendly summary for the parent agent
    summary = {
        "n_runs": len(results),
        "total_elapsed_s": total_elapsed,
        "ICs": ICs, "Ns": NS, "nus": NUS,
        "T": T, "dt": dt,
        "per_run": [
            {k: (v if not isinstance(v, np.ndarray) else v.tolist())
             for k, v in r.items()}
            for r in results
        ],
        "scaling_fits": summary_rows,
    }
    json_path = os.path.join(data_dir, "onsager_sweep_summary.json")
    with open(json_path, "w") as f:
        json.dump(summary, f, indent=2, default=str)
    print(f"[saved] {json_path}")


if __name__ == "__main__":
    main()