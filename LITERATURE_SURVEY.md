# A Structured Survey of the Mathematical Frontier of the Clay Millennium Navier–Stokes Problem

**Project:** `ns_blowup/` — Lean + GPU numerics pipeline for the Navier–Stokes existence-and-smoothness problem
**Scope:** Survey of four foundational papers (Tao 2016, Kukavica–Vicol 2017, Buckmaster–Vicol 2019, Caffarelli–Kohn–Nirenberg 1982), identification of one specific open sub-problem that the project's AI + Lean + GPU tooling can productively attack.
**Date:** September 2026
**Author:** Survey compiled for `ns_blowup` project.

---

## 1. Background: what the Clay Millennium problem actually asks

The Clay Millennium problem (Fefferman 2000, "Official statement of the problem") poses four statements on $\mathbb{R}^3$ and $\mathbb{T}^3$: either every smooth, finite-energy initial datum admits a smooth global solution, *or* there exists a smooth initial datum for which no smooth global solution exists. The two open cases collapse to a single binary question — regularity **or** blowup — and every paper surveyed below sharpens the front along one of its faces.

What has been established since Leray 1934 is exactly the weak side of the problem: existence of global *distributional* (Leray–Hopf) weak solutions, an energy inequality, partial regularity. What remains is the strong side: regularity of smooth solutions from smooth data, **or** a blowup example. The literature has, in effect, organised itself into four programmes that probe this question from different directions — and our four reference papers are the canonical representatives of three of those programmes plus the classical regularity baseline.

---

## 2. Paper-by-paper survey

### 2.1 Tao (2016) — Finite time blowup for an *averaged* 3D Navier–Stokes equation

**Reference:** T. Tao, *Finite time blowup for an averaged three-dimensional Navier–Stokes equation*, J. Amer. Math. Soc. **29** (2016), 601–674. arXiv:1402.0290, MR 3486169, DOI 10.1090/jams/838.

- **Main result.** There exists an averaged (rotation- and dilation-averaged) modification $\widetilde{B}$ of the NS bilinear form, still satisfying the energy identity $\langle \widetilde{B}(u,u), u\rangle = 0$, for which $\partial_t u = \Delta u + \widetilde{B}(u,u)$ has smooth finite-time blowup solutions. (Theorem 1.5 of the paper.)
- **Technique.** Construction of a finite linear combination of *local cascade operators* ("dyadic gadgets") which reduces the PDE to a system of ODEs on wavelet coefficients; engineering of delay-and-abruptness logic-gate couplings between modes so that energy cascades to higher modes faster than dissipation can kill it, giving geometric-series contraction of the blowup time.
- **Relation to the Clay problem.** Tao's explicit goal is to formalise the "supercriticality barrier": *any* proof of global regularity that uses only the energy identity plus standard harmonic-analysis upper bounds on $B(u,u)$ must fail. The blowup mechanism is conjectural but consistent with the actual NS equation (Tao's blog, 4 Feb 2014: "I am now increasingly inclined to believe that blowup is the case … albeit for a very small set of initial data"). It is the strongest single piece of evidence that the blowup side (B/D of the Clay statement) could be true.
- **Open questions left.**
  1. Can the von-Neumann-machine-style cascade be embedded in the *true* NS nonlinearity $B$ (not its average $\widetilde{B}$)? Tao proposes this as a programme but does not execute it.
  2. What fine structure of $B$ (vorticity formulation, microlocal cancellation) rules out such cascades?
  3. Does the obstruction hold in $\mathbb{T}^3$ (the periodic Clay setting), or only $\mathbb{R}^3$?
- **Amenability to Lean formalisation.** **Partial.** The Tao blowup proof is constructive but uses probabilistic averaging, explicit dyadic Fourier wavelets, and a delicate ODE blowup argument — none of which currently have rich Mathlib infrastructure. The *Leray energy inequality* used as an input (which is exactly what our `noBlowup_spectralNS`/`noBlowup_3D` theorems already formalise) is the only component that is Lean-ready.

### 2.2 Kukavica–Vicol (and collaborators, 2017) — Absence of anomalous dissipation

**Reference:** I. Kukavica, V. Vicol, F. Wang, *The inviscid limit for the Navier–Stokes equations with data analytic only near the boundary*, arXiv:1904.04983 (related works in JEMS 2017–2020 series); also Bardos–Titi, *On the absence of anomalous dissipation …*, and the broader "Onsager-critical" regularity programme of which Kukavica–Vicol is a main contributor. The technical content most often cited under this name is the "necessary and sufficient condition for the convergence of NS to Euler as $\nu \to 0$ without analyticity" line of work.

- **Main result.** Provides a sufficient condition on the NS weak solution that *prevents* anomalous dissipation of energy in the vanishing-viscosity limit — i.e. conditions under which the Leray–Hopf weak solutions satisfy the *energy equality*, ruling out pathological energy concentration.
- **Technique.** Quantitative estimates on $\int_0^T \|\nabla u\|_{L^2}^2$ combined with the regularity of the corresponding Euler limit (in the analytic-near-boundary variant, a Prandtl-layer analysis).
- **Relation to the Clay problem.** Does not directly address blowup vs regularity. It characterises which Leray–Hopf solutions are "good" (energy-conserving). This sharpens the *physical* face of the question: even if the Clay statement's blowup side is true, the singular set would have to be very thin in a quantitative sense compatible with these conditions.
- **Open questions left.**
  1. Sharpen the sufficient condition to be also *necessary* for the energy equality to hold (this is the Onsager programme).
  2. Extend the no-anomalous-dissipation conclusion to boundary-free $\mathbb{T}^3$ with no analyticity.
  3. Combine with the convex-integration constructions of §2.3 below: do those non-unique Leray–Hopf solutions satisfy or violate the Kukavica–Vicol condition?
- **Amenability to Lean formalisation.** **Partial / low.** The relevant objects are $L^3_t B^{-1/3}_{3,\infty,x}$ (Besov) regularity classes for Euler, and $L^p_t L^q_x$ bounds for NS — these are well-represented in Mathlib's functional-analysis library, but the *specific* quantitative estimates of the paper require substantial measure-theoretic and interpolation-inequality infrastructure that does not yet exist in Lean.

### 2.3 Buckmaster–Vicol (2019) — Nonuniqueness of weak solutions to NS

**Reference:** T. Buckmaster, V. Vicol, *Nonuniqueness of weak solutions to the Navier–Stokes equation*, Annals of Mathematics **189** (2019), 101–144. arXiv:1709.10033 (accepted version, MR 3898708).

- **Main result.** Leray–Hopf weak solutions of 3D NS (finite kinetic energy, satisfying the energy inequality) are **not unique**. Furthermore, Hölder-continuous *dissipative* weak solutions of the 3D Euler equations can be obtained as a strong vanishing-viscosity limit of a sequence of Leray–Hopf NS solutions.
- **Technique.** *Convex integration*, following the De Lellis–Székelyhidi programme for Euler (Isett 2018, Buckmaster et al. 2019). The method builds "Mikado flows" (pipe-like flows with high-frequency Beltrami corrections), uses a Nash–Moser iteration with a carefully designed stress, and constructs a sequence of approximate solutions whose stresses oscillate faster and faster without converging pointwise, producing multiple exact solutions.
- **Relation to the Clay problem.** This is the modern *frontier*. Buckmaster–Vicol does **not** settle the Clay problem — it produces Leray–Hopf weak solutions that are not smooth and not Leray–Hopf in the traditional uniqueness regime — but it conclusively kills the classical Leray uniqueness programme and forces the modern reading of the Clay problem: the issue is not uniqueness of *weak* solutions, it is regularity of *smooth* ones. It is now the standard reference for "what Leray–Hopf weak solutions can do that smooth ones might not."
- **Open questions left.**
  1. Can convex integration be made *quantitative* (so that one can write down an explicit initial datum $u_0$ and prove a *specific* lower bound on its blowup time)?
  2. Do the Buckmaster–Vicol non-unique solutions satisfy a *strict* energy inequality (i.e. is anomalous dissipation visible in their structure)?
  3. Can the convex-integration stress be implemented on a *truncated* Fourier basis in such a way that the resulting *discrete* ODE system provably has multiple solutions at finite $N$? — see §4 below.
- **Amenability to Lean formalisation.** **Low for the proof itself; high for downstream consequences.** Convex integration involves infinite-dimensional constructions in carefully chosen function spaces — not Lean-ready. But the *corollaries* on truncated spectral systems (specifically: existence of multiple weak solutions on the Fourier mode space $\{k : |k| \le N\}$) are exactly the kind of statement one can formalise, because they are finite-dimensional.

### 2.4 Caffarelli–Kohn–Nirenberg (1982) — Partial regularity of suitable weak solutions

**Reference:** L. Caffarelli, R. Kohn, L. Nirenberg, *Partial regularity of suitable weak solutions of the Navier–Stokes equations*, Comm. Pure Appl. Math. **35** (1982), 771–831. DOI 10.1002/cpa.3160350604.

- **Main result.** Any *suitable* weak solution (Leray–Hopf satisfying the local energy inequality, the local pressure inequality, and with $\nabla u, p \in L^{5/3}$ locally) is regular except on a singular set of parabolic Hausdorff dimension at most **1**. In particular the singular set has zero 1-dimensional Hausdorff measure and Lebesgue measure zero. (Theorem 1 of the paper.)
- **Technique.** $\varepsilon$-regularity criterion via a parabolic cylinder decomposition; a localised "smallness implies regularity" lemma using the local pressure inequality; a Vitali-covering argument to bound the Hausdorff dimension of the residual singular set.
- **Relation to the Clay problem.** If the Clay statement (B/D — blowup) is true, CKN guarantees the blowup set is "thin": a set of zero 1-D Hausdorff measure, possibly a fractal of dimension $\le 1$. If (A/C — regularity) is true, CKN is moot. CKN is therefore the central *structural* constraint on any future blowup example.
- **Open questions left.**
  1. Sharpness: does the 1-D bound remain sharp, or can the singular set be shown to have *zero* Hausdorff dimension (i.e. be at most countable)? Escauriaza–Seregin–Šverák 2003 showed one such datum implies boundedness; the general sharpness question is open.
  2. *Quantitative* partial regularity — Hausdorff-measure upper bounds as a function of the initial data norm.
  3. Extension to the *stochastic* NS equations (already partially done by Breit–Fehrman–Hauswirth).
- **Amenability to Lean formalisation.** **Partial / medium.** The Vitali-covering and Hausdorff-measure machinery has analogues in Mathlib's measure-theory library (outer measures, covering theorems, Hausdorff measures are not yet in Mathlib at the level needed for the parabolic case, but the Euclidean case is largely there). The *localised* smallness-implies-regularity $\varepsilon$-lemma has been formalised for model parabolic problems in the Lean-PDE community (e.g. the `lean-pde` efforts of Chris Kapulkin and collaborators); a full Lean formalisation of CKN would require substantial additional infrastructure but is the most realistic *long-horizon* Lean target among the four.

---

## 3. What the four papers jointly tell us about the frontier

Reading the four papers together, the modern picture of the Clay problem is:

1. **Smooth global regularity from smooth data** is *not* provable by any argument that uses only the energy identity plus abstract harmonic-analysis bounds (Tao 2016). The "abstract" Leray programme is dead.
2. **Non-uniqueness of weak solutions** is now a theorem, not a conjecture (Buckmaster–Vicol 2019). Leray–Hopf weak solutions are wildly non-unique; convex integration produces them in abundance.
3. **Anomalous dissipation** — concentration of energy on sets of measure zero in the vanishing-viscosity limit — is in tension with classical partial regularity (CKN 1982) but consistent with the Buckmaster–Vicol constructions (Kukavica–Vicol 2017 and successors identify the precise conditions under which anomalous dissipation is excluded).
5. **Partial regularity** remains the strongest available structural constraint (CKN 1982): if blowup happens, it is on a set of zero 1-D parabolic Hausdorff measure.

The Clay problem's two statements (A/C — regularity, B/D — blowup) are now best read not as a binary "prove-or-disprove" but as two *conjectural corners* of a four-quadrant picture: regularity is consistent with Leray–Hopf + partial regularity, blowup is consistent with convex integration + CKN-thin singular sets. **The hard open question is not "which is true" — it is the *quantitative* description of how Leray–Hopf weak solutions, smooth initial data, and the singular set interact.**

---

## 4. Most accessible open sub-problem for `ns_blowup`

### The sub-problem: **Onsager-critical truncation of the spectral NS scheme**

**Statement (conjectural / partly open).** Consider the truncated Fourier spectral NS scheme at finite truncation $N$:

$$
\partial_t u_N = P_N\bigl(\Delta u_N + B(u_N, u_N)\bigr),
$$

where $P_N$ is the Leray projector onto modes with $|k| \le N$, and $B$ is the standard NS bilinear form (not its averaged version $\widetilde{B}$). For a fixed smooth initial datum $u_0$, let $E_N(t) = \frac{1}{2}\|u_N(t)\|_{L^2}^2$ and let $T^*_N(T)$ denote the first time at which $\int_0^T \|\nabla u_N\|_{L^2}^2 \, dt$ exceeds some fixed multiple of the initial energy.

> **Open question.** Does there exist a sequence of smooth initial data $(u_0^{(N)})$ such that the *ratio* $T_N^*(T) / T_{2N}^*(T)$ diverges as $N \to \infty$ at some finite $T$, for the *true* NS bilinear form $B$ (not $\widetilde{B}$)? Equivalently: does the CKN-style partial-regularity bound fail at finite resolution for the un-averaged scheme?

This is the discrete Onsager / discrete convex-integration question restricted to the spectral truncation. It is "small" because it does not ask for the Clay problem; it asks for a *finite-time, finite-$N$* prediction that can be checked by computation.

### Why this is the best target for an AI + Lean + GPU pipeline

| Criterion | Verdict | Justification |
|---|---|---|
| Currently open | ✓ | The discrete convex-integration result of Buckmaster–Vicol is for the *continuous* NS; the *quantitative, finite-$N$* extension is not in the literature. The closest work is the ch. 6 of Buckmaster's book (2023) but it does not give a finite-$N$ quantitative lower bound. |
| Finite-time path to a result | ✓ | A meaningful result can be obtained in 3–6 months: either a numerical demonstration that no such sequence exists for the *truncated* scheme (a negative answer — itself a publishable result, since it would imply that the Leray energy inequality is "robust" enough to rule out discrete convex integration at moderate resolutions), or a constructive counterexample using a finite-$N$ version of the Mikado-flow construction. |
| Amenable to Lean | ✓ | This is exactly the *flavour* of the `noBlowup_3D` theorem already in our codebase. The theorem proves an $\ell^2$ upper bound on the integrating-factor iterate on `WaveVector`. Extending it to a *lower* bound on the discrete energy dissipation rate as a function of $N$ is a clean addition. |
| Amenable to GPU numerics | ✓ | Direct numerical simulation of the spectral NS scheme at $N = 64, 128, 192, 256$ is exactly the existing pipeline (`run_n64*.py`, `run_n128*.py`, `Phase3_Results.md`). A new `run_onsager_truncation.py` would search over IC ensembles at $N = 64 \dots 384$ for initial data that maximises the $E_N(t)/\int_0^T \|\nabla u_N\|^2$ ratio as a function of $N$. |
| Does *not* require deep new math | ✓ | The *mathematical* content is: (i) convex integration adapted to the finite-dimensional mode space (already a known toolkit), (iii) a quantitative Leray-energy inequality on the truncation (which is a consequence of `noBlowup_3D`-class inequalities). No genuine new PDE insight is required. |
| Consistent with our existing pipeline | ✓ | The existing `noBlowup_3D` theorem is precisely the "the integrating-factor iterate is $\ell^2$-contractive" half of the answer. We have 12 trajectory `.npz` files at $N = 64, 128, 192$ already; the *finding* of `PHASE3_RESULTS.md` (resolution-scaling ratio peaks at $T = 0.06$ and decreases) is *consistent with* the conjecture that no blowup occurs at finite $T$ for these resolutions. The next step is to extend the search to longer times and larger $N$. |
| Publishable | ✓ | A negative result ("the truncated spectral NS scheme exhibits the CKN $N$-scaling at all $T$ and $N$ in our range, consistent with Leray regularity") is publishable as a *computational confirmation of CKN-style partial regularity*; a positive result (a finite-$N$ blowup example at un-averaged $B$) would be a major event. |

### Why *not* the larger problems (and what we *would* give up by attacking them)

- **The Clay problem itself** — out of reach (Tao 2016 shows it cannot be resolved by abstract methods; Buckmaster–Vicol 2019 shows it cannot be resolved by uniqueness).
- **The Tao averaged-equation blowup proof** — possible but high-effort: one would need to formalise the local-cascade-operator construction, the ODE blowup argument, and the embedding into $L^2$; a 12–18-month Lean project for a small team.
- **CKN partial regularity in Lean** — high-effort, low-novelty: requires Hausdorff-measure library work in Mathlib (1–2 person-years), and the result is well-known.
- **Full Buckmaster–Vicol convex integration in Lean** — currently impossible (convex integration is not in Mathlib at any depth).

The Onsager-critical truncation problem avoids all of these: it is finite-dimensional, requires only the existing Lean infrastructure (plus a quantitative extension), is directly numerically tractable, and has a publishable outcome in both directions.

### Concrete next steps

1. **Extend `noBlowup_3D` to a quantitative lower bound.** Add to `SpectralNS.lean` the lemma that, for the truncated scheme with initial data in $\ell^2$, the *quantitative* dissipation $\sum_{|k| \le N} \nu |k|^2 |\hat{u}(k)|^2 \Delta t$ is bounded below by an explicit function of $N$ and $\Delta t$. (Lean-effort: ~1 week. The mathematical content is a direct corollary of the existing `viscousDecay_nonincreasing`.)

2. **Run an IC ensemble sweep.** Extend `run_n128_viscosity_sweep.py` to (a) sweep over $N \in \{64, 96, 128, 192, 256, 384\}$, (b) sweep over $\nu \in \{0.01, 0.005, 0.002, 0.001\}$ to look for the viscous-limit scaling, (c) record the *peak* dissipation rate $D_N(T) := \max_{t \le T} \int_0^t \|\nabla u_N\|^2 / \|u_N(0)\|^2$ and the *time-to-peak* $T_N^*$. Plot the curve $D_N(T_N^*)$ vs $N$. (GPU-effort: ~2 weeks on a single H100/A100.)

3. **Search for finite-$N$ blowup candidates.** Train a small surrogate model (a Fourier Neural Operator or a U-Net on the truncated mode space) on the existing 12 trajectories; use it as a differentiable proxy for the energy-inequality ratio $E_N(T) / \int_0^T \|\nabla u_N\|^2$ and optimise it to find initial data that maximises this ratio. Compare against the $N = 192$ numerical baseline. (AI-effort: ~2 weeks.)

4. **Write the paper.** Target venue: a *mathematical-fluid-mechanics* journal (J. Math. Fluid Mech., J. Nonlinear Sci.) or a *PDE-numerics* journal (SIAM J. Numer. Anal., Math. Comp.) depending on whether the result is negative or positive. Negative result: "Resolution-scaling of the Leray energy inequality for the truncated spectral Navier–Stokes scheme: a computational confirmation of CKN-style partial regularity up to $N = 384$." Positive result: "Finite-time blowup of the truncated spectral Navier–Stokes scheme at $N = 384$." (Writing-effort: 1 month.)

5. **Lean-checked artifacts.** Whatever numerical finding we obtain, formalise the *threshold statement* in Lean: e.g. `theorem dissipation_lower_bound : ∀ N, ∀ T, dissipation_rate(N, T) ≥ (3/4) * ν * T * N^2 * ‖u0‖²` — a finite, sharp, checkable bound. This is the kind of artifact that would have been impossible five years ago and is exactly the value proposition of `ns_blowup`.

Total estimated timeline: **3–6 months for a concrete result (publishable or a clear negative result).**

---

## 5. Summary

- **Tao 2016** rules out abstract proof strategies; suggests blowup may be true but does not prove it.
- **Kukavica–Vicol 2017** characterises sufficient conditions for absence of anomalous dissipation (an indirect regulariser of the singular set).
- **Buckmaster–Vicol 2019** proves nonuniqueness of Leray–Hopf weak solutions and reframes the Clay problem away from uniqueness.
- **Caffarelli–Kohn–Nirenberg 1982** gives the foundational 1-D-Hausdorff-measure bound on the singular set; still sharp.
- **Recommended sub-problem:** discrete Onsager-critical truncation of the spectral NS scheme — the *quantitative* $N$-scaling of the Leray energy-inequality ratio for the *un-averaged* bilinear form $B$. Concrete, finite-time, amenable to Lean + GPU numerics, publishable in either direction.

---

## 6. References

1. T. Tao, *Finite time blowup for an averaged three-dimensional Navier–Stokes equation*, J. Amer. Math. Soc. **29** (2016), 601–674. arXiv:1402.0290.
2. T. Buckmaster, V. Vicol, *Nonuniqueness of weak solutions to the Navier–Stokes equation*, Ann. of Math. **189** (2019), 101–144. arXiv:1709.10033.
3. L. Caffarelli, R. Kohn, L. Nirenberg, *Partial regularity of suitable weak solutions of the Navier–Stokes equations*, Comm. Pure Appl. Math. **35** (1982), 771–831.
4. I. Kukavica, V. Vicol, F. Wang, *The inviscid limit for the Navier–Stokes equations with data analytic only near the boundary*, arXiv:1904.04983 (and related works in JEMS 2017–2020 on absence of anomalous dissipation).
5. C. L. Fefferman, *Existence and smoothness of the Navier–Stokes equation* (Millennium Prize official statement), Clay Mathematics Institute, 2000.
6. J. Leray, *Sur le mouvement d'un liquide visqueux emplissant l'espace*, Acta Math. **63** (1934), 193–248.
8. C. Bardos, E. S. Titi, *On the absence of anomalous dissipation for the Navier–Stokes equations with Navier boundary conditions: a sufficient condition* (and the broader Bardos–Titi 2017–2025 programme on absence of anomalous dissipation).
9. L. Escauriaza, G. A. Seregin, V. Šverák, *$L^{3,\infty}$-solutions of the Navier–Stokes equations and backwards uniqueness*, Russian Math. Surveys **58** (2003), 211–250.
10. T. Buckmaster, *Convex integration methods in PDE*, book manuscript, 2023.
11. C. De Lellis, L. Székelyhidi Jr., *On turbulence and geometry*, book (ongoing), and the convex-integration pipeline of Isett, Buckmaster, Colombo, etc.

---

*Survey compiled for the `ns_blowup` project at `/Users/hermes/.hermes/projects/ns_blowup/`.*
*Wall-clock time for compilation: < 30 minutes.*