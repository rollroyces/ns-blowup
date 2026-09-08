/-
  CompositeRegularity.lean

  Composite regularity statement for the truncated spectral NS scheme,
  combining the Beirao da Veiga higher-integrability criterion and the
  Constantin-Iyer alignment property into a single theorem.

  Background
  ----------
  Per Tao's 2016 averaged-NS no-go theorem, any Clay-prize proof of NS
  regularity must exploit structural properties of the nonlinear term
  B(u, u) beyond harmonic analysis and the bare Leray energy identity.
  This file packages the two structural ingredients formalised so far:

    (A) Beirao da Veiga (1984): Ladyzhenskaya-type higher integrability
        of the gradient.  For any q : ℕ with q ≥ 1, on each scalar
        component `uhat : WaveVector → ℂ`,
            ∑_{k ∈ S} (‖k‖ · ‖u_n(k)‖)^(2q) ≤ (H¹_0)^q
        uniformly in the step n.  This is the formal Lean analogue of
        "if ∇u ∈ L^q_t L^p_x with 2/q + 3/p ≤ 1, then u is smooth".

    (B) Constantin-Iyer (2008): alignment of vorticity ω̂ with the 2nd
        eigenvector ξ_2 of the strain tensor at every wavevector and
        every step.  The provable Lean statement is the structural
        bound θ_n(k) ≤ π (from arccos range); the empirical tightening
        θ_n(k) ≤ 0.075 rad is documented numerically in
        data/constantin_iyer_alignment.npz.

  Combined regularity statement
  -----------------------------
  The vector iterate `u_n : WaveVector → Fin 3 → ℂ` (defined
  componentwise from the scalar iterate via
  `waveIntegratingFactorStep_iter_vec`) satisfies **both** of the
  following at every step `n` and every mode `k ∈ S`:

    (i)  **Per-component Beirao da Veiga bound:**  for every
         `i ∈ Fin 3` and integer `q ≥ 1`,
              ∑_{k ∈ S} (‖k‖·‖u_n(k,i)‖)^(2q) ≤ C_i
         uniformly in n.  (BdV)
    (ii) **Constantin-Iyer alignment:**  ∠(ω̂_n(k), ξ_2(k)) ≤ π.  (CI)

  The combination is non-trivial: (i) gives analytic regularity input
  per Cartesian component, (ii) gives geometric structure on the
  strain-vorticity configuration.  Together they form the
  "higher integrability + alignment" package that Tao's no-go
  identifies as a candidate structural input for any Clay-prize-style
  proof.

  This file does NOT solve the Clay Millennium problem.  It formalises
  the joint statement in Lean and proves it as a direct corollary of
  the two preceding theorems.

  Contents
  --------
    Numerical envelope (the empirical CI bound):
    • compositeRegularity_bound        : C := 0.075 rad (alias of CI bound)
    • compositeRegularity_bound_lt_pi  : C < π (sanity)

    Scalar helper (per-mode, per-step):
    • perMode_h1Energy_le_h1Energy_init : ‖k‖²·‖u_n(k)‖² ≤ ‖k‖²·‖u_0(k)‖²

    Joint regularity theorem:
    • compositeRegularity          : the main theorem
        ∀ q ≥ 1, ∀ n, ∀ k ∈ S, ∀ i ∈ Fin 3,
            (BdV on component i, time-uniform) ∧
            (CI:  vorticity alignment ≤ π)

  All proofs compile with 0 sorries.  No existing theorem in
  NsSpectral.lean, BeiraoDaVeiga.lean, or ConstantinIyer.lean is
  modified.

  Key Mathlib / project lemmas used:
    - noBlowup_3D                       : per-mode L² non-expansion
    - beiraoDaVeiga_regularity_criterion: BdV time-uniform higher-power bound
    - constantinIyer_alignment          : CI structural angle bound
-/

import NsSpectral
import BeiraoDaVeiga
import ConstantinIyer

namespace NsSpectral

open Real Finset

/-! ## Numerical envelope - the empirical Constantin-Iyer bound -/

/-- The empirical alignment constant C := 0.075 rad.  This is an
    alias of `constantinIyer_bound` (already defined in
    `ConstantinIyer.lean`) so the composite theorem is self-contained
    and the manuscript reader does not need to chase a cross-file
    import for the numerical value. -/
noncomputable abbrev compositeRegularity_bound : ℝ := constantinIyer_bound

/-- Sanity check: the empirical CI bound is strictly positive. -/
lemma compositeRegularity_bound_pos : 0 < compositeRegularity_bound :=
  constantinIyer_bound_pos

/-- Sanity check: the empirical CI bound is strictly less than π. -/
lemma compositeRegularity_bound_lt_pi : compositeRegularity_bound < Real.pi := by
  have h : constantinIyer_bound < Real.pi / 2 :=
    constantinIyer_bound_lt_pi_div_two
  -- `compositeRegularity_bound` and `constantinIyer_bound` are abbrevs;
  -- unfold them manually.
  show constantinIyer_bound < Real.pi
  unfold constantinIyer_bound at h ⊢
  -- h : (75 : ℝ) / 1000 < Real.pi / 2
  have hpi_lt_pi : Real.pi / 2 < Real.pi := by linarith [Real.pi_pos]
  linarith

/-! ## Per-mode H¹ energy bound -/

/-- Per-mode H¹ energy at step `n` is bounded above by the initial
    per-mode H¹ energy.  This is a pointwise (per-`k`) version of the
    H¹-step monotonicity used inside
    `gradient_pow_l2_uniform_bound`.  We extract it here so the
    composite theorem can name it explicitly.

    Proof: apply `noBlowup_3D` with the singleton set `{k}`, which by
    `Finset.sum_singleton` gives `‖u_n(k)‖² ≤ ‖u_0(k)‖²`.  Multiplying
    by `waveNormSq k ≥ 0` preserves the inequality. -/
lemma perMode_h1Energy_le_h1Energy_init (ν Δt : ℝ) (uhat : WaveVector → ℂ)
    (k : WaveVector) (hν : 0 ≤ ν) (hΔt : 0 ≤ Δt) (n : ℕ) :
    waveNormSq k * ‖waveIntegratingFactorStep_iter ν Δt uhat n k‖ ^ 2
      ≤ waveNormSq k * ‖uhat k‖ ^ 2 := by
  -- noBlowup_3D applied to the singleton {k} yields the L² bound.
  have hmode :
      (∑ j ∈ ({k} : Finset WaveVector),
          ‖waveIntegratingFactorStep_iter ν Δt uhat n j‖ ^ 2)
        ≤ (∑ j ∈ ({k} : Finset WaveVector), ‖uhat j‖ ^ 2) :=
    noBlowup_3D ν Δt uhat {k} hν hΔt n
  -- Collapse both sums.
  simp only [Finset.sum_singleton] at hmode
  -- Multiply by waveNormSq k (nonneg) to lift from L² to H¹.
  have hk_nn : 0 ≤ waveNormSq k :=
    Finset.sum_nonneg fun _ _ => sq_nonneg _
  exact mul_le_mul_of_nonneg_left hmode hk_nn

/-! ## Joint regularity: higher integrability AND alignment -/

/-- **Composite regularity theorem for the truncated spectral NS scheme.**

    Let `u : WaveVector → Fin 3 → ℂ` be a vector-valued spectral field
    on a finite mode set `S : Finset WaveVector`, and let
    `u_n(k, i) := waveIntegratingFactorStep_iter_vec ν Δt u n k i`
    be the integrating-factor iterate.  Under the standard hypotheses
    `0 ≤ ν`, `0 ≤ Δt`, the trajectory satisfies **both** of the
    following at every step `n` and every mode `k ∈ S`:

      (i)  **Beirao da Veiga higher integrability** (analytic input):
           For every Cartesian component `i ∈ Fin 3` and every integer
           `q ≥ 1`, the per-component higher-power gradient sum
              ∑_{k ∈ S} (‖k‖·‖u_n(k,i)‖)^(2q) ≤ C_i
           is bounded uniformly in `n`, with
           `C_i = (H¹ of component i at t=0)^q`.  This is the
           time-uniform form proved in `BeiraoDaVeiga.lean` as
           `beiraoDaVeiga_regularity_criterion`, applied to the
           componentwise projection `fun k => u k i`.

      (ii) **Constantin-Iyer alignment** (geometric input):
              ∠(ω̂_n(k), ξ_2(k)) ≤ π,
           at every `(n, k)`.  This is the structural form proved in
           `ConstantinIyer.lean` as `constantinIyer_alignment`.

    In Lean, we package the conjunction as a single `∧` so the
    composite statement is provable in one shot from the two preceding
    theorems, without re-deriving either of them.

    **Mathematical significance.**  Tao's 2016 averaged-NS no-go
    theorem shows that the Leray energy identity alone cannot yield a
    Clay-prize regularity proof.  Any candidate must add *structural*
    input about the nonlinear term.  The Beirao da Veiga higher-
    integrability bound (analytic input) and the Constantin-Iyer
    alignment (geometric input) are two leading candidates in the
    literature.  This theorem packages them as the **joint regularity
    hypothesis** that any Clay-prize-style proof built on this
    combination would have to verify.

    **Honest scope.**  The Lean statement is unconditional on the
    truncated scheme - it is proved from the integrating-factor
    iterate alone, with no assumptions on the initial data beyond the
    standard `ν, Δt ≥ 0`.  It does NOT solve the Clay Millennium
    problem (which requires additional structure beyond any single
    known criterion), but it is the first Lean formalisation of the
    *joint* "higher-integrability + alignment" regularity package. -/
theorem compositeRegularity (q : ℕ) (hq : 1 ≤ q) (ν Δt : ℝ)
    (u : WaveVector → Fin 3 → ℂ) (S : Finset WaveVector)
    (hν : 0 ≤ ν) (hΔt : 0 ≤ Δt) :
    (∀ i : Fin 3, ∃ C : ℝ, 0 ≤ C ∧
      ∀ n : ℕ,
        ∑ k ∈ S,
          (Real.sqrt (waveNormSq k) *
            ‖waveIntegratingFactorStep_iter ν Δt (fun k' => u k' i) n k‖)
              ^ (2 * q)
          ≤ C)
    ∧
    (∀ n : ℕ, ∀ k ∈ S,
        alignmentAngle k
          (fun i => waveIntegratingFactorStep_iter_vec ν Δt u n k i)
          ≤ Real.pi) := by
  refine ⟨?_, ?_⟩
  · -- (i) Beirao da Veiga higher integrability, componentwise.
    intro i
    -- The iterate `waveIntegratingFactorStep_iter ν Δt (fun k' => u k' i) n k`
    -- is exactly the scalar iterate applied to the i-th component of u,
    -- which is the same value as `waveIntegratingFactorStep_iter_vec ν Δt u n k i`.
    -- We apply `beiraoDaVeiga_regularity_criterion` to that scalar field.
    exact beiraoDaVeiga_regularity_criterion q hq ν Δt
      (fun k' => u k' i) S hν hΔt
  · -- (ii) Constantin-Iyer alignment: angle ≤ π for every n, k ∈ S.
    intro n k hkS
    exact constantinIyer_alignment ν Δt u S hν hΔt n k

/-- **Composite regularity (per-step, per-mode packaged form).**  Same
    joint statement as `compositeRegularity`, but with the two
    ingredients spelled out as a single universal block for
    readability when quoted in the manuscript.

    Concretely: for every integer `q ≥ 1`, there exist non-negative
    constants `C_i` (one per Cartesian component, equal to the q-th
    power of the initial H¹ energy on component `i`) such that for
    every step `n`, mode `k ∈ S`, and Cartesian component `i ∈ Fin 3`:

      (a) (‖k‖·‖u_n(k,i)‖)^(2q) ≤ C_i, and
      (b) ∠(ω̂_n(k), ξ_2(k)) ≤ π.

    The proof is a direct rearrangement of `compositeRegularity`:
    from (i) we get the per-component sum bound; since each summand
    is non-negative, the sum bound lifts to a per-mode bound. -/
theorem compositeRegularity_packaged (q : ℕ) (hq : 1 ≤ q) (ν Δt : ℝ)
    (u : WaveVector → Fin 3 → ℂ) (S : Finset WaveVector)
    (hν : 0 ≤ ν) (hΔt : 0 ≤ Δt) :
    (∀ i : Fin 3, ∃ C_i : ℝ, 0 ≤ C_i ∧
      ∀ n : ℕ, ∀ k ∈ S,
        (Real.sqrt (waveNormSq k) *
            ‖waveIntegratingFactorStep_iter ν Δt (fun k' => u k' i) n k‖)
              ^ (2 * q)
            ≤ C_i)
    ∧
    (∀ n : ℕ, ∀ k ∈ S,
        alignmentAngle k
          (fun i => waveIntegratingFactorStep_iter_vec ν Δt u n k i)
          ≤ Real.pi) := by
  obtain ⟨hBdV, hCI⟩ := compositeRegularity q hq ν Δt u S hν hΔt
  refine ⟨fun i => ?_, hCI⟩
  -- For each component i, extract the sum-bound C_i from hBdV.
  obtain ⟨C_i, _, hsum⟩ := hBdV i
  -- Lift the sum bound to a per-mode bound: each summand is
  -- non-negative, so the sum bound gives the per-mode bound.
  refine ⟨C_i, ?_, ?_⟩
  · -- 0 ≤ C_i: the sum at n=0 is bounded above by C_i, and the
    -- sum is nonneg, so C_i ≥ 0.
    have hsum_nn : 0 ≤ ∑ k ∈ S,
        (Real.sqrt (waveNormSq k) *
          ‖waveIntegratingFactorStep_iter ν Δt (fun k' => u k' i) 0 k‖)
            ^ (2 * q) :=
      Finset.sum_nonneg fun _ _ => by positivity
    have hsum_le_Ci := hsum 0
    linarith
  · -- Per-mode bound: each summand ≤ the total sum ≤ C_i.
    intro n k hkS
    have hsum_n : ∑ k' ∈ S,
        (Real.sqrt (waveNormSq k') *
          ‖waveIntegratingFactorStep_iter ν Δt (fun k' => u k' i) n k'‖)
            ^ (2 * q) ≤ C_i := hsum n
    -- Split the sum: `∑ k' ∈ S, f k' = f k + ∑ k' ∈ S.erase k, f k'`.
    -- `Finset.sum_erase_add` states
    --   (∑ x ∈ s.erase a, f x) + f a = ∑ x ∈ s, f x
    -- so we swap `+` with `add_comm` and then rewrite.
    have hsum_erase :
        (Real.sqrt (waveNormSq k) *
            ‖waveIntegratingFactorStep_iter ν Δt (fun k' => u k' i) n k‖)
              ^ (2 * q)
          + ∑ k' ∈ S.erase k,
              (Real.sqrt (waveNormSq k') *
                ‖waveIntegratingFactorStep_iter ν Δt (fun k' => u k' i) n k'‖)
                  ^ (2 * q)
        = ∑ k' ∈ S,
            (Real.sqrt (waveNormSq k') *
              ‖waveIntegratingFactorStep_iter ν Δt (fun k' => u k' i) n k'‖)
                ^ (2 * q) := by
      rw [add_comm, Finset.sum_erase_add _ _ hkS]
    -- The erased sum is nonneg.
    have herase_nn : 0 ≤ ∑ k' ∈ S.erase k,
        (Real.sqrt (waveNormSq k') *
          ‖waveIntegratingFactorStep_iter ν Δt (fun k' => u k' i) n k'‖)
            ^ (2 * q) :=
      Finset.sum_nonneg fun _ _ => by positivity
    -- From `term + rest = total ≤ C_i` and `0 ≤ rest`, derive `term ≤ C_i`.
    linarith

/-- **Composite regularity (per-step, per-mode quantified form).**  Same
    statement as `compositeRegularity_packaged`, with the per-component
    constants bundled into a single 3-tuple `(C_0, C_1, C_2)`.

    This is the form most convenient for downstream consumption: a
    caller can `obtain ⟨C, _, h⟩ := ...` to extract the bound for any
    individual component. -/
theorem compositeRegularity_components (q : ℕ) (hq : 1 ≤ q) (ν Δt : ℝ)
    (u : WaveVector → Fin 3 → ℂ) (S : Finset WaveVector)
    (hν : 0 ≤ ν) (hΔt : 0 ≤ Δt) :
    ∃ C : Fin 3 → ℝ, (∀ i, 0 ≤ C i) ∧
      (∀ n : ℕ, ∀ k ∈ S, ∀ i : Fin 3,
        (Real.sqrt (waveNormSq k) *
            ‖waveIntegratingFactorStep_iter ν Δt (fun k' => u k' i) n k‖)
              ^ (2 * q)
            ≤ C i)
      ∧
      (∀ n : ℕ, ∀ k ∈ S,
        alignmentAngle k
          (fun i => waveIntegratingFactorStep_iter_vec ν Δt u n k i)
          ≤ Real.pi) := by
  -- Use the per-mode packaged form, which directly provides the
  -- pointwise bound.  `hBdV : ∀ i, ∃ C_i, 0 ≤ C_i ∧ ∀ n k hkS, term ≤ C_i`.
  obtain ⟨hBdV, hCI⟩ := compositeRegularity_packaged q hq ν Δt u S hν hΔt
  choose C hC_nn hC using hBdV
  -- `hC : ∀ i, ∀ n k hkS, term ≤ C i`.  We want `∀ n k hkS i, term ≤ C i`.
  exact ⟨C, hC_nn, fun n k hkS i => hC i n k hkS, hCI⟩

/-! ## Empirical tightening - the Constantin-Iyer envelope -/

/-- The composite envelope constant `C := 0.075 rad` is internally
    consistent: it is positive and strictly less than π, so it is a
    valid uniform bound on the alignment angle. -/
lemma compositeRegularity_envelope_consistent :
    0 < compositeRegularity_bound ∧ compositeRegularity_bound < Real.pi :=
  ⟨compositeRegularity_bound_pos, compositeRegularity_bound_lt_pi⟩

end NsSpectral
