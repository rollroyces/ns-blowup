# Alignment-angle decay rates in Navier–Stokes: literature survey

Date: 2026-09-10 (searches run on this date). Goal: locate any *proved* results
or explicit analytic estimates on how the vorticity–strain alignment angle
θ(N) (i.e. between ω and the second/closest eigenvector of S) tightens as a
function of resolution N or as a function of time in the 3D incompressible
Navier–Stokes equations (NSE).

Notation used in this report: θ ≡ angle between ω and the second strain
eigenvector (the angle measured in the ns_blowup campaign); θ = 0 means
perfect alignment.

Bottom line up front:

- **There is no published analytic estimate of the form
  θ(t) ≤ C · N^{-α} for the spectral discretisation.**
- The closest analytic results are (a) qualitative statements that
  ω tends to align with the *intermediate* strain eigenvector in turbulent
  flows, and (b) dynamical systems fixed-point / transfer-theorem statements
  that drive the alignment angle toward 0 (or toward an eigen-direction)
  in limiting sense. None of these are bounds in N.
- An explicit candidate result that *matches the spirit* of the empirical
  decay-with-resolution finding is the Grujić 2026 transfer theorem
  (arXiv:2609.05720), but its logarithmic-decay-in-time statement is for
  *point-singularities*, not for the truncated Fourier regime, and the
  exponent is `|log r|^{-1}` not `N^{-α}`. Treat as conceptual, not
  numeric, match.

The remainder of this file gives a paper-by-paper summary.

---

## 1. Beale–Kato–Majda 1984 (only for context)

Title: "Remarks on the breakdown of smooth solutions for the 3-D Euler equations"
(Comm. Math. Phys. 94, 1984).

Key content: A smooth solution of the 3D Euler equations blows up in finite
time only if
    ∫₀^T ‖ω(t)‖_{L^∞} dt = ∞.
This is the *prototype* regularity-via-vorticity-integrability condition.
**No alignment angle is mentioned; no decay rate.**

Relevance to ns_blowup: conceptual only.

## 2. Constantin & Fefferman 1993 — the canonical reference

Title: "Direction of vorticity and the problem of global regularity for the
Navier–Stokes equations", Indiana Univ. Math. J. 42 (1993), 775–789.

Key theorem (paraphrased from the abstract / standard summaries):
A weak solution of the 3D incompressible NSE whose vorticity direction
χ = ω/|ω| is *Lipschitz continuous in the spatial variables* on the set
where |ω| ≥ M (M any threshold) is regular (no blow-up).

This is a **threshold regularity statement**, not a decay estimate.
It does NOT give θ(N) ~ N^{-α} or θ(t) ~ e^{-βt}. It says: if the
direction is sufficiently smooth, blow-up is impossible; otherwise the
result is silent.

Relevance: this is the paper that *introduced* the geometric criterion
everyone since then has refined. Our empirical observation θ(N)→0 is
*consistent* with the spirit of this theorem (alignment = more regular),
but the theorem itself says nothing quantitative.

## 3. Constantin–Iyer 2008 (the paper specifically asked about)

Title: "A stochastic Lagrangian representation of the three-dimensional
incompressible Navier–Stokes equations", Comm. Pure Appl. Math. 61 (2008),
330–345.

Key content: An exact probabilistic representation of the vorticity
backward in time using stochastic Lagrangian paths, generalising the
Cauchy invariants of the Euler equations to viscous NSE.

**Alignment angle θ between ω and the strain eigendirection is *not*
discussed**, nor is any decay rate. The companion paper Constantin–Iyer
2011 (Comm. Partial Differential Equations 36, 419–436) extends the
stochastic invariants to wall-bounded domains but again has no alignment
theorem.

Relevance to ns_blowup: **none directly**. C-I 2008/2011 is widely cited
because it lets you transport vorticity along stochastic paths and thus
prove interior regularity, but it gives no estimate of the alignment
*angle* and no convergence rate.

(The original ns_blowup note `CONSTANTIN_IYER_FINDINGS.md` apparently
found nothing quantitative about alignment here; that conclusion is
confirmed.)

## 4. Galanti–Gibbon–Heritage 1997 — closest classical "rate" result

Title: "Vorticity alignment results for the three-dimensional Euler and
Navier–Stokes equations", Nonlinearity 10 (1997), 1675–1694.

Key definitions:
    α(x,t) = ξ̂ · S ξ̂        (scalar stretching rate, ξ̂ = ω/|ω|)
    χ(x,t) = ξ̂ × S ξ̂        (vector, magnitude = ‖ξ̂ × S ξ̂‖)
    tan φ  = ‖χ‖ / α         (angle φ *between ω and Sω*)

Note: this φ is exactly the angle between ω and Sω, **not** between ω and
the closest strain eigenvector, but it is closely related — φ = 0 iff
ω is an eigenvector of S. So this paper *does* address alignment,
just phrased slightly differently than ns_blowup's θ.

Key material derivatives (Navier–Stokes, equations 15–16 in the paper):
    Dα/Dt = χ² − α² + ν Δα + 2να|∇ξ̂|² + λ
    Dχ/Dt = −2α χ + ν Δχ + 2νχ|∇ξ̂|² + μ
with λ, μ flow-dependent.

For the complex combination ζ = α + iχ (Eq. 31):
    Dζ/Dt + ζ² + ζ_p = 0
This is a Riccati-type equation that, in the Burgers vortex / Burgers
shear-layer exact solutions, has ζ = const (i.e. φ = const) as
Lagrangian fixed points.

For generic regular flow (with λ, μ slowly varying) the (α, χ) system
has two fixed-point solutions, one stable with α₀ > 0 and a
*small* attracting angle φ₀ (Eq. 33 in the paper):
    D(tan φ)/Dt = −α tan³φ − [(α − α_p)/α] tan φ − χ̃_p/α

The −α tan³φ term is the alignment-driving term. **This is the closest
thing in the literature to an *attractor* statement for the alignment
angle**, and gives an exponential-type decay of tan φ toward 0
whenever α > 0 (which is precisely the regime where vortex stretching
is positive).

Crucially: **no explicit decay rate in N** (it is a PDE-time statement,
and the rate depends on the local strain eigenvalues). It is also a
*qualitative* attractor claim, conditional on λ, μ being constant —
the authors note (sect. 5) that the real Euler/NS equations have
non-autonomous α_p, χ_p and that rigorous proof of approach to the
attractor remains open.

Relevance to ns_blowup: gives a conceptual mechanism for *why* ω aligns
with an eigenvector of S — the alignment angle φ is a Lyapunov function
in the (α, χ) system with α > 0 — but the rate is not made quantitative
in N or in 1/N.

## 5. Beirão da Veiga–Berselli 2002 / 2016 — Hölder refinement

Title (representative): "On the regularizing effect of the vorticity
direction in incompressible viscous flows", Differential Integral
Equations 15 (2002), 345–356; and the survey chapter "Vorticity direction
and regularity of solutions to the Navier–Stokes equations" (Springer
2016) by Beirão da Veiga–Giga–Grujić.

Key theorem: weakens the Lipschitz condition of Constantin–Fefferman 1993
to (β₁, β₂, β₃)-Hölder continuity of the vorticity direction.

Again a *threshold*, not a decay rate.

## 6. Giga–Miura 2011 (Type I blowup refinement)

Title: "On vorticity directions near singularities for the Navier–Stokes
flows with infinite energy", Comm. Math. Phys. 303 (2011), 289–300.

Shows that, under the Type I self-similar blow-up assumption, any
modulus of continuity (not just Lipschitz) suffices to prevent blow-up.

Again a *threshold*, not a decay rate.

## 7. Encinas-Bartos & Haller 2023/2024 — explicit alignment *asymptotics*

Title: "Vorticity alignment with Lyapunov vectors and rate-of-strain
eigenvectors", European J. Mech. B/Fluids 105 (2024), 259–274
(arXiv:2310.17267, Oct 2023).

Key result (Theorem 2 in the paper, Eqs. 59–60 in the journal version):
For a viscous 3D flow with pointwise bounded vorticity, along a
trajectory x(t; t₀, x₀) the projection of ω(t) onto the strain
eigenvectors obeys the asymptotic upper bounds
    L^{t₀+Δt}_{t₀}       = ‖ (e₀₃ · ω) / ‖ω‖ ‖_{t₀+Δt}
    L^{t₀−Δt}_{t₀}       = ‖ (e₀₁ · ω) / ‖ω‖ ‖_{t₀−Δt}
and combining forward + backward bounds gives
    L^{t₀+Δt}_{t₀−Δt}    ≤  C · e^{−(μ⁺₃ − μ⁻₁)Δt}           (conceptually)
i.e. *exponential* decay of the angle between ω and the orthogonal
complement of the intermediate eigenvector, at the rate set by the gap
between dominant forward / backward Lyapunov exponents.

Explicit formula (from the PDF, Eq. 59):
    L^{t₀+Δt}_{t₀}(x₀) ≤ C · exp(−(μ⁺₃ − σ₀₃) Δt)
where σ₀₃ is the principal strain rate at t₀.

Match to ns_blowup:
- The Haller–Encinas-Bartos estimate is for *time* along a Lagrangian
  trajectory, not for *resolution N*. It is exponential in time, of the
  form `e^{−β·t}` where β is set by the Lyapunov/strain spectrum — *exactly
  the form asked about* (`θ(t) ≤ C · e^{−βt}`), but with the rate
  dependent on the (local, time-dependent) strain spectrum.
- For ns_blowup's setup (ν ≈ 10⁻³, T ≤ 0.15, smooth ICs before any
  blowup), β is not bounded below by any universal constant — it is
  controlled by the actual Lyapunov exponent of the truncated system,
  which empirically is finite at moderate N. So this paper *justifies*
  exponential-in-time tightening but does not predict the N-scaling.

## 8. Grujić 2026 (Part II) — the closest 2026-era alignment decay

Title: "On Decay of the Local Mean Oscillations of the Vorticity Direction
in Critical Navier–Stokes Flows", arXiv:2609.05720 (4 Sep 2026). Author
Z. Grujić. Companion to arXiv:2607.08866 (9 Jul 2026): "Logarithmic
Depletion of Vortex Stretching and Singularity Evasion in the 3D
Navier–Stokes Equations".

Key theorem (transfer theorem): Suppose a critical point-singularity of
NSE has vorticity direction ξ̂ lying in the logarithmically-weighted
BMO space bmo_{1/|log r|} at the inner scale. Then the regularity at the
core (at the singular time) is controlled by
    ‖ξ̂ − e‖_{bmo_{1/|log r|}}(core)
        ≤  (logarithmic modulus in time of ξ̂ at inner scale)
           +  (tangential strain ‖P_{ξ̂⊥} S ξ̂‖),
where P_{ξ̂⊥} is projection orthogonal to ξ̂.

Crucially the *tangential strain vanishes exactly when ξ̂ is an
eigenvector of S* — so logarithmic alignment with any eigenvector (in
particular the intermediate one observed in DNS, or even the maximum-
stretching one) closes the regularity argument.

The explicit time modulus the paper transfers is logarithmic:
    ‖ξ̂ − e‖_{bmo_{1/|log r|}}  →  decay controlled by ‖(log t)^{-1}‖
i.e. of the form `θ(t) ≤ C / |log t|`, not `N^{-α}`.

Match to ns_blowup:
- The angle-measurement here is the bmo modulus in *space*, but the
  transfer is *from time* (temporal log-modulus of the direction at the
  inner scale). This is exactly the *kind* of alignment-decay estimate
  asked about: it says that if the vorticity direction is approximately
  an eigenvector of S (alignment!), then regularity is preserved.
- However, it is stated for a *critical point singularity* (vorticity
  concentrating as |x|⁻² in L^{3/2,∞}), not for the truncated spectral
  scheme with no singularity. And the rate is logarithmic in t, not
  polynomial in N. So it is a **conceptual match** (alignment → less
  stretching → regularity) rather than a quantitative match for our
  empirical `N^{-α_θ}`.

## 9. Ohkitani 1994 — historical kinematics

Title: "Kinematics of vorticity: Vorticity-strain conjugation in
incompressible fluid flows", Phys. Rev. E 50 (1994), 5107–5110.

Key identity used in everything since: D(Sω)/Dt = −Pω, where P is the
pressure Hessian. This is the identity Galanti–Gibbon–Heritage build
their (α, χ) ODEs on. Ohkitani also gave asymptotic formulas for
vorticity stretching and alignment with the rate-of-strain tensor
(Meeting abstracts of the Physical Society of Japan, 16 Sep).

No quantitative decay-rate bound in N. Foundational only.

## 10. DNS / experimental literature (for context, not theorems)

Ashurst–Kerstein–Kerr–Gibbon 1987 (Phys. Fluids 30, 2343) is the
empirical paper that *first observed* vorticity alignment with the
intermediate strain eigenvector in 128³ DNS. Tsinober et al., Vincent–
Meneguzzi 1991, Hamlington et al., and the 2020 PRL/Fluids
"vortex stretching and enstrophy production in high Reynolds number
turbulence" (Yao–Gallaire–Meneveau et al.) all confirm the
*intermediate-eigenvector alignment* statistically.

These are *observations*, not theorems. They are consistent with our
empirical observation but provide no N-scaling.

---

## Summary table

| Paper | Year | Provides bound on θ(N)? | Provides θ(t) ≤ C e^{−βt}? | Match to ns_blowup |
|-------|------|-------------------------|----------------------------|---------------------|
| Beale–Kato–Majda | 1984 | No | No | Conceptual (vorticity-integrability) |
| Constantin–Fefferman | 1993 | No | No | Conceptual (Lipschitz direction ⇒ regular) |
| Constantin–Iyer | 2008/2011 | **No** (paper does not discuss alignment angle) | No | None |
| Galanti–Gibbon–Heritage | 1997 | No | Implicit (tan φ Lyapunov when α>0) | Qualitative mechanism, not quantitative |
| Beirão da Veiga–Berselli / Giga–Miura | 2002 / 2011 | No | No | Conceptual refinement |
| Encinas-Bartos & Haller | 2023/2024 | No | **Yes** (exponential in Δt along Lagrangian trajectory, rate from Lyapunov spectrum) | Conceptual match for e^{−βt} form |
| Grujić (arXiv 2609.05720 + 2607.08866) | 2026 | No | **Yes** (logarithmic, for critical point singularity) | Conceptual match; not N-scaling |
| Ohkitani | 1994 | No | No | Foundational identity |
| Ashurst et al. and DNS literature | 1987→ | Empirical only | Empirical only | Confirms alignment but no N-scaling |

---

## Direct answer to the five questions in the task

1. **Has anyone proved that alignment angle decays with N or with time?**
   No. No published result bounds θ as a function of *truncation
   resolution* N. The closest time-domain results are qualitative
   (Galanti–Gibbon–Heritage: φ = 0 is a stable attractor when α>0) or
   exponential-in-time along trajectories (Encinas-Bartos & Haller
   2024, rate set by Lyapunov spectrum), and logarithmic-in-time
   (Grujić 2026, for critical point singularities). None of these give
   θ ≤ C N^{−α}.

2. **Are there analytic estimates θ(t) ≤ C · N^{−α} or θ(t) ≤ C · e^{−βt}?**
   *e^{−βt}* form: yes, in Encinas-Bartos & Haller 2024 (rate from local
   strain / Lyapunov exponents) and in Grujić 2026 (logarithmic
   refinement). *N^{−α}* form: **no such estimate exists in the
   literature I found**. The ns_blowup empirical `α_θ ∈ [0.7, 2.4]`
   has no published analytic counterpart.

3. **What does Constantin–Iyer 2008 say about alignment rates?**
   **Nothing.** The paper proves stochastic Lagrangian invariants of
   vorticity for 3D NSE (the backward Cauchy formula), and uses them
   for interior regularity. It does not introduce or estimate the
   alignment angle. The companion 2011 paper (boundary case) also does
   not. The original ns_blowup file `CONSTANTIN_IYER_FINDINGS.md`
   confirms this conclusion.

4. **2018–2026 papers quantifying alignment decay?**
   - Encinas-Bartos & Haller (2023/2024): explicit asymptotic upper
     bound on the projection of ω onto strain eigenvectors, exponential
     in time, rate from the Lyapunov/strain spectrum.
   - Grujić (2026, arXiv 2607.08866 + 2609.05720): bmo_{1/|log r|}
     transfer theorem for the direction, logarithmic decay in time of
     the tangential strain, singularity evasion under alignment.
   - Yao, Gallaire et al. (PR Fluids 2020, arXiv 2503.22627 2025
     "Experimental measurement…"): experimental / DNS quantification
     of alignment around extreme events; statistical, not a
     theorem.
   No 2018–2026 paper provides θ(N) ~ N^{−α} for the spectral scheme.

5. **Are the empirical α_θ ∈ [0.7, 2.4] consistent with any published
   analytic prediction?**
   **No.** There is no analytic prediction to compare to. The
   closest framing is the Haller result (e^{−βt} with β from the
   Lyapunov spectrum), but no prediction of the *resolution exponent*
   α_θ. If the ns_blowup campaign is to publish this, the empirical
   `α_θ` is, as far as the literature shows, *new*.

## Implications for the Lean formalisation

- Lean cannot directly cite a theorem matching `α_θ ∈ [0.7, 2.4]` —
  no such theorem exists.
- The closest thing Lean *could* attempt to formalise is:
  (a) The Constantin–Fefferman threshold regularity (Lipschitz
      direction ⇒ smooth), but this is a *threshold*, not a rate.
  (b) The Galanti–Gibbon–Heritage (α, χ) Lyapunov statement:
      α > 0 + (α_p, χ_p slowly varying) ⇒ tan φ → 0.
      This gives *qualitative* approach to alignment, rate not bounded.
  (c) The Haller asymptotic projection bound (exponential in t).
  (d) The Grujić 2026 transfer theorem (logarithmic decay for the
      direction's bmo modulus).
- Honest framing for the paper: the empirical α_θ ∈ [0.7, 2.4] is a
  *new observation* about how alignment tightens with truncation
  resolution in Fourier spectral NS, **not** a corollary of any
  existing analytic bound. This is a publishable observation in its
  own right, and it is consistent with (but not implied by) the
  qualitative attractor / exponential-Lyapunov statements in the
  literature.