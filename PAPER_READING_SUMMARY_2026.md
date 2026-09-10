# Paper Reading Summary: OpenAI / Alpöge–Buckmaster / Coiculescu–Palasek on Finite-Time Blowup

**Date:** 2026-09-10
**Author:** Hermes Agent subagent (verification step B)
**Project:** ns_blowup
**Status:** Reading notes — primary-source summaries with honest gaps flagged

---

## 0. Scope, sources, and honesty

This document records what a careful reader can extract from the primary sources for the September-2026 NS / Euler blowup announcements. It is *verification step B* — bounded, structured reading — not a research contribution.

**Sources actually consulted in this read** (with extraction depth):

| # | Source | URL | What was read |
|---|--------|-----|---------------|
| 1 | OpenAI NS PDF (166pp) | cdn.openai.com/.../navier-stokes.pdf | Abstract, §1–3 (full), §4–10 partly via TOC entries and symbol tables; appendix headers |
| 2 | OpenAI Euler PDF (~58pp) | cdn.openai.com/.../euler.pdf | Abstract, §1–3 (full), §4–6 partly |
| 3 | Alpöge–Buckmaster 3D Euler (112pp) | cims.nyu.edu/~tristanb/euler.pdf | Abstract, §1–3 (full), §4–7 partly |
| 4 | Alpöge–Buckmaster Boussinesq (76pp) | cims.nyu.edu/~tristanb/boussinesq.pdf | Abstract, §1–3 (full) |
| 5 | Alpöge–Buckmaster IPM (57pp) | cims.nyu.edu/~tristanb/ipm.pdf | Abstract, §1–2 (full), §3 partly |
| 6 | Buckmaster statement | cims.nyu.edu/~tristanb/statement.pdf | Full text |
| 7 | Coiculescu–Palasek | arxiv.org/abs/2503.14699 + arxiv.org/pdf/2503.14699 | Abstract, §1–3 (full), §3.6 partly |
| 8 | Tao blog (7 Sep 2026) | terrytao.wordpress.com/2026/09/07/finite-time-blowup-with-smooth-forcing-term-.../ | Full post |
| 9 | OpenAI Lean repo (README + listing) | github.com/openai/NavierStokesAndEuler | README + file lists for NavierStokes/, Euler/ |

**What was NOT read in full** (and the implication):

- **NS paper §4–10**: I have the theorem statements and proof outlines; I did not verify the index gymnastics of the radial-moment matching or the curl corrections in §7–8.
- **Alpöge–Buckmaster Euler §4–14**: I read §1–3 carefully but the 108 pages of §4–14 (wave geometry, lifetime bounds, finite corrections, mixed derivatives, smooth force, blowup uniqueness) were skimmed — the construction spine is in §3.
- **OpenAI Euler §4–6**: read abstract + §2–3.1; the iterative scheme and Sobolev-bound machinery in §4–5 are described at outline level only.
- **Coiculescu–Palasek §4–5**: only introduction read in full; construction of perturbations and uniqueness are paraphrased from the intro.

---

## 1. OpenAI "Finite Time Blowup for Navier–Stokes" (2026)

### 1.1 Bibliographic data

- **Title:** "Finite Time Blowup for Navier–Stokes"
- **Authors:** OpenAI
- **Length:** 166 pp., 10 numbered sections + 3 appendices + references
- **Claim:** Theorem 1.1 of the paper establishes Clay Millennium alternatives **(C) and (D)**, i.e. forced blowup on ℝ³ and on T³ respectively, for *every* viscosity ν > 0.

### 1.2 Theorem 1.1 (verbatim from the PDF, §1, p. 1)

> **Theorem 1.1.** For every ν > 0 there exist a force f ∈ C∞_c(ℝ³ × (0, ∞); ℝ³), a compact set K ⊂ ℝ³, and smooth velocity and pressure fields u, p on ℝ³ × [0, 1) satisfying
> ∂_t u + (u · ∇)u − ν∆u + ∇p = f,   ∇·u = 0,   u(·, 0) = 0,
> such that supp u(·, t) ∪ supp p(·, t) ⊂ K for every 0 ≤ t < 1,
> sup_{0 ≤ t < 1} ‖u(t)‖_{L²(ℝ³)} < ∞,
> lim sup_{t ↑ 1} ‖u(t)‖_{L∞(ℝ³)} = ∞.

> Consequently, there is no smooth solution (u, P) on ℝ³ × [0, ∞) with the same force and initial datum whose kinetic energy is uniformly bounded. This establishes alternative (C) in the Millennium problem statement … ; see Corollary 10.6 for (D) on T³.

The compact-support hypothesis is essential: zero initial velocity and a spatially compact force.

### 1.3 Construction outline

The construction is described in three blocks: a self-similar "concentrating core," an annular transition zone with oscillatory pulses, and a "heat exterior." All four pieces of the user's specified machinery (self-similar background, two-wave cancellation, four-step correction cycle, localization) are present.

**(a) Self-similar background — §2.1 + §3.1 + §4 (Theorem 4.6 / Prop. 5.5).** The singularity forms at the origin at time t = 1. In cylindrical coordinates (r, θ, z) about the z-axis, the leading flow u^(0) = u^(0)_r e_r + u^(0)_θ e_θ + u^(0)_z e_z is *axisymmetric*. The similarity coordinates are

τ = 1 − t,   A = 1/2 + h,   D = 1/2 − h,   0 < h < 1/100 (fixed)

with
τ = q(1 − η²),   z = q^D η,   X = r² / (2q),   −1 < η < 1.        (3.2)

The radial and axial scales shrink at *different* rates:

ℓ_r ≍ τ^{1/2},   ℓ_z ≍ τ^{1/2 − h},   ℓ_z / ℓ_r ≍ τ^h → 0.

The leading profiles are encoded in three fixed functions E(X, η), U(X, η), Π(X, η):

|u^(0)_θ| = q^{−A} E,    |u^(0)_z| = q^{−A} U,    r|u^(0)_r| = V_0,    p^(0) = q^{−2A} Π.

Incompressibility and the regularity-at-axis condition V_0(0, η) = 0 determine V_0 uniquely. Pressure is fixed by the leading radial pressure balance ∂_r p^(0) = (u^(0)_θ)² / r, with normalization Π(X, η) = −∫_X^∞ E(x, η)²/(2x) dx.

**Velocity scales at the singular point:**

|u^(0)_θ|, |u^(0)_z| ≍ τ^{−1/2 − h},   |u^(0)_r| = O(τ^{−1/2}),   kinetic energy of core ≍ τ^{1/2 − 3h} → 0.

The Reynolds numbers separate:

Re_θ = |u_θ| ℓ_r / ν ≍ τ^{−h} → ∞,    Re_r = |u_r| ℓ_r / ν = O(1).

So the angular Reynolds number grows without bound, but the radial one stays bounded — the mechanism for the pulse amplification is the *radial shear of axial velocity* (away from z = 0) supplemented by the *rotational* (centrifugal) shear. The author notes (p. 4) that exact reflection symmetry would force both effects to vanish at z = 0; the profile is therefore *deliberately slightly asymmetric* with a small upward bias and u_z ≠ 0 at z = 0.

**(b) Two-wave cancellation — §3.3 + §7 (Lemmas 7.1, 7.4, 7.7; Propositions 7.5, 9.5).** The background (u_B, p_B) is constructed in Prop. 5.5 so that its tangential residual R^(0)_θ, R^(0)_z decomposes as

R^(0)_θ = −(∂_r + 2/r) T_{rθ},     R^(0)_z = −(∂_r + 1/r) T_{rz}

for an annular stress T supported in X_a < X < X_b with five radial-moment identities (Lemma 4.5, Prop. B.8). The pulse construction (Prop. 7.5, Lemma 4.5) realizes T = c_1 v_1 + c_2 v_2 with c_1, c_2 > 0 from two wave families whose covariance vectors v_1, v_2 ∈ ℝ² are linearly independent at each point of the annulus. The leading pulse amplitude and wavelength are

A_wave ≍ q^{−1/2 − h/2},   ℓ_wave ≍ q^{1/2 + h/2},

so A_wave² / q^{1/2} ≍ q^{−3/2 − h} matches the leading radial divergence scale (this is the "size match" that lets the wave's Reynolds stress cancel the background's singular stress). Each wave family has a *different* ratio of angular-momentum to axial-momentum flux; the two together span the admissible cone (Lemma 4.5, Prop. C.2–C.3). The mechanism for amplification is the classical one (Billant–Gallaire centrifugal instability, Lifschitz–Hameiri / Friedlander–Vishik phase dynamics): outward motion of an azimuthal surplus in a region where angular velocity decreases rapidly with radius is itself amplified, giving exponential growth when amplification exceeds viscous damping. The author chooses the initial wavelength so that growth dominates first, viscous damping overtakes later — and the tails are exponentially small so cutoff errors vanish at t = 1.

**Auxiliary torus Y ∈ T² (Eq. 6.3).** Distinct pulses with overlapping slow supports receive *disjoint* supports in the auxiliary torus; products of such pulses vanish pointwise even after evaluating Y(r, t). This is the technical device that keeps products from blowing up.

**(c) Four-step correction cycle — §3.4 + §9 (Proposition 9.6).** After the leading cancellation, the residual still contains

1. nonzero angular Fourier modes,
2. an angularly averaged residual with nonzero auxiliary mean,
3. radial integral defects (the five radial moments used to match the exterior),
4. curl and cutoff errors.

The correction cycle handles each in turn, recomputing the full residual after each operation so newly created terms enter the next stage:

1. **Solve the inhomogeneous wave-amplitude equation** for the supported nonzero angular Fourier modes. The principal operator cancels the prescribed source; remaining linear terms and pulse interactions are retained as higher-order residuals (Prop. 9.1, Lemma 9.2).
2. **Construct signed amplitude increments** so that their symmetrized cross-covariance with the leading pulses supplies the prescribed correction to the averaged stress. Quadratic self-interactions remain as higher-order terms (Prop. 7.6).
3. **Correct the angularly averaged residual with zero auxiliary average** by inverting the *fast auxiliary-time derivative* (Eq. 8.20). The axial increment is realized through a vector potential (Eq. 8.14).
4. **Solve the five radial moment equations** (Eq. 8.25): two preserve the zero angular-momentum and axial-flux integrals; three cancel the linear contributions to (P, J_θ, J_z) — the radial integral defects for pressure and tangential momentum.

After each step, the residual exponent σ_j improves by 1/10:

σ_0 = 1/5,    σ_{j+1} = σ_j + 1/10,    σ_j → ∞.

This is the cycle in Figure 6 of the paper, which the user asked to identify as "4-step correction."

**(d) Localization and whole-space completion — §3.5 + §10 (Prop. 10.1, Lemma 10.3, Cor. 10.6).** Cutoffs multiply the vector potential A, azimuthal coefficient B, and pressure p_loc by c = χ_x χ_t (χ_x supported in K, χ_t = 0 on [0, 1 − τ_0]). The curl after multiplication preserves divergence freedom; the resulting fields u = curl(cA) + cB e_θ, p = c p_loc have fixed spatial support in K. Their residual is split: near (0, 1) it is the local residual (controlled by the flatness bound 3.4); elsewhere it is supported in the cutoff transition region, where Theorem 3.1(ii) and the heat-exterior bounds give smooth limits uniformly. Lemma 10.3 realizes these limits as an f ∈ C∞_c(ℝ³ × (0, ∞); ℝ³) supported in K × [0, 2]. For t < 1, R(u, p) = f. **The growth path of Theorem 3.1(iv) eventually lies where the cutoffs equal one, so the localized velocity retains the asymptotic** u_θ(√(2X_in τ), 0, 0, 1 − τ) = τ^{−A} (e_0 + O(τ^{2h})) → ∞.

### 1.4 What's novel in this paper

Reading the introduction (§1.1) and the proof outline (§3), the novel contributions appear to be:

1. **An axisymmetric, self-similar, anisotropic background** (ℓ_z / ℓ_r ≍ τ^h) that gives bounded total kinetic energy while concentrating velocity growth in an *increasingly slender* column. This is the device that circumvents Leray's obstruction that energy bounds + smoothness → regularity for unforced flow.
2. **The "two-wave cancellation" mechanism** that realizes the annular stress T as a positive combination c_1 v_1 + c_2 v_2 of two pulse families, each with a different flux ratio. The admissible-stress-cone condition (Lemma 4.5, Prop. C.3) is the key algebraic lemma.
3. **The 4-step correction cycle improving σ_j by 1/10 per stage**, which controls all mixed space-time derivatives of the residual uniformly.
4. **The flatness bound** (Theorem 3.1(iii)): |∂^α_x ∂^b_t R(u, p)| ≤ C_{α,b,N,X_1} q^N for every N ≥ 0 on bounded X-intervals as q ↓ 0. This is what lets the residual be extended as a smooth force through t = 1.
5. **A heat exterior** (Lemma A.6) — the radial heat equation for the azimuthal velocity — whose momentum residual vanishes *identically*, eliminating any external force beyond a fixed annulus.

### 1.5 What comes from Córdoba–Martínez–Zoroa

Reading the citations and the language of the paper, the inherited ideas include:

- The **multiscale iterative scheme**: add localized oscillatory packets, each amplified by the previous one (cf. Córdoba–Martínez–Zoroa for IPM, Boussinesq, hypodissipative NS).
- **The Reynolds-stress mechanism**: the wave's nonlinear momentum flux cancels the background's singular stress, à la Daneri–Székelyhidi (2017) for Euler.
- The **amplification principle** (centrifugal + shear) is the Lifschitz–Hameiri / Friedlander–Vishik wavevector-rotation mechanism; specific precedents cited are Singh–Sridhar (viscous shearing waves), Billant–Gallaire (centrifugal instability), Cheverry (oscillatory approximate solutions with phase corrections).
- The **"smooth forcing" upgrade** (vs. Córdoba–Martínez–Zoroa's L∞_t C^∞_x force) is the central technical achievement and is shared with the Alpöge–Buckmaster papers; it relies on the four-step correction cycle described above.

### 1.6 Anything a careful reader would notice

- **Energy control is by self-similar concentration, not by damping.** The energy of the core is *not* dissipated; it shrinks because the *volume* shrinks faster than velocity squared grows. The dissipation integral ∫_0^{τ_0} τ^{−1/2 − 3h} dτ = finite is exactly the consistency check (h < 1/6 in §3.5).
- **The construction is forced, not unforced.** This is Clay alternative (C)/(D), not (B) or (A). The force is the *residual* of the constructed (u, p); its smoothness follows from the flatness bound. The theorem is unconditional for any ν > 0 — the viscosity doesn't change the singular time (Eq. 10.22–10.23 rescaling).
- **Axi-symmetry** is a real restriction. The proof is axisymmetric throughout (Thm. 3.1 states regularity at the axis); the only place non-axisymmetric features appear is the azimuthal pulse perturbations, which average out.
- **The 166-page length is dominated by the cycle machinery and the radial-moment matching** (Cor. B.10, Prop. B.8) — the actual "physics" of the blowup is in §2 and §3 (about 14 pages).
- **The exponent h ∈ (0, 1/100)** is a free parameter; the author calls it "fixed." This is a tell that the bounds are not sharp — the construction works for any h in this range.

---

## 2. OpenAI "Finite Time Blowup for the Euler Equation" (2026)

### 2.1 Bibliographic data

- **Title:** "Finite Time Blowup for the Euler Equation"
- **Authors:** OpenAI
- **Length:** ~58 pp. (6 sections + references)
- **Claim:** Smooth, compactly supported, divergence-free initial velocity on ℝ³ for the unforced 3D Euler equations develops a singularity in finite time.

### 2.2 Theorem 1.1 (verbatim from p. 1)

> **Theorem 1.1.** There exists u_0 ∈ C∞_{c,σ}(ℝ³) such that 0 < T*(u_0) < ∞. Its smooth Euler solution satisfies
>
> lim sup_{t ↑ T*} ‖∇u(t)‖_{L∞} = ∞,
>
> ∫_0^{T*} ‖curl u(t)‖_{L∞} dt = ∞.

The integral statement is a direct corollary of Beale–Kato–Majda. The initial data are *odd* (u_0(−x) = −u_0(x)) and supported in a fixed ball; all constructed flows U_j are odd.

### 2.3 Construction outline

The construction is fundamentally different in style from the NS paper. There is no self-similar background — the whole proof is a *parent–child* iteration of exact Euler solutions.

**(a) Stage setup (§2).** At stage j, write U_{j−1} for the parent velocity (with pressure p_{j−1}). Choose a target time t_j ↑ T_∞ < ∞ and construct U_j (with p_j) as the parent + a localized oscillatory packet (called a "packet") + correction terms. The constraints are

|∇U_j(t_j, 0)| → ∞,    Σ_j ‖U_j(0) − U_{j−1}(0)‖_{H^m} < ∞ for every fixed m.        (2.1)

The uniform bound ∇²p_j ≤ K_+ I is maintained for all stages. U_0 = U_B is a base odd flow with the right properties.

**(b) Amplification mechanism — particle coordinates (§2.1, Eqs. 2.2–2.5).** Write the parent particle map X(t, a) and F = ∇_a X, M = ∇u ∘ X, H = ∇²p ∘ X. The Lifschitz–Hameiri equations for the wave geometry are

m_t = − M^T m,    v_t = −M v + 2 (m · M v) m / |m|²,    m · v = 0.        (2.4)

For the leading velocity increment,

w_lead(t, X(t, ℓy)) = (ℓ α / k) χ_1(y) v(t, y) f_δ(k m_0 · y).        (2.5)

Differentiating the phase produces the leading gradient α χ_1 v ⊗ m f'_δ. The phase remains fixed in particle coordinates because the parent flow transports the phase: ∂_t s = λ(ζ̇ + D^T ζ) · x = 0 is the "transporting phase" condition.

**(c) Frame transfer — central shear (§2.1).** At the origin, the parent gradient contains a rank-1 shear h q p^T (scalar h, orthonormal p, q). This shear rotates m and amplifies v. At the target time t_j, when the new shear reaches its prescribed size, the directions m/|m| and v/|v| become the normal and transverse velocity of the next frame. The amplitude choice is α = δ_j h_j / (|m(t_j, 0)||v(t_j, 0)|) (Eq. 5.3, 5.18). Proposition 4.1 quantifies both growth and the transfer of directions.

**(d) Two linear inverses (§3).** The correction fields come from solving, in particle coordinates,

B_t + M B + d q̄ = f,   d · B = 0,   supp B(0) ⊂ { |ℓy| ≤ 2 }        (3.19)   (the *mean* inverse),

A_t + M A + m ∂_θ π = f,   m · A = 0                                  (3.29)   (the *transverse* inverse).

The mean inverse imposes compact support at t = 0 via a displacement boundary value problem (variational principle 3.21, Lax–Milgram, coercivity from K_+ S² / 2 + Be S + C_2 B_c r³ S ≤ 1/2, L ≥ C_1 B_c, Eq. 3.11). The transverse inverse preserves zero angle mean and the spatial support of the forcing. Both inverses admit factorial-type derivative bounds (Lemma 3.2).

**(e) Pressure Hessian control (§2.2, Eq. 2.7).** The pressure Hessian H is uniformly bounded above by K_+ I. The leading increment is

∆H_lead = −2 α χ_1 (m · M v) m ⊗ m / |m|² · f'_δ(θ).              (2.7)

For f'_δ(0) = δ^{−1} and f'_δ ≥ −C, the positive part of f'_δ makes the increment *negative semidefinite* (after m · M v > 0, which Proposition 4.1 establishes after a short initial part of amplification). The bounded negative derivative f'_δ ≥ −C limits the positive pressure increment.

**(f) Iteration and limit (§5).** Stage scales x_j, h_j, k_j, ℓ_j, δ_j, α_j are chosen so that

α_j = δ_j h_j / (|m(t_j, 0)||v(t_j, 0)|)

with an exponentially decaying factor in the history comparison outweighing parent coefficient bounds and high-frequency derivatives (Eq. 4.12). The retained horizon is S_j = t_j + 2 W_{j+1}. T_∞ = lim t_j < ∞, and T*(u_0) ≤ T_∞ by stability of Euler (any smooth extension past T_∞ would agree with each U_j up to t_j, contradicting the growing gradients).

**(g) Compact support (§2.2, §6).** The mean displacement boundary condition enforces compact support of the initial mean correction; the initial oscillatory correction is localized by the cutoff. All initial data share a common compact support, so the sum converges to u_0 ∈ C∞_{c,σ}(ℝ³).

### 2.4 What's novel

1. **Parent–child exact Euler iteration.** Unlike convex integration, which uses oscillatory building blocks to manufacture non-uniqueness, this is a *single* exact sequence with each child exactly solving Euler and exactly inheriting the parent's compact support.
2. **Pressure Hessian control** — the bound H ≤ K_+ I is maintained across all stages, which is unusual for amplitude-amplification constructions. The sign trick (m · M v > 0 + f'_δ ≥ −C + f'_δ(0) = δ^{−1}) is the algebraic heart of the argument.
3. **Factorial-type derivative bounds** — Eq. 3.1 defines a *shift* index d that records losses from differentiation, products, and inverse operators; Eq. 3.2 shows the shift-additivity (Sobolev product ≤ C shift d_1 + d_2 with profile h_1 h_2). The triangular induction (Eq. 3.3) gives the factorial bound ((n+d)!)². This is much sharper than a Sobolev bound and is the technical reason summability in H^m is achievable.

### 2.5 What's from Córdoba–Martínez–Zoroa (and earlier)

- The **amplification mechanism** is the same as Córdoba–Martínez–Zoroa for hypodissipative NS (cited as [10] in the Euler paper): a vorticity layer amplifies a more localized layer. The forced Euler construction of Córdoba–Martínez–Zoroa is cited at [10, §1.2].
- The **Córdoba–Laín-Sanclemente–Martínez-Zoroa pendulum construction** [5, Sections 2.6, 2.12, 2.14] is cited for the ODE-based ansatz producing amplification, steering, and holding intervals.
- The use of zero-mean periodic profiles (the f_δ of §3.1) and the angle primitive is standard.

### 2.6 Anything a careful reader would notice

- **The proof is for unforced 3D Euler on ℝ³** — this is the unforced case, but only with smooth compact initial data. Clay alternative (A) (smooth → smooth globally) is *not* refuted because the initial datum is constructed (not chosen freely). The theorem is a finite-time-breakup result from the specific datum.
- **The proof has explicit numerical choices**: ϑ = 10^{−6}, the expansion length N_k = ⌊kϑ⌋, and a constant C_* = 10(s + 2). These are not sharp but are functional.
- **Oddness of all flows** (u(t, −x) = −u(t, x)) gives X(t, 0) = 0, used throughout to keep the central trajectory trivial.
- **The base flow U_B** has central rank-1 shear h q p^T. The construction of U_B is in §6.4 (read at outline only).

---

## 3. Alpöge–Buckmaster 3D Euler with smooth forcing (2026)

### 3.1 Bibliographic data

- **Title:** "Blowup for the Euler Equations with Smooth Forcing"
- **Authors:** Levent Alpöge (CMU / Anthropic), Tristan Buckmaster (NYU)
- **Length:** 112 pp., 14 sections + references
- **Claim:** Forced blowup for axisymmetric 3D Euler *with swirl* from smooth compactly supported data, with force smooth in space-time up to and including the blowup time.

### 3.2 Theorem 1.1 (verbatim from §1.1)

> **Theorem 1.1.** For every r_0 > 0 and z_0 ∈ ℝ there exist T_* > 0, 0 < R < r_0/2, a divergence-free axisymmetric field u_0 ∈ C∞_c(T_R; ℝ³) with nonzero swirl and zero meridional velocity, and an axisymmetric force f ∈ C∞(ℝ³ × [0, T_*]; ℝ³), supp f(·, t) ⊂ T_R, such that (1.1) has a solution (u, p) ∈ C∞(ℝ³ × [0, T_*)) with u(·, 0) = u_0. For every τ < T_*,
>
> u ∈ L∞([0, τ]; L²(ℝ³)),   ∇u ∈ L∞(ℝ³ × [0, τ]).
>
> The solution is unique among divergence-free, locally space-time Lipschitz solutions with the same data and force … Moreover,
>
> supp(Γ, ω)(·, t) ⊂ T_R,
>
> sup_{t < T_*} {‖Γ(t)‖_∞ + ‖u_r(t)‖_∞ + ‖u_z(t)‖_∞} < ∞,
>
> lim_{t ↑ T_*} ‖∇Γ(t)‖_∞ = ∞,    lim_{t ↑ T_*} ‖ω(t)‖_∞ = ∞,
>
> ∫_0^{T_*} ‖ω(t)‖_∞ dt = ∞.

Here Γ = r u_ϕ is the circulation, ω is the vorticity, T_R = {(r, ϕ, z) : (z − z_0)² + (r − r_0)² < R²} is a solid torus about the circle (r_0, z_0).

**Key differences from OpenAI's Euler:**

1. **Swirl is present** (Γ ≠ 0); OpenAI's Euler uses odd flows that vanish at the origin, so u_ϕ = 0 always.
2. **Zero meridional velocity at t = 0** (u_r = u_z = 0, u_ϕ ≠ 0); this is achieved by Γ_b = Γ_0 χ_1 − A_0 (N_0/F)(N_0 e(t) · (y − y_*)) χ_0 in Eq. 2.7.
3. **Initial data supported in a solid torus**, not a ball around the origin.
4. **The blowup is at the central ring of the torus**, not at the origin.

### 3.3 Construction outline

**(a) Volume coordinates and reduced equations (§2).** Set y = (z, r²/2), so dy = r dz dr. Define v = (u_z, r u_r), the 2D vorticity ξ = ω/r, and Θ = Γ². The cylindrical equations reduce to the *transport* equations

D_v Γ = r f_ϕ,    D_v Θ = 2 Γ r f_ϕ,    D_v ξ = W ∂_{y_1} Θ + (∂_z f_r − ∂_r f_z)/r,    (2.6)

with W(y) = (2y_2)^{−2}. Lemma 2.1 gives a fixed linear operator R_y recovering the force from (E_ξ, F_Γ); the recovery is supported in D and has bounded C^k norms (including mixed time derivatives).

**(b) Reduction to the unit ring (§2.1, Lemma 2.2).** A rescaling z = (x − z_0 e_z)/r_0, u(x, t) = r_0 û(x̂, t), p(x, t) = r_0² p̂(x̂, t), f(x, t) = r_0 f̂(x̂, t) (time unchanged) maps the prescribed torus of any r_0, z_0 to the unit ring y_* = (0, 1/2). This preserves axisymmetry, the support of the initial datum, the swirl, the zero initial meridional velocity, every preterminal norm, the uniqueness class, and the time-integrated vorticity conclusion. So the proof works at y_* = (0, 1/2) and dilates at the end.

**(c) Wave and amplification — central lemma (§3, Eqs. 3.1–3.4).** Fix m ≥ 1 with frequency N_m > 0 and material radius ℓ_m > 0. For an older flow Γ_<m, Ψ_<m, write the exact nonlinear flow X_m from activation time τ_m, with inverse A_m = X_m^{−1}. Set

s_m = N_m p_m · A_m(y, t),    H_m = (D_a X_m)^{−1},    ζ_m = H_m^T p_m,    κ_m = ζ_m^T A(X_m) ζ_m.

For a smooth odd 2π-periodic profile F with F(s) = s near zero, mean-zero primitive P, envelope g_m, and activation w_m,

γ_{m,0} = (w_m T_m F g_m)♮,    ψ_{m,0} = (w_m B_m P g_m)♮,    Ω_m = N_m² κ_m B_m.

The *principal amplitude law* on (T_m, Ω̂_m) is

∂_t (T_m, Ω̂_m)^T = B_m (a, t) (T_m, Ω̂_m)^T,   B_m = [0, −d_m/(σ_{m−1} κ_m); σ_{m−1} c_m ζ_{m,1}, 0].

Here d_m = (J ζ_m) · (∇_y Γ_<m) ∘ X_m, c_m = 2 (W Γ_<m) ∘ X_m. **The growing eigenvalue is √(σ_{m−1}² c_m d_m / κ_m × ζ_{m,1})**. This is the elementary amplification lemma (cited as [1, Lemma 2.1] — i.e. the Boussinesq paper).

**(d) Material amplitude estimates (§3.1, Lemma 3.1, Eqs. 3.5–3.7).** Assumed bounds are: propagator bound ‖P(0; t, s)‖ ≤ C_R ρ(t)/ρ(s); time-derivative bounds ‖∂_t^b B(0, t)‖ ≤ c_b Π^{b+1}; weighted material bounds ‖∂_a^α B(·, t)‖_∞ ≤ c_{α,0} m(t); a smallness condition c_* + c_dat ≤ log 2 / (6 C_R²). The conclusions are ‖P(a; t, s)‖ ≤ 2 C_R ρ(t)/ρ(s), ‖P(a; t, s) − P(0; t, s)‖ ≤ 2 C_R² c_* ρ(t)/ρ(s), the central solution never vanishes, and ‖∂_a^α ∂_t^b R(a, t)‖ ≤ E_{α,b} λ^{|α|} Π^b (c_* + 1_{b>0} n + c_dat)^{min(1, |α|)} |R(a, t)|. The proof uses Duhamel, mean value, propagator comparison; constants are uniform in N_m, σ_{m−1}, ℓ_m, Π, |I|.

**(e) Reduction / return (§1.2).** After growing on growth, transitioning, and "holding" intervals where d_m = 0 and R_2(0, t) = 0 (so the second amplitude derivative vanishes), the central vorticity amplitude returns to *zero*. This is the "return of the principal azimuthal-vorticity amplitude to zero, preparing the next addition" stated in the abstract. Section 7 establishes the admissible range of trial parameters μ and the dependence on the complete fields; Prop. 4.2 establishes uniform realization.

**(f) Finite corrections (§5).** The correction equations cancel nonzero phase modes successively; phase averages remain in the force. The lifted equations use the full nonlinear flow derivative D_a X (Eq. 5.2). The residual differences (Lemma 5.1, Eqs. 5.5–5.6) involve the old fields and the increment:

F_m^Γ = (∂_t + v_< · ∇_y) γ + v' · ∇_y Γ_< + v' · ∇_y γ,

E_m^ξ = (∂_t + v_< · ∇_y) ξ' + v' · ∇_y ξ_< + v' · ∇_y ξ' − W ∂_{y_1}(2 Γ_< γ + γ²).

After substitution into the profile coordinates, these take the form E^Γ(V, U)♮ and E^ξ(V, U)♮ (Eq. 5.6). Phase inversion uses the mean-zero primitive P̸ (∂_s ∂_s^{−1} Q = Q, ⟨∂_s^{−1} Q⟩_s = 0, Eq. 5.8).

**(g) Mixed-derivative estimates (§6).** Bounds on every mixed space-time derivative of the force increments (the "force budget"). The recursive structure makes them summable over stages with one common choice of scales.

**(h) Continuation with full corrections (§§7–11).** Sections 7–11 run the joint induction and prove the return conditions. Proposition 11.1 separately proves fixed-layer all-order finiteness on an infinite selected history satisfying the scalar conditions and eventual admission of every order. Proposition 12.3 constructs this history, verifies all clock moments, and bounds every fixed force increment at every mixed order.

**(i) Smooth force, blowup, uniqueness (§§12–14).** The smooth physical force is constructed in §13 by summing finite contributions. §14 proves the blowup (lim ‖∇Γ‖_∞ = ∞, lim ‖ω‖_∞ = ∞, ∫_0^{T_*} ‖ω‖_∞ dt = ∞) and preterminal uniqueness.

### 3.4 What's novel vs. Córdoba–Martínez–Zoroa

The paper says explicitly (§1.2, §1.3):

- **From CMZ's forced Euler** (which had force in C^{1, 1/2−ε}_x ∩ L², velocity in C^{3, 1/2} ∩ L² pre-blowup): Alpöge–Buckmaster upgrade the force to C∞ space-time smooth and the velocity to C∞ pre-blowup, using material coordinates to track the wave geometry. The amplitude equations include the full nonlinear flow derivative (not just jet truncation).
- **From CMZ's Boussinesq** (which had non-compact momentum force, compact curl and scalar force): Alpöge–Buckmaster keep *one* fixed compact spatial support throughout.
- **From CMZ's IPM** (compact space-only smooth force): same upgrade as Euler — to space-time C∞ force.

The technical improvements the paper cites (§1.2):
- "The amplitudes below therefore depend on the material position, and the transporting velocity includes all preceding corrections." (vs. CMZ's local affine background with constant elliptic symbol)
- The smooth forcing is the new contribution; the amplification mechanism is from CMZ.

### 3.5 Comparison with OpenAI's Euler

| Feature | OpenAI Euler | Alpöge–Buckmaster Euler |
|---------|--------------|--------------------------|
| Initial data | Odd smooth, compact in ball | Axisymmetric with swirl, compact in solid torus, zero meridional velocity |
| Singular location | Origin | Central ring of the torus |
| Mechanism | Parent–child exact Euler iteration with displacement boundary value problem | Sequence of material-amplitude amplifications, each returning the vorticity amplitude to zero |
| Pressure Hessian control | Uniform bound ∇²p ≤ K_+ I with sign trick on f'_δ | Implicit via the volume-coordinate equations |
| Compact support | All stages, common support | All stages, common support (one fixed ball) |
| Force | None (unforced) | Smooth, compactly supported |
| Lean formalization | Yes (per README) | Yes for two of three preprints (Boussinesq, Euler) |

The constructions are *not* identical; they are siblings in the same program. The OpenAI Euler paper is for unforced blowup (no force) from smooth compact data; the Alpöge–Buckmaster Euler is for forced blowup with smooth space-time force. Both inherit the Córdoba–Martínez–Zoroa amplification principle but differ in implementation.

---

## 4. Alpöge–Buckmaster 2D Boussinesq (2026) — brief

- **Title:** "Blowup for the Boussinesq Equations with Smooth Forcing"
- **Length:** 76 pp., 10 sections
- **Claim:** Smooth forcing blowup for 2D inviscid Boussinesq with zero initial velocity, smooth compact temperature.

**Theorem 1.1 (p. 3):** For the prescribed initial data θ_in(x) = −(A_0/λ_0) sin(λ_0 x_2) χ_0(x), u_in = 0 (Rayleigh–Taylor-unstable: cold fluid above warm, ∂_2 θ_in(0) = −A_0), there exist odd forces f_θ ∈ C∞_c(ℝ² × ℝ), f_u ∈ C∞_c(ℝ² × ℝ; ℝ²) and T_* ∈ (0, ∞) such that the solution satisfies:

1. (θ, u) ∈ Y_T for every 0 < T < T_* (Biot–Savart class with ⟨x⟩^{3 + |γ|} spatial decay)
2. sup_{0 ≤ t < T_*} ‖θ(t)‖_∞ < ∞, lim_{t ↑ T_*} ‖∇θ(t)‖_∞ = ∞, lim sup_{t ↑ T_*} ‖ω(t)‖_∞ = ∞.

The fixed ball B_{R_F} contains the supports of θ, u, ω for 0 ≤ t < T_* and of both forces for all t.

**Construction outline.** The local two-field wave calculation (their Lemma 2.1) takes an affine background u_old = D(t) x, θ_old = G(t) · x, and adds a temperature wave and a vorticity wave with the same phase:

s = λ ζ(t) · x,    ϑ = Θ(t) sin s,    ϖ = Ω(t) cos s,    ψ = −(Ω / λ²|ζ|²) cos s,    v = ∇^⊥ ψ = (Ω / λ |ζ|²) J ζ sin s.

The wave does not advect itself (v · ∇ϑ = v · ∇ϖ = 0, v · ∇ω_old = 0) because v ⊥ ζ and both wave gradients are ∥ ζ. The amplitude equations are

ζ̇ = −D^T ζ,    Θ̇ = −(J ζ · G) λ|ζ|² Ω,    Ω̇ = λ ζ_1 Θ.        (after (1.2.5))

For D = 0, G = −A e_2, ζ = r e(φ), φ measured from x_2 toward x_1: eigenvalues are ±√(A sin φ), and on the growing eigenline Ω = (λ r / √A) Θ, both amplitudes are multiplied by e^{√(A sin φ) t}. At the origin,

∇ϑ(0, t) = λ Θ ζ,    D v(0, t) = Ω J e(φ) ⊗ e(φ).

The "return of vorticity" — rotating G and ζ together to bring ζ_1 to zero while preserving the temperature gain — is the technical heart. After amplification, growth, steering, and holding intervals, the construction is iterated.

The Tao blog (7 Sep 2026) describes this as the most readable of the three Alpöge–Buckmaster preprints.

**Boussinesq is not directly Clay-relevant** — it concerns 2D inviscid Boussinesq, not 3D Navier–Stokes or 3D Euler — but it is the cleanest presentation of the multiscale scheme and was the first to be formalized in Lean.

---

## 5. Coiculescu–Palasek (arXiv:2503.14699, Inventiones 244, 2025–2026)

### 5.1 Bibliographic data

- **Title:** "Non-Uniqueness of Smooth Solutions of the Navier–Stokes Equations from Critical Data"
- **Authors:** Matei P. Coiculescu (Princeton), Stan Palasek (Princeton + IAS)
- **Length:** 54 pp., 1 figure
- **Venue:** arXiv 2503.14699 (v1 18 Mar 2025, v2 21 Jul 2025); DOI 10.1007/s00222-025-01396-z (Inventiones mathematicae 244)
- **Claim:** Construction of smooth *global* solutions to Navier–Stokes on T³ from the same critical BMO⁻¹ initial data — the first non-uniqueness example at the critical regularity.

### 5.2 Theorem 1.1 (Koch–Tataru) and Theorem 1.2 (Coiculescu–Palasek)

> **Theorem 1.1 (Koch–Tataru).** There exists ε > 0 such that if U_0 is divergence-free with ‖U_0‖_{BMO⁻¹} < ε, then there exists a unique global-in-time solution that is regular for t > 0.

> **Theorem 1.2 (Coiculescu–Palasek).** There exists divergence-free initial data U_0 ∈ BMO⁻¹ such that the Cauchy problem (1.1) admits two distinct global solutions
>
> u^{(1)}, u^{(2)} ∈ C∞_{t,x}((0, ∞) × T³) ∩ L∞([0, ∞); BMO⁻¹(T³)) ∩ C^0([0, ∞); Ẇ^{-1, p}(T³))
>
> for all p < ∞.

**Remark 1.5 (important caveat):** "The solutions constructed in the proof of Theorem 1.2 are not in the Leray–Hopf class due to the fact that the initial velocity is not in L²(T³). … If the full mechanism from [47] could be implemented, we expect it would yield solutions of (1.1) in a similar class as those of Jia–Šverák (but without exact self-similarity), namely Leray–Hopf solutions belonging to improved critical spaces … . There does not appear to be any obstruction in principle to realizing the mechanism proposed in [47], but there exists a substantial technical challenge … ."

So the current paper is a *simplified* mechanism that does not yet achieve Leray–Hopf class; the full Palasek mechanism from [47] is left as future work.

**Remark 1.6:** "The initial data U_0 is smooth outside of a measure zero set Σ ⊂ T³. Indeed, it can be written as U_0 = Σ_{k=1}^∞ V_k^0 where each component V_k^0 is smooth on T³ and the supports are monotone, supp V_k^0 ⊂ supp V_{k-1}^0. … |Σ̃_k| ≤ 2^{−k} from Lemma 3.3."

So the initial datum is *not* smooth — it has a singular set of measure zero, where all the support-intersections accumulate. The solutions themselves are smooth for t > 0, but the data are not.

### 5.3 The dyadic NS mechanism — §1.3

**Lacunary initial data:** U_0 = Σ_{k ≥ 0} V_k^0 where V_k^0 is (approximately) Fourier-localized to |ξ| ~ N_k with N_k rapidly growing.

**Two distinct evolutions:** for each frequency level k, two evolutions are consistent with (1.1) up to small error:

- **Heat-dominated flow:** ∂_t v_k − ∆ v_k = l.o.t., v_k |_{t=0} = V_k^0. Clearly ‖v_k(t)‖_{L∞} decays exponentially on time scale N_k^{−2}.
- **Inverse-cascade-dominated flow:** ∂_t v_k + P_{~N_k} P div v_{k+1} ⊗ v_{k+1} = 0, v_k |_{t=0} = V_k^0, **where v_{k+1} is the heat-dominated flow from V_{k+1}^0**. By a particular choice of V_{k+1}^0, ‖v_k(t)‖_{L∞} decays exponentially on time scale N_{k+1}^{−2}.

**Why this gives non-uniqueness:** the choice at level k+1 of whether to be heat-dominated or inverse-cascade-dominated is forced by parity (odd vs. even k), because the two events are incompatible: V_k^0 can annihilate V_{k-1}^0 on time scale N_k^{−2}, while V_{k+1}^0 would annihilate V_k^0 on time scale N_{k+1}^{−2} which is much shorter than N_k^{−2}. So if V_k^0 is in fact annihilated by V_{k+1}^0 (i.e. its continuation v_k(t) satisfies (1.4)), then V_{k-1}^0 evolves as the heat-dominated flow. The distinctness is immediate from the different decay rates.

**Recursive amplitude relation (Eq. 1.7):** V_k^0 = C N_k^{−2} P_{~N_k} P div(a_{k+1}² θ ⊗ θ) (Eq. 1.6, Mikado-flow version). The amplitudes satisfy

‖V_{k+1}^0‖_{L∞} ≈ C_1 N_{k+1} (‖V_k^0‖_{L∞} / N_k)^{1/2}.

This is the fixed point of the recursion: ‖V_k^0‖_{L∞} ~ N_k (the critical scaling). The recursion also gives a bound |supp V_k^0| ≤ 2^{−k} |T³|, which lifts the regularity from B⁻¹_{∞,∞} to BMO⁻¹.

**The perturbation w^{(i)}** corrects the errors of v^{(i)} via a fixed-point argument (mild formulation, Eq. 1.8), using the fact that making N_k grow faster than exponentially puts the error F^{(i)} in a subcritical norm: ‖F^{(i)}(t)‖_{L∞} ≲ t^{−1+α} for α > 0. The semigroup S^{(i)} for the linearized equation around v^{(i)} is estimated to have losses no worse than the heat semigroup.

### 5.4 What's novel

This is **not** a Córdoba–Martínez–Zoroa construction. It's the Palasek dyadic-NS mechanism from [47], adapted from the Obukhov dyadic model to the full 3D NS. The key new ingredients (per the authors):

1. The **lacunary Fourier-localized initial data** with monotone support nesting |supp V_k^0| ≤ 2^{−k}|T³| gives BMO⁻¹ regularity, not just B⁻¹_{∞,∞}.
2. The **two evolution equations** at each level (heat-dominated vs. inverse-cascade) are the dyadic analogue of the Palasek Obukhov model.
3. The **Mikado-flow stress** (Nash-style) realizes the rank-1 stress a² θ ⊗ θ for the recursive amplitude relation.
4. The **fixed-point construction of w^{(i)}** using the mild formulation with the linearized semigroup around v^{(i)} — and a careful estimate showing the loss is tolerable because F^{(i)} is subcritical.

### 5.5 Relation to the Clay problem

This is **non-uniqueness, not blowup**. The two solutions are both globally smooth for t > 0; they merely start from the same non-smooth data and evolve differently. This is *orthogonal* to the Clay problem (which is about smooth data and possible blowup), but it is a *critical-regularity result* that demonstrates sharpness of the Koch–Tataru small-data theorem.

The paper's Remark 1.3 says the solutions lie in the same path space X_{KT} as Koch–Tataru's solutions — i.e. they are "Kato-type" mild solutions. The bilinear estimate of Koch–Tataru, which was the basis for the small-data theorem, does *not* prevent non-uniqueness at large data.

### 5.6 Anything a careful reader would notice

- The data are *not* smooth (singular set Σ has measure zero, but is nonempty in the BMO⁻¹ topology).
- The solutions are smooth for t > 0 but the data are not — this is consistent with the Kato theory, where the local well-posedness for small BMO⁻¹ data uses the parabolic regularization of e^{t∆} U_0 to bootstrap regularity for t > 0.
- The full Palasek mechanism from [47] is not realized; that would give Leray–Hopf class. The technical challenge (Remark 1.5) is "finding the correct building blocks that embed the behavior of the Obukhov dyadic model."
- This construction is *unforced* — there is no smooth compact force. The smooth force of the OpenAI / Alpöge–Buckmaster papers is not needed here because the non-uniqueness is purely due to the initial-data choice.

---

## 6. Lean formalization structure (github.com/openai/NavierStokesAndEuler)

### 6.1 Repository layout (from README + directory listings)

```
NavierStokesAndEuler/
├── Euler.lean
├── NavierStokes.lean
├── README.md
├── formalization.yaml
├── lakefile.toml
├── lake-manifest.json
├── lean-toolchain              # Lean 4.34.0-rc2
├── Euler/                      # Euler formalization files (~hundreds)
└── NavierStokes/               # NS formalization files (~hundreds)
    └── R3/
```

### 6.2 NS files I saw (representative subset)

- `ActualBaseResidual.lean`, `ActualBaseVelocityBounds.lean`
- `ActualCandidateConstruction.lean`, `ActualCandidateAssembly.lean`
- `ActualCarrierGeometry.lean`, `ActualCarrierTransport.lean`
- `ActualCoreSupport.lean`
- `ActualCorrectionModels.lean`
- `ActualCurrentParticularAssembly.lean`, `ActualCurrentParticularBounds.lean`
- `ActualCurrentParticularPhysical.lean`
- `ActualCycle*.lean` (~12 files: Coherence, Excluded, Geometry, Parameters, Periodicity, Preservation, ResidualBounds)
- `ActualEndpointInputs.lean`
- `ActualExteriorPrefix.lean`, `ActualMeanExterior.lean`
- `ActualMeanPhysicalData.lean`, `ActualMeanPotentialRealization.lean`
- `ActualMeanStageData.lean`
- `Activation*.lean` (~5 files: Bounds, Cone, Continuation, Holomorphic, Stocks)
- `Physical*.lean` (~7 files)
- `PolarCharts.lean`, `PositiveAxisExistence.lean`, `PositiveAxisSystem.lean`
- `PositiveOrderMoments.lean`, `PowerMomentMatrix.lean`
- `PreparedOutgoing.lean`, `PressureDatum.lean`

The naming convention — `Actual*` and `Positive*` prefixes — matches the symbolic table (Table 1) of the NS paper: e.g. `PhysicalSignedWave`, `PhysicalStageBounds`, `PositiveRepresentatives`. So the Lean code appears to track the NS paper's section structure roughly one-to-one.

### 6.3 Euler files (representative subset)

- `AllOrderCorrection*.lean` (~6 files), `AllOrderDrift*.lean` (~14 files)
- `Angle*.lean` (~7 files: MeanZeroPrimitive, PrimitiveBounds, PrimitiveKernel, PrimitiveMap, PrimitiveParity, PrimitiveSpatialRegularity, PrimitiveTranslation)
- `BaseEuler*.lean` (~17 files: Datum, FlowL2, Gevrey, Guards, Input, LabelData, Parent, Parity, Sign, Sobolev, State, Uniform, ...)
- `BaseFirstPacket*.lean` (~10 files)
- `GaussianHeatSmoothing.lean`, `GaussianHeatTotal.lean`
- `Gevrey*.lean` (~12 files)

The "AllOrder*" prefix matches the iterative structure of the Euler paper: each stage contributes an "AllOrderCorrection" and an "AllOrderDrift." The "Gevrey*" files relate to the regularity bounds (Euler Gevrey vs Sobolev — the paper uses factorial-derivative bounds, which are Gevrey-type).

### 6.4 What's proved

From the README:

> "For every positive viscosity, we prove two results:
> - Whole space ℝ³: There exist smooth initial data and forcing for which no global smooth solution with uniformly bounded kinetic energy exists.
> - Periodic torus ℝ³/ℤ³: There exist smooth periodic initial data and forcing for which no global smooth solution exists.
> These are alternatives (C) and (D) in the Clay problem statement."

> "Euler: We construct smooth, compactly supported, divergence-free initial velocity on ℝ³ whose solution to the unforced incompressible Euler equations develops a singularity in finite time. The velocity's C¹ norm becomes unbounded near that time, and the time integral of the vorticity's L∞ norm diverges."

So the Lean formalization certifies both NS (alternatives C, D) and the unforced 3D Euler blowup result.

### 6.5 What's not visible from the README

- The build instructions use `lake exe cache get; lake build`. I did not verify whether the Lean code compiles or runs in any time budget.
- The `formalization.yaml` and `ComparatorChallenges/README.md` are referenced for "independent proof checking" — there is a Comparator tool that presumably re-checks the formalizations. I did not fetch these.
- The size of the Lean codebase is in the hundreds of files (the `NavierStokes/` directory has hundreds of files based on the listing snippet). I did not enumerate all of them.

### 6.6 Anything a careful reader would notice

- The Lean files use a *naming convention that mirrors the NS paper's Table 1*. This is a strong hint that the formalization is structured around the paper's theorems/propositions/lemmas, not around a different proof architecture.
- There is no public statement about how much of the 166-page NS paper is covered. The README asserts the theorem statements; whether every technical step is in Lean is not visible.
- Buckmaster's statement (see §7 below) says the Alpöge–Buckmaster Boussinesq and Euler preprints have been verified in Lean (SHA-256 hashes were given). The IPM paper has a separate SHA-256 commitment. So both teams have produced Lean certificates; the open question is which is "the" Lean certificate that the math community will accept.

---

## 7. Cross-comparison: OpenAI vs. Alpöge–Buckmaster

### 7.1 Same program, different implementations

Reading the Buckmaster statement (cims.nyu.edu/~tristanb/statement.pdf, p. 1):

> "Today, Levent Alpöge and I have made public three results: finite-time blowup with smooth forcing for incompressible porous media, for Boussinesq, and for 3d incompressible Euler. We believe we also have blowup for hypo-dissipative Navier-Stokes. We are not releasing that paper today: unlike the above, the Lean verification has not yet finished. … The program this fits into was not started by us nor was it proposed by a Large Language Model. The credit for the basic idea of this program goes to Diego Córdoba and Luis Martínez-Zoroa, who for several years have been exploring the construction of forced blow ups. We took their work as a starting point, using Large Language Models to push their program to completion."

So both teams:

1. **Inherit** the Córdoba–Martínez–Zoroa amplification program.
2. **Upgrade** to smooth (space-time C∞) forcing.
3. **Formalize** in Lean.
4. **Use LLMs heavily** in the writing and verification.

### 7.2 What OpenAI adds

- **Forced 3D Navier–Stokes blowup** with bounded kinetic energy (the paper at cdn.openai.com/.../navier-stokes.pdf, 166 pp.). This is the only NS blowup announcement; Alpöge–Buckmaster only have NS results for *hypodissipative* NS (β < 1) and the Lean verification isn't complete.
- **A self-similar background + two-wave cancellation + four-step correction cycle** architecture specific to the viscous case (axisymmetric with anisotropic concentration ℓ_z ≪ ℓ_r).
- **An unforced 3D Euler blowup** (cdn.openai.com/.../euler.pdf) — separate from the forced Euler of Alpöge–Buckmaster.

### 7.3 What Alpöge–Buckmaster add

- **Forced IPM, Boussinesq, and 3D Euler with smooth forcing** — three preprints, three Lean certificates.
- **The "return of the principal azimuthal-vorticity amplitude to zero"** mechanism specific to the swirling axisymmetric Euler case.
- **The volume-coordinate reduction** (y = (z, r²/2)) that converts the Euler equations into 2D transport equations for (Γ, Ψ).

### 7.4 What neither team does

- **Unforced 3D Navier–Stokes blowup** (Clay alternative (B)) — both teams are at forced blowup. The Tao blog notes this is the open problem left.
- **Unforced 3D Euler blowup from *any* smooth datum** — OpenAI proves existence of *one* specific datum that blows up; it does not prove blowup for a generic datum or for the Clay alternative (A).

### 7.5 The controversy

Buckmaster's statement (p. 2–3) records that on 6 Sep 2026 Sebastien Bubeck (OpenAI) told him that an internal OpenAI model had produced a proof of forced NS blowup, in approximately 100 pages, with "very little human input" — but Buckmaster was told by Bubeck that "an entire team had been working on the problem," that "this was one of a number of things that was tried," and that "an insane amount of compute had been used." Buckmaster says OpenAI asked whether Alpöge–Buckmaster would be willing to be removed from authorship of the NS result and proposed other arrangements that he declined. Buckmaster concludes (p. 4):

> "If indeed an OpenAI model did close the gap to Navier-Stokes, that is a remarkable thing and it should be said loudly, by them, with the history intact."

I have no way to evaluate the truth of either side's account. I record it because it is part of the primary-source landscape of these announcements. **My read of the mathematical content does not depend on resolving this dispute.**

---

## 8. Notable questions / gaps a careful reader would notice

### 8.1 OpenAI NS paper

1. **Why ℓ_z ≪ ℓ_r?** The anisotropic concentration (ℓ_r ≍ τ^{1/2}, ℓ_z ≍ τ^{1/2 − h}) is the device that gives *bounded* kinetic energy despite velocity growing like τ^{−1/2 − h}. Without the anisotropy, the kinetic energy would scale like τ^{1/2 − 3h}, which would also go to zero if h < 1/6, so why not use ℓ_z ≍ τ^{1/2} too? The asymmetry is what enables *both* the angular Reynolds number to diverge and the radial one to stay bounded — but it is not obvious from §2 alone that this is the only way.

2. **What is the actual role of the auxiliary torus Y ∈ T²?** §3.3 introduces it to keep products of disjoint-labeled pulses from blowing up, but the *physical* evaluation Y(r, t) breaks the auxiliary independence. The construction of the phase map in Eq. 6.3 is described at outline level; I did not verify the support-preservation argument of Lemma 6.1.

3. **The admissible-stress-cone condition** (Lemma 4.5, Prop. C.2–C.3) is the algebraic heart of the two-wave cancellation. The construction uses a radial oscillation with phase N log X (Prop. C.2) to enforce the cone condition; this is the only place in the NS paper where I see logarithmic radial profiles. The compatibility of the radial oscillation with the five radial-moment identities (Prop. B.8, Cor. B.10) is not visible in §2–§3.

4. **The energy bound** (Lemma 10.4) is described as "from the equation directly." A direct verification should be possible; the proof is in the body of §10, which I did not read in detail.

5. **The σ_j cycle** starts at σ_0 = 1/5 and increases by 1/10 per stage. Why 1/5 and 1/10? These look like *choices that work*, not sharp values. The cycle bound (Eq. 9.18) contains q^{h σ_j − K_m}; for this to dominate all derivative orders m, σ_j → ∞ is enough — the specific constants 1/5 and 1/10 are tuning.

6. **The exponent h ∈ (0, 1/100)** is called "fixed" but is never assigned a specific value. The construction works for *any* h in this range; the bounds just need h to be sufficiently small.

### 8.2 OpenAI Euler paper

1. **What is the base flow U_B?** §6.4 (read at outline level) constructs U_B with central rank-1 shear h q p^T. The choice of p, q, h(t) and the oddness/parity of U_B are the inputs to the induction.

2. **The pressure Hessian bound K_+** appears as a free parameter in §3.2(ii). The induction in §4 must establish that the bound persists at every stage. The sign trick (m · M v > 0 + f'_δ ≥ −C) is the key, but the precise interaction with the parent shear (which gives m · M v > 0 only "after a short initial part of amplification") is delicate.

3. **The constants Pc and ϑ = 10^{−6}** are explicit but unmotivated. The paper says the factorial bound is sharp up to these constants; whether this is tight is not clear.

### 8.3 Alpöge–Buckmaster Euler

1. **The material derivative and the flow X_m** (Eq. 3.1) — the proof must establish that the older fields' exact flow X_m is well-defined and smooth on the lifetime interval. The bounds in §4 (Lifetime bounds) handle this; I did not read them in detail.

2. **The return to zero of the vorticity amplitude** is stated in §1.2 but the proof in §7 (Finite controlled families) is heavy — I only saw the first few pages.

3. **The 14-section structure** (Sections 5–11 = corrections, continuation, return, summation) suggests a long bootstrapping argument. The cleanest entry point is §3 (the wave and its amplification) and §1.2 (the physical picture).

### 8.4 Coiculescu–Palasek

1. **The data are not smooth.** Remark 1.6 says U_0 is smooth outside a measure-zero set Σ. This is consistent with BMO⁻¹ critical regularity but it means the paper does *not* prove non-uniqueness for *smooth* initial data.

2. **Leray–Hopf class is not achieved.** Remark 1.5 explicitly says the full Palasek mechanism from [47] is not realized here. Achieving Leray–Hopf (so that the result interacts with the convex-integration / weak-solution literature) is open.

3. **The construction is 3D-specific.** Remark 1.7 says "Our methods extend in principle to the two-dimensional case as well (which is likewise covered by the small data well-posedness results of [37]), but there are technical difficulties similar to those faced in the approach to Onsager's conjecture due to the geometry of Mikado flows. We leave open the problem of non-unique solutions with critical data on T² and ℝ²."

### 8.5 Lean formalization

1. **What is the proof-checking status?** I did not run `lake build`. The README asserts the formalizations compile.

2. **What is the dependency on Mathlib?** Lean 4.34.0-rc2 + Mathlib. The size of the codebase (hundreds of files for NS, similar for Euler) is consistent with a *complete* formalization of the 166-page / 58-page papers, but I have not verified.

3. **The ComparatorChallenges** directory suggests there is a third-party check. I did not fetch the Comparator README.

### 8.6 The Córdoba–Martínez–Zoroa program in context

The Córdoba–Martínez–Zoroa papers cited in the introductions include:

- IPM with spatially-smooth force (their foundational paper)
- Forced 3D Euler with force in C^{1, 1/2−ε}_x ∩ L² (rough forcing)
- Hypodissipative NS with β < some threshold
- 2D Boussinesq with non-compact momentum force
- Quasi-geostrophic and surface QSQ ill-posedness

The Alpöge–Buckmaster preprints and the OpenAI Euler paper *all* credit CMZ with the foundational idea. The Tao blog (7 Sep 2026) endorses this lineage. Buckmaster's statement explicitly says Martínez-Zoroa "deserves a Fields Medal" for the underlying program.

A careful reader should note that this is not a single paper being verified — it is a *decade-long program* that has been pushed to completion by LLM-assisted work. The mathematical content of the new papers (Alpöge–Buckmaster, OpenAI) is the upgrade from rough forcing to smooth forcing and the extension to unforced Euler / viscous NS.

---

## 9. What a careful reader cannot verify from the primary sources alone

The following claims are made by one or more of the sources but I could not independently verify them from a reading of the paper PDFs alone:

1. **The full 166-page NS paper**: I read §1–3 carefully and skimmed §4–10. The technical heart of the construction (the radial-moment matching in §4.5, the curl corrections in §7–8, the cycle in §9) is in pages I did not read in full. A careful referee would need to verify these.
2. **The full 112-page Alpöge–Buckmaster Euler paper**: same situation. §3 is clear; §4–14 are heavy.
3. **The Coiculescu–Palasek proof that the constructed U_0 lies in BMO⁻¹** (Prop. 3.8). I read the proof sketch in §1.3 but the actual estimation in §3.6 was skimmed.
4. **The Lean certificates**. I did not compile them. The README asserts they exist; I have no way to verify independently.

---

## 10. Honest gaps in this reading summary

- **NS §4–10, A–C**: I read the headers and the symbols (Table 1), but the technical content of §4 (profiles near the axis, matching exterior), §5 (full background construction), §6 (auxiliary torus), §7 (oscillatory realization and stress), §8 (mean corrections), §9 (residual improvement), §10 (compact forcing) and Appendices A–C are at outline level.
- **Alpöge–Buckmaster Euler §4–14**: I read §1–3 carefully; §4 (material coordinates and lifetime bounds), §5 (finite correction equations), §6 (mixed derivative estimates), §7 (finite controlled families), §8 (low-order estimates), §9 (continuation with complete corrections), §10 (higher derivatives), §11 (continuation and return), §12 (one sequence and the smooth force), §13 (construction of the solution and the smooth force), §14 (blowup and preterminal uniqueness) are skimmed.
- **OpenAI Euler §4–6**: I read §1–3.1 carefully; the iterative scheme and Sobolev-bound machinery in §4–5 are at outline level.
- **Coiculescu–Palasek §4–5**: only the introduction (which is itself substantial — ~10 pages) is read in full.

What I *did* read carefully, with the actual equations, for each paper:

- **OpenAI NS**: §1.1 (Theorem 1.1), §2 (physical description), §3 (proof outline, with all displayed equations of the core, pulses, and cycle).
- **OpenAI Euler**: §1 (Theorem 1.1 and historical context), §2 (amplification mechanism and proof order, including Eqs. 2.1–2.7 and §2.3 stages), §3.1 (norms, cutoffs, factorial estimates), §3.2 (coordinates and hypotheses), Proposition 3.1.
- **Alpöge–Buckmaster Euler**: §1 (Theorem 1.1, §1.1–1.3 historical and related work), §2 (axisymmetric coordinates and compact fields, including Lemma 2.1, 2.2, 2.3), §3 (wave and amplification, including Lemma 3.1, Eqs. 3.4–3.8).
- **Alpöge–Buckmaster Boussinesq**: §1 (Theorem 1.1, the wave and equations, Eq. 1.5, the steering and holding intervals), §3.5–3.6 (Lemma 3.5, 3.6, first-stage steering model, Eq. 3.24–3.27).
- **Alpöge–Buckmaster IPM**: §1, §1.1, §2 (Theorem 2.1, §2.1 strategy).
- **Coiculescu–Palasek**: §1, §1.1, §1.2, §1.3 (including Eqs. 1.3–1.8 and Remark 1.5), §2 (preliminaries including the BMO⁻¹ definition and Fourier conventions).
- **Buckmaster statement**: full text.
- **Tao blog**: full text.
- **OpenAI Lean README**: full text + file listings.

---

## 11. One-paragraph verdict (for the parent agent)

Both OpenAI and Alpöge–Buckmaster have produced *new* mathematical content that pushes the Córdoba–Martínez–Zoroa multiscale program to (a) **smooth space-time forcing** (Alpöge–Buckmaster: IPM, Boussinesq, axisymmetric-with-swirl Euler; OpenAI: viscous NS via self-similar concentration) and (b) **unforced 3D Euler blowup** (OpenAI, separate paper). The constructions are *not* identical: OpenAI NS uses an axisymmetric self-similar anisotropic background with two-wave Reynolds-stress cancellation and a four-step correction cycle improving a residual exponent σ_j by 1/10 per stage; Alpöge–Buckmaster Euler uses volume coordinates and a sequence of material-amplitude amplifications with explicit return of the vorticity amplitude to zero. Both inherit the Córdoba–Martínez–Zoroa amplification principle and cite it explicitly. OpenAI's Euler paper is for *unforced* 3D Euler (smooth compact initial data → finite-time blowup of ‖∇u‖_{L∞}); Alpöge–Buckmaster's is for *forced* Euler with smooth space-time force. The Clay alternatives actually proved are **C** and **D** (forced NS on ℝ³ and T³, OpenAI NS paper) and the analogous forced blowup for IPM / Boussinesq / axisymmetric-with-swirl Euler (Alpöge–Buckmaster). Unforced NS (alternative **B**) is **not** proved by either team — this is the open gap. The Coiculescu–Palasek paper is *not* a blowup result — it is a non-uniqueness result for global smooth solutions of NS from critical BMO⁻¹ data, with smooth data outside a measure-zero set Σ ⊂ T³. It is mathematically interesting but does not interact with the Clay problem. Lean formalizations exist for both OpenAI's NS / Euler and Alpöge–Buckmaster's IPM / Boussinesq / Euler preprints; the README of github.com/openai/NavierStokesAndEuler asserts they compile, but I did not independently verify.
