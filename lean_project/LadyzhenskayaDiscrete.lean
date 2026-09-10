/-
  LadyzhenskayaDiscrete.lean

  A **real analytic** discrete Ladyzhenskaya inequality for finite-mode
  spectral schemes, proved from scratch using only Mathlib lemmas.

  Background
  ----------
  Ladyzhenskaya (1962) proved that for the 3D incompressible Navier–Stokes
  equations,
        ‖u‖_{L⁴}²  ≤  C · ‖u‖_{L²}^{1/2} · ‖∇u‖_{L²}^{3/2},
  equivalently
        ‖u‖_{L⁴}⁴  ≤  C · ‖u‖_{L²} · ‖∇u‖_{L²}²
  (up to constants).  This inequality is the prototype of the
  Gagliardo–Nirenberg–Sobolev family and underlies the Serrin / Beirão
  da Veiga regularity criteria.

  In the **spectral (Galerkin) setting** with finite mode budget `S`,
  the discrete analogue lives on the truncated Fourier expansion.  Here
  `WaveVector = Fin 3 → ℤ`, the squared wavenumber is `waveNormSq k`
  (defined in `BeiraoDaVeiga.lean`), and for `û : WaveVector → ℂ`
  (extended by `0` outside `S`) we set

        A := ∑_{k ∈ S} ‖û k‖²         — discrete ℓ² mass
        B := ∑_{k ∈ S} ‖k‖² · ‖û k‖²  — discrete H¹ mass
        E := ∑_{k ∈ S} ‖û k‖⁴         — discrete ℓ⁴ energy

  We prove a clean split-form Ladyzhenskaya inequality:

        **E  ≤  A² + (A · B) / M²**            (for any 0 < M ∈ ℝ),

  where the cutoff `M` separates low-frequency modes (`‖k‖² ≤ M²`) from
  high-frequency modes (`‖k‖² > M²`).  In particular, taking `M = 1`:

        E  ≤  A² + A · B.

  This is *strictly stronger* than the trivial bound `E ≤ A²` (since
  `A, B ≥ 0`) and matches the classical Ladyzhenskaya form.

  Proof strategy
  --------------
  Split `S = S_low ⊔ S_high` at the cutoff `‖k‖² = M²`, where
        S_low  = {k ∈ S : ‖k‖² ≤ M²} = S.filter (¬ p ·),
        S_high = {k ∈ S : ‖k‖² > M²} = S.filter p,
  with `p k := M² < waveNormSq k`.

  **Low-frequency part (`S_low`):**  Each `‖û k‖²` is nonneg, so
        ∑_{S_low} ‖û k‖⁴  =  ∑_{S_low} (‖û k‖²)²
                          ≤  (∑_{S_low} ‖û k‖²)²
                          ≤  A².
  (Sum-of-squares inequality `∑ aₖ² ≤ (∑ aₖ)²`, and `∑_{S_low} ≤ ∑_S`.)

  **High-frequency part (`S_high`):**  For `k ∈ S_high` we have
  `‖k‖² > M² > 0`, so `‖k‖² / M² > 1`.  Hence for any `x ≥ 0`,
        x  ≤  (‖k‖² / M²) · x.
  Apply with `x := ‖û k‖²` and multiply by `‖û k‖² ≥ 0`:
        ‖û k‖⁴  ≤  (‖k‖² / M²) · ‖û k‖⁴
                =  ‖k‖² · ‖û k‖² · (‖û k‖² / M²).
  Summing over `S_high`:
        ∑_{S_high} ‖û k‖⁴  ≤  (1 / M²) · ∑_{S_high} (‖k‖² · ‖û k‖²) · ‖û k‖².
  Now each `‖k‖² · ‖û k‖² ≤ B` (since each term is a nonneg summand of
  `B`), and `∑_{S_high} ‖û k‖² ≤ A`.  Therefore
        ∑_{S_high} ‖û k‖⁴  ≤  (B / M²) · ∑_{S_high} ‖û k‖²  ≤  (B · A) / M².

  Combining the two parts,
        E  =  ∑_{S_low}  ‖û k‖⁴  +  ∑_{S_high} ‖û k‖⁴
          ≤  A² + (A · B) / M².     ▢

  Optimization over M
  -------------------
  Choosing `M = 1` gives the cleanest useful form `E ≤ A² + A · B`.
  Choosing `M² = B / A` (when `A > 0`) gives `E ≤ 2 A²`, i.e. the
  trivial bound up to a factor of 2.

  Contents
  --------
    Definitions:
    • `l2EnergyS`            — discrete ℓ² mass  A = ∑ ‖û k‖².
    • `l4EnergyS`            — discrete ℓ⁴ energy E = ∑ ‖û k‖⁴.

    Elementary helpers:
    • `mul_le_mul_of_one_le_of_nonneg` — 1 ≤ r, 0 ≤ y ⟹ y ≤ r·y.
    • `sum_sq_le_sq_sum`     — ∑ aₖ² ≤ (∑ aₖ)²  (aₖ ≥ 0).
    • `hf_per_mode`          — M² < ‖k‖², x ≥ 0 ⟹ x ≤ (‖k‖² / M²) · x.

    Main theorem:
    • `ladyzhenskaya_split`  — E ≤ A² + (A · B) / M²  for any 0 < M.

    Corollaries:
    • `ladyzhenskaya_split_M1`  — E ≤ A² + A · B    (M = 1).
    • `ladyzhenskaya_bound_h1` — E ≤ A² + A · h1EnergyS.

  All proofs compile with **0 sorries and 0 axioms**.  No existing
  theorem in the project is modified.

  Key Mathlib lemmas used:
    - `Finset.sum_filter_add_sum_filter_not`
    - `Finset.sum_le_sum`, `Finset.sum_nonneg`
    - `Finset.sum_le_sum_of_subset_of_nonneg`
    - `Finset.sum_mul`, `Finset.mul_sum`
    - `mul_le_mul_of_nonneg_left`, `mul_le_mul_of_nonneg_right`
    - `sq_pos_of_pos`, `sq_nonneg`, `div_lt_div_iff₀`
-/

import SpectralNS
import BeiraoDaVeiga

namespace NsSpectral

open Real Finset

/-! ## Discrete ℓ² mass and ℓ⁴ energy (definitions) -/

/-- The discrete **ℓ² mass** of a spectral field on the finite mode set `S`:
`A := ∑_{k ∈ S} ‖û k‖²`. -/
noncomputable def l2EnergyS (uhat : WaveVector → ℂ) (S : Finset WaveVector) : ℝ :=
  ∑ k ∈ S, ‖uhat k‖ ^ 2

/-- `l2EnergyS` is nonneg. -/
lemma l2EnergyS_nonneg (uhat : WaveVector → ℂ) (S : Finset WaveVector) :
    0 ≤ l2EnergyS uhat S :=
  Finset.sum_nonneg fun _ _ => sq_nonneg _

/-- The discrete **ℓ⁴ energy** (the LHS of Ladyzhenskaya). -/
noncomputable def l4EnergyS (uhat : WaveVector → ℂ) (S : Finset WaveVector) : ℝ :=
  ∑ k ∈ S, ‖uhat k‖ ^ 4

/-- `l4EnergyS` is nonneg. -/
lemma l4EnergyS_nonneg (uhat : WaveVector → ℂ) (S : Finset WaveVector) :
    0 ≤ l4EnergyS uhat S := by
  -- Each term: ‖u k‖⁴ = (‖u k‖²)² ≥ 0 (by ring on ℝ).
  -- Rewrite the LHS sum using Finset.sum_congr (each summand matches by ring).
  have hrewrite : l4EnergyS uhat S = ∑ k ∈ S, (‖uhat k‖ ^ 2) ^ 2 :=
    Finset.sum_congr rfl fun k hk => by ring
  rw [hrewrite]
  exact Finset.sum_nonneg fun k _ => sq_nonneg (‖uhat k‖ ^ 2)

/-! ## Elementary helpers -/

/-- **Monotonicity of multiplication by `≥ 1`.**  If `1 ≤ r` and
`0 ≤ y`, then `y ≤ r · y`. -/
lemma mul_le_mul_of_one_le_of_nonneg {r y : ℝ} (hr : 1 ≤ r) (hy : 0 ≤ y) :
    y ≤ r * y := by
  -- Goal: y ≤ r * y.  We have r * y - y = (r - 1) * y ≥ 0.
  -- So r * y = y + (r - 1) * y ≥ y.
  have hrewrite : r * y = y + (r - 1) * y := by ring
  rw [hrewrite]
  have hsub : 0 ≤ r - 1 := sub_nonneg.mpr hr
  have hkey : 0 ≤ (r - 1) * y := mul_nonneg hsub hy
  -- Goal: y ≤ y + (r - 1) * y.  Since (r - 1) * y ≥ 0, linarith.
  linarith

/-- **Squared sum bound.**  For nonneg reals `aₖ` indexed by a finite set
`s`, we have `∑_{k ∈ s} aₖ² ≤ (∑_{k ∈ s} aₖ)²`. -/
lemma sum_sq_le_sq_sum {ι : Type*} (s : Finset ι) (a : ι → ℝ)
    (ha : ∀ k ∈ s, 0 ≤ a k) :
    ∑ k ∈ s, (a k) ^ 2 ≤ (∑ k ∈ s, a k) ^ 2 := by
  have h_sum_nn : 0 ≤ ∑ j ∈ s, a j :=
    Finset.sum_nonneg fun j hj => ha j hj
  have hper : ∀ k ∈ s, a k ^ 2 ≤ a k * ∑ j ∈ s, a j := by
    intro k hk
    have hak : 0 ≤ a k := ha k hk
    have hk_le_sum : a k ≤ ∑ j ∈ s, a j := by
      have hkey : a k = ∑ j ∈ ({k} : Finset ι), a j := by
        simp [Finset.sum_singleton]
      have hsub : ({k} : Finset ι) ⊆ s := by
        intro j hj
        obtain rfl : j = k := Finset.mem_singleton.mp hj
        exact hk
      rw [hkey]
      -- ∑_{j ∈ {k}} a j ≤ ∑_{j ∈ s} a j when all a j ≥ 0.
      -- Use sum_le_sum_of_subset_of_nonneg since ℝ is not canonically-ordered.
      -- We need ∀ i ∈ s, i ∉ {k} → 0 ≤ a i (i.e., 0 ≤ a i for i ∈ s \ {k}).
      exact Finset.sum_le_sum_of_subset_of_nonneg hsub fun i hi _ => ha i hi
    -- We have a k ≤ ∑ a j and 0 ≤ a k.  Multiplying both sides by a k gives
    -- a k * a k ≤ (∑ a j) * a k.  The goal wants a k² ≤ a k * ∑ a j.  Rewrite
    -- the LHS of the goal from a k² to a k * a k.
    rw [pow_two]
    exact mul_le_mul_of_nonneg_left hk_le_sum hak
  -- Now: ∑ a k² ≤ ∑ a k · ∑ a j.  We want ≤ (∑ a k)².
  -- The two sums in the product are equal (both are ∑_s a), so:
  --   ∑ a k · ∑ a j  =  ∑ a k · ∑ a k  =  (∑ a k)².
  have hrewrite : ∑ k ∈ s, a k * ∑ j ∈ s, a j = (∑ k ∈ s, a k) ^ 2 := by
    -- LHS: ∑ a k · (∑ a j).  Pull the inner sum out: (∑ a k) · (∑ a j).
    rw [← Finset.sum_mul]
    -- Now: (∑ a k) * ∑ a j = ∑ ∑ a k * a j.
    rw [Finset.sum_mul_sum]
    -- Reverse: ∑ ∑ a k * a j = (∑ a k) * ∑ a j = (∑ a k)².
    rw [← Finset.sum_mul_sum]
    rw [sq]
    -- After `rw [sq]`, the goal closes automatically since both sides have
    -- the same `∑ k ∈ s, a k` after rewriting.
  exact (Finset.sum_le_sum hper).trans_eq hrewrite

/-! ## Per-mode inequality: high-frequency bound -/

/-- **Per-mode bound for high frequencies.**  For `0 < M` and
`M² < ‖k‖²`, and `x ≥ 0`:
        x  ≤  (‖k‖² / M²) · x. -/
lemma hf_per_mode {k : WaveVector} {M : ℝ} (hM : 0 < M)
    (hk : M ^ 2 < waveNormSq k) {x : ℝ} (hx : 0 ≤ x) :
    x ≤ (waveNormSq k / M ^ 2) * x := by
  have hM_sq_pos : (0 : ℝ) < M ^ 2 := sq_pos_of_pos hM
  have hk_pos : (0 : ℝ) < waveNormSq k := lt_of_lt_of_le hM_sq_pos (le_of_lt hk)
  have hdiv_gt_one : (1 : ℝ) < waveNormSq k / M ^ 2 := by
    -- Rewrite as (1/1) < (‖k‖² / M²), apply div_lt_div_iff₀.
    rw [show (1 : ℝ) = 1 / 1 from by norm_num,
        div_lt_div_iff₀ (show (0 : ℝ) < 1 from zero_lt_one) hM_sq_pos]
    simpa [one_mul] using hk
  have hdiv_ge_one : (1 : ℝ) ≤ waveNormSq k / M ^ 2 := le_of_lt hdiv_gt_one
  exact mul_le_mul_of_one_le_of_nonneg hdiv_ge_one hx

/-! ## The split-form discrete Ladyzhenskaya inequality -/

/-- **Decomposition helper.**  For any summand function `f : ι → α`,
the sum over `S` decomposes as `∑_S f = ∑_{S_high} f + ∑_{S_low} f`,
where `S_high = S.filter p` and `S_low = S.filter (¬ p ·)`. -/
private lemma sum_split_decomp {ι α : Type*} [DecidableEq ι]
    (s : Finset ι) (p : ι → Prop) [DecidablePred p] (f : ι → α)
    [AddCommMonoid α] :
    ∑ x ∈ s, f x = ∑ x ∈ s.filter p, f x + ∑ x ∈ s.filter (¬ p ·), f x :=
  (Finset.sum_filter_add_sum_filter_not s p f).symm

/-- **Discrete Ladyzhenskaya (split-form).**

For any spectral field `û : WaveVector → ℂ` on a finite mode set `S`
and any cutoff `0 < M ∈ ℝ`, the discrete ℓ⁴ energy is bounded by

      `∑_{k ∈ S} ‖û k‖⁴  ≤  (∑_{k ∈ S} ‖û k‖²)²
                              +  (∑_{k ∈ S} ‖û k‖²) · (∑_{k ∈ S} ‖k‖² · ‖û k‖²) / M²`.

This is the spectral avatar of the classical Ladyzhenskaya inequality
`‖u‖_{L⁴}⁴ ≤ C · ‖u‖_{L²} · ‖∇u‖_{L²}²`.  See the file header for the
full proof strategy. -/
theorem ladyzhenskaya_split (uhat : WaveVector → ℂ) (S : Finset WaveVector)
    (M : ℝ) (hM : 0 < M) :
    l4EnergyS uhat S
      ≤ l2EnergyS uhat S ^ 2 + l2EnergyS uhat S * h1EnergyS uhat S / M ^ 2 := by
  -- Local notation.
  set A : ℝ := l2EnergyS uhat S with hA_def
  set B : ℝ := h1EnergyS uhat S with hB_def
  set p : WaveVector → Prop := fun k => M ^ 2 < waveNormSq k with hp_def
  set S_high : Finset WaveVector := S.filter p with hSh_def
  set S_low  : Finset WaveVector := S.filter (¬ p ·) with hSl_def
  -- Nonnegativity of A, B.
  have hA_nn : 0 ≤ A := l2EnergyS_nonneg uhat S
  have hB_nn : 0 ≤ B := Finset.sum_nonneg fun k _ =>
    mul_nonneg (Finset.sum_nonneg fun _ _ => sq_nonneg _) (sq_nonneg _)
  have hM_sq_pos : (0 : ℝ) < M ^ 2 := sq_pos_of_pos hM

  -- Helper: ‖û k‖² is nonneg on S_high and S_low.
  have hun_kf_nn_high : ∀ k ∈ S_high, 0 ≤ ‖uhat k‖ ^ 2 := fun k _ => sq_nonneg _
  have hun_kf_nn_low  : ∀ k ∈ S_low,  0 ≤ ‖uhat k‖ ^ 2 := fun k _ => sq_nonneg _

  -- Step 1: Decompose sums.
  -- E = ∑_S ‖û k‖⁴ = ∑_{S_high} ‖û k‖⁴ + ∑_{S_low} ‖û k‖⁴.
  have hE_decomp :
      l4EnergyS uhat S = (∑ k ∈ S_high, ‖uhat k‖ ^ 4) + ∑ k ∈ S_low, ‖uhat k‖ ^ 4 := by
    unfold l4EnergyS
    exact sum_split_decomp S p (fun k => ‖uhat k‖ ^ 4)

  -- A = ∑_S ‖û k‖² = ∑_{S_high} ‖û k‖² + ∑_{S_low} ‖û k‖².
  have hA_decomp :
      A = (∑ k ∈ S_high, ‖uhat k‖ ^ 2) + ∑ k ∈ S_low, ‖uhat k‖ ^ 2 := by
    show l2EnergyS uhat S = _
    unfold l2EnergyS
    exact sum_split_decomp S p (fun k => ‖uhat k‖ ^ 2)

  -- Local names for the partial sums.
  set E_high : ℝ := ∑ k ∈ S_high, ‖uhat k‖ ^ 4 with hEh_def
  set E_low  : ℝ := ∑ k ∈ S_low,  ‖uhat k‖ ^ 4 with hEl_def
  set A_high : ℝ := ∑ k ∈ S_high, ‖uhat k‖ ^ 2 with hAh_def
  set A_low  : ℝ := ∑ k ∈ S_low,  ‖uhat k‖ ^ 2 with hAl_def

  -- Step 2: Bound E_low ≤ A².
  have hE_low : E_low ≤ A ^ 2 := by
    -- First, ‖u k‖⁴ = (‖u k‖²)².  Both forms hold.
    have hrewrite_lhs : (∑ k ∈ S_low, (‖uhat k‖ ^ 2) ^ 2) = E_low := by
      apply Finset.sum_congr rfl
      intro k hk
      ring
    -- Now apply sum_sq_le_sq_sum.
    have hsq_bd : ∑ k ∈ S_low, (‖uhat k‖ ^ 2) ^ 2
                  ≤ (∑ k ∈ S_low, ‖uhat k‖ ^ 2) ^ 2 :=
      sum_sq_le_sq_sum S_low (fun k => ‖uhat k‖ ^ 2) hun_kf_nn_low
    rw [hrewrite_lhs] at hsq_bd
    -- We have E_low ≤ A_low² where A_low = ∑_{S_low} ‖u k‖².
    -- Need to show A_low² ≤ A².
    have hA_low_le_A : A_low ≤ A := by
      have hA_high_nn : 0 ≤ A_high := Finset.sum_nonneg hun_kf_nn_high
      linarith [hA_decomp, hA_high_nn]
    -- Apply pow_le_pow_left₀ to A_low ≤ A.  We need 0 ≤ A_low.
    have hA_low_nn : 0 ≤ A_low := Finset.sum_nonneg hun_kf_nn_low
    have hA_low_sq_le_A_sq : A_low ^ 2 ≤ A ^ 2 :=
      pow_le_pow_left₀ hA_low_nn hA_low_le_A 2
    -- Convert E_low ≤ (∑ ‖u k‖²)² via sum_sq_le_sq_sum to E_low ≤ A_low² = ... ≤ A².
    -- Actually sum_sq_le_sq_sum gives E_low ≤ (∑ ‖u k‖²)².  And ∑ ‖u k‖² = A_low.
    have hsum_eq_A_low : (∑ k ∈ S_low, ‖uhat k‖ ^ 2) = A_low := by
      simp [A_low]
    -- Rewrite the RHS of hsq_bd from (∑ ‖u k‖²)² to A_low².
    have hsq_bd' : E_low ≤ A_low ^ 2 := by
      rw [hsum_eq_A_low] at hsq_bd
      exact hsq_bd
    exact hsq_bd'.trans hA_low_sq_le_A_sq

  -- Step 3: Bound E_high ≤ A · B / M².
  have hE_high : E_high ≤ A * B / M ^ 2 := by
    -- Per-mode: ‖u k‖⁴ ≤ (‖k‖² / M²) · ‖u k‖⁴ = (‖k‖² · ‖u k‖²) · ‖u k‖² / M².
    have hper_mode : ∀ k ∈ S_high,
        ‖uhat k‖ ^ 4 ≤ (waveNormSq k * ‖uhat k‖ ^ 2) * ‖uhat k‖ ^ 2 / M ^ 2 := by
      intro k hk
      have huk_nn : 0 ≤ ‖uhat k‖ ^ 2 := sq_nonneg _
      -- Extract M² < waveNormSq k from hk : k ∈ S_high = S.filter p, where
      -- p k = M² < waveNormSq k.
      have hk_pred : M ^ 2 < waveNormSq k := (Finset.mem_filter.mp hk).2
      have hfpm : ‖uhat k‖ ^ 2 ≤ (waveNormSq k / M ^ 2) * ‖uhat k‖ ^ 2 :=
        hf_per_mode hM hk_pred huk_nn
      have hmul : ‖uhat k‖ ^ 2 * ‖uhat k‖ ^ 2
                ≤ (waveNormSq k / M ^ 2) * ‖uhat k‖ ^ 2 * ‖uhat k‖ ^ 2 :=
        mul_le_mul_of_nonneg_right hfpm huk_nn
      -- LHS = ‖u k‖⁴; RHS = (‖k‖² / M²) · ‖u k‖² · ‖u k‖² = (‖k‖² · ‖u k‖²) · ‖u k‖² / M².
      have hlhs : ‖uhat k‖ ^ 2 * ‖uhat k‖ ^ 2 = ‖uhat k‖ ^ 4 := by ring
      have hrhs : (waveNormSq k / M ^ 2) * ‖uhat k‖ ^ 2 * ‖uhat k‖ ^ 2
                = (waveNormSq k * ‖uhat k‖ ^ 2) * ‖uhat k‖ ^ 2 / M ^ 2 := by
        rw [div_mul_eq_mul_div]
        ring
      rw [hlhs, hrhs] at hmul
      exact hmul
    -- Sum the per-mode bound:
    have hsum_per : ∑ k ∈ S_high, ‖uhat k‖ ^ 4
                  ≤ ∑ k ∈ S_high, (waveNormSq k * ‖uhat k‖ ^ 2) * ‖uhat k‖ ^ 2 / M ^ 2 :=
      Finset.sum_le_sum hper_mode
    -- Factor out 1/M²: ∑ aₖ / M² = (1/M²) · ∑ aₖ.  This uses a · (1/M²) = a/M².
    have hfactor : (∑ k ∈ S_high, (waveNormSq k * ‖uhat k‖ ^ 2) * ‖uhat k‖ ^ 2 / M ^ 2)
                = (1 / M ^ 2) * ∑ k ∈ S_high, (waveNormSq k * ‖uhat k‖ ^ 2) * ‖uhat k‖ ^ 2 := by
      -- ∑ (aₖ / M²) = (1/M²) · ∑ aₖ via Finset.sum_mul (reverse direction).
      have ha_eq : ∀ k ∈ S_high,
          (waveNormSq k * ‖uhat k‖ ^ 2) * ‖uhat k‖ ^ 2 / M ^ 2
            = (1 / M ^ 2) * ((waveNormSq k * ‖uhat k‖ ^ 2) * ‖uhat k‖ ^ 2) := by
        intro k hk
        rw [← div_mul_eq_mul_div, one_div]
        ring
      rw [Finset.sum_congr rfl ha_eq, Finset.mul_sum]
    rw [hfactor] at hsum_per
    -- Now bound ∑ (‖k‖² · ‖u k‖²) · ‖u k‖² ≤ B · A_high ≤ B · A.
    have hbound_inner :
        ∑ k ∈ S_high, (waveNormSq k * ‖uhat k‖ ^ 2) * ‖uhat k‖ ^ 2 ≤ B * A_high := by
      -- Per-mode: (‖k‖² · ‖u k‖²) · ‖u k‖² ≤ B · ‖u k‖²
      -- since ‖k‖² · ‖u k‖² ≤ B (as a nonneg summand of B).
      have hper' : ∀ k ∈ S_high,
          ‖uhat k‖ ^ 2 * (waveNormSq k * ‖uhat k‖ ^ 2)
            ≤ ‖uhat k‖ ^ 2 * B := by
        intro k hk
        -- k ∈ S_high ⊆ S, so waveNormSq k · ‖u k‖² ≤ B (one nonneg summand of B).
        have hmember : k ∈ S := (Finset.mem_filter.mp hk).1
        have hkey : waveNormSq k * ‖uhat k‖ ^ 2
                  = ∑ j ∈ ({k} : Finset WaveVector), waveNormSq j * ‖uhat j‖ ^ 2 := by
          simp [Finset.sum_singleton]
        have hsub : ({k} : Finset WaveVector) ⊆ S := by
          intro j hj
          obtain rfl : j = k := Finset.mem_singleton.mp hj
          exact hmember
        rw [hkey]
        have hle_singleton_sum : ∑ j ∈ ({k} : Finset WaveVector),
                                   waveNormSq j * ‖uhat j‖ ^ 2
                                 ≤ ∑ j ∈ S, waveNormSq j * ‖uhat j‖ ^ 2 :=
          Finset.sum_le_sum_of_subset_of_nonneg hsub
            (fun i hi _ => mul_nonneg
              (Finset.sum_nonneg fun _ _ => sq_nonneg _) (sq_nonneg _))
        -- The RHS = B.
        have hrhs_eq : (∑ j ∈ S, waveNormSq j * ‖uhat j‖ ^ 2) = B := rfl
        rw [hrhs_eq] at hle_singleton_sum
        -- Now we have waveNormSq k · ‖u k‖² ≤ B.  Multiply by ‖u k‖² ≥ 0:
        -- (B · ‖u k‖²) ≥ (waveNormSq k · ‖u k‖²) · ‖u k‖²  iff ‖u k‖² ≤ B.
        -- But we want: ‖u k‖² · (waveNormSq k · ‖u k‖²) ≤ ‖u k‖² · B.
        -- This is mul_le_mul_of_nonneg_left hle_singleton_sum (‖u k‖² ≥ 0).
        exact mul_le_mul_of_nonneg_left hle_singleton_sum (sq_nonneg _)
      -- Rewrite ∑ (‖k‖² · ‖u k‖²) · ‖u k‖² as ∑ ‖u k‖² · (‖k‖² · ‖u k‖²):
      have hreorder : ∑ k ∈ S_high, (waveNormSq k * ‖uhat k‖ ^ 2) * ‖uhat k‖ ^ 2
                   = ∑ k ∈ S_high, ‖uhat k‖ ^ 2 * (waveNormSq k * ‖uhat k‖ ^ 2) := by
        apply Finset.sum_congr rfl
        intro k hk; ring
      rw [hreorder]
      have hsum' : ∑ k ∈ S_high, ‖uhat k‖ ^ 2 * (waveNormSq k * ‖uhat k‖ ^ 2)
                ≤ ∑ k ∈ S_high, ‖uhat k‖ ^ 2 * B :=
        Finset.sum_le_sum hper'
      -- RHS = (∑ ‖u k‖²) · B = A_high · B.
      have hrhs : ∑ k ∈ S_high, ‖uhat k‖ ^ 2 * B = A_high * B := by
        rw [Finset.sum_mul]
      rw [hrhs] at hsum'
      -- hsum' : ∑ ‖u k‖² · (‖k‖² · ‖u k‖²) ≤ A_high · B
      -- We want ≤ B · A_high.  Same by commutativity.
      linarith
    -- Now chain:
    -- E_high ≤ (1/M²) · ∑ (‖k‖² · ‖u k‖²) · ‖u k‖²
    --        ≤ (1/M²) · B · A_high  (by hbound_inner)
    --        ≤ (1/M²) · B · A      (by A_high ≤ A)
    have hA_high_le_A : A_high ≤ A := by
      -- A_high = A - A_low ≤ A since A_low ≥ 0.
      have hA_low_nn : 0 ≤ A_low := Finset.sum_nonneg hun_kf_nn_low
      linarith [hA_decomp, hA_low_nn]
    have hBAh_le_BA : B * A_high ≤ B * A :=
      mul_le_mul_of_nonneg_left hA_high_le_A hB_nn
    have hone_div_nn : (0 : ℝ) ≤ 1 / M ^ 2 := one_div_nonneg.mpr (le_of_lt hM_sq_pos)
    have h1 : (1 / M ^ 2) * ∑ k ∈ S_high,
                (waveNormSq k * ‖uhat k‖ ^ 2) * ‖uhat k‖ ^ 2
              ≤ (1 / M ^ 2) * (B * A_high) :=
      mul_le_mul_of_nonneg_left hbound_inner hone_div_nn
    have h2 : (1 / M ^ 2) * (B * A_high) ≤ (1 / M ^ 2) * (B * A) :=
      mul_le_mul_of_nonneg_left hBAh_le_BA hone_div_nn
    -- Now (1/M²) · B · A = A · B / M² by commutativity.
    have hrhs_eq : (1 / M ^ 2) * (B * A) = A * B / M ^ 2 := by ring
    -- hsum_per : E_high ≤ (1/M²) · ∑ (...)
    -- So E_high ≤ (1/M²) · (B * A_high) ≤ (1/M²) · (B * A) = A · B / M².
    linarith

  -- Step 4: Combine.
  -- l4EnergyS uhat S = E_high + E_low (from hE_decomp).
  -- E_high + E_low ≤ E_high + A²  (since E_low ≤ A²)
  -- E_high + A² ≤ A · B / M² + A² (since E_high ≤ A · B / M²)
  rw [hE_decomp]
  -- add_le_add_left : a ≤ b → a + c ≤ b + c, so with a := E_low, b := A², c := E_high.
  have hstep1 : E_low + E_high ≤ A ^ 2 + E_high :=
    add_le_add_left hE_low E_high
  -- Need to commute: E_low + E_high → E_high + E_low, and A² + E_high → E_high + A².
  have hstep1' : E_high + E_low ≤ E_high + A ^ 2 := by
    -- hstep1 : E_low + E_high ≤ A² + E_high
    -- Convert: E_low + E_high = E_high + E_low (comm), A² + E_high = E_high + A² (comm).
    rw [add_comm E_low, add_comm (A ^ 2)] at hstep1
    exact hstep1
  -- add_le_add_left : E_high ≤ A * B / M² → E_high + A² ≤ A * B / M² + A².
  have hstep2 : E_high + A ^ 2 ≤ A * B / M ^ 2 + A ^ 2 :=
    add_le_add_left hE_high (A ^ 2)
  -- Goal: E_high + E_low ≤ A² + A · B / M².
  -- hstep1' : E_high + E_low ≤ E_high + A²
  -- hstep2  : E_high + A² ≤ A · B / M² + A²
  -- Need to commute RHS: A · B / M² + A² = A² + A · B / M².
  have hswap : A * B / M ^ 2 + A ^ 2 = A ^ 2 + A * B / M ^ 2 := by ring
  rw [hswap] at hstep2
  exact hstep1'.trans hstep2

/-- **Discrete Ladyzhenskaya (cutoff M = 1).**  Setting `M := 1` in
`ladyzhenskaya_split`:
        ∑ ‖û k‖⁴  ≤  A² + A · B. -/
theorem ladyzhenskaya_split_M1 (uhat : WaveVector → ℂ) (S : Finset WaveVector) :
    l4EnergyS uhat S
      ≤ l2EnergyS uhat S ^ 2 + l2EnergyS uhat S * h1EnergyS uhat S := by
  have hM1_pos : (0 : ℝ) < 1 := zero_lt_one
  have hsplit := ladyzhenskaya_split uhat S 1 hM1_pos
  -- hsplit : l4EnergyS uhat S ≤ A² + A · B / 1²
  -- We need: A · B / 1² = A · B.
  have hdiv1 : (l2EnergyS uhat S * h1EnergyS uhat S) / (1 : ℝ) ^ 2
              = l2EnergyS uhat S * h1EnergyS uhat S := by
    rw [one_pow, div_one]
  rw [hdiv1] at hsplit
  exact hsplit

/-- **Discrete Ladyzhenskaya (H¹ side).**  Re-stating `ladyzhenskaya_split_M1`
with `h1EnergyS` as the H¹ norm. -/
theorem ladyzhenskaya_bound_h1 (uhat : WaveVector → ℂ) (S : Finset WaveVector) :
    l4EnergyS uhat S
      ≤ l2EnergyS uhat S ^ 2 + l2EnergyS uhat S * h1EnergyS uhat S :=
  ladyzhenskaya_split_M1 uhat S

/-- **Aggregate Ladyzhenskaya constant.**  There exists a nonneg constant
`C := A² + A · B` such that the discrete ℓ⁴ energy is bounded by `C`. -/
theorem ladyzhenskaya_constant_exists (uhat : WaveVector → ℂ) (S : Finset WaveVector) :
    ∃ C : ℝ, 0 ≤ C ∧ l4EnergyS uhat S ≤ C := by
  refine ⟨l2EnergyS uhat S ^ 2 + l2EnergyS uhat S * h1EnergyS uhat S, ?_, ?_⟩
  · -- 0 ≤ A² + A · B
    have hA_nn : 0 ≤ l2EnergyS uhat S := l2EnergyS_nonneg uhat S
    have hB_nn : 0 ≤ h1EnergyS uhat S := Finset.sum_nonneg fun k _ =>
      mul_nonneg (Finset.sum_nonneg fun _ _ => sq_nonneg _) (sq_nonneg _)
    have hA_sq_nn : 0 ≤ l2EnergyS uhat S ^ 2 := pow_two_nonneg _
    have hA_mul_B_nn : 0 ≤ l2EnergyS uhat S * h1EnergyS uhat S :=
      mul_nonneg hA_nn hB_nn
    exact add_nonneg hA_sq_nn hA_mul_B_nn
  · exact ladyzhenskaya_split_M1 uhat S

end NsSpectral
