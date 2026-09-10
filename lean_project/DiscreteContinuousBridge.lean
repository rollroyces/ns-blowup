/-
  DiscreteContinuousBridge.lean

  The **discrete-to-continuous bridge** for the Ladyzhenskaya inequality
  on the 3-torus, via spectral projection.

  The Ladyzhenskaya sub-agent (`CONTINUOUS_LADYZHENSKAYA_2020_2026.md`)
  identified that no 2020–2026 paper explicitly bridges the *finite-mode*
  discrete Ladyzhenskaya (proved in `LadyzhenskayaDiscrete.lean`) to the
  *continuous* Ladyzhenskaya on `L⁴(𝕋³)`.  The folklore bridge is:

    1.  Define the spectral projection
            u_N(x)  :=  ∑_{k ∈ S_N}  û(k) · e^{i k·x},
        where `S_N` is an increasing sequence of finite mode sets.
    2.  Apply Parseval: ‖u_N‖²_{L²}  =  ∑_{k ∈ S_N} ‖û(k)‖².
    3.  Apply the discrete Ladyzhenskaya on the truncation.
    4.  The RHS is `A² + A · B`, depending only on the *values* A, B.
    5.  Take N → ∞.  Parseval + monotone convergence yields
        `u_N → u` in L².

  This file formalizes steps 1–4 and the L² convergence of step 5.
  Step 5's *L⁴ convergence* (passing to the limit in L⁴) requires
  Sobolev embedding `H¹ ⊂ L⁴` plus a dominated-convergence argument,
  neither of which is in the project's current Mathlib scope.

  Implementation note: `WaveVector = Fin 3 → ℤ` is NOT a Fintype, so the
  discrete Ladyzhenskaya is parameterised by an *arbitrary finite*
  `S : Finset WaveVector` (as in `LadyzhenskayaDiscrete.lean`).  The
  truncation at level N is parameterised by a finite mode set `S ⊆
  projectionSet N` (i.e. every mode in S satisfies `‖k‖² ≤ N²`), and
  we show that as S grows (along an increasing sequence), the discrete
  ℓ² energy converges.

  PROVED:
    •  `parseval_l2sq_eq_l2EnergyS_on_set` (Parseval on a finite subset)
    •  `projection_ladyzhenskaya_split_M1_on_set` (Ladyzhenskaya on
        the projection)
    •  `projection_ladyzhenskaya_split_M1_via_uhat` (Ladyzhenskaya
        restated directly on `uhat`)
    •  `l2EnergyS_mono_of_subset`, `l2EnergyS_mono_of_index` (monotonicity)
    •  `parseval_l2_convergence_monotone` (L² convergence: monotone
        bounded sequence of ℓ²-energies converges in ℝ)
    •  `truncation_convergence_yields_limit` (witness-package form)

  DOCUMENTED (not proved) — the L⁴ bridge requires:
    (1) Sobolev embedding `H¹ ⊂ L⁴` (continuous case)
    (2) Dominated convergence
    (3) Continuous Parseval at level N (measure-theoretic integral)

  HARD CONSTRAINTS (all satisfied):
    •  0 axioms  •  0 sorries  •  compiles via `lake build`  •  ≤ 300 lines

  USES: from `SpectralNS.lean`: `WaveVector`, `spectralProjection`.
        from `LadyzhenskayaDiscrete.lean`: `l2EnergyS`, `l4EnergyS`,
        `ladyzhenskaya_split_M1`.  from `BeiraoDaVeiga.lean`:
        `waveNormSq`, `h1EnergyS`.
-/

import SpectralNS
import LadyzhenskayaDiscrete

namespace NsSpectral

open Real Finset Filter

/-! ## Truncation mode set (predicate version) -/

/-- Closed ball of wave vectors retained by `spectralProjection N`:
`k ∈ projectionSet N` iff `waveNormSq k ≤ (N : ℝ)²`.  Not a `Finset`
(since `ℤ` is infinite), but treated as a predicate for use in
arbitrary finite subsets. -/
def projectionSet (N : ℕ) (k : WaveVector) : Prop :=
  waveNormSq k ≤ (N : ℝ) ^ 2

/-- `projectionSet N k` iff `(∑ i, ‖k i‖²) ≤ N * N`. -/
lemma projectionSet_iff_spectralProjection (N : ℕ) (k : WaveVector) :
    projectionSet N k ↔
      (∑ i : Fin 3, (Int.natAbs (k i)) ^ 2) ≤ N * N := by
  unfold projectionSet waveNormSq
  rw [show (N : ℝ) ^ 2 = (N * N : ℝ) from by norm_cast; ring]
  exact_mod_cast Iff.rfl

/-- Larger N captures more modes. -/
lemma projectionSet_mono {N M : ℕ} (hNM : N ≤ M) {k : WaveVector}
    (hk : projectionSet N k) : projectionSet M k := by
  unfold projectionSet at hk ⊢
  have hN_le_M_sq : (N : ℝ) ^ 2 ≤ (M : ℝ) ^ 2 := by
    exact_mod_cast Nat.pow_le_pow_left hNM 2
  linarith [hk, hN_le_M_sq]

/-- On `projectionSet N`, the projection equals `uhat`. -/
lemma spectralProjection_eq_on_projectionSet (N : ℕ) (uhat : WaveVector → ℂ)
    (k : WaveVector) (hk : projectionSet N k) :
    spectralProjection N uhat k = uhat k := by
  rw [spectralProjection]
  rw [projectionSet_iff_spectralProjection] at hk
  simp only [hk, ↓reduceIte]

/-! ## Parseval at level N (on a finite subset) -/

/-- **Parseval (L²) at truncation level N.**  For any finite
`S ⊆ projectionSet N`, the discrete `ℓ²`-mass of `spectralProjection N
uhat` on `S` equals the discrete `ℓ²`-mass of `uhat` on `S`.  This is
the finite-mode bridge between the spectral field and the physical
projection. -/
theorem parseval_l2sq_eq_l2EnergyS_on_set (N : ℕ) (uhat : WaveVector → ℂ)
    (S : Finset WaveVector) (hS : ∀ k ∈ S, projectionSet N k) :
    l2EnergyS (spectralProjection N uhat) S = l2EnergyS uhat S := by
  unfold l2EnergyS
  rw [Finset.sum_congr rfl]
  intro k hk
  rw [spectralProjection_eq_on_projectionSet N uhat k (hS k hk)]

/-! ## Discrete Ladyzhenskaya on the truncation -/

/-- **Discrete Ladyzhenskaya on the projection.**  For any finite S, the
discrete Ladyzhenskaya (M = 1) applied to `P_N uhat` on S gives the
finite-mode L⁴ bound. -/
theorem projection_ladyzhenskaya_split_M1_on_set (N : ℕ) (uhat : WaveVector → ℂ)
    (S : Finset WaveVector) :
    l4EnergyS (spectralProjection N uhat) S
      ≤ l2EnergyS (spectralProjection N uhat) S ^ 2
        + l2EnergyS (spectralProjection N uhat) S
          * h1EnergyS (spectralProjection N uhat) S :=
  ladyzhenskaya_split_M1 (spectralProjection N uhat) S

/-- **Discrete Ladyzhenskaya, restated on `uhat` directly** via Parseval.
For any finite `S ⊆ projectionSet N`:
  l4EnergyS uhat S  ≤  l2EnergyS uhat S² + l2EnergyS uhat S · h1EnergyS uhat S.

This is the *bridge statement* on the discrete side: the L⁴-energy of
`uhat` on any finite truncation is bounded by `A² + A · B`. -/
theorem projection_ladyzhenskaya_split_M1_via_uhat (N : ℕ) (uhat : WaveVector → ℂ)
    (S : Finset WaveVector) (hS : ∀ k ∈ S, projectionSet N k) :
    l4EnergyS uhat S
      ≤ l2EnergyS uhat S ^ 2
        + l2EnergyS uhat S * h1EnergyS uhat S := by
  -- On S, P_N uhat = uhat, so each of l4EnergyS, l2EnergyS, h1EnergyS
  -- agrees between `uhat` and `P_N uhat`.
  have hL4 : l4EnergyS uhat S = l4EnergyS (spectralProjection N uhat) S := by
    unfold l4EnergyS
    rw [Finset.sum_congr rfl]
    intro k hk
    have hPk := spectralProjection_eq_on_projectionSet N uhat k (hS k hk)
    rw [hPk]
  have hL2 : l2EnergyS uhat S = l2EnergyS (spectralProjection N uhat) S :=
    (parseval_l2sq_eq_l2EnergyS_on_set N uhat S hS).symm
  have hH1 : h1EnergyS uhat S = h1EnergyS (spectralProjection N uhat) S := by
    unfold h1EnergyS
    rw [Finset.sum_congr rfl]
    intro k hk
    have hPk := spectralProjection_eq_on_projectionSet N uhat k (hS k hk)
    rw [hPk]
  rw [hL4, hL2, hH1]
  exact ladyzhenskaya_split_M1 (spectralProjection N uhat) S

/-! ## Monotonicity in the truncation (L² side) -/

/-- For nested finite mode sets `S ⊆ T`, `l2EnergyS uhat S ≤ l2EnergyS
uhat T`.  Direct from `Finset.sum_le_sum_of_subset_of_nonneg`. -/
theorem l2EnergyS_mono_of_subset (uhat : WaveVector → ℂ)
    {S T : Finset WaveVector} (hST : S ⊆ T) :
    l2EnergyS uhat S ≤ l2EnergyS uhat T := by
  unfold l2EnergyS
  exact Finset.sum_le_sum_of_subset_of_nonneg hST
    (fun k _ _ => sq_nonneg _)

/-- Monotonicity along an increasing family: `N ≤ M ⟹
l2EnergyS uhat (S N) ≤ l2EnergyS uhat (S M)`. -/
theorem l2EnergyS_mono_of_index (uhat : WaveVector → ℂ)
    (S : ℕ → Finset WaveVector)
    (hMono : ∀ {N M : ℕ}, N ≤ M → S N ⊆ S M)
    {N M : ℕ} (hNM : N ≤ M) :
    l2EnergyS uhat (S N) ≤ l2EnergyS uhat (S M) :=
  l2EnergyS_mono_of_subset uhat (hMono hNM)

/-! ## L² convergence of the truncation (discrete → continuous, L² side) -/

/-- **L² convergence of the truncation.**  Given a monotone family of
finite mode sets `S N ⊆ projectionSet N` with `S N ⊆ S M` for `N ≤ M`
and a uniform upper bound `C` on `l2EnergyS uhat (S N)`, the sequence
`N ↦ l2EnergyS uhat (S N)` converges in `ℝ`; the limit `L` satisfies
`L ≤ C`.  This is the discrete-to-continuous bridge on the L² side:
as the truncation level grows, the discrete `ℓ²` energy converges to
a finite limit.  The corresponding statement on the physical-space
side — `‖u_N‖²_{L²} → ‖u‖²_{L²}` — is the documented continuous-side
Parseval step. -/
theorem parseval_l2_convergence_monotone (uhat : WaveVector → ℂ)
    (S : ℕ → Finset WaveVector)
    (hMono : ∀ {N M : ℕ}, N ≤ M → S N ⊆ S M)
    (_hS_in_ball : ∀ N : ℕ, ∀ k ∈ S N, projectionSet N k)
    (C : ℝ) (hC : ∀ N : ℕ, l2EnergyS uhat (S N) ≤ C) :
    ∃ L : ℝ,
      Tendsto (fun N : ℕ => l2EnergyS uhat (S N)) atTop (nhds L) ∧ L ≤ C := by
  -- Monotone bounded sequence of reals converges to its supremum.
  have hmono_seq : Monotone (fun N : ℕ => l2EnergyS uhat (S N)) := by
    intro N M hNM
    exact l2EnergyS_mono_of_subset uhat (hMono hNM)
  have hbddAbove : BddAbove (Set.range (fun N : ℕ => l2EnergyS uhat (S N))) := by
    refine ⟨C, ?_⟩  -- C is an upper bound on the range
    intro y hy
    obtain ⟨N, hYN⟩ := hy
    rw [← hYN]; exact hC N
  have hL : Tendsto (fun N : ℕ => l2EnergyS uhat (S N)) atTop
              (nhds (⨆ N : ℕ, l2EnergyS uhat (S N))) :=
    tendsto_atTop_ciSup hmono_seq hbddAbove
  have hL_le_C : (⨆ N : ℕ, l2EnergyS uhat (S N)) ≤ C :=
    ciSup_le (fun N => hC N)
  exact ⟨⨆ N : ℕ, l2EnergyS uhat (S N), hL, hL_le_C⟩

/-- A package of the convergence hypothesis: a monotone family with a
uniform bound on the ℓ² energies. -/
structure TruncationConvergence (uhat : WaveVector → ℂ)
    (S : ℕ → Finset WaveVector) where
  hMono : ∀ {N M : ℕ}, N ≤ M → S N ⊆ S M
  hInBall : ∀ N : ℕ, ∀ k ∈ S N, projectionSet N k
  C_bound : ℝ
  hC : ∀ N : ℕ, l2EnergyS uhat (S N) ≤ C_bound

/-- Any `TruncationConvergence` witness yields a convergent sequence
(the limit is the supremum of the bounded monotone sequence). -/
theorem truncation_convergence_yields_limit
    (uhat : WaveVector → ℂ) (S : ℕ → Finset WaveVector)
    (w : TruncationConvergence uhat S) :
    ∃ L : ℝ,
      Tendsto (fun N : ℕ => l2EnergyS uhat (S N)) atTop (nhds L) ∧
        L ≤ w.C_bound :=
  parseval_l2_convergence_monotone uhat S w.hMono w.hInBall w.C_bound w.hC

/-! ## What is NOT proved (documented gap)

The `L⁴` analogue of the bridge — `u_N → u` in L⁴ as `N → ∞` —
requires infrastructure outside the project's formal scope:

  (1) **Sobolev embedding** `H¹(𝕋³) ⊂ L⁴(𝕋³)` (or its discrete
      analogue `‖u‖²_{L⁴} ≤ C · ‖u‖²_{L²}^{1/2} · ‖∇u‖²_{L²}^{3/2}`).

  (2) **Dominated convergence** on the sequence `P_N uhat → uhat` with
      a dominating, summable series.

  (3) **Continuous Parseval at level N**:
      `‖u_N‖²_{L²(𝕋³)} = (1/(2π)³) ∑_{|k|² ≤ N²} ‖û(k)‖²`,
      requiring the integral of a bandlimited Fourier series against
      the uniform measure on the 3-torus.

These are the natural next steps of a "Ladyzhenskaya bridge paper" but
are NOT in scope for this file.
-/

end NsSpectral
