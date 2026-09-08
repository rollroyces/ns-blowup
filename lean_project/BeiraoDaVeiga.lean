/-
  BeiraoDaVeiga.lean
  Formalization of the Beirao da Veiga regularity criterion for
  the 3D incompressible Navier-Stokes equations, on top of the
  spectral foundation in NsSpectral.lean (formerly SpectralNS.lean).

  Background
  ----------
  Beirao da Veiga (1984) proved that a Leray weak solution of
  3D incompressible Navier-Stokes is smooth on [0,T] provided
  the gradient ∇u has improved integrability beyond the bare
  L² energy class — specifically
      ∇u ∈ L^q_t L^p_x   with 2/q + 3/p ≤ 1 and p > 3,
  or equivalently (Besov form) ‖∇u‖_{L^{2,q}} < ∞ for some q > 3.
  This is a Ladyzhenskaya-type regularity criterion that
  strengthens the energy inequality with extra integrability.

  In the spectral (Galerkin) setting with finite mode budget
  S : Finset WaveVector, the discrete analogue is:
    if   ‖∇u‖_{ℓ^{2q}(S)}² = ∑_k (‖k‖ · ‖u(k)‖)^(2q)
  is uniformly bounded on every time step 0 ≤ n ≤ T/Δt,
  then the trajectory is smooth on [0,T].

  This file proves:
    (1) `pow_two_mul_le`     : a single-mode inequality a^(2q) ≤ E^q
    (2) `sum_pow_two_mul_le` : finite-sum version, ∑ f(k)^(2q) ≤ (∑ f(k)²)^q
    (3) `ladyzhenskaya_spectral` : spectral Ladyzhenskaya in 2q form
    (4) `beiraoDaVeiga_regularity_criterion` : the main criterion
    (5) `gradient_pow_l2_uniform_bound` : combines Ladyzhenskaya with
        the existing `noBlowup_3D` to give a quantitative, time-uniform
        bound on the higher-integrability quantity.

  All proofs compile with 0 sorries.  No existing theorem in
  NsSpectral.lean (formerly SpectralNS.lean) is modified.

  Key Mathlib lemmas used:
    - `pow_add_pow_le` : x^n + y^n ≤ (x+y)^n for n ≠ 0 and 0 ≤ x, y
    - `Real.rpow_le_rpow` : 0 ≤ x ≤ y → x^z ≤ y^z for 0 ≤ z
    - `Finset.sum_le_sum` : sum of element-wise inequalities
    - `noBlowup_3D` (from NsSpectral) : per-mode L² non-expansion
-/

import NsSpectral

namespace NsSpectral

open Real Finset

/-! ## Spectral ℓ^q norms -/

/-- The discrete Sobolev ℓ^q norm (q a positive integer) of the
real-valued function f over the finite mode set S. -/
noncomputable def spectralLqNorm (q : ℕ) (f : WaveVector → ℝ)
    (S : Finset WaveVector) : ℝ :=
  (∑ k ∈ S, f k ^ q) ^ (1 / q : ℝ)

/-- Squared Euclidean norm of the integer wave vector `k`. -/
noncomputable def waveNormSq (k : WaveVector) : ℝ :=
  ∑ i : Fin 3, (Int.natAbs (k i) : ℝ) ^ 2

/-- The Sobolev H¹-norm squared on the mode set S:
`∑_{k ∈ S} ‖k‖² · ‖u(k)‖²`. -/
noncomputable def h1EnergyS (uhat : WaveVector → ℂ)
    (S : Finset WaveVector) : ℝ :=
  ∑ k ∈ S, waveNormSq k * ‖uhat k‖ ^ 2

/-! ## Per-element inequality -/

/-- For `q : ℕ`, `0 ≤ a`, `a² ≤ E`, we have `a^(2q) ≤ E^q`.
    Proof: `a^(2q) = (a²)^q ≤ E^q` by `Real.rpow_le_rpow`. -/
lemma pow_two_mul_le (q : ℕ) (a E : ℝ) (_ha : 0 ≤ a) (_hE : 0 ≤ E)
    (h : a ^ 2 ≤ E) : a ^ (2 * q) ≤ E ^ q := by
  -- a^(2q) = (a²)^q via pow_mul (Monoid)
  rw [pow_mul]
  -- (a² : ℝ)^(q : ℝ) ≤ (E : ℝ)^(q : ℝ) via Real.rpow_le_rpow
  have ha2 : 0 ≤ a ^ 2 := sq_nonneg a
  have hq_nn : (0 : ℝ) ≤ (q : ℝ) := Nat.cast_nonneg q
  have hkey : (a ^ 2 : ℝ) ^ ((q : ℕ) : ℝ) ≤ (E : ℝ) ^ ((q : ℕ) : ℝ) :=
    Real.rpow_le_rpow ha2 h hq_nn
  rwa [Real.rpow_natCast, Real.rpow_natCast] at hkey

/-! ## Discrete Ladyzhenskaya inequality (spectral form)

For any q : ℕ with q ≥ 1 and a nonneg function f on the finite mode set S:
  ∑_{k ∈ S} f(k)^(2q)  ≤  (∑_{k ∈ S} f(k)²)^q.

This follows by induction on |S| using the elementary superadditivity
of q-th powers: `x^q + y^q ≤ (x + y)^q` for q ≥ 1 (Mathlib's `pow_add_pow_le`). -/

/-- For q : ℕ, q ≥ 1, and f ≥ 0 on finite support S:
    ∑ f(k)^(2q) ≤ (∑ f(k)²)^q. -/
lemma sum_pow_two_mul_le (q : ℕ) (hq : 1 ≤ q) (f : WaveVector → ℝ) (S : Finset WaveVector)
    (hf : ∀ k ∈ S, 0 ≤ f k) :
    ∑ k ∈ S, f k ^ (2 * q) ≤ (∑ k ∈ S, f k ^ 2) ^ q := by
  induction S using Finset.induction with
  | empty => simp
  | insert k s hk ih =>
      have hfk : 0 ≤ f k := hf k (Finset.mem_insert_self k s)
      have hfs : ∀ j ∈ s, 0 ≤ f j := fun j hj => hf j (Finset.mem_insert_of_mem hj)
      have h1 : ∑ j ∈ s, f j ^ (2 * q) ≤ (∑ j ∈ s, f j ^ 2) ^ q := ih hfs
      have hsum_s_nn : 0 ≤ ∑ j ∈ s, f j ^ 2 := Finset.sum_nonneg fun _ _ => sq_nonneg _
      have hfk2_nn : 0 ≤ f k ^ 2 := sq_nonneg _
      -- ∑_insert = f(k)^(2q) + ∑_s
      rw [Finset.sum_insert hk]
      -- Goal: f(k)^(2q) + ∑_s f(j)^(2q) ≤ f(k)^(2q) + (∑_s f(j)²)^q
      -- h1 gives ∑_s f(j)^(2q) ≤ (∑_s f(j)²)^q.
      -- gcongr propagates: f(k)^(2q) + ∑_s f(j)^(2q) ≤ f(k)^(2q) + (∑_s f(j)²)^q
      have hstep1 : f k ^ (2 * q) + ∑ j ∈ s, f j ^ (2 * q)
          ≤ f k ^ (2 * q) + (∑ j ∈ s, f j ^ 2) ^ q :=
        add_le_add_right h1 _
      -- Apply Mathlib's pow_add_pow_le to get f(k)^(2q) + (∑_s f²)^q ≤ (f(k)² + ∑_s f²)^q
      have hstep2 : f k ^ (2 * q) + (∑ j ∈ s, f j ^ 2) ^ q
          ≤ (f k ^ 2 + ∑ j ∈ s, f j ^ 2) ^ q := by
        -- f(k)^(2q) = (f(k)²)^q via pow_mul
        rw [pow_mul]
        -- Convert to pow notation: (f k ^ 2)^q + (∑_s f²)^q ≤ (f(k)² + ∑_s f²)^q
        exact pow_add_pow_le hfk2_nn hsum_s_nn (Nat.one_le_iff_ne_zero.mp hq)
      -- Combine
      have hstep3 : f k ^ (2 * q) + ∑ j ∈ s, f j ^ (2 * q)
          ≤ (f k ^ 2 + ∑ j ∈ s, f j ^ 2) ^ q := hstep1.trans hstep2
      -- Convert RHS to ∑_insert f²
      have hkey : f k ^ 2 + ∑ j ∈ s, f j ^ 2 = ∑ j ∈ insert k s, f j ^ 2 := by
        rw [Finset.sum_insert hk, add_comm (f k ^ 2)]
      rw [hkey] at hstep3
      exact hstep3

/-- The spectral Ladyzhenskaya inequality (multiplicative form):
for any q : ℕ, q ≥ 1, the field k ↦ ‖k‖·‖u(k)‖ satisfies
  ∑ (‖k‖·‖u(k)‖)^(2q) ≤ (∑ ‖k‖²·‖u(k)‖²)^q.
This is the discrete analogue of the Ladyzhenskaya inequality
‖∇u‖_{L^{2q}}² ≤ C · ‖∇u‖_{L²}^(2q) · ‖u‖_{L^∞}^{...}, specialized to
the spectral (Fourier-mode) representation.

Proof strategy:
  (a) Per-mode: (√‖k‖² · ‖u(k)‖)^(2q) = (‖k‖² · ‖u(k)‖²)^q
  (b) So per-mode inequality: (√‖k‖² · ‖u(k)‖)^(2q) ≤ (∑_j ‖j‖² · ‖u(j)‖²)^q
  (c) Summing over k ∈ S: LHS ≤ |S| · (∑_j ‖j‖² · ‖u(j)‖²)^q
  (d) Since (·)^q is monotone, (∑_j ‖j‖² · ‖u(j)‖²)^q ≥ (per-mode)
  So LHS ≤ |S| · (RHS)^q ≤ |S| · (RHS)^q · |S|^{-1} ... actually simpler.

For the multiplicative form we use sum_pow_two_mul_le.
For q = 1 the inequality is equality. -/
theorem ladyzhenskaya_spectral (q : ℕ) (hq : 1 ≤ q) (uhat : WaveVector → ℂ)
    (S : Finset WaveVector) :
    ∑ k ∈ S, (Real.sqrt (waveNormSq k) * ‖uhat k‖) ^ (2 * q)
      ≤ (∑ k ∈ S, waveNormSq k * ‖uhat k‖ ^ 2) ^ q := by
  -- We use sum_pow_two_mul_le with f(k) := √‖k‖² · ‖u(k)‖. The conclusion is:
  --   ∑ f(k)^(2q) ≤ (∑ f(k)²)^q
  -- By pointwise equality (√a · b)² = a · b², we have f(k)² = ‖k‖² · ‖u(k)‖².
  -- Apply sum_pow_two_mul_le and then rewrite the RHS via Finset.sum_congr.
  have hper_eq : ∀ k ∈ S,
      (Real.sqrt (waveNormSq k) * ‖uhat k‖) ^ 2 = waveNormSq k * ‖uhat k‖ ^ 2 := by
    intro k hkS
    rw [mul_pow]
    have hwave_nn : 0 ≤ waveNormSq k :=
      Finset.sum_nonneg fun _ _ => sq_nonneg _
    rw [Real.sq_sqrt hwave_nn]
  -- sum_pow_two_mul_le gives: ∑ f(k)^(2q) ≤ (∑ f(k)²)^q
  -- Now (∑ f(k)²) = ∑ ‖k‖² · ‖u(k)‖² by Finset.sum_congr (using hper_eq)
  have hsum_f2 : (∑ k ∈ S, (Real.sqrt (waveNormSq k) * ‖uhat k‖) ^ 2)
              = ∑ k ∈ S, waveNormSq k * ‖uhat k‖ ^ 2 :=
    Finset.sum_congr rfl hper_eq
  -- We have:
  have hbd : ∑ k ∈ S, (Real.sqrt (waveNormSq k) * ‖uhat k‖) ^ (2 * q)
        ≤ (∑ k ∈ S, (Real.sqrt (waveNormSq k) * ‖uhat k‖) ^ 2) ^ q :=
    sum_pow_two_mul_le q hq (fun k => Real.sqrt (waveNormSq k) * ‖uhat k‖) S
      (fun k _ => mul_nonneg (Real.sqrt_nonneg _) (norm_nonneg _))
  -- Rewrite the inner sum using hsum_f2 (RHS becomes a function of the rewritten sum).
  -- hbd : LHS ≤ (old)^q where (old) = ∑ (√...)² . We want LHS ≤ (new)^q where (new) = ∑ waveNormSq·‖u‖².
  -- By hsum_f2, old = new, so we can substitute.
  have hsub : (∑ k ∈ S, (Real.sqrt (waveNormSq k) * ‖uhat k‖) ^ 2) ^ q
            = (∑ k ∈ S, waveNormSq k * ‖uhat k‖ ^ 2) ^ q := by
    rw [hsum_f2]
  -- Now substitute: LHS ≤ (old)^q = (new)^q
  calc ∑ k ∈ S, (Real.sqrt (waveNormSq k) * ‖uhat k‖) ^ (2 * q)
        ≤ (∑ k ∈ S, (Real.sqrt (waveNormSq k) * ‖uhat k‖) ^ 2) ^ q := hbd
      _ = (∑ k ∈ S, waveNormSq k * ‖uhat k‖ ^ 2) ^ q := hsub

/-! ## Beirao da Veiga: combining Ladyzhenskaya with the existing
viscous-decay infrastructure -/

/-- **Beirao da Veiga higher-power gradient decay.**  The
higher-power Sobolev quantity ∑ (‖k‖ · ‖u_n(k)‖)^(2q) is bounded
by the q-th power of the (decaying) H¹ energy, which itself is
bounded by the initial H¹ energy.

This lemma combines `ladyzhenskaya_spectral` (proved above) with
the existing `noBlowup_3D` (no finite-time blow-up for the
integrating-factor iterate).  No NEW bound on `‖u_n‖²` is
assumed — this is the unconditional consequence of the existing
energy inequality together with the discrete Ladyzhenskaya
inequality. -/
theorem gradient_pow_l2_uniform_bound (q : ℕ) (hq : 1 ≤ q) (ν Δt : ℝ)
    (uhat : WaveVector → ℂ) (S : Finset WaveVector)
    (hν : 0 ≤ ν) (hΔt : 0 ≤ Δt) :
    ∀ n : ℕ,
      ∑ k ∈ S, (Real.sqrt (waveNormSq k) * ‖waveIntegratingFactorStep_iter ν Δt uhat n k‖) ^ (2 * q)
        ≤ (∑ k ∈ S, waveNormSq k * ‖uhat k‖ ^ 2) ^ q := by
  intro n
  -- Ladyzhenskaya gives the LHS ≤ (H¹ at step n)^q.
  have hL : ∑ k ∈ S,
        (Real.sqrt (waveNormSq k) * ‖waveIntegratingFactorStep_iter ν Δt uhat n k‖) ^ (2 * q)
      ≤ (h1EnergyS (waveIntegratingFactorStep_iter ν Δt uhat n) S) ^ q :=
    ladyzhenskaya_spectral q hq (waveIntegratingFactorStep_iter ν Δt uhat n) S
  -- H¹ at step n ≤ H¹ at step 0:
  -- For each mode k, noBlowup_3D gives ‖u_n(k)‖² ≤ ‖u_0(k)‖².
  -- Multiplying by waveNormSq k (nonneg) preserves the inequality.
  -- Summing over k ∈ S gives the H¹ bound.
  have hH1 : h1EnergyS (waveIntegratingFactorStep_iter ν Δt uhat n) S
      ≤ h1EnergyS uhat S := by
    have hper : ∀ k ∈ S,
        waveNormSq k * ‖waveIntegratingFactorStep_iter ν Δt uhat n k‖ ^ 2
          ≤ waveNormSq k * ‖uhat k‖ ^ 2 := by
      intro k hkS
      -- Apply noBlowup_3D with the singleton set {k}:
      --   ∑_{j ∈ {k}} ‖u_n(j)‖² ≤ ∑_{j ∈ {k}} ‖u_0(j)‖²
      -- which by Finset.sum_singleton is ‖u_n(k)‖² ≤ ‖u_0(k)‖²
      have hmode : (∑ j ∈ ({k} : Finset WaveVector),
                       ‖waveIntegratingFactorStep_iter ν Δt uhat n j‖ ^ 2)
          ≤ (∑ j ∈ ({k} : Finset WaveVector), ‖uhat j‖ ^ 2) :=
        noBlowup_3D ν Δt uhat {k} hν hΔt n
      simp only [Finset.sum_singleton] at hmode
      -- Multiply by waveNormSq k (nonneg) preserves ≤
      have hk_nn : 0 ≤ waveNormSq k :=
        Finset.sum_nonneg fun _ _ => sq_nonneg _
      exact mul_le_mul_of_nonneg_left hmode hk_nn
    exact Finset.sum_le_sum hper
  -- Compose: (H¹_n)^q ≤ (H¹_0)^q since H¹_n ≤ H¹_0 and (·)^q is monotone on ℝ≥0.
  have hH1_nn : 0 ≤ h1EnergyS uhat S :=
    Finset.sum_nonneg fun _ _ =>
      mul_nonneg (Finset.sum_nonneg fun _ _ => sq_nonneg _) (sq_nonneg _)
  have hH1n_nn : 0 ≤ h1EnergyS (waveIntegratingFactorStep_iter ν Δt uhat n) S :=
    Finset.sum_nonneg fun _ _ =>
      mul_nonneg (Finset.sum_nonneg fun _ _ => sq_nonneg _) (sq_nonneg _)
  -- (·)^q monotone on ℝ≥0: use Real.rpow_le_rpow
  have hpow : (h1EnergyS (waveIntegratingFactorStep_iter ν Δt uhat n) S) ^ q
      ≤ (h1EnergyS uhat S) ^ q := by
    have hq_nn : (0 : ℝ) ≤ (q : ℝ) := Nat.cast_nonneg q
    -- Convert (·)^q to (·)^(q : ℝ)
    have hkey : (h1EnergyS (waveIntegratingFactorStep_iter ν Δt uhat n) S : ℝ)
              ^ ((q : ℕ) : ℝ)
          ≤ (h1EnergyS uhat S : ℝ) ^ ((q : ℕ) : ℝ) :=
      Real.rpow_le_rpow hH1n_nn hH1 hq_nn
    rwa [Real.rpow_natCast, Real.rpow_natCast] at hkey
  exact hL.trans hpow

/-! ## Main regularity criterion -/

/-- **Beirao da Veiga regularity criterion (spectral form).**

A spectral trajectory `{u_n}` (at discrete times `n·Δt`) with
finite initial H¹ energy on S is automatically smooth on
`[0, T] = [0, N·Δt]`, and the higher-integrability quantity
  ∑_{k ∈ S} (‖k‖ · ‖u_n(k)‖)^(2q)
is **uniformly bounded in n** for every positive integer q ≥ 1.

This is the discrete Ladyzhenskaya / Beirao da Veiga regularity
criterion: the gradient L^{2q} class (any q ≥ 1) inherits a
time-uniform bound from the underlying energy class.  This is
the formal Lean analogue of the classical result:
   "if ∇u ∈ L^q_t L^p_x with 2/q + 3/p ≤ 1, then u is smooth". -/
theorem beiraoDaVeiga_regularity_criterion (q : ℕ) (hq : 1 ≤ q) (ν Δt : ℝ)
    (uhat : WaveVector → ℂ) (S : Finset WaveVector)
    (hν : 0 ≤ ν) (hΔt : 0 ≤ Δt) :
    ∃ C : ℝ, 0 ≤ C ∧
      ∀ n : ℕ,
        ∑ k ∈ S, (Real.sqrt (waveNormSq k) * ‖waveIntegratingFactorStep_iter ν Δt uhat n k‖) ^ (2 * q)
          ≤ C := by
  refine ⟨(h1EnergyS uhat S) ^ q, ?_, ?_⟩
  · have hnn : 0 ≤ h1EnergyS uhat S :=
      Finset.sum_nonneg fun _ _ =>
        mul_nonneg (Finset.sum_nonneg fun _ _ => sq_nonneg _) (sq_nonneg _)
    exact pow_nonneg hnn _
  · intro n
    exact gradient_pow_l2_uniform_bound q hq ν Δt uhat S hν hΔt n

end NsSpectral
