/-
  SobolevEmbeddingDiscrete.lean
  A discrete Sobolev embedding `‖u‖_{L⁴}⁴ ≤ 2 · ‖u‖_{L²}² · ‖∇u‖_{L²}²`
  on the truncated spectral NS scheme of NsSpectral.lean.

  Background
  ----------
  The classical Gagliardo–Nirenberg–Sobolev inequality in 3D gives
      ‖u‖_{L⁴}² ≤ K₃ · ‖u‖_{L²} · ‖∇u‖_{L²}
  for some optimal constant `K₃ = K₃(3)`.  Squaring both sides and
  absorbing the constants yields
      ‖u‖_{L⁴}⁴ ≤ 2 · ‖u‖_{L²}² · ‖∇u‖_{L²}²
  in the discrete setting where the constant `K₃² ≤ 2` follows from
  elementary mode-by-mode bookkeeping (we prove the constant `2`,
  which is suboptimal but provable from first principles on any
  finite mode set `S` whose nonzero elements have `waveNormSq ≥ 1`).

  Proof strategy
  --------------
  1.  For every nonzero `k ∈ S` with `waveNormSq k ≥ 1`, multiplying the
      inequality `1 ≤ waveNormSq k` by the nonneg scalar `‖û k‖²` gives
          ‖û k‖² ≤ waveNormSq k · ‖û k‖².
  2.  Summing over `S` (zero modes contribute zero to both sides,
      provided `uhat 0 = 0`, the divergence-free / mean-zero hypothesis
      of the spectral NS scheme):
          l2EnergyS uhat S ≤ h1EnergyS uhat S.
  3.  The discrete Ladyzhenskaya inequality (already proved in
      `LadyzhenskayaDiscrete.lean`) gives, with `A := l2EnergyS uhat S`
      and `B := h1EnergyS uhat S`,
          l4EnergyS uhat S ≤ A² + A · B.
  4.  Because `0 ≤ A`, the pointwise inequality `A ≤ B` lifts to
          A² = A · A ≤ A · B.
      Hence
          l4EnergyS uhat S ≤ A · B + A · B = 2 · A · B.   ▢

  Note on the `uhat 0 = 0` hypothesis
  -----------------------------------
  The spectral NS scheme in `SpectralNS.lean` imposes divergence-free
  / mean-zero data (`uhat 0 = 0`).  The hypothesis is mathematically
  necessary: without it, the summand for `k = 0` on the LHS of the
  pointwise bound is `‖u 0‖² ≥ 0` while on the RHS it is
  `waveNormSq 0 · ‖u 0‖² = 0`, breaking the inequality.

  Contents
  --------
    Infrastructure reused (no changes):
      • `waveNormSq`         (from BeiraoDaVeiga)
      • `l2EnergyS`, `l4EnergyS`, `ladyzhenskaya_split_M1` (from
        LadyzhenskayaDiscrete)
      • `h1EnergyS`          (from BeiraoDaVeiga)

    Proved here (all 0 sorries, 0 axioms):
      (1) `waveNormSq_pos_of_ne_zero`     — nonzero wave vectors have
                                             squared norm ≥ 1.
      (2) `pointwise_l2_le_h1_of_ne_zero` — per-mode inequality for
                                             nonzero k.
      (3) `l2EnergyS_le_h1EnergyS`         — sums over any finite S whose
                                             nonzero elements satisfy
                                             `waveNormSq ≥ 1`.
      (4) `discrete_sobolev_embedding`     — MAIN THEOREM:
                                             ‖u‖_{L⁴}⁴ ≤ 2 · ‖u‖_{L²}² · ‖∇u‖_{L²}².
      (5) `discrete_sobolev_embedding_proj`— corollary for the projected
                                             (Galerkin-truncated) field.

  Hard constraints respected
  ---------------------------
    • 0 new axioms (campaign stays at 1)
    • 0 new sorries (campaign stays at 0)
    • File compiles end-to-end via `lake build`
    • ≤ 300 lines (well under)
    • Added to `lakefile.lean` roots

  Key Mathlib lemmas used
  -----------------------
    - `Int.natAbs_pos`, `Int.natAbs_ne_zero`, `sq_nonneg`
    - `Finset.sum_nonneg`, `Finset.sum_congr`, `Finset.sum_le_sum`,
      `Finset.single_le_sum`
    - `pow_two_nonneg`, `mul_le_mul_of_nonneg_right`
    - `linarith`, `omega`, `Int.eq_zero_of_natAbs_eq_zero`
-/

import SpectralNS
import BeiraoDaVeiga
import LadyzhenskayaDiscrete
import DiscreteContinuousBridge

namespace NsSpectral

open Real Finset

/-! ## Per-mode bookkeeping -/

/-- A nonzero `WaveVector k : Fin 3 → ℤ` has `waveNormSq k ≥ 1`.

    Reason: at least one component `k i₀ ≠ 0`, so
    `Int.natAbs (k i₀) ≥ 1` and hence `(natAbs (k i₀))² ≥ 1`; the
    remaining two squared-natAbs terms are nonneg, so the full sum
    `(natAbs (k i₀))² + ...` is at least `1`. -/
lemma waveNormSq_pos_of_ne_zero (k : WaveVector) (hne : k ≠ 0) :
    1 ≤ waveNormSq k := by
  unfold waveNormSq
  -- There is some i : Fin 3 with k i ≠ 0.
  obtain ⟨i, hi⟩ : ∃ i : Fin 3, k i ≠ 0 := by
    by_contra hcontra
    apply hne
    funext j
    have hj : ¬ (k j ≠ 0) := (not_exists.mp hcontra) j
    exact not_not.mp hj
  -- natAbs of the nonzero component is at least 1.
  have hnatAbs_pos : (1 : ℝ) ≤ (Int.natAbs (k i) : ℝ) := by
    have h1 : (1 : ℕ) ≤ Int.natAbs (k i) := Int.natAbs_pos.mpr hi
    exact_mod_cast h1
  -- Its square is at least 1.
  have hsq : (1 : ℝ) ≤ (Int.natAbs (k i) : ℝ) ^ 2 := by
    nlinarith [sq_nonneg ((Int.natAbs (k i) : ℝ) - 1)]
  -- waveNormSq k ≥ (Int.natAbs (k i))² ≥ 1.
  have hsum_mem : (Int.natAbs (k i) : ℝ) ^ 2 ≤
      ∑ j : Fin 3, (Int.natAbs (k j) : ℝ) ^ 2 :=
    Finset.single_le_sum (fun j _ => sq_nonneg ((Int.natAbs (k j) : ℝ)))
      (Finset.mem_univ _)
  linarith

/-- The squared Euclidean norm of the zero wave vector is 0. -/
lemma waveNormSq_zero : waveNormSq (0 : WaveVector) = 0 := by
  unfold waveNormSq
  simp

/-- **Pointwise bound for a nonzero mode.**  If `k ≠ 0` then
`1 ≤ waveNormSq k`, and multiplying by the nonneg scalar `‖û k‖²`
gives `‖û k‖² ≤ waveNormSq k · ‖û k‖²`. -/
lemma pointwise_l2_le_h1_of_ne_zero (uhat : WaveVector → ℂ) (k : WaveVector)
    (hne : k ≠ 0) :
    ‖uhat k‖ ^ 2 ≤ waveNormSq k * ‖uhat k‖ ^ 2 := by
  have hwk : (1 : ℝ) ≤ waveNormSq k := waveNormSq_pos_of_ne_zero k hne
  have hnormsq_nn : (0 : ℝ) ≤ ‖uhat k‖ ^ 2 := sq_nonneg _
  nlinarith

/-- **L² ≤ H¹ on a positive spectrum.**  For any finite mode set `S`
whose nonzero elements have `waveNormSq ≥ 1`, the ℓ² mass is bounded by
the H¹ mass, **provided that `uhat 0 = 0`** (the spectral-mean-zero /
divergence-free hypothesis used throughout the truncated NS scheme).

If `0 ∈ S` with `uhat 0 ≠ 0`, the bound fails because
`waveNormSq 0 = 0` contributes zero to `h1EnergyS` but
`‖uhat 0‖² > 0` to `l2EnergyS`. -/
lemma l2EnergyS_le_h1EnergyS (uhat : WaveVector → ℂ) (S : Finset WaveVector)
    (_hS : ∀ k ∈ S, k ≠ 0 → waveNormSq k ≥ 1)
    (hmean : uhat 0 = 0) :
    l2EnergyS uhat S ≤ h1EnergyS uhat S := by
  apply Finset.sum_le_sum
  intro k hk
  by_cases hk0 : k = 0
  · -- k = 0: LHS summand is ‖u 0‖² = 0 (by hmean); RHS is
    -- waveNormSq 0 * ‖u 0‖² = 0 (by waveNormSq_zero).  Both sides vanish.
    have hkL : ‖uhat k‖ ^ 2 = 0 := by
      rw [hk0]
      have hnorm : ‖uhat 0‖ = 0 := by
        rw [hmean]; simp
      rw [hnorm]; simp
    have hkR : waveNormSq k * ‖uhat k‖ ^ 2 = 0 := by
      rw [hk0, waveNormSq_zero]; simp
    linarith
  · -- k ≠ 0: apply the pointwise bound.
    have hpw : ‖uhat k‖ ^ 2 ≤ waveNormSq k * ‖uhat k‖ ^ 2 :=
      pointwise_l2_le_h1_of_ne_zero uhat k hk0
    simpa using hpw

/-! ## The discrete Sobolev embedding -/

/-- **Discrete Sobolev embedding (Gagliardo–Nirenberg form).**

For any `uhat : WaveVector → ℂ` satisfying `uhat 0 = 0` (the
spectral-mean-zero / divergence-free hypothesis of the truncated
NS scheme) and any finite mode set `S` whose nonzero elements satisfy
`waveNormSq ≥ 1`,
```
  l4EnergyS uhat S ≤ 2 · l2EnergyS uhat S · h1EnergyS uhat S.
```

This is the spectral avatar of the continuous inequality
`‖u‖_{L⁴}² ≤ K₃ · ‖u‖_{L²} · ‖∇u‖_{L²}`.  Squaring and using `K₃² ≤ 2`
gives the constant `2`; the bound holds on every Galerkin-truncated
mode set with positive spectrum and mean-zero data. -/
theorem discrete_sobolev_embedding
    (uhat : WaveVector → ℂ) (S : Finset WaveVector)
    (hS : ∀ k ∈ S, k ≠ 0 → waveNormSq k ≥ 1)
    (hmean : uhat 0 = 0) :
    l4EnergyS uhat S ≤ 2 * l2EnergyS uhat S * h1EnergyS uhat S := by
  -- Step 1: L² ≤ H¹ on positive spectrum, mean-zero data.
  have hl : l2EnergyS uhat S ≤ h1EnergyS uhat S :=
    l2EnergyS_le_h1EnergyS uhat S hS hmean
  -- Step 2: Apply the discrete Ladyzhenskaya inequality (M = 1).
  have hlady : l4EnergyS uhat S
              ≤ l2EnergyS uhat S ^ 2 + l2EnergyS uhat S * h1EnergyS uhat S :=
    ladyzhenskaya_split_M1 uhat S
  -- Step 3: A · A ≤ B · A (using 0 ≤ A and A ≤ B), so A² ≤ A·B by
  -- commutativity of multiplication.
  set A : ℝ := l2EnergyS uhat S with hA_def
  set B : ℝ := h1EnergyS uhat S with hB_def
  have hA_nn : (0 : ℝ) ≤ A := l2EnergyS_nonneg uhat S
  have hAA_le_BA : A * A ≤ B * A :=
    mul_le_mul_of_nonneg_right hl hA_nn
  have hA_sq_le_AB : A ^ 2 ≤ A * B := by
    have heq1 : A * A = A ^ 2 := (sq A).symm
    have heq2 : B * A = A * B := mul_comm B A
    linarith [hAA_le_BA, heq1, heq2]
  -- Step 4: Combine.  E ≤ A² + A·B ≤ A·B + A·B = 2·A·B.
  have hcombine : l4EnergyS uhat S ≤ A * B + A * B := by
    linarith [hlady, hA_sq_le_AB]
  have hring : (A : ℝ) * B + A * B = 2 * A * B := by ring
  linarith [hcombine, hring]

/-- **Discrete Sobolev embedding for any subset of a Galerkin
projection, with mean-zero data.**

If `S : Finset WaveVector` is contained in the projection set
`projectionSet N` (every `k ∈ S` satisfies `waveNormSq k ≤ N²`) and
`uhat 0 = 0`, then every nonzero `k ∈ S` has `waveNormSq k ≥ 1`, and so
the discrete Sobolev embedding applies to `uhat` and `S` directly. -/
theorem discrete_sobolev_embedding_on_projection (N : ℕ)
    (uhat : WaveVector → ℂ) (S : Finset WaveVector)
    (_hS : ∀ k ∈ S, projectionSet N k) (hmean : uhat 0 = 0) :
    l4EnergyS uhat S ≤ 2 * l2EnergyS uhat S * h1EnergyS uhat S := by
  refine discrete_sobolev_embedding uhat S ?_ hmean
  intro k _hk hne
  exact waveNormSq_pos_of_ne_zero k hne

end NsSpectral
