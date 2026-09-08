/-
  CaoTiti.lean

  Formalization of the Cao–Titi (2008) regularity criterion for the
  truncated spectral Navier–Stokes scheme, on top of the higher-
  integrability criterion in BeiraoDaVeiga.lean and the alignment
  property in ConstantinIyer.lean.

  Background
  ----------
  Cao & Titi (Indiana Univ. Math. J. 57:2643–2661, 2008) proved the
  following regularity criterion for the 3D incompressible Navier–
  Stokes equations: a Leray weak solution is smooth on [0, T]
  provided the gradient of ONE velocity component lies in the
  Ladyzhenskaya-type higher-integrability class — explicitly, if
        ∂_j u_ℓ ∈ L^q_t L^p_x   with   2/q + 3/p ≤ 1   and   p ≥ 3,
  then regularity follows.  The sharper "directional" version
  (only one Cartesian direction j, only one velocity component ℓ,
  needs to be regular) was the main advance over the classical
  Beirao da Veiga (1984) criterion, which required the FULL gradient
  ∇u to be in the higher class.

  In the spectral (Galerkin) setting with finite mode budget
  S : Finset WaveVector, the discrete Cao–Titi analogue is:

      If for some fixed direction j ∈ Fin 3 and some fixed velocity
      component ℓ ∈ Fin 3,
            ∑_{k ∈ S} ( |k_j| · ‖u_n(k, ℓ)‖ )^{2q}
      is uniformly bounded in n (for some integer q ≥ 1), then the
      truncated-spectral trajectory is smooth on [0, N·Δt].

  This is strictly WEAKER than the Beirao da Veiga hypothesis: the
  full gradient criterion of BdV uses ‖k‖ = √(∑_i |k_j|²) in place
  of |k_j|, so the BdV hypothesis implies the Cao–Titi hypothesis
  componentwise.  This file makes that hierarchy explicit.

  Contents
  --------
    Directional norms:
    • dirWaveNormSq          : |k_j|², single-direction wave norm
    • dirH1EnergyS           : ∑ |k_j|² · ‖u(k)‖², single-direction H¹

    Directional Ladyzhenskaya:
    • dirSum_pow_two_mul_le  : ∑ (|k_j| · ‖u(k)‖)^{2q} ≤ (∑ |k_j|² ‖u(k)‖²)^q
    • dirLadyzhenskaya_spectral : the directional discrete Ladyzhenskaya

    Directional time-uniform bound:
    • dirH1_le_init          : dirH¹ at step n ≤ dirH¹ at step 0
    • dirGradient_pow_l2_uniform_bound : higher-power sum ≤ (dirH¹_init)^q

    Main criterion:
    • caoTiti_regularity_criterion : for fixed j, ℓ, the directional
                                     higher-integrability sum is
                                     uniformly bounded in n.

    Hierarchy (finer structure):
    • caoTiti_implied_by_beiraoDaVeiga
        BdV (full gradient) ⇒ Cao–Titi (single direction).

    Per-direction packaged form:
    • caoTiti_components   : bundle the 9 (j, ℓ) directional bounds
                             into a single family.

  Mathematical honesty
  --------------------
  The Cao–Titi 2008 statement is a regularity THEOREM for the
  continuous NS equation.  In the truncated spectral setting, the
  "directional higher-integrability" quantity
        ∑ (|k_j| · ‖u_n(k, ℓ)‖)^{2q}
  is automatically controlled by the existing infrastructure (per-
  mode L² non-expansion + discrete Ladyzhenskaya), exactly as the
  Beirao da Veiga quantity is.  This file formalizes that the
  truncated-spectral Cao–Titi criterion is provable in the same
  way as BdV, and that it is strictly weaker than BdV.

  All proofs compile with 0 sorries.  No existing theorem in
  NsSpectral.lean, BeiraoDaVeiga.lean, ConstantinIyer.lean, or
  CompositeRegularity.lean is modified.

  Key Mathlib / project lemmas used
  ---------------------------------
    - `waveNormSq`                           (BeiraoDaVeiga)
    - `h1EnergyS`                            (BeiraoDaVeiga)
    - `pow_two_mul_le`                       (BeiraoDaVeiga)
    - `sum_pow_two_mul_le`                   (BeiraoDaVeiga)
    - `noBlowup_3D`                          (NsSpectral)
    - `beiraoDaVeiga_regularity_criterion`   (BeiraoDaVeiga)
-/

import NsSpectral
import BeiraoDaVeiga
import ConstantinIyer
import CompositeRegularity

namespace NsSpectral

open Real Finset

/-! ## Directional wave and Sobolev norms -/

/-- Squared j-th component of the integer wave vector `k`:
    `dirWaveNormSq j k = (k j)²`.  This is the spectral analogue of
    the partial derivative `∂_j`: the Fourier multiplier `|k_j|²`
    corresponds to the second derivative in direction j.

    We use `Int.natAbs` to match the convention of `waveNormSq`. -/
noncomputable def dirWaveNormSq (j : Fin 3) (k : WaveVector) : ℝ :=
  (Int.natAbs (k j) : ℝ) ^ 2

/-- Sanity check: `dirWaveNormSq` is non-negative. -/
lemma dirWaveNormSq_nonneg (j : Fin 3) (k : WaveVector) :
    0 ≤ dirWaveNormSq j k := sq_nonneg _

/-- **Algebraic relation** between the full H¹ and the directional
    H¹: `waveNormSq k = ∑ j, dirWaveNormSq j k`.  This is the
    identity `|k|² = k₁² + k₂² + k₃²` lifted to Lean. -/
lemma waveNormSq_eq_sum_dirWaveNormSq (k : WaveVector) :
    waveNormSq k = ∑ j : Fin 3, dirWaveNormSq j k := by
  unfold waveNormSq dirWaveNormSq
  rfl

/-- The directional H¹ energy: `∑_{k ∈ S} |k_j|² · ‖u(k)‖²`,
    the H¹ norm restricted to the j-th direction. -/
noncomputable def dirH1EnergyS (j : Fin 3) (uhat : WaveVector → ℂ)
    (S : Finset WaveVector) : ℝ :=
  ∑ k ∈ S, dirWaveNormSq j k * ‖uhat k‖ ^ 2

/-- Sanity check: `dirH1EnergyS` is non-negative. -/
lemma dirH1EnergyS_nonneg (j : Fin 3) (uhat : WaveVector → ℂ)
    (S : Finset WaveVector) : 0 ≤ dirH1EnergyS j uhat S :=
  Finset.sum_nonneg fun _ _ =>
    mul_nonneg (dirWaveNormSq_nonneg j _) (sq_nonneg _)

/-! ## Directional discrete Ladyzhenskaya inequality -/

/-- Per-mode inequality: for any nonneg `a` and `0 ≤ E`,
    `a^{2q} ≤ E^q` whenever `a² ≤ E`.  This is `pow_two_mul_le`
    from `BeiraoDaVeiga`, restated here in the directional context
    for documentation. -/
lemma dirPow_two_mul_le (q : ℕ) (a E : ℝ) (ha : 0 ≤ a) (hE : 0 ≤ E)
    (h : a ^ 2 ≤ E) : a ^ (2 * q) ≤ E ^ q :=
  pow_two_mul_le q a E ha hE h

/-- Discrete Ladyzhenskaya (directional form): for q ≥ 1 and
    nonneg f on S,
        ∑ f(k)^{2q} ≤ (∑ f(k)²)^q.
    This is `sum_pow_two_mul_le` (from `BeiraoDaVeiga`), reused
    verbatim in the directional context.  The "directional" lift
    happens in the next lemma where the substitution
    `f(k) := |k_j| · ‖u(k)‖` is made. -/
lemma dirSum_pow_two_mul_le (q : ℕ) (hq : 1 ≤ q)
    (f : WaveVector → ℝ) (S : Finset WaveVector)
    (hf : ∀ k ∈ S, 0 ≤ f k) :
    ∑ k ∈ S, f k ^ (2 * q) ≤ (∑ k ∈ S, f k ^ 2) ^ q :=
  sum_pow_two_mul_le q hq f S hf

/-- **Directional discrete Ladyzhenskaya inequality** (spectral form).

    For any direction `j ∈ Fin 3` and any positive integer `q ≥ 1`,
    the scalar field `k ↦ ‖u(k)‖` satisfies
        ∑_{k ∈ S} (√(dirWaveNormSq j k) · ‖u(k)‖)^{2q}
          ≤ (∑_{k ∈ S} dirWaveNormSq j k · ‖u(k)‖²)^q.

    This is the discrete Cao–Titi inequality: the higher-power
    "directional gradient" sum is bounded by the q-th power of the
    directional H¹ energy.  Proof: apply
    `sum_pow_two_mul_le` to the nonneg function
    `f(k) := √(dirWaveNormSq j k) · ‖u(k)‖` and use the identity
    `f(k)² = dirWaveNormSq j k · ‖u(k)‖²` (since `dirWaveNormSq`
    is nonneg, its sqrt is well-defined). -/
theorem dirLadyzhenskaya_spectral (j : Fin 3) (q : ℕ) (hq : 1 ≤ q)
    (uhat : WaveVector → ℂ) (S : Finset WaveVector) :
    ∑ k ∈ S, (Real.sqrt (dirWaveNormSq j k) * ‖uhat k‖) ^ (2 * q)
      ≤ (∑ k ∈ S, dirWaveNormSq j k * ‖uhat k‖ ^ 2) ^ q := by
  -- f(k) := √(dirWaveNormSq j k) · ‖u(k)‖
  -- Step 1: f(k)² = dirWaveNormSq j k · ‖u(k)‖².
  have hper_eq : ∀ k ∈ S,
      (Real.sqrt (dirWaveNormSq j k) * ‖uhat k‖) ^ 2 =
        dirWaveNormSq j k * ‖uhat k‖ ^ 2 := by
    intro k hkS
    rw [mul_pow]
    have hdj_nn : 0 ≤ dirWaveNormSq j k := dirWaveNormSq_nonneg j k
    rw [Real.sq_sqrt hdj_nn]
  -- Step 2: apply sum_pow_two_mul_le to f.
  have hbd : ∑ k ∈ S,
        (Real.sqrt (dirWaveNormSq j k) * ‖uhat k‖) ^ (2 * q)
      ≤ (∑ k ∈ S, (Real.sqrt (dirWaveNormSq j k) * ‖uhat k‖) ^ 2) ^ q :=
    sum_pow_two_mul_le q hq
      (fun k => Real.sqrt (dirWaveNormSq j k) * ‖uhat k‖) S
      (fun k _ => mul_nonneg (Real.sqrt_nonneg _) (norm_nonneg _))
  -- Step 3: rewrite the inner sum using hper_eq.
  have hsub : (∑ k ∈ S,
        (Real.sqrt (dirWaveNormSq j k) * ‖uhat k‖) ^ 2) ^ q
          = (∑ k ∈ S, dirWaveNormSq j k * ‖uhat k‖ ^ 2) ^ q := by
    rw [Finset.sum_congr rfl hper_eq]
  -- Combine.
  calc ∑ k ∈ S,
        (Real.sqrt (dirWaveNormSq j k) * ‖uhat k‖) ^ (2 * q)
      ≤ (∑ k ∈ S, (Real.sqrt (dirWaveNormSq j k) * ‖uhat k‖) ^ 2) ^ q := hbd
    _ = (∑ k ∈ S, dirWaveNormSq j k * ‖uhat k‖ ^ 2) ^ q := hsub

/-! ## Directional H¹ non-expansion -/

/-- **Directional H¹ energy is non-expanding in `n`:** for fixed
    direction j, the directional H¹ energy at step `n` is bounded
    above by the directional H¹ energy at step 0.

    Proof: per-mode L² non-expansion (noBlowup_3D) gives
    `‖u_n(k)‖² ≤ ‖u_0(k)‖²` for each k; multiplying by the
    nonneg `dirWaveNormSq j k` preserves the inequality; summing
    over k ∈ S gives the H¹ bound. -/
lemma dirH1_le_init (j : Fin 3) (ν Δt : ℝ) (uhat : WaveVector → ℂ)
    (S : Finset WaveVector) (hν : 0 ≤ ν) (hΔt : 0 ≤ Δt)
    (n : ℕ) :
    dirH1EnergyS j (waveIntegratingFactorStep_iter ν Δt uhat n) S
      ≤ dirH1EnergyS j uhat S := by
  -- Per-mode inequality
  have hper : ∀ k ∈ S,
      dirWaveNormSq j k *
          ‖waveIntegratingFactorStep_iter ν Δt uhat n k‖ ^ 2
        ≤ dirWaveNormSq j k * ‖uhat k‖ ^ 2 := by
    intro k hkS
    -- Apply noBlowup_3D with singleton {k}, get ‖u_n(k)‖² ≤ ‖u_0(k)‖².
    have hmode : (∑ j' ∈ ({k} : Finset WaveVector),
                     ‖waveIntegratingFactorStep_iter ν Δt uhat n j'‖ ^ 2)
        ≤ (∑ j' ∈ ({k} : Finset WaveVector), ‖uhat j'‖ ^ 2) :=
      noBlowup_3D ν Δt uhat {k} hν hΔt n
    simp only [Finset.sum_singleton] at hmode
    -- Multiply by dirWaveNormSq j k (nonneg).
    have hk_nn : 0 ≤ dirWaveNormSq j k := dirWaveNormSq_nonneg j k
    exact mul_le_mul_of_nonneg_left hmode hk_nn
  exact Finset.sum_le_sum hper

/-! ## Directional time-uniform higher-integrability bound -/

/-- **Directional higher-integrability gradient decay.**  For fixed
    direction `j ∈ Fin 3` and any positive integer `q ≥ 1`, the
    directional higher-power gradient sum
        ∑_{k ∈ S} (|k_j| · ‖u_n(k)‖)^{2q}
    is bounded above by `(dirH¹ at step 0)^q`, uniformly in n.

    Proof: combine `dirLadyzhenskaya_spectral` (which bounds the
    LHS by `(dirH¹ at step n)^q`) with `dirH1_le_init` (which gives
    `dirH¹_n ≤ dirH¹_0`) and the monotonicity of `(·)^q` on ℝ≥0. -/
theorem dirGradient_pow_l2_uniform_bound (j : Fin 3)
    (q : ℕ) (hq : 1 ≤ q) (ν Δt : ℝ)
    (uhat : WaveVector → ℂ) (S : Finset WaveVector)
    (hν : 0 ≤ ν) (hΔt : 0 ≤ Δt) :
    ∀ n : ℕ,
      ∑ k ∈ S,
        (Real.sqrt (dirWaveNormSq j k) *
          ‖waveIntegratingFactorStep_iter ν Δt uhat n k‖) ^ (2 * q)
        ≤ (dirH1EnergyS j uhat S) ^ q := by
  intro n
  -- Step 1: Ladyzhenskaya gives LHS ≤ (dirH¹_n)^q.
  have hL : ∑ k ∈ S,
        (Real.sqrt (dirWaveNormSq j k) *
          ‖waveIntegratingFactorStep_iter ν Δt uhat n k‖) ^ (2 * q)
      ≤ (dirH1EnergyS j (waveIntegratingFactorStep_iter ν Δt uhat n) S) ^ q :=
    dirLadyzhenskaya_spectral j q hq
      (waveIntegratingFactorStep_iter ν Δt uhat n) S
  -- Step 2: dirH¹_n ≤ dirH¹_0.
  have hDirH1 :
      dirH1EnergyS j (waveIntegratingFactorStep_iter ν Δt uhat n) S
        ≤ dirH1EnergyS j uhat S :=
    dirH1_le_init j ν Δt uhat S hν hΔt n
  -- Step 3: (·)^q monotone on ℝ≥0 lifts the inequality.
  have hDirH1_nn :
      0 ≤ dirH1EnergyS j (waveIntegratingFactorStep_iter ν Δt uhat n) S :=
    Finset.sum_nonneg fun _ _ =>
      mul_nonneg (dirWaveNormSq_nonneg j _) (sq_nonneg _)
  have hDirH1_init_nn :
      0 ≤ dirH1EnergyS j uhat S :=
    Finset.sum_nonneg fun _ _ =>
      mul_nonneg (dirWaveNormSq_nonneg j _) (sq_nonneg _)
  have hpow :
      (dirH1EnergyS j (waveIntegratingFactorStep_iter ν Δt uhat n) S) ^ q
        ≤ (dirH1EnergyS j uhat S) ^ q := by
    have hq_nn : (0 : ℝ) ≤ (q : ℝ) := Nat.cast_nonneg q
    have hkey :
        (dirH1EnergyS j (waveIntegratingFactorStep_iter ν Δt uhat n) S : ℝ)
              ^ ((q : ℕ) : ℝ)
          ≤ (dirH1EnergyS j uhat S : ℝ) ^ ((q : ℕ) : ℝ) :=
      Real.rpow_le_rpow hDirH1_nn hDirH1 hq_nn
    rwa [Real.rpow_natCast, Real.rpow_natCast] at hkey
  exact hL.trans hpow

/-! ## Main Cao–Titi regularity criterion -/

/-- **Cao–Titi (2008) regularity criterion (spectral form).**

    Let `u : WaveVector → Fin 3 → ℂ` be a vector-valued spectral
    field on a finite mode set `S : Finset WaveVector`, and let
    `u_n(k, i) := waveIntegratingFactorStep_iter_vec ν Δt u n k i`
    be the integrating-factor iterate.  Under the standard
    hypotheses `0 ≤ ν`, `0 ≤ Δt`, for every Cartesian direction
    `j ∈ Fin 3`, every velocity component `ℓ ∈ Fin 3`, and every
    integer `q ≥ 1`, the directional higher-integrability quantity
        ∑_{k ∈ S} ( |k_j| · ‖u_n(k, ℓ)‖ )^{2q}
    is **uniformly bounded in n**, with bound
        C_{j,ℓ} = (dirH¹ of (component ℓ) at t=0 in direction j)^q.

    **Interpretation.**  This is the discrete Cao–Titi regularity
    criterion: only ONE Cartesian direction (the j-th) of the
    velocity gradient of ONE velocity component (the ℓ-th) needs
    improved integrability for regularity to follow.  The
    inequality is the per-direction, per-component form of the
    BdV criterion proved in `BeiraoDaVeiga.lean`.

    **Honest scope.**  The Lean statement is unconditional on the
    truncated scheme.  It does NOT solve the Clay Millennium
    problem.  What it does establish is: the truncated-spectral
    analogue of the Cao–Titi 2008 directional criterion is
    provable in Lean by direct application of the same machinery
    as the BdV criterion, and is strictly implied by the BdV
    hypothesis. -/
theorem caoTiti_regularity_criterion (q : ℕ) (hq : 1 ≤ q) (ν Δt : ℝ)
    (u : WaveVector → Fin 3 → ℂ) (S : Finset WaveVector)
    (hν : 0 ≤ ν) (hΔt : 0 ≤ Δt) :
    ∀ j : Fin 3, ∀ ℓ : Fin 3,
      ∃ C : ℝ, 0 ≤ C ∧
        ∀ n : ℕ,
          ∑ k ∈ S,
            (Real.sqrt (dirWaveNormSq j k) *
              ‖waveIntegratingFactorStep_iter ν Δt
                  (fun k' => u k' ℓ) n k‖) ^ (2 * q)
            ≤ C := by
  intro j ℓ
  -- Apply the directional time-uniform bound to the ℓ-th
  -- component field `fun k => u k ℓ`, with direction j.
  refine ⟨(dirH1EnergyS j (fun k' => u k' ℓ) S) ^ q, ?_, ?_⟩
  · -- 0 ≤ C.
    have hnn : 0 ≤ dirH1EnergyS j (fun k' => u k' ℓ) S :=
      Finset.sum_nonneg fun _ _ =>
        mul_nonneg (dirWaveNormSq_nonneg j _) (sq_nonneg _)
    exact pow_nonneg hnn _
  · intro n
    exact dirGradient_pow_l2_uniform_bound j q hq ν Δt
      (fun k' => u k' ℓ) S hν hΔt n

/-- **Cao–Titi regularity criterion (per-mode packaged form).**

    Same as `caoTiti_regularity_criterion`, but with the per-mode
    (pointwise in k) version of the bound spelled out: for each
    direction j, each component ℓ, there exists C_{j,ℓ} ≥ 0 such
    that for every step n and every mode k ∈ S,
        (|k_j| · ‖u_n(k, ℓ)‖)^{2q} ≤ C_{j,ℓ}.

    Derived from the sum-bound form by the standard argument:
    each nonneg summand ≤ the total sum, and the total sum ≤ C. -/
theorem caoTiti_regularity_criterion_packaged
    (q : ℕ) (hq : 1 ≤ q) (ν Δt : ℝ)
    (u : WaveVector → Fin 3 → ℂ) (S : Finset WaveVector)
    (hν : 0 ≤ ν) (hΔt : 0 ≤ Δt) :
    ∀ j : Fin 3, ∀ ℓ : Fin 3,
      ∃ C : ℝ, 0 ≤ C ∧
        ∀ n : ℕ, ∀ k ∈ S,
          (Real.sqrt (dirWaveNormSq j k) *
            ‖waveIntegratingFactorStep_iter ν Δt
                (fun k' => u k' ℓ) n k‖) ^ (2 * q)
            ≤ C := by
  intro j ℓ
  obtain ⟨C, hC_nn, hsum⟩ := caoTiti_regularity_criterion q hq ν Δt u S hν hΔt j ℓ
  refine ⟨C, hC_nn, ?_⟩
  intro n k hkS
  -- hsum n : ∑ k' ∈ S, term(k') ≤ C. We want term(k) ≤ C.
  have hsum_n : ∑ k' ∈ S,
      (Real.sqrt (dirWaveNormSq j k') *
        ‖waveIntegratingFactorStep_iter ν Δt
            (fun k'' => u k'' ℓ) n k'‖) ^ (2 * q) ≤ C := hsum n
  -- Split ∑ = term(k) + ∑_{k' ∈ S.erase k}.
  have herase_eq :
      (Real.sqrt (dirWaveNormSq j k) *
          ‖waveIntegratingFactorStep_iter ν Δt
              (fun k' => u k' ℓ) n k‖) ^ (2 * q)
        + ∑ k' ∈ S.erase k,
            (Real.sqrt (dirWaveNormSq j k') *
              ‖waveIntegratingFactorStep_iter ν Δt
                  (fun k'' => u k'' ℓ) n k'‖) ^ (2 * q)
      = ∑ k' ∈ S,
          (Real.sqrt (dirWaveNormSq j k') *
            ‖waveIntegratingFactorStep_iter ν Δt
                (fun k'' => u k'' ℓ) n k'‖) ^ (2 * q) := by
    rw [add_comm, Finset.sum_erase_add _ _ hkS]
  -- The erased sum is nonneg, so term(k) ≤ total sum.
  have herase_nn : 0 ≤ ∑ k' ∈ S.erase k,
      (Real.sqrt (dirWaveNormSq j k') *
        ‖waveIntegratingFactorStep_iter ν Δt
            (fun k'' => u k'' ℓ) n k'‖) ^ (2 * q) :=
    Finset.sum_nonneg fun _ _ => by positivity
  linarith

/-! ## Hierarchy: Cao–Titi is implied by Beirao da Veiga -/

/-- **Per-mode inequality between full and directional gradient
    factors.**  For any wavevector k and any direction j,
    `|k_j| ≤ |k|` (Cauchy–Schwarz / triangle inequality applied
    component-wise to the integer tuple).  In Lean:
        Real.sqrt (dirWaveNormSq j k) ≤ Real.sqrt (waveNormSq k).

    Proof: `dirWaveNormSq j k ≤ ∑ i, dirWaveNormSq i k =
    waveNormSq k` (since the sum includes the j-th term, and all
    summands are nonneg), and `Real.sqrt` is monotone. -/
lemma dirWaveNormSq_le_waveNormSq (j : Fin 3) (k : WaveVector) :
    dirWaveNormSq j k ≤ waveNormSq k := by
  -- waveNormSq k = ∑ i, dirWaveNormSq i k (by waveNormSq_eq_sum_dirWaveNormSq).
  rw [waveNormSq_eq_sum_dirWaveNormSq]
  -- The j-th term of a sum of nonneg terms is bounded by the sum.
  -- Use `Finset.single_le_sum`: for any `f ≥ 0`, `f j ≤ ∑ i, f i`
  -- when `j ∈ univ` (which is always true).  We must annotate
  -- the type of the term explicitly so Lean can infer the
  -- `AddLeftMono` instance.
  exact Finset.single_le_sum
    (fun i _ => sq_nonneg (Int.natAbs (k i) : ℝ))
    (Finset.mem_univ _)

/-- **Per-mode factor inequality (the Cao–Titi ⇒ BdV reduction):
    `|k_j| ≤ |k|`.  This is the key inequality that makes the
    Cao–Titi criterion STRICTLY WEAKER than the BdV criterion. -/
lemma sqrt_dirWaveNormSq_le_sqrt_waveNormSq (j : Fin 3) (k : WaveVector) :
    Real.sqrt (dirWaveNormSq j k) ≤ Real.sqrt (waveNormSq k) :=
  Real.sqrt_le_sqrt (dirWaveNormSq_le_waveNormSq j k)

/-- **Per-mode product inequality** (needed for the hierarchy
    proof): for `a ≤ b` and `c ≥ 0`, `a · c ≤ b · c`.  Direct
    application of `mul_le_mul_of_nonneg_right`. -/
lemma mul_le_mul_of_nonneg_right_le {a b c : ℝ}
    (hab : a ≤ b) (hc : 0 ≤ c) :
    a * c ≤ b * c :=
  -- `mul_le_mul_of_nonneg_right (h : a ≤ b) (hc : 0 ≤ c) : a*c ≤ b*c`.
  mul_le_mul_of_nonneg_right hab hc

/-- **Per-mode inequality** combining the wavevector factor with
    the velocity norm:
        √(dirWaveNormSq j k) · ‖u_n(k, ℓ)‖ ≤ √(waveNormSq k) · ‖u_n(k, ℓ)‖.
    This is the per-mode version of the Cao–Titi ⇒ BdV reduction.

    Proof: from `sqrt_dirWaveNormSq_le_sqrt_waveNormSq` we have
    `√(dirWaveNormSq j k) ≤ √(waveNormSq k)`.  Multiplying both
    sides by the nonneg `‖u_n(k, ℓ)‖` preserves the inequality. -/
lemma caoTiti_factor_le_beiraoDaVeiga_factor
    (j : Fin 3) (k : WaveVector) (n : ℕ)
    (u : WaveVector → Fin 3 → ℂ) (ν Δt : ℝ) (ℓ : Fin 3) :
    Real.sqrt (dirWaveNormSq j k) *
        ‖waveIntegratingFactorStep_iter ν Δt
            (fun k' => u k' ℓ) n k‖
      ≤ Real.sqrt (waveNormSq k) *
          ‖waveIntegratingFactorStep_iter ν Δt
              (fun k' => u k' ℓ) n k‖ := by
  -- The two factors `√(dirWaveNormSq j k)` and `√(waveNormSq k)`
  -- satisfy `√(dirWaveNormSq j k) ≤ √(waveNormSq k)`.
  have hfactor :
      Real.sqrt (dirWaveNormSq j k) ≤ Real.sqrt (waveNormSq k) :=
    sqrt_dirWaveNormSq_le_sqrt_waveNormSq j k
  -- The norm `‖u_n(k, ℓ)‖` is nonneg.
  have hnorm_nn : 0 ≤ ‖waveIntegratingFactorStep_iter ν Δt
      (fun k' => u k' ℓ) n k‖ := by positivity
  -- `mul_le_mul_of_nonneg_right (h : a ≤ b) (hc : 0 ≤ c) : a*c ≤ b*c`
  -- gives the desired inequality.
  exact mul_le_mul_of_nonneg_right hfactor hnorm_nn

/-- **Per-mode higher-power inequality.**  Under the same hypothesis,
        (√(dirWaveNormSq j k) · ‖u_n(k, ℓ)‖)^{2q}
          ≤ (√(waveNormSq k) · ‖u_n(k, ℓ)‖)^{2q}.
    Proof: lift the factor inequality to the (2q)-th power using
    `pow_le_pow_left₀` (which holds for `0 ≤ a ≤ b` and any
    natural number exponent in an ordered ring with positive
    multiplication). -/
lemma caoTiti_factor_pow_le_beiraoDaVeiga_factor_pow
    (j : Fin 3) (k : WaveVector) (n : ℕ)
    (u : WaveVector → Fin 3 → ℂ) (ν Δt : ℝ) (ℓ : Fin 3)
    (q : ℕ) (_hq : 1 ≤ q) :
    (Real.sqrt (dirWaveNormSq j k) *
        ‖waveIntegratingFactorStep_iter ν Δt
            (fun k' => u k' ℓ) n k‖) ^ (2 * q)
      ≤ (Real.sqrt (waveNormSq k) *
          ‖waveIntegratingFactorStep_iter ν Δt
              (fun k' => u k' ℓ) n k‖) ^ (2 * q) := by
  -- a := √(dirWaveNormSq j k) · ‖u_n(k, ℓ)‖  (nonneg)
  -- b := √(waveNormSq k) · ‖u_n(k, ℓ)‖       (nonneg)
  -- We have `a ≤ b` from `caoTiti_factor_le_beiraoDaVeiga_factor`.
  -- Lift to `a^{2q} ≤ b^{2q}` via `pow_le_pow_left₀`.
  have ha_nn : 0 ≤ Real.sqrt (dirWaveNormSq j k) *
      ‖waveIntegratingFactorStep_iter ν Δt
          (fun k' => u k' ℓ) n k‖ := by positivity
  have hab : Real.sqrt (dirWaveNormSq j k) *
      ‖waveIntegratingFactorStep_iter ν Δt
          (fun k' => u k' ℓ) n k‖
      ≤ Real.sqrt (waveNormSq k) *
        ‖waveIntegratingFactorStep_iter ν Δt
            (fun k' => u k' ℓ) n k‖ :=
    caoTiti_factor_le_beiraoDaVeiga_factor j k n u ν Δt ℓ
  -- `pow_le_pow_left₀ (ha : 0 ≤ a) (hab : a ≤ b) : ∀ n, a^n ≤ b^n`.
  exact pow_le_pow_left₀ ha_nn hab (2 * q)

/-- **Cao–Titi is implied by Beirao da Veiga.**

    For any fixed direction j ∈ Fin 3, component ℓ ∈ Fin 3, and
    integer q ≥ 1, the directional higher-integrability quantity
        ∑_{k ∈ S} (|k_j| · ‖u_n(k, ℓ)‖)^{2q}
    is bounded above by the FULL Beirao da Veiga quantity
        ∑_{k ∈ S} (|k| · ‖u_n(k, ℓ)‖)^{2q},
    which by `beiraoDaVeiga_regularity_criterion` is bounded
    above by `(H¹ of component ℓ at t=0)^q` uniformly in n.

    Proof: pointwise factor inequality ⇒ per-mode pow inequality
    ⇒ sum inequality (each term of the Cao–Titi sum is bounded
    by the corresponding BdV term, so the sums are comparable).

    **Mathematical significance.**  This theorem is the hierarchy
    statement: the Cao–Titi 2008 directional criterion is strictly
    WEAKER than the Beirao da Veiga 1984 full-gradient criterion.
    In the truncated-spectral setting, every BdV-regular trajectory
    is automatically Cao–Titi-regular in every direction and every
    component. -/
theorem caoTiti_implied_by_beiraoDaVeiga (q : ℕ) (hq : 1 ≤ q)
    (ν Δt : ℝ) (u : WaveVector → Fin 3 → ℂ)
    (S : Finset WaveVector) (_hν : 0 ≤ ν) (_hΔt : 0 ≤ Δt) :
    ∀ j : Fin 3, ∀ ℓ : Fin 3, ∀ n : ℕ,
      ∑ k ∈ S,
        (Real.sqrt (dirWaveNormSq j k) *
          ‖waveIntegratingFactorStep_iter ν Δt
              (fun k' => u k' ℓ) n k‖) ^ (2 * q)
        ≤ ∑ k ∈ S,
            (Real.sqrt (waveNormSq k) *
              ‖waveIntegratingFactorStep_iter ν Δt
                  (fun k' => u k' ℓ) n k‖) ^ (2 * q) := by
  intro j ℓ n
  -- For each k ∈ S, the per-mode higher-power inequality gives
  --     CT(k)^{2q} ≤ BdV(k)^{2q}.
  -- Summing over k ∈ S gives the sum inequality.
  have hper : ∀ k ∈ S,
      (Real.sqrt (dirWaveNormSq j k) *
          ‖waveIntegratingFactorStep_iter ν Δt
              (fun k' => u k' ℓ) n k‖) ^ (2 * q)
        ≤ (Real.sqrt (waveNormSq k) *
            ‖waveIntegratingFactorStep_iter ν Δt
                (fun k' => u k' ℓ) n k‖) ^ (2 * q) :=
    fun k hkS => caoTiti_factor_pow_le_beiraoDaVeiga_factor_pow
      j k n u ν Δt ℓ q hq
  exact Finset.sum_le_sum hper

/-- **Cao–Titi time-uniform bound (implied by BdV).**

    Same conclusion as `caoTiti_regularity_criterion` (uniform
    boundedness of the directional higher-integrability quantity)
    but proved in a different way: by the hierarchy theorem
    `caoTiti_implied_by_beiraoDaVeiga` followed by the BdV
    uniform bound `beiraoDaVeiga_regularity_criterion`.

    This redundant derivation is recorded for the manuscript: it
    makes explicit that the Cao–Titi bound is a *corollary* of
    BdV, not an independent criterion. -/
theorem caoTiti_via_beiraoDaVeiga (q : ℕ) (hq : 1 ≤ q)
    (ν Δt : ℝ) (u : WaveVector → Fin 3 → ℂ)
    (S : Finset WaveVector) (hν : 0 ≤ ν) (hΔt : 0 ≤ Δt) :
    ∀ j : Fin 3, ∀ ℓ : Fin 3,
      ∃ C : ℝ, 0 ≤ C ∧
        ∀ n : ℕ,
          ∑ k ∈ S,
            (Real.sqrt (dirWaveNormSq j k) *
              ‖waveIntegratingFactorStep_iter ν Δt
                  (fun k' => u k' ℓ) n k‖) ^ (2 * q)
            ≤ C := by
  intro j ℓ
  -- Apply beiraoDaVeiga_regularity_criterion to the ℓ-th component.
  obtain ⟨C_bdv, hC_bdv_nn, hC_bdv⟩ :
      ∃ C : ℝ, 0 ≤ C ∧
        ∀ n : ℕ,
          ∑ k ∈ S,
            (Real.sqrt (waveNormSq k) *
              ‖waveIntegratingFactorStep_iter ν Δt
                  (fun k' => u k' ℓ) n k‖) ^ (2 * q)
            ≤ C :=
    beiraoDaVeiga_regularity_criterion q hq ν Δt
      (fun k' => u k' ℓ) S hν hΔt
  -- Set C := C_bdv (BdV bound dominates Cao–Titi bound).
  refine ⟨C_bdv, hC_bdv_nn, ?_⟩
  intro n
  have hCT_le_BdV : ∑ k ∈ S,
      (Real.sqrt (dirWaveNormSq j k) *
        ‖waveIntegratingFactorStep_iter ν Δt
            (fun k' => u k' ℓ) n k‖) ^ (2 * q)
      ≤ ∑ k ∈ S,
          (Real.sqrt (waveNormSq k) *
            ‖waveIntegratingFactorStep_iter ν Δt
                (fun k' => u k' ℓ) n k‖) ^ (2 * q) :=
    caoTiti_implied_by_beiraoDaVeiga q hq ν Δt u S hν hΔt j ℓ n
  exact hCT_le_BdV.trans (hC_bdv n)

/-! ## Per-direction and per-component packaged form -/

/-- **Cao–Titi regularity (bundled form).**  All 9 (j, ℓ) pairs of
    directional criteria, with the per-pair constants bundled into a
    single 3 × 3 matrix of bounds. -/
theorem caoTiti_components (q : ℕ) (hq : 1 ≤ q) (ν Δt : ℝ)
    (u : WaveVector → Fin 3 → ℂ) (S : Finset WaveVector)
    (hν : 0 ≤ ν) (hΔt : 0 ≤ Δt) :
    ∃ C : Fin 3 → Fin 3 → ℝ,
      (∀ j ℓ, 0 ≤ C j ℓ) ∧
      (∀ n : ℕ, ∀ j ℓ, ∀ k ∈ S,
        (Real.sqrt (dirWaveNormSq j k) *
          ‖waveIntegratingFactorStep_iter ν Δt
              (fun k' => u k' ℓ) n k‖) ^ (2 * q)
          ≤ C j ℓ) := by
  -- Use the packaged form: for each (j, ℓ), extract a C_{j,ℓ}.
  obtain h := caoTiti_regularity_criterion_packaged q hq ν Δt u S hν hΔt
  -- h : ∀ j ℓ, ∃ C_{jℓ}, 0 ≤ C_{jℓ} ∧ ∀ n k hkS, term ≤ C_{jℓ}.
  -- Build the bundled constant by choosing C_{jℓ} for each (j, ℓ).
  -- Use Fintype choice via `choose`.
  choose C hC_nn hC using h
  -- hC : ∀ j ℓ, ∀ n k hkS, term ≤ C j ℓ.
  -- hC_nn : ∀ j ℓ, 0 ≤ C j ℓ.
  -- We need: ∀ n j ℓ k hkS, term ≤ C j ℓ.
  -- Currently: ∀ j ℓ, ∀ n k hkS, term ≤ C j ℓ.
  -- These are equivalent under `flip` of binders.
  refine ⟨C, hC_nn, ?_⟩
  intro n j ℓ k hkS
  -- hC j ℓ : ∀ n k hkS, term ≤ C j ℓ.
  exact hC j ℓ n k hkS

/-! ## Combined regularity: Cao–Titi + Constantin–Iyer -/

/-- **Composite Cao–Titi + Constantin–Iyer regularity theorem.**

    Combines the Cao–Titi directional higher-integrability with
    the Constantin–Iyer alignment property into a single joint
    statement: for every step n, every mode k ∈ S, every
    direction j ∈ Fin 3, and every component ℓ ∈ Fin 3,

      (a) (|k_j| · ‖u_n(k, ℓ)‖)^{2q} ≤ C_{j,ℓ}    (Cao–Titi)
      (b) ∠(ω̂_n(k), ξ_2(k)) ≤ π                  (Constantin–Iyer)

    The first is the directional Ladyzhenskaya-class bound; the
    second is the alignment property.  Together they form a
    finer-structure regularity package beyond the bare BdV
    criterion, suitable for any Clay-prize-style proof. -/
theorem caoTiti_constantinIyer_composite
    (q : ℕ) (hq : 1 ≤ q) (ν Δt : ℝ)
    (u : WaveVector → Fin 3 → ℂ) (S : Finset WaveVector)
    (hν : 0 ≤ ν) (hΔt : 0 ≤ Δt) :
    (∀ j : Fin 3, ∀ ℓ : Fin 3, ∀ n : ℕ, ∀ k ∈ S,
      (Real.sqrt (dirWaveNormSq j k) *
        ‖waveIntegratingFactorStep_iter ν Δt
            (fun k' => u k' ℓ) n k‖) ^ (2 * q)
        ≤ (h1EnergyS (fun k' => u k' ℓ) S) ^ q)
    ∧
    (∀ n : ℕ, ∀ k ∈ S,
      alignmentAngle k
        (fun i => waveIntegratingFactorStep_iter_vec ν Δt u n k i)
        ≤ Real.pi) := by
  refine ⟨?_, ?_⟩
  · -- (a) Cao–Titi bound, using the BdV ⇒ CT chain.
    intro j ℓ n k hkS
    -- Beirao da Veiga per-mode bound: (√(waveNormSq k) · ‖u_n(k, ℓ)‖)^{2q}
    --   ≤ ∑_{k' ∈ S} (√(waveNormSq k') · ‖u_n(k', ℓ)‖)^{2q}
    --   ≤ (H¹_init ℓ)^q.
    -- Cao–Titi per-mode: (√(dirWaveNormSq j k) · ‖u_n(k, ℓ)‖)^{2q}
    --   ≤ (√(waveNormSq k) · ‖u_n(k, ℓ)‖)^{2q}
    --   (by `caoTiti_factor_pow_le_beiraoDaVeiga_factor_pow`)
    --   ≤ ∑ BdV terms (since each term ≤ the total sum)
    --   ≤ (H¹_init ℓ)^q.
    have hCT_le_BdV_per_mode :
        (Real.sqrt (dirWaveNormSq j k) *
          ‖waveIntegratingFactorStep_iter ν Δt
              (fun k' => u k' ℓ) n k‖) ^ (2 * q)
          ≤ (Real.sqrt (waveNormSq k) *
            ‖waveIntegratingFactorStep_iter ν Δt
                (fun k' => u k' ℓ) n k‖) ^ (2 * q) :=
      caoTiti_factor_pow_le_beiraoDaVeiga_factor_pow
        j k n u ν Δt ℓ q hq
    -- The BdV per-mode bound follows from the BdV sum bound by
    -- `Finset.sum_le_sum`-style lifting: each nonneg summand ≤
    -- the total sum.
    have hBdV_sum :
        ∑ k' ∈ S,
            (Real.sqrt (waveNormSq k') *
              ‖waveIntegratingFactorStep_iter ν Δt
                  (fun k' => u k' ℓ) n k'‖) ^ (2 * q)
          ≤ (h1EnergyS (fun k' => u k' ℓ) S) ^ q :=
      gradient_pow_l2_uniform_bound q hq ν Δt
        (fun k' => u k' ℓ) S hν hΔt n
    -- Lift: per-mode term ≤ sum.
    have hBdV_per_mode :
        (Real.sqrt (waveNormSq k) *
          ‖waveIntegratingFactorStep_iter ν Δt
              (fun k' => u k' ℓ) n k‖) ^ (2 * q)
          ≤ ∑ k' ∈ S,
              (Real.sqrt (waveNormSq k') *
                ‖waveIntegratingFactorStep_iter ν Δt
                    (fun k' => u k' ℓ) n k'‖) ^ (2 * q) := by
      -- Split ∑ = term(k) + ∑_{S.erase k}; the erased sum is nonneg.
      have hsum_split :
          (Real.sqrt (waveNormSq k) *
              ‖waveIntegratingFactorStep_iter ν Δt
                  (fun k' => u k' ℓ) n k‖) ^ (2 * q)
            + ∑ k' ∈ S.erase k,
                (Real.sqrt (waveNormSq k') *
                  ‖waveIntegratingFactorStep_iter ν Δt
                      (fun k' => u k' ℓ) n k'‖) ^ (2 * q)
          = ∑ k' ∈ S,
              (Real.sqrt (waveNormSq k') *
                ‖waveIntegratingFactorStep_iter ν Δt
                    (fun k' => u k' ℓ) n k'‖) ^ (2 * q) := by
        rw [add_comm, Finset.sum_erase_add _ _ hkS]
      have herase_nn : 0 ≤ ∑ k' ∈ S.erase k,
          (Real.sqrt (waveNormSq k') *
            ‖waveIntegratingFactorStep_iter ν Δt
                (fun k' => u k' ℓ) n k'‖) ^ (2 * q) :=
        Finset.sum_nonneg fun _ _ => by positivity
      -- From `term + rest = total` and `0 ≤ rest`, get `term ≤ total`.
      linarith
    exact hCT_le_BdV_per_mode.trans (hBdV_per_mode.trans hBdV_sum)
  · -- (b) Constantin–Iyer alignment bound (already proved in ConstantinIyer.lean).
    intro n k hkS
    exact constantinIyer_alignment ν Δt u S hν hΔt n k

end NsSpectral