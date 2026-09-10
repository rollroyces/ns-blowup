# Literature Consolidation — September 2026

**Project:** `/Users/hermes/.hermes/projects/ns_blowup/`
**Compiled:** 2026-09-10
**Author:** Hermes Agent (consolidating the five literature-mining sub-agent outputs)
**Source files:**
- `FIELD_MAP_2026.md` (field map of 2024–2026 surveys and substantive results)
- `POST2016_SEARCH.md` (constructive use of Tao's no-go; post-2016 follow-up)
- `ALIGNMENT_DECAY_LITERATURE_2026.md` (alignment-angle decay estimates)
- `CONVEX_INTEGRATION_LANDSCAPE_2026.md` (convex-integration state of the art)
- `CONTINUOUS_LADYZHENSKAYA_2020_2026.md` (refinements of the continuous Ladyzhenskaya inequality)
- `VERIFICATION_TABLE_2026-09-10.md` (independent verification of OpenAI / Alpöge–Buckmaster / Coiculescu–Palasek)

This document is the single point of entry for the post-Sep-2026 literature
context for the `ns_blowup` campaign. It does *not* attempt a comprehensive
survey of NS regularity; it summarises the directly-relevant subset.

---

## 1. What we proved in Lean

| Component | File | Theorems | Axioms | Role |
|-----------|------|----------|--------|------|
| Spectral NS scheme | `SpectralNS.lean` | 29 | 0 | Leray energy machinery, integrating-factor time stepping, DFT/Parseval, viscous decay, 1D/3D no-blowup at finite $N$ |
| Beirao da Veiga criterion | `BeiraoDaVeiga.lean` | 5 | 0 | Improved integrability ⟹ smooth (BdV regularity criterion) |
| Constantin–Iyer alignment | `ConstantinIyer.lean` | 22 | 0 | Spectral strain tensor, vorticity alignment angle |
| Composite regularity | `CompositeRegularity.lean` | 7 | 0 | Joint BdV + CI composite regularity theorem |
| Cao–Titi directional | `CaoTiti.lean` | 19 | 0 | BdV ⟹ CT hierarchy + joint CT+CI composite |
| Tao no-go interface | `TaoNoGo.lean` | 5 | **1** (`tao_averaged_blowup`) | The irreducible Lean axiom |
| Unified composite | `UnifiedComposite.lean` | 17 | 0 | All three criteria unified + hierarchy + reverse + equivalence |
| Vortex stretching | `VortexStretching.lean` | 16 | 0 | Discrete vortex-stretching identity |
| Bridge theorem | `VortexRegularity.lean` | 23 | 0 | Combines vortex-stretching + Serrin integrability |
| Discrete Ladyzhenskaya | `LadyzhenskayaDiscrete.lean` | 9 | 0 | Finite-mode cross-product bound |
| Uniform-in-$N$ | `UniformInN.lean` | 8 | 0 | Uniform-in-$N$ component of the discrete-to-continuous bridge |
| **Total** | **11 files** | **~160** | **1** | **0 sorries** |

All theorems apply to the **truncated spectral NS scheme at finite $N$**.
The discrete-to-continuous bridge (uniform-in-$N$ components + spectral
projection convergence to continuous Sobolev / Gagliardo–Nirenberg
embedding) is **not** closed in Lean and is the gap that separates the
campaign from any regularity statement about the continuous NS PDE.

---

## 2. What the field did in 2018–2026

### 2.1 Surveys / overviews (peer-reviewed or by established authors)

| Reference | arXiv | Venue | Scope |
|-----------|-------|-------|-------|
| Barker & Prange 2023 | 2211.16215 | Vietnam J. Math. | Concentration → quantitative regularity; "slight criticality breaking" |
| Miller 2022 | 2111.00040 | J. Math. Anal. Appl. | Geometric constraints on blowup (Serrin / vorticity / directional) |
| Buckmaster–Vicol 2021 | — | Bulletin of the AMS 58, 1–44 | Convex integration / h-principle |
| Tao blog 7 Sep 2026 | — | terrytao.wordpress.com | De-facto overview of the Sep 2026 burst |

### 2.2 Substantive mathematical results, 2018–2026

| Reference | Result | Direction |
|-----------|--------|-----------|
| Tao 2019 (arXiv:1908.04958) | Quantitative ESS refinement; $\\|u\\|_{L^\infty_t L^3_x} \le A$ ⟹ triple-exp $t^{-(j+1)/2}$ bounds | Quantitative blowup rate; no constructive regularity |
| Lange 2022 (arXiv:2205.14941) | Stochastic transport noise does *not* regularise averaged NS | Negative for noise-as-fix |
| Coiculescu 2023 (arXiv:2307.15986) | Partial regularity for averaged NS in hyperdissipative range only; blowup for all $\alpha \in (0, 5/4)$ | No-go *strengthened* (theorem weakened during revision) |
| Córdoba–Martínez-Zoroa–Zheng 2024 (arXiv:2407.06776) | Hypodissipative NS blowup with finite energy | First subcritical blowup, seed for Alpöge–Buckmaster |
| Miao–Nie–Ye 2024 (arXiv:2412.10404) | Whole-space non-uniqueness of finite-energy weak NS solutions | Extends BV19 to ℝ³ |
| Hou–Wang–Yang 2025/2026 (arXiv:2509.25116) | Computer-assisted Leray-Hopf non-uniqueness for unforced 3D NS | Negative direction; not yet peer-reviewed |
| **Coiculescu–Palasek 2026** (Invent. math. 244, 165–219; DOI 10.1007/s00222-025-01396-z; arXiv:2503.14699) | **Two distinct global smooth NS solutions from critical BMO⁻¹ data** (non-uniqueness, *not* blowup) | Sharpens BV19 to the critical regularity |
| Encinas-Bartos & Haller 2024 (arXiv:2310.17267, Eur. J. Mech. B/Fluids) | Exponential-in-time alignment decay along Lagrangian trajectories | Closest analytic counterpart to empirical alignment tightening |
| Grujić 2026 (arXiv:2609.05720 + 2607.08866) | Logarithmic-in-time alignment decay for critical point-singularities; transfer theorem | Conceptual match, not quantitative |
| **Alpöge–Buckmaster Sep 2026** (cims.nyu.edu/~tristanb/) | **Forced-blowup for IPM, 2D Boussinesq, and 3D incompressible Euler** with smooth forcing | **The field's new centre of gravity** |
| **OpenAI 8 Sep 2026** (openai.com/index/navier-stokes-solution/) | **Forced NS blowup claim** (Clay alternatives C/D), 166-page PDF, companion Euler paper, Lean repo | **Disputed; NOT accepted by Clay** |

### 2.3 The Sep 2026 paradigm shift

In the **two-week window of 5–10 Sep 2026**, three orthogonal attacks on
Clay alternatives C/D landed almost simultaneously:

1. **Alpöge–Buckmaster** (human-authored preprints on IPM / Boussinesq /
   Euler with smooth forcing, hosted on Buckmaster's NYU CIMS page).
   Finite-time blowup using a Córdoba–Martínez-Zoroa iterative ansatz
   with improved ODE-instability and spatial-localisation. Lean
   formalisation is being attempted for at least two of three (per
   Buckmaster's statement). **This is the legitimate reference** for the
   new mathematics.
2. **OpenAI** (8 Sep 2026 announcement, 166-page PDF, companion Euler
   paper, Lean repo at github.com/openai/NavierStokesAndEuler). Claims
   forced NS blowup at Clay alternatives C/D. Per OpenAI's own post and
   Buckmaster's reply (cims.nyu.edu/~tristanb/statement.pdf), OpenAI
   pivoted to the forced-blowup line after hearing the Buckmaster–Alpöge
   rumor. **Disputed; NOT accepted by Clay.** OpenAI explicitly states
   they will *not* claim the Clay Millennium Prize.
3. **Ganeshram–Duruisseaux–Anandkumar** (Sep 2026, anima-ai.org
   preprint). PINN-discovered candidate blowup profile for unforced 3D
   Euler. Very preliminary; stability not established.

**The field has shifted from constructive regularity proofs to
constructive blowup constructions.** Tao's averaging / cascade machinery
(originally a *negative* tool for regularity) is now being reused
*positively* to construct explicit singularities for related equations.

---

## 3. What is verified vs. disputed

### 3.1 Verified (high confidence; primary sources checked)

- **Coiculescu–Palasek 2026** paper exists at the cited DOI, with the
  cited author list (Coiculescu + Palasek; **Vlad Vicol is NOT an
  author** — a prior sub-agent's hallucination, corrected in
  `VERIFICATION_TABLE_2026-09-10.md`). Mechanism is Palasek's dyadic NS
  work, *not* convex integration. Result is non-uniqueness, not blowup.
- **Alpöge–Buckmaster** three preprints exist on cims.nyu.edu/~tristanb/,
  with the cited titles and authors. Per Buckmaster's own statement
  (cims.nyu.edu/~tristanb/statement.pdf), the underlying forced-blowup
  idea traces to Córdoba–Martínez-Zoroa.
- **OpenAI announcement** of 8 Sep 2026 is real; 166-page PDF at the
  cited URL; Lean repo at github.com/openai/NavierStokesAndEuler is
  public; targets Clay alternatives C/D per OpenAI's own statement.
- **Clay Mathematics Institute** has **not** accepted any of these as a
  resolution of the prize problem; the millennium page still lists the
  problem as open.
- **Tao 2019, Lange 2022, Barker–Prange 2023, Miller 2022, Buckmaster–Vicol
  2021** — all cited arXiv IDs and venues exist; abstracts and selected
  fragments reviewed.
- **Tao blog post 7 Sep 2026** is real and confirms the framing above.

### 3.2 Disputed / unverified

- **OpenAI's mathematical correctness.** No independent expert has
  publicly walked through all 166 pages. The MathOverflow discussion
  thread is open but has not delivered a verdict. OpenAI explicitly
  states they will *not* claim the Clay prize. Treat as
  "high-profile unverified announcement."
- **Whether OpenAI's models were trained on Buckmaster–Alpöge drafts.**
  OpenAI's Bubeck denies; Buckmaster says he was not given a clear
  answer. Unresolved.
- **Whether Alpöge–Buckmaster's preprints are peer-reviewed.** Posted
  ~5–6 Sep 2026; Buckmaster himself called the initial writeup
  ("rewritten") "the worst writeup we had ever seen in the history of
  mathematics." Lean formalisation not finished for one of three per
  Buckmaster.

### 3.3 Confidently *not* found

- **No paper takes Tao's no-go as input and uses *specific NS nonlinearity
  structure* (vorticity stretching, helicity conservation, Biot–Savart,
  Serrin-type condition) to prove a constructive regularity criterion
  for all smooth ICs.** Six years of post-Tao work (Lange, Coiculescu,
  Tao 2019, Buckmaster–Vicol, Buckmaster–Colombo–Vicol, Jin–Zhou
  withdrawn, etc.) confirm or strengthen the no-go, never defeat it.
- **No published analytic estimate of the form
  $\theta(t) \le C \cdot N^{-\alpha}$ for the spectral discretisation.**
  Haller 2024 gives $e^{-\beta t}$ (time); Grujić 2026 gives
  $(\log t)^{-1}$ (time). **The campaign's empirical
  $\alpha_\theta \in [0.7, 2.4]$ has no analytic counterpart.**
- **No new refinement of bare 3D Ladyzhenskaya on 𝕋³ in 2020–2026.**
  The frontier is weighted / fractional / higher-order. **No paper
  bridges the finite-mode-sum Ladyzhenskaya (`LadyzhenskayaDiscrete.lean`)
  to continuous-torus Ladyzhenskaya.** The natural "bridge paper" would
  be Riemann-sum convergence of spectral projections.

---

## 4. What the campaign's contribution is

### 4.1 What is honest and verified

1. **Lean formalisation of the truncated spectral NS scheme** — 160
   theorems across 11 files, 0 sorries, 1 irreducible axiom
   (`tao_averaged_blowup`). `lake build` succeeds.
2. **Numerical anti-blowup evidence** at resolutions $N \in \{64, 128, 192\}$,
   three IC families, time horizons $T \le 0.15$.
3. **Empirical Constantin–Iyer alignment confirmation** with
   $\theta(\omega_{\max}) \le 0.075 \text{ rad}$ and tightening at higher
   $N$ (5 of 6 cases).
4. **A new observation worth publishing** in its own right: the
   power-law $\alpha_\theta \in [0.7, 2.4]$ scaling of the alignment
   angle at the max-vorticity point with spectral resolution, which
   has **no analytic counterpart** in the literature.
5. **A formal infrastructure for the discrete-to-continuous bridge**
   (uniform-in-$N$ component in `UniformInN.lean`, discrete
   Ladyzhenskaya in `LadyzhenskayaDiscrete.lean`).

### 4.2 What is NOT contributed

1. **No solution to the Clay Millennium problem.** The discrete-to-
   continuous bridge is not closed; continuous NS at infinite resolution
   is out of scope.
2. **No contribution to OpenAI's claimed blowup proof.** The campaign
   does not engage with the claimed Theorem 1.1 of OpenAI's 166-page PDF.
3. **No direct engagement with Coiculescu–Palasek non-uniqueness.** The
   campaign formalises properties of *the* (truncated) NS solution, not
   properties of *non-unique* smooth solutions.
4. **No constructive regularity proof for unforced 3D NS.** That is
   exactly what the field has stopped trying to do (Sep 2026 paradigm
   shift); the campaign's Lean work uses Tao 2016 as a one-axiom encoding
   of this hard barrier.

### 4.3 What the campaign's framing now correctly captures

The campaign's choice of Tao's 2016 averaged-NS no-go as the irreducible
Lean axiom is **even more clearly aligned** with the post-Sep-2026
field than when the campaign started. The Alpöge–Buckmaster and OpenAI
programmes use cascade machinery to *construct* singularities; the
campaign uses the same machinery (Tao's averaging) to *prove a no-go*
on regularity proofs that use only harmonic analysis + energy. Both are
valid uses of the same underlying mathematics; the campaign's choice is
the conservative one that does not require belief in singularity
formation.

---

## 5. What would be needed for Clay (honest assessment)

### 5.1 What a Clay-level regularity proof would require

1. **A constructive regularity criterion for unforced 3D NS** (Clay
   problem statement, alternative A / B).
2. **OR** a constructive non-uniqueness proof for the Leray-Hopf
   solutions to unforced 3D NS (alternative D in some formulations;
   Coiculescu–Palasek gets close but uses forcing-like critical data).
3. **OR** a forced-blowup proof for unforced NS that survives rigorous
   peer review (Alpöge–Buckmaster + OpenAI claim this for *forced* NS;
   not yet for *unforced* NS).

### 5.2 What is missing in the current campaign

- **No Lean statement of a regularity criterion for continuous NS.** The
  campaign's Lean theorems are about the truncated scheme; the passage
  to continuous NS is a separate limit argument (Lions–Foias compactness
  or Kolmogorov–Riesz), not formalised.
- **No Lean proof of a discrete-to-continuous bridge.** The uniform-in-$N$
  component is one piece; the spectral-projection convergence to
  continuous Sobolev / Gagliardo–Nirenberg embedding is the missing
  complementary piece.
- **No identification of the Tao "finer structure."** Per Tao 2016, *some*
  such structure must exist for any proof; the campaign formalises three
  candidates (BdV integrability, CI alignment, vortex-stretching
  geometry) on the *truncated* scheme, but none has been shown to close
  the discrete-to-continuous gap.

### 5.3 What a future human contribution would look like

A realistic Clay-level contribution from the campaign's vantage point:

1. **Add Lean statements** of (a) the continuous Sobolev embedding
   $H^1(\mathbb{T}^3) \hookrightarrow L^4(\mathbb{T}^3)$ (Gagliardo–
   Nirenberg–Sobolev) and (b) a discrete-to-continuous compactness
   theorem. Both are large standalone projects.
2. **Use the existing Lean infrastructure** to attempt a Lean proof that
   one of the three "finer structure" candidates (BdV / CI /
   vortex-stretching) actually closes the discrete-to-continuous
   bridge. If such a proof exists, it would be the campaign's most
   leveraged next step.
3. **Engage with a human PDE researcher** who could identify a
   "finer structure" not in the three candidates above. The campaign's
   Lean code is structured so that adding a new regularity criterion
   requires only defining a new `BilinearNSLike`-like type and proving
   the analogue of `tao_no_go`.

### 5.4 What this campaign is honest about

The campaign does not solve Clay, does not contribute to OpenAI's claim,
does not directly engage with Coiculescu–Palasek non-uniqueness, and
does not bridge the discrete-to-continuous gap. **The Clay Millennium
problem remains open.** What this campaign *does* contribute is a
real, citable, formal-methods package for the truncated spectral NS
scheme and a publishable empirical observation (the $\alpha_\theta$
scaling) that has no analytic counterpart in the literature.

---

## 6. File pointers

| File | Contents |
|------|----------|
| `FIELD_MAP_2026.md` | Survey-level overview of the field as of Sep 2026 |
| `POST2016_SEARCH.md` | Paper-by-paper post-Tao-2016 follow-up inventory |
| `ALIGNMENT_DECAY_LITERATURE_2026.md` | 10-paper review of alignment-angle decay estimates |
| `CONVEX_INTEGRATION_LANDSCAPE_2026.md` | State-of-the-art convex-integration / h-principle programme |
| `CONTINUOUS_LADYZHENSKAYA_2020_2026.md` | Continuous-torus Ladyzhenskaya refinements, 2020–2026 |
| `VERIFICATION_TABLE_2026-09-10.md` | Independent verification of OpenAI / Alpöge–Buckmaster / Coiculescu–Palasek |
| `TAO_2016_NOGO.md` | Updated with §7 on the 2026 paradigm shift |
| `CONSTANTIN_IYER_FINDINGS.md` | Updated with §A on modern alignment analysis |
| `FINAL_REPORT.md` | Updated with "2026 field context" section |
| `manuscript/MANUSCRIPT.tex` | Updated with §6 limitations entry on Sep 2026 + 10 new bibliography entries |
| `manuscript/MANUSCRIPT.pdf` | Recompiled; 11 pages, 116.3 KiB |

---

*Document compiled for `ns_blowup/` at `/Users/hermes/.hermes/projects/ns_blowup/`.*
*Source: the five literature-mining sub-agent outputs listed above, plus direct reading of the cited arXiv / DOI / cims.nyu.edu / openai.com / springer.com / claymath.org primary sources.*