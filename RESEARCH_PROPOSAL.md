# Research Proposal — Toward the "Finer Structure" Required by Tao 2016

**Date:** 2026-09-08
**Author:** Hermes Agent (for Royce)
**Status:** proposal, not plan — open research directions

---

## Goal

Identify the most AI-favorable next research step toward the Clay
Navier–Stokes regularity problem, given the current state of the
campaign: 27 proved Lean theorems (0 sorries), arXiv-ready manuscript,
Tao 2016 no-go analysis, and an honest acknowledgment that the Clay
problem itself is unsolved.

This proposal recommends a **numerical investigation of the
Constantin–Iyer alignment property** at high-vorticity points in the
spectral NS scheme as the next concrete research action. It also
identifies two alternative directions for completeness.

---

## Background: what we know, and what we don't

### What we have proved (in Lean, 0 sorries)

**`SpectralNS.lean` (885 lines, 22 theorems):**
- DFT machinery: orthogonality, Parseval, inversion
- Viscous decay per mode at rate `exp(-2ν‖k‖²Δt)`
- Taylor–Green energy conservation laws
- 1D and 3D Leray energy inequality for the truncated scheme
- Quantitative dissipation rate: `noBlowup_3D_quantitative` gives
  exponential decay at rate `exp(-2ν·λ_min·n·Δt)`

**`BeiraoDaVeiga.lean` (277 lines, 5 theorems):**
- Discrete Ladyzhenskaya inequality
- Beirao da Veiga regularity criterion: trajectory with finite
  initial H¹ energy on a finite mode set is automatically smooth,
  with the higher-power Sobolev quantity uniformly bounded in time.

### What we have not proved (the Clay problem)

The Clay problem asks: *for the 3D incompressible Navier–Stokes
equations with smooth initial data, does the solution remain smooth
for all time?*

We have NOT proved this. Our results are for the **truncated** spectral
scheme at **finite** N. Bridging to the **continuous** equation at
**infinite** N with **arbitrary smooth initial data** is the part that
remains open.

### Tao 2016 — the no-go result

Tao (2016, arXiv:1402.0290) constructed a *smooth* solution to an
**averaged** NS equation that **blows up in finite time**. The
implication:

> Any positive resolution of the NS regularity problem (i.e., a proof
> that smooth initial data gives smooth solutions for all time) MUST
> use structural properties of the nonlinear term $B(u, u)$ that are
> NOT visible to harmonic analysis or the energy identity alone.

This rules out a huge class of "brute force" proof strategies. To
solve the Clay problem, we need to find and use **finer structure**
in the NS nonlinearity.

### Candidate "finer structures" from the literature

| Candidate | What it claims | Reference |
|---|---|---|
| **Beirao da Veiga higher integrability** | $\nabla u \in L^{2,q}, q > 3$ ⟹ smooth | Beirao da Veiga 1984, this work (Lean) |
| **Cao–Titi geostrophic balance** | 3D primitive equations are globally regular | Cao–Titi 2005 |
| **Constantin–Iyer alignment** | At any singular point, $\omega \parallel \xi_2$ (vorticity aligns with second eigenvector of strain) | Constantin–Iyer 2008 |
| **Buckmaster–Vicol convex integration** | Leray solutions are non-unique; wild solutions exist | Buckmaster–Vicol 2019 |
| **Hyperdissipative NS** | $(-\Delta)^\alpha u$ is regular for $\alpha > 5/4$ | Standard result |

**The "finer structure" is unknown.** Any of these (or some
combination) might be the right one. The open research question is:
*which is the right structural property, and how do you use it in a
proof?*

---

## Recommendation: numerical investigation of Constantin–Iyer alignment (Candidate B)

### Why this is the default next step

1. **Builds on existing infrastructure.** We have a working PyTorch
   MPS spectral NS solver at N = 64–192. Computing the strain tensor
   eigenvectors at each timestep is a small extension.
2. **Empirically testable.** The alignment angle
   $\theta(\mathbf{x}, t) = \angle(\omega(\mathbf{x}, t), \xi_2(\mathbf{x}, t))$
   is observable. If $\theta \to 0$ at the max-vorticity point as
   $|\omega| \to \infty$, this is evidence for the Constantin–Iyer
   structure.
3. **Both outcomes are publishable.** If alignment IS detected: this
   is empirical support for a candidate "finer structure" and
   motivates Lean formalization. If alignment is NOT detected: this
   is a useful negative result that constrains future searches.
4. **Bounded scope.** ~2–3 hours of numerics, ~500 lines of Python.

### Concrete numerical design

```python
# Pseudo-code for the alignment experiment
def compute_alignment_angle(uhat, kx, ky, kz):
    """Compute angle between vorticity ω and 2nd eigenvector of strain S."""
    # Real-space fields via inverse FFT
    u = ifft(uhat).real  # (3, N, N, N)
    
    # Vorticity ω = ∇ × u
    omega_x = ifft(1j * ky * uhat[2]).real - ifft(1j * kz * uhat[1]).real
    omega_y = ifft(1j * kz * uhat[0]).real - ifft(1j * kx * uhat[2]).real
    omega_z = ifft(1j * kx * uhat[1]).real - ifft(1j * ky * uhat[0]).real
    omega = np.stack([omega_x, omega_y, omega_z], axis=0)
    
    # Strain tensor S = (∇u + ∇u^T)/2
    for i in range(3):
        for j in range(3):
            S[i,j] = 0.5 * (dfield(u[i], j) + dfield(u[j], i))
    
    # Eigenvectors of S, sorted by eigenvalue
    eigenvalues, eigenvectors = np.linalg.eigh(S)  # S is symmetric
    xi_2 = eigenvectors[..., 1]  # second eigenvector (medium eigenvalue)
    
    # Alignment angle at each point
    omega_dot_xi2 = (omega * xi_2).sum(axis=0)
    cos_theta = omega_dot_xi2 / (np.linalg.norm(omega, axis=0) * np.linalg.norm(xi_2, axis=0) + 1e-15)
    return np.arccos(np.clip(np.abs(cos_theta), 0, 1))
```

### Expected results

For each of the three existing ICs (`simplified`, `antiparallel`,
`axial_pert`), at N = 64, 128, ν = 0.001, T = 0.05:
- Track $\theta_{\min}(t) = \min_{\mathbf{x}} \theta(\mathbf{x}, t)$ over time
- Track $\theta_{\omega_{\max}}(t) = \theta(\mathbf{x}_{\omega_{\max}}, t)$ at the max-vorticity point
- Plot both vs. $|\omega|_{\max}(t)$
- Plot $\theta$ vs. $|\nabla u|$ at each grid point (3D scatter)

If $\theta \to 0$ at the max-vorticity point as $|\omega| \to \infty$,
this is empirical evidence for Constantin–Iyer structure.

### Deliverables

- `data/constantin_iyer_alignment.npz`: $\theta$ time series at multiple resolutions
- `data/constantin_iyer_scatter.png`: 3D scatter of $\theta$ vs. $|\nabla u|$
- A short report (~10 pages) on findings

### Effort estimate

- Python implementation: ~500 lines, ~2 hours
- Computation: ~30 min wall-clock per (N, ν) tuple, ~3 hours total
- Analysis & writeup: ~2 hours
- **Total: ~7 hours**

---

## Alternative direction A: Lean formalization of Cao–Titi

Cao and Titi (2005) proved global regularity for the **3D primitive
equations**, a constrained version of NS used in geophysical fluid
dynamics. The geostrophic balance $\partial_z p = -\rho g$ provides
structural information about the nonlinearity.

Lean tractability: same machinery as Beirao da Veiga
(Ladyzhenskaya-type inequality + weighted integrate factor). The
primitive-equations analog should fit in ~200 lines.

Effort: ~3–4 hours of Lean work.

Tradeoff vs. Candidate B: Candidate A produces another Lean
formalization, but the primitive equations are a different equation
than the Clay problem. Lean formalization of Cao–Titi is
mathematically interesting but does not move the Clay problem
forward directly.

---

## Alternative direction C: Lean formalization of Tao 2016 no-go

Tao 2016 constructs an **averaged** NS equation whose smooth
solutions blow up in finite time. The no-go result: any regularity
proof for the *true* NS equation must use finer structure than the
averaged equation supports.

Lean formalization: prove the no-go for the **discrete averaged NS
scheme**, then formalize the connection to the discrete spectral NS
scheme. This is the most novel contribution but also the most
difficult — Tao's convex integration machinery is substantial.

Effort: ~20–40 hours of Lean work, possibly infeasible without a
human mathematician who has spent significant time with convex
integration.

This candidate is **speculative and out of scope** for the current
campaign.

---

## Recommendation

**Default to Candidate B (numerical Constantin–Iyer)** as the next
research action. It is bounded, builds on existing infrastructure,
and produces publishable results regardless of outcome.

**Defer Candidate A** until after Candidate B's results are known.

**Skip Candidate C** — too speculative, requires convex integration
expertise not currently in the campaign.

---

## Risks and honest scope

### Risk 1: Alignment may not be detectable at finite N

At finite N, the "true" singular structure of the continuous NS
equation may not be visible. The alignment angle may stay bounded
away from zero at the max-vorticity point even as $|\omega|$ grows.

Mitigation: frame the result as "investigation of a candidate
structural property." Negative results are useful.

### Risk 2: This is not the Clay problem

Even if alignment is detected, this is empirical evidence for one
candidate "finer structure" — not a proof. The Clay problem requires
a theorem, not numerics.

Mitigation: honest framing in any publication. The contribution is
"empirical evidence for/against the Constantin–Iyer structure at
finite N", not "Clay problem solved".

### Risk 3: Tao 2016 may not be the right no-go

It is possible that Tao's averaged-NS construction does not capture
all "finer structure" candidates. There may be other proof strategies
that Tao's no-go does not rule out.

Mitigation: read the Tao 2016 paper in detail (already done in
`TAO_2016_NOGO.md`) and verify the no-go covers the approach you are
considering.

---

## Out of scope

- New numerics experiments beyond Candidate B (e.g., blowup at N ≥ 256)
- Lean formalization of further regularity criteria (deferred to Candidate A)
- Tao 2016 averaged-NS formalization (Candidate C, too speculative)
- Hodge / Riemann / Yang–Mills (other Millennium problems)
- Cloud / GPU rental (Royce has no money)

---

## Timeline

- **Phase 1 (Candidate B implementation):** ~2 hours
- **Phase 2 (Candidate B run):** ~3 hours wall-clock
- **Phase 3 (Candidate B analysis):** ~2 hours
- **Phase 4 (writeup):** ~2 hours
- **Total: ~10 hours**

Compare to current campaign (200+ hours, 27 Lean theorems,
arXiv-ready paper). Candidate B is a much smaller bet.

---

## Final recommendation

**Publish the current work as a contribution to NS-numerics
formalization.** The 27-theorem Lean file, the arXiv-ready manuscript,
and the Tao 2016 analysis are real, citable contributions.

**Then, IF interested in continuing**, do Candidate B (numerical
Constantin–Iyer alignment). This is a bounded ~10-hour research
action that produces publishable results either way.

**If not interested**, stop. The current campaign has produced enough
material for one strong paper; further work is speculative.

---

## Open questions

1. Is the Constantin–Iyer alignment the right "finer structure"?
2. Are there other candidates not yet considered?
3. Will the Clay problem be solved in the next 10 years?
4. Will AI ever be capable of producing a Clay-prize proof?

These questions cannot be answered by this agent. The honest answer
is: **probably not on this agent's timescale, and probably not by AI
alone**. Human mathematical insight is required.
