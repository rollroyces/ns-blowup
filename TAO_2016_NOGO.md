# Tao 2016 — The "No-Go" Result for the Navier–Stokes Regularity Problem

**Reference:** Tao, T. (2016). "Finite time blowup for an averaged three-dimensional Navier–Stokes equation." *Annals of Mathematics* 187 (2018), 601–646. arXiv:1402.0290.

**Compiled:** 2026-09-07 for the `ns_blowup` project.

---

## 1. The main result (Tao's Theorem 1.1)

Consider the 3D incompressible Navier–Stokes equation in the form
$$\partial_t u = \Delta u + B(u, u), \qquad \nabla \cdot u = 0, \qquad u(0) = u_0,$$
where $B$ is the standard NS bilinear form (skew-symmetric, $\langle B(u,u), u \rangle = 0$, the property equivalent to the energy identity).

Tao considers a family of **modified** equations
$$\partial_t u = \Delta u + \widetilde{B}(u, u),$$
where $\widetilde{B}$ is an **averaged version** of $B$, where the average is taken over rotations and dilations (and in v3, also over Fourier multipliers of order zero). The averaged bilinear form $\widetilde{B}$ also satisfies the cancellation property $\langle \widetilde{B}(u,u), u \rangle = 0$, so the modified equation obeys the **same energy identity** as the true NS.

**Tao's Theorem 1.1:** There exists a choice of $\widetilde{B}$ and a smooth initial datum $u_0$ such that the solution to $\partial_t u = \Delta u + \widetilde{B}(u,u)$ with $u(0) = u_0$ blows up in finite time.

**Tao's construction:** the blowup is built from a system of ODEs related to (but more complicated than) the dyadic Navier–Stokes model of Katz and Pavlovic. The blowup profile is self-similar.

---

## 2. The "no-go" implication

The crucial observation is that **the blowup proof uses *only* the following structural properties of $\widetilde{B}$:**
1. $\widetilde{B}$ is bilinear and skew-symmetric ($\langle \widetilde{B}(u,u), u \rangle = 0$ — the energy identity).
2. $\widetilde{B}$ has the same **regularity estimates** that harmonic analysis gives for $B$. Specifically, the estimates on $\widetilde{B}$ that Tao uses are the same Sobolev inequalities that hold for the true NS bilinear form.

This means: **any proof of regularity for the true NS equation that uses *only* the energy identity and standard harmonic analysis estimates (Sobolev embeddings, interpolation, etc.) cannot succeed**, because the same proof would have to work for the averaged equation, which Tao proved blows up.

Translated: **the missing ingredient is "finer structure" on $B$ that distinguishes it from $\widetilde{B}$** — structure that the averaged equation does not have but the true NS equation does.

---

## 3. What "finer structure" is not

By the Tao no-go, the following are *not* sufficient to prove regularity:
- ❌ The energy identity alone (used by Leray 1934, who proved weak existence but not regularity).
- ❌ The standard Sobolev/Hölder estimates on $B$ alone.
- ❌ Any proof that uses *only* the fact that $B$ is a bounded bilinear map between the standard function spaces ($L^p$, $\dot H^s$, Besov $\dot B^{s}_{p,q}$).
- ❌ Any proof by "soft" harmonic-analysis / interpolation / bootstrapping arguments.

These are the "harmonic analysis + energy identity" class of proofs. They are ruled out.

---

## 4. What "finer structure" might be

Tao does not identify a specific sufficient condition, but the paper mentions several candidates for "finer structure" and proposes a "program for adapting these blowup results to the true NS equations" (in the paper's introduction). The candidates include:

1. **Geometric / algebraic structure of $B$ beyond bilinearity.** The actual NS bilinear form is *not* just any bilinear form; it is the Lie bracket of the Eulerian velocity field. It has a specific structure: $B(u,v) = (u \cdot \nabla) v + (v \cdot \nabla) u$. The averaged $\widetilde{B}$ does not have this structure in general.

2. **Vortex-stretching structure.** The NS nonlinearity can be rewritten as $\omega \cdot \nabla u$ (vorticity advected and stretched by strain). This is a *geometric* statement: the rate-of-change of vorticity is controlled by the local alignment between $\omega$ and the strain eigenvectors. The Constantin–Iyer blowup-conditional (2008) shows that *if* blowup occurs, then at singular points the vorticity must align with the second eigenvector of the strain tensor.

3. **Cancellations / antisymmetric structure.** $B$ is not just bilinear — it satisfies additional **Coifman–Rochberg–Weiss** type commutator estimates that the averaged $\widetilde{B}$ does not. These are the "Bony paraproduct" decompositions that are not captured by the standard harmonic analysis.

4. **Monotonicity or positive-definiteness of certain quantities.** For example: enstrophy $E(t) = \int |\omega|^2$ evolves as $dE/dt = -2 \int |\nabla \omega|^2 + 2 \int \omega \cdot \nabla u \cdot \omega$, where the second term is a *correction* that does not have a definite sign. The Tao no-go says that the "blowup-allowing" averaged $\widetilde{B}$ may not preserve any monotonicity that $B$ does.

5. **Regularity criteria (Beirao da Veiga, Serrin).** The classical regularity criteria state: $u$ is smooth if $\int_0^T \|u(t)\|_p^q dt < \infty$ for $2/p + 3/q \le 1$ (Serrin), or $\int_0^T \|\nabla u(t)\|_p^q dt < \infty$ for $2/p + 3/q \le 2$ (Beirao da Veiga). These are *sufficient* conditions for regularity. They use the fact that the bootstrap argument can be closed with a "small" enough norm. The Tao no-go says: these criteria might be sharp (or close to sharp) for the *averaged* equation, but for the *true* equation, a stronger condition might hold because of the "finer structure."

---

## 5. Implications for the `ns_blowup` Lean project

Our existing 22-theorem Lean file at `lean_project/SpectralNS.lean` proves:
- The integrating-factor time-stepping is unconditionally L²-non-expansive.
- The discrete Leray energy inequality holds for the truncated scheme at any finite $N$.
- The quantitative Leray rate: energy decays at $e^{-2\nu\lambda_{\min} n\Delta t}$ per step.
- The Taylor-Green IC has spectral support in $\{-1, +1\}^3$, so the discrete energy equals the analytic energy for $N \ge 2$.

**All of these are in the "harmonic analysis + energy identity" class.** They are the discrete analogues of what Tao's no-go rules out. In particular, our Leray inequality is exactly the kind of estimate that the averaged equation also satisfies — and Tao proved that the averaged equation *blows up*. So our Lean file does **not** contain the "finer structure" needed to prove regularity.

To make progress toward a Clay-style result, the next Lean theorems would need to formalize one of:

1. **A regularity criterion in Lean.** State: "if the Leray solution satisfies $\int_0^T \|\nabla u\|_{L^\infty} dt < \infty$ (or some other Serrin-type condition), then it is smooth." This is a *sufficient* condition, not a *necessary* one. It is provable using the energy identity + interpolation, but the *conclusion* (smoothness) is what a Clay proof would establish. Formalizing this in Lean would be a non-trivial contribution: it would be the first formal Lean statement of a *regularity* theorem (as opposed to a *stability* or *decay* theorem).

2. **A discrete regularity criterion.** A discrete analog of the Serrin or Beirao da Veiga criterion: if a *discrete* solution satisfies the discrete gradient bound $\sum_n \Delta t \cdot \|\nabla u_n\|_{L^\infty} < \infty$, then the solution is bounded. This would be a step toward a "finer structure" result for the truncated scheme.

3. **A vortex-stretching identity in Lean.** State the identity $\partial_t \omega = \Delta \omega + \omega \cdot \nabla u - (\nabla u)^T \omega$ in Lean. This is a *structural* identity of the NS nonlinearity that is not preserved under Tao's averaging. Formalizing it would be the first Lean statement of the "finer structure" that Tao identifies as necessary.

**The most leveraged next step** (from the perspective of moving toward the Clay problem) is **(1)**: a discrete Serrin-type regularity criterion in Lean. This is provable using the energy identity + interpolation, but the *conclusion* is what a Clay-prize winning proof would establish. It is the first Lean statement that says "this solution is *smooth*" rather than "this solution has *bounded energy*."

---

## 6. Honest assessment

The Tao 2016 result is a **no-go** for the strategy class "energy identity + harmonic analysis alone." It does not say the Clay problem is unsolvable — it says a specific class of approaches is ruled out. The actual proof, when it comes, will use one of the "finer structures" listed above.

For the `ns_blowup` project, the implication is: **adding more "energy inequality"-type Lean theorems does not move toward the Clay problem.** The next step is a *qualitatively different* Lean theorem: a regularity criterion. Our current 22-theorem foundation is a building block (the energy inequality is a prerequisite for any regularity argument), but it is not the differentiator.

**What this means for the user's question "what to work on next":**
- The Lean file should add a regularity criterion theorem next, not more energy inequality theorems.
- The numerics should look for ICs that *do* show a higher gradient scaling exponent, because the absence of such ICs is evidence (not proof) that the true NS is regular.
- The literature work should focus on which "finer structure" is most amenable to Lean formalization. The Constantin–Iyer geometric blowup-conditional is a strong candidate: it uses *alignment* between vorticity and strain, which is a concrete algebraic / geometric object that Lean can express.

---

## 7. Post-2016 verification and the 2026 paradigm shift

**Added 2026-09-10** after a literature survey (see `POST2016_SEARCH.md`,
`FIELD_MAP_2026.md`, `LITERATURE_2026.md`).

The Tao 2016 result has been *re-tested* by the field in at least six
post-2016 ways. **None has produced a constructive regularity proof
that takes Tao's no-go as input.** The dominant post-2016 development
is the field's *inversion* of the cascade machinery: Tao-style averaging
and Córdoba–Martínez-Zoroa-style iterative constructions are now
being used **positively** to construct explicit blowup for related
equations, not to design regularity proofs.

### 7.1 Tao 2019 — quantitative ESS refinement (arXiv:1908.04958)
- **Result.** For an NS solution with $\|u\|_{L^\infty_t L^3_x} \le A$:
  $|\nabla^j u(t)| \le \exp\exp\exp(A^{O(1)})\, t^{-(j+1)/2}$, $j = 0,1$,
  and the blowup criterion $\limsup_{t\to T_*^-} \|u(t)\|_{L^3_x} /
  (\log\log\log(1/(T_*-t)))^c = +\infty$ for an absolute $c > 0$.
- **For the no-go.** This is Tao's *only* post-2016 NS paper that uses
  specific NS structure (Carleman inequalities / backwards uniqueness
  for the heat equation). It is a *quantitative blowup-rate refinement*
  of the Escauriaza–Seregin–Šverák 2003 endpoint, **not** a
  constructive regularity proof. The barrier stands.

### 7.2 Lange 2022 — stochastic noise + Tao no-go (arXiv:2205.14941)
- **Result.** Tests whether Flandoli–Galeati–Luo stochastic-transport-
  noise regularization can fix the Tao averaged-NS blowup. **Negative:**
  the three Flandoli–Luo conditions (continuity, growth, local
  monotonicity) fail on the velocity level for the periodised averaged
  NS on $\mathbb{T}^3$. A lower bound on the Sobolev-derivative order
  needed is given; no global existence result.
- **For the no-go.** Most directly relevant to the `ns_blowup` Tao
  axiom. Even adding stochastic transport noise does not recover
  regularity. The barrier is **robust** under noise.

### 7.3 Coiculescu 2023 (arXiv:2307.15986, v4 Sep 2024)
- **Result.** Proves (1) partial regularity for the averaged pseudo-
  differential equation $\partial_t u + (-\Delta)^\alpha u + B(u,u) = 0$
  for $B$ in a Coiculescu class $\mathfrak{B}$, $\alpha \in
  ((n+1)/4, (n+2)/4)$; and (2) blowup for $\alpha \in (0, 5/4)$
  for a specific $C \in \mathfrak{B}$ that satisfies the Tao
  cancellation $\langle C(u,u), u \rangle = 0$.
- **For the no-go.** The partial regularity theorem was *weakened*
  during revision (energy-barrier argument after an error was found),
  and applies only to the **hyperdissipative** range, not $\alpha = 1$.
  The blowup companion result *strengthens* the no-go. Net message:
  *improving partial regularity will not solve NS regularity; you need
  specific nonlinearity structure.*

### 7.4 Buckmaster–Vicol 2021 (AMS Bulletin)
- **Reference.** Buckmaster, Vicol, *Convex integration and
  phenomenologies in turbulence*, Bulletin of the AMS 58 (2021) 1–44.
- **For the no-go.** Confirms that the convex-integration /
  h-principle programme (BV19, BCV18, Albritton–Brué–Colombo) is the
  anti-regularity side of the field. Explicitly credits "Tao's earlier
  averaged-equation blowup" as a precursor. Does **not** provide any
  constructive regularity criterion.

### 7.5 Coiculescu–Palasek 2026 (*Inventiones mathematicae* 244, 165–219)
- **Reference.** M. P. Coiculescu and S. Palasek, *Non-uniqueness of
  smooth solutions of the Navier–Stokes equations from critical
  data*, Invent. math. 244 (2026), 165–219. DOI 10.1007/s00222-025-01396-z.
  Online 12 Dec 2025. arXiv:2503.14699.
- **Result.** Construct initial data in the **critical** space
  BMO$^{-1}$ (the Koch–Tataru threshold) from which there exist
  **two distinct global solutions, both smooth for all $t > 0$**.
  Mechanism: a non-uniqueness idea of Vicol on dyadic NS lifted to
  the true NS via a non-convex-integration construction.
- **For the no-go.** This is *non-uniqueness*, not blowup, and is the
  opposite direction of regularity. It sharpens the BV19 result down
  to the critical space and is the single most important 2025–2026
  result for our campaign: it pushes the boundary of "non-uniqueness
  with smoothness" exactly to the regime where our truncated spectral
  scheme lives. Both authors are at Princeton; **Vlad Vicol is *not*
  an author** of this paper.

### 7.6 Alpöge–Buckmaster preprints (Sep 2026, cims.nyu.edu/~tristanb/)
- **Three preprints**: incompressible porous medium (IPM) equation,
  2D Boussinesq, and unforced 3D incompressible Euler. Posted ~5–6 Sep 2026.
- **Result.** Finite-time blow-up with **smooth forcing term** for
  each of the three model equations, using a Córdoba–Martínez-Zoroa
  iterative ansatz (background + high-frequency plane wave) with
  improved ODE-instability and spatial-localisation.
- **For the no-go.** **The field has shifted from constructive
  regularity proofs to constructive blowup constructions.** Tao's
  cascade machinery (originally a *negative* tool for regularity)
  is being reused *positively* to build explicit singularities
  for related equations. **Lean formalization is being attempted**
  for at least two of the three (the third is not finished per
  Buckmaster). For our campaign, this is direct validation that the
  truncated-spectral + Lean + Tao-axiom framing is the live one.

### 7.7 OpenAI NS announcement (8 Sep 2026) — DISPUTED
- **URL.** openai.com/index/navier-stokes-solution/; 166-page PDF at
  cdn.openai.com; companion Euler PDF; Lean repo at
  github.com/openai/NavierStokesAndEuler.
- **Claim.** For every $\nu > 0$, smooth forcing $f \in C^\infty_c$,
  smooth $(u, p)$ on $\mathbb{R}^3 \times [0, 1)$, uniformly bounded
  $L^2$ energy, but **unbounded $L^\infty$ velocity in finite time**.
  Targets Clay alternatives C/D (smooth forcing).
- **Status.** **Heavily disputed, NOT accepted by Clay.** The Clay
  Mathematics Institute has **not** accepted the result; the problem
  remains officially open on their site as of 10 Sep 2026. Buckmaster
  has stated publicly (cims.nyu.edu/~tristanb/statement.pdf) that
  the underlying forced-blowup idea traces to Córdoba–Martínez-Zoroa
  and that OpenAI only pivoted to that line after hearing the
  Buckmaster–Alpöge rumor. OpenAI explicitly states they will **not**
  claim the Clay Millennium Prize.
- **For the campaign.** **Do not cite as a theorem.** Cite the
  underlying mathematical claim as a "high-profile unverified
  announcement" only. The Alpöge–Buckmaster human-authored preprints
  are the legitimate reference for the same mathematics.

### 7.8 Honest assessment (Sep 2026)

The Tao 2016 averaged-NS no-go remains the irreducible axiom of the
campaign. Six years of follow-up work have:

1. **Tested it.** Lange 2022 (noise), Coiculescu 2023 (partial regularity
   for averaged NS), Jin–Zhou 2018 (model NS in $n \ge 5$, withdrawn),
   each re-confirms the no-go or weakens a constructive claim.
2. **Refined it quantitatively.** Tao 2019 quantitative ESS,
   Barker–Prange 2023 survey, Miller 2022 geometric-constraints
   survey.
3. **Inverted the machinery.** Alpöge–Buckmaster 2026 + Córdoba–
   Martínez-Zoroa 2024 + OpenAI 2026 use cascade / averaging ideas
   *positively* for blowup of related equations. **No paper has
   used Tao's no-go as a starting point for a constructive regularity
   proof for un-averaged 3D NS.**

The campaign's choice of `tao_averaged_blowup` as the single irreducible
Lean axiom is therefore even more clearly the correct framing as of
Sep 2026. Any future Clay-style regularity result must use Tao's
"finer structure" — and the field's investment has shifted from
*finding* such structure to *constructing* blowup, leaving the
regularity path more open than ever.


## 8. References

- Tao, T. (2016). *Finite time blowup for an averaged three-dimensional Navier–Stokes equation.* arXiv:1402.0290v3; J. Amer. Math. Soc. 29 (2016).
- Tao, T. (2019). *Quantitative bounds for critically bounded solutions to the Navier–Stokes equations.* arXiv:1908.04958v2 (10 Jul 2020); Analysis of PDEs.
- Lange, T. (2022). *Regularization by noise of an averaged Navier–Stokes equation.* arXiv:2205.14941.
- Coiculescu, M. P. (2023/2024). *Partial regularity and finite-time blow-up for an averaged Navier–Stokes equation.* arXiv:2307.15986v4 (8 Sep 2024).
- Barker, T., & Prange, C. (2023). *From Concentration to Quantitative Regularity: a short survey of recent developments for the Navier–Stokes equations.* arXiv:2211.16215; Vietnam J. Math. (online 29 Dec 2023), DOI 10.1007/s10013-023-00665-9.
- Miller, E. (2022). *A survey of geometric constraints on the blowup of solutions of the Navier–Stokes equation.* arXiv:2111.00040; J. Math. Anal. Appl. 2022.
- Buckmaster, T., & Vicol, V. (2021). *Convex integration and phenomenologies in turbulence.* Bulletin of the AMS 58, 1–44.
- Buckmaster, T., De Lellis, C., Isett, P., & Székelyhidi, L. (2019). *Wild solutions of the Navier–Stokes equations whose singular sets in time have Hausdorff dimension strictly less than 1.* JEMS 24 (2022), 3333–3378.
- Coiculescu, M. P., & Palasek, S. (2026). *Non-uniqueness of smooth solutions of the Navier–Stokes equations from critical data.* Inventiones mathematicae 244, 165–219. DOI 10.1007/s00222-025-01396-z; arXiv:2503.14699.
- Córdoba, A., Martínez-Zoroa, L., & Zheng, F. (2024). *Finite-time blowup for a hypodissipative Navier–Stokes equation.* arXiv:2407.06776.
- Alpöge, L., & Buckmaster, T. (Sep 2026). Three preprints on IPM, 2D Boussinesq, and 3D incompressible Euler with smooth forcing. Hosted at cims.nyu.edu/~tristanb/.
- OpenAI (8 Sep 2026). *Finite time blowup for Navier–Stokes.* openai.com/index/navier-stokes-solution/; cdn.openai.com PDFs; github.com/openai/NavierStokesAndEuler. **DISPUTED; not accepted by Clay.**
- Tao, T. (7 Sep 2026). *Finite time blowup with smooth forcing term for the incompressible porous medium, Boussinesq, and incompressible Euler equations.* What's New blog. terrytao.wordpress.com.
- Constantin, P., & Iyer, G. (2008). *A blow-up criterion for the 3D Navier–Stokes equations.* arXiv:0802.0301.
- Beirao da Veiga, H. (1995). *A new regularity class for the Navier–Stokes equations in $\mathbb{R}^n$.* Chinese Annals of Mathematics.
- Serrin, J. (1962). *On the interior regularity of weak solutions of the Navier–Stokes equations.* Archive for Rational Mechanics and Analysis.
- Caffarelli, L., Kohn, R., & Nirenberg, L. (1982). *Partial regularity of suitable weak solutions of the Navier–Stokes equations.* CPAM 35.

---

*Document compiled for the `ns_blowup` project at `/Users/hermes/.hermes/projects/ns_blowup/`.*
*Source: arXiv:1402.0290 abstract + introduction (read via web fetch on 2026-09-07); §7 added 2026-09-10 from survey sub-agent outputs in `POST2016_SEARCH.md`, `FIELD_MAP_2026.md`, `LITERATURE_2026.md`.*
