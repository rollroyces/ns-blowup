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

## 7. References

- Tao, T. (2016). *Finite time blowup for an averaged three-dimensional Navier–Stokes equation.* arXiv:1402.0290v3.
- Constantin, P., & Iyer, G. (2008). *A blow-up criterion for the 3D Navier–Stokes equations.* arXiv:0802.0301.
- Beirao da Veiga, H. (1995). *A new regularity class for the Navier–Stokes equations in $\mathbb{R}^n$.* Chinese Annals of Mathematics.
- Serrin, J. (1962). *On the interior regularity of weak solutions of the Navier–Stokes equations.* Archive for Rational Mechanics and Analysis.
- Caffarelli, L., Kohn, R., & Nirenberg, L. (1982). *Partial regularity of suitable weak solutions of the Navier–Stokes equations.* CPAM 35.

---

*Document compiled for the `ns_blowup` project at `/Users/hermes/.hermes/projects/ns_blowup/`.*
*Source: arXiv:1402.0290 abstract + introduction (read via web fetch on 2026-09-07).*
