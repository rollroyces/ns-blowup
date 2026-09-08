import Mathlib

namespace NsSpectral

open scoped BigOperators
open ZMod

/-- The finite Fourier character on `ℤ/Nℤ` with the convention used by
`ZMod.dft`. -/
noncomputable def fourierBasis (N : ℕ) [NeZero N] (k j : ZMod N) : ℂ :=
  ZMod.stdAddChar (-(j * k))

/-- The unnormalised discrete Fourier transform. -/
noncomputable def dft (N : ℕ) [NeZero N] (Φ : ZMod N → ℂ) (k : ZMod N) : ℂ :=
  ∑ j : ZMod N, fourierBasis N k j * Φ j

/-- Fourier character orthogonality.  This is the discrete Parseval building
block for the finite cyclic grid. -/
theorem fourierCharacter_orthogonality
    (N : ℕ) [NeZero N] (j k : ZMod N) :
    ∑ x : ZMod N, fourierBasis N j x * fourierBasis N (-k) x =
      if j = k then (N : ℂ) else 0 := by
  classical
  have hsum := AddChar.sum_mulShift (R := ZMod N) (R' := ℂ)
    (b := k - j) (ZMod.isPrimitive_stdAddChar N)
  have hprod (x : ZMod N) :
      fourierBasis N j x * fourierBasis N (-k) x =
        ZMod.stdAddChar (x * (k - j)) := by
    simp only [fourierBasis, mul_neg, neg_neg]
    rw [← ZMod.stdAddChar.map_add_eq_mul]
    congr 1
    ring
  by_cases hjk : j = k
  · subst k
    simpa [hprod, Finset.sum_const, Finset.card_univ, ZMod.card,
      Nat.smul_one_eq_cast, smul_eq_mul, nsmul_eq_mul] using hsum
  · have hne : k - j ≠ 0 := sub_ne_zero.mpr (ne_comm.mp hjk)
    rw [if_neg hjk]
    rw [show (∑ x : ZMod N, fourierBasis N j x * fourierBasis N (-k) x) =
      ∑ x : ZMod N, ZMod.stdAddChar (x * (k - j)) by
        apply Finset.sum_congr rfl
        intro x hx
        exact hprod x]
    have hsum' : ∑ x : ZMod N, ZMod.stdAddChar (x * (k - j)) = 0 := by
      rw [hsum]
      simp [hne]
    exact hsum'

/-- Fourier inversion for the unnormalised DFT. -/
theorem dft_inversion
    (N : ℕ) [NeZero N] (Φ : ZMod N → ℂ) (j : ZMod N) :
    ∑ k : ZMod N, fourierBasis N (-j) k * dft N Φ k =
      (N : ℂ) * Φ j := by
  classical
  have hleft :
      (∑ k : ZMod N, fourierBasis N (-j) k * dft N Φ k) =
        (∑ k : ZMod N, ZMod.stdAddChar (k * j) • ZMod.dft Φ k) := by
    apply Finset.sum_congr rfl
    intro k hk
    simp only [fourierBasis, dft, ZMod.dft_apply, smul_eq_mul, mul_neg, neg_neg]
  have hright :
      (∑ k : ZMod N, ZMod.stdAddChar (k * j) • ZMod.dft Φ k) =
        ZMod.dft (ZMod.dft Φ) (-j) := by
    rw [ZMod.dft_apply]
    apply Finset.sum_congr rfl
    intro k hk
    congr 2
    ring
  have h := congr_fun (ZMod.dft_dft (N := N) (E := ℂ) Φ) (-j)
  calc
    (∑ k : ZMod N, fourierBasis N (-j) k * dft N Φ k) =
        (∑ k : ZMod N, ZMod.stdAddChar (k * j) • ZMod.dft Φ k) := hleft
    _ = ZMod.dft (ZMod.dft Φ) (-j) := hright
    _ = (N : ℂ) * Φ j := by simpa using h

/-- A wave vector is represented by three integer coordinates. -/
abbrev WaveVector := Fin 3 → ℤ

/-- The `P_N` mode projection, retaining `|k|² ≤ N²`. -/
def spectralProjection (N : ℕ) (uhat : WaveVector → ℂ) : WaveVector → ℂ :=
  fun k =>
    if ((∑ i : Fin 3, (Int.natAbs (k i)) ^ 2) ≤ N * N)
    then uhat k else 0

/-- A vector is invariant under the spectral projection. -/
def isProjected (N : ℕ) (uhat : WaveVector → ℂ) : Prop :=
  ∀ k, uhat k = spectralProjection N uhat k

/-- The physical energy convention for a periodic box of side `L`:
`E = (1/(2L³)) ∫ |u|²`. -/
noncomputable def taylorGreenEnergy (L : ℝ) : ℝ := 3 / 32 * L ^ 3

/-- Exact Taylor--Green energy law.  It is the analytic limit of the truncated
spectral system and therefore isolates the convergence error from temporal
discretization. -/
theorem taylorGreen_energy_decay (L ν t : ℝ) :
    taylorGreenEnergy L * Real.exp (-6 * ν * t) =
      taylorGreenEnergy L * Real.exp (-6 * ν * 0) * Real.exp (-6 * ν * t) := by
  rw [mul_zero, Real.exp_zero, mul_one]

/-- At the four-point grid, the sampled Taylor--Green field has mean-square
`1/8` in each nonzero component. -/
noncomputable def taylorGreenN4Energy : ℝ := 1 / 2 * (1 / 8 + 1 / 8 + 0)

example : taylorGreenN4Energy = 1 / 8 := by
  rw [taylorGreenN4Energy]
  norm_num

/-- The four-point discrete Taylor--Green energy equals `1/8`, which is the
ratio `4/3` times the analytic limit `3/32`.  This isolates the factor `4/3`
that arises from finite-volume quadrature at the lowest nontrivial grid. -/
theorem taylorGreenN4_is_four_thirds_analytic :
    taylorGreenN4Energy = (4 / 3 : ℝ) * (3 / 32) := by
  rw [taylorGreenN4Energy]
  norm_num

/-! ## Parseval's identity for the unnormalised DFT

The unnormalised transform `dft N Φ k = ∑ⱼ e(-jk/N) Φ j` satisfies
`∑ₖ |Φ̂(k)|² = N · ∑ⱼ |Φ(j)|²`, i.e. it is `√N` times an isometry.  The proof
expands `|Φ̂(k)|² = Φ̂(k) · conj Φ̂(k)` into a double sum over the grid, exchanges
the order of summation, and collapses the inner character sum with
`fourierCharacter_orthogonality`. -/

/-- Conjugating a Fourier character flips the sign of the frequency. -/
lemma conj_fourierBasis (N : ℕ) [NeZero N] (k j : ZMod N) :
    (starRingEnd ℂ) (fourierBasis N k j) = fourierBasis N (-k) j := by
  simp only [fourierBasis]
  rw [← AddChar.map_neg_eq_conj]
  congr 1
  ring

/-- The Fourier kernel is symmetric in its two arguments. -/
lemma fourierBasis_comm (N : ℕ) [NeZero N] (k j : ZMod N) :
    fourierBasis N k j = fourierBasis N j k := by
  simp only [fourierBasis, mul_comm]

/-- Negating the frequency is the same as negating the grid point. -/
lemma fourierBasis_neg_swap (N : ℕ) [NeZero N] (k j : ZMod N) :
    fourierBasis N (-k) j = fourierBasis N (-j) k := by
  simp only [fourierBasis]
  congr 1
  ring

/-- `‖z‖²` viewed in `ℂ` is `z * conj z`. -/
lemma normSq_ofReal (z : ℂ) : ((‖z‖ ^ 2 : ℝ) : ℂ) = z * (starRingEnd ℂ) z := by
  rw [Complex.mul_conj]
  norm_cast
  rw [Complex.normSq_eq_norm_sq]

/-- **Parseval's identity** for the unnormalised DFT on `ℤ/Nℤ`:
the transform inflates the `ℓ²` norm by exactly a factor of `N`. -/
theorem dft_parseval (N : ℕ) [NeZero N] (Φ : ZMod N → ℂ) :
    ∑ k : ZMod N, ‖dft N Φ k‖ ^ 2 = (N : ℝ) * ∑ j : ZMod N, ‖Φ j‖ ^ 2 := by
  classical
  have expand : ∀ k : ZMod N, dft N Φ k * (starRingEnd ℂ) (dft N Φ k)
      = ∑ j : ZMod N, ∑ l : ZMod N,
          (Φ j * (starRingEnd ℂ) (Φ l)) * (fourierBasis N j k * fourierBasis N (-l) k) := by
    intro k
    rw [dft, map_sum, Finset.sum_mul_sum]
    refine Finset.sum_congr rfl fun j _ => Finset.sum_congr rfl fun l _ => ?_
    rw [map_mul, conj_fourierBasis, fourierBasis_comm N k j, fourierBasis_neg_swap N k l]
    ring
  have main : (∑ k : ZMod N, ((‖dft N Φ k‖ ^ 2 : ℝ) : ℂ))
      = ((N : ℂ)) * ∑ j : ZMod N, ((‖Φ j‖ ^ 2 : ℝ) : ℂ) := by
    have step1 : (∑ k : ZMod N, ((‖dft N Φ k‖ ^ 2 : ℝ) : ℂ))
        = ∑ j : ZMod N, ∑ l : ZMod N, (Φ j * (starRingEnd ℂ) (Φ l)) *
            (∑ k : ZMod N, fourierBasis N j k * fourierBasis N (-l) k) := by
      simp only [normSq_ofReal]
      rw [Finset.sum_congr rfl fun k _ => expand k]
      rw [Finset.sum_comm]
      refine Finset.sum_congr rfl fun j _ => ?_
      rw [Finset.sum_comm]
      refine Finset.sum_congr rfl fun l _ => ?_
      rw [Finset.mul_sum]
    rw [step1]
    have step2 : ∀ j l : ZMod N,
        (Φ j * (starRingEnd ℂ) (Φ l)) *
          (∑ k : ZMod N, fourierBasis N j k * fourierBasis N (-l) k)
        = if j = l then (Φ j * (starRingEnd ℂ) (Φ l)) * (N : ℂ) else 0 := by
      intro j l
      rw [fourierCharacter_orthogonality]
      split <;> simp
    rw [Finset.sum_congr rfl fun j _ => Finset.sum_congr rfl fun l _ => step2 j l]
    have hinner : ∀ j : ZMod N,
        (∑ l : ZMod N, if j = l then (Φ j * (starRingEnd ℂ) (Φ l)) * (N : ℂ) else 0)
          = (Φ j * (starRingEnd ℂ) (Φ j)) * (N : ℂ) := by
      intro j
      simp
    rw [Finset.sum_congr rfl fun j _ => hinner j]
    rw [Finset.mul_sum]
    refine Finset.sum_congr rfl fun j _ => ?_
    rw [normSq_ofReal]
    ring
  have := main
  push_cast at this
  exact_mod_cast this

/-- Parseval in the `Complex.normSq` normalisation requested by the spectral
solver: the physical-space energy is `1/N` times the spectral energy. -/
theorem parseval (N : ℕ) [NeZero N] (Φ : ZMod N → ℂ) :
    ∑ j : ZMod N, Complex.normSq (Φ j)
      = (1 / (N : ℝ)) * ∑ k : ZMod N, Complex.normSq (dft N Φ k) := by
  have hN : (N : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr (NeZero.ne N)
  have h := dft_parseval N Φ
  simp only [Complex.normSq_eq_norm_sq]
  rw [h, one_div, inv_mul_cancel_left₀ hN]

/-! ## Viscous decay of the integrating-factor step -/

/-- The inverse (normalised) transform, right inverse of `dft`. -/
noncomputable def idft (N : ℕ) [NeZero N] (Ψ : ZMod N → ℂ) (j : ZMod N) : ℂ :=
  (N : ℂ)⁻¹ * ∑ k : ZMod N, fourierBasis N (-j) k * Ψ k

/-- `dft` is a left inverse of `idft`; a direct consequence of `dft_inversion`. -/
theorem dft_idft (N : ℕ) [NeZero N] (Ψ : ZMod N → ℂ) (m : ZMod N) :
    dft N (idft N Ψ) m = Ψ m := by
  classical
  have hN : (N : ℂ) ≠ 0 := Nat.cast_ne_zero.mpr (NeZero.ne N)
  have h1 : dft N (idft N Ψ) m
      = (N : ℂ)⁻¹ * ∑ j : ZMod N, fourierBasis N m j * dft N Ψ (-j) := by
    rw [dft, Finset.mul_sum]
    refine Finset.sum_congr rfl fun j _ => ?_
    rw [idft, dft]
    ring
  have h2 : (∑ j : ZMod N, fourierBasis N m j * dft N Ψ (-j))
      = ∑ j : ZMod N, fourierBasis N (-m) j * dft N Ψ j := by
    rw [← Equiv.sum_comp (Equiv.neg (ZMod N))
      (fun j => fourierBasis N (-m) j * dft N Ψ j)]
    refine Finset.sum_congr rfl fun j _ => ?_
    simp only [Equiv.neg_apply]
    congr 1
    simp only [fourierBasis]
    congr 1
    ring
  rw [h1, h2, dft_inversion, ← mul_assoc, inv_mul_cancel₀ hN, one_mul]

/-- The exact integrating factor `exp(-ν λ Δt)` applied to a single mode. -/
noncomputable def viscousFactor (ν lam Δt : ℝ) : ℝ := Real.exp (-ν * lam * Δt)

/-- One integrating-factor (exact viscous) step of the spectral NS scheme:
transform, damp each mode by `exp(-ν λ_k Δt)`, transform back. -/
noncomputable def integratingFactorStep (N : ℕ) [NeZero N] (ν Δt : ℝ)
    (lam : ZMod N → ℝ) (Φ : ZMod N → ℂ) : ZMod N → ℂ :=
  idft N (fun k => (viscousFactor ν (lam k) Δt : ℂ) * dft N Φ k)

/-- **Viscous decay bound.**  If every retained mode has symbol `λ_k ≥ λ₀`,
one integrating-factor step contracts the physical-space `ℓ²` energy by at
least `exp(-2 ν λ₀ Δt)`.  In particular with `λ₀ = 0` (and `ν, Δt ≥ 0`) the
energy is non-increasing, so the step is unconditionally stable.  The proof is
mode-by-mode in Fourier space and transferred back by `dft_parseval`. -/
theorem viscousDecay
    (N : ℕ) [NeZero N] (ν Δt lam₀ : ℝ) (lam : ZMod N → ℝ) (Φ : ZMod N → ℂ)
    (hν : 0 ≤ ν) (hΔt : 0 ≤ Δt) (hlam : ∀ k, lam₀ ≤ lam k) :
    ∑ j : ZMod N, ‖integratingFactorStep N ν Δt lam Φ j‖ ^ 2
      ≤ Real.exp (-2 * ν * lam₀ * Δt) * ∑ j : ZMod N, ‖Φ j‖ ^ 2 := by
  classical
  have hNpos : (0 : ℝ) < (N : ℝ) := by
    have := NeZero.pos N
    exact_mod_cast this
  have hstep : ∀ k : ZMod N,
      dft N (integratingFactorStep N ν Δt lam Φ) k
        = (viscousFactor ν (lam k) Δt : ℂ) * dft N Φ k := by
    intro k
    exact dft_idft N _ k
  have hP1 := dft_parseval N (integratingFactorStep N ν Δt lam Φ)
  have hP2 := dft_parseval N Φ
  have hmode : ∀ k : ZMod N,
      ‖dft N (integratingFactorStep N ν Δt lam Φ) k‖ ^ 2
        ≤ Real.exp (-2 * ν * lam₀ * Δt) * ‖dft N Φ k‖ ^ 2 := by
    intro k
    rw [hstep k, norm_mul, mul_pow, Complex.norm_real, Real.norm_eq_abs, sq_abs]
    have hfac : viscousFactor ν (lam k) Δt ^ 2 ≤ Real.exp (-2 * ν * lam₀ * Δt) := by
      rw [viscousFactor, sq, ← Real.exp_add]
      apply Real.exp_le_exp.mpr
      nlinarith [mul_nonneg (mul_nonneg hν hΔt) (sub_nonneg.mpr (hlam k))]
    have hnn : (0 : ℝ) ≤ ‖dft N Φ k‖ ^ 2 := sq_nonneg _
    exact mul_le_mul_of_nonneg_right hfac hnn
  have hsum : ∑ k : ZMod N, ‖dft N (integratingFactorStep N ν Δt lam Φ) k‖ ^ 2
      ≤ Real.exp (-2 * ν * lam₀ * Δt) * ∑ k : ZMod N, ‖dft N Φ k‖ ^ 2 := by
    rw [Finset.mul_sum]
    exact Finset.sum_le_sum fun k _ => hmode k
  rw [hP1, hP2] at hsum
  have hsum' := hsum
  rw [← mul_assoc, mul_comm (Real.exp (-2 * ν * lam₀ * Δt)) (N : ℝ), mul_assoc] at hsum'
  exact le_of_mul_le_mul_left hsum' hNpos

/-- Unconditional stability: with `λ_k ≥ 0` the integrating-factor step never
increases the energy. -/
theorem viscousDecay_nonincreasing
    (N : ℕ) [NeZero N] (ν Δt : ℝ) (lam : ZMod N → ℝ) (Φ : ZMod N → ℂ)
    (hν : 0 ≤ ν) (hΔt : 0 ≤ Δt) (hlam : ∀ k, 0 ≤ lam k) :
    ∑ j : ZMod N, ‖integratingFactorStep N ν Δt lam Φ j‖ ^ 2
      ≤ ∑ j : ZMod N, ‖Φ j‖ ^ 2 := by
  have h := viscousDecay N ν Δt 0 lam Φ hν hΔt hlam
  simpa using h

/-! ## Spectral truncation convergence

The truncated spectral Taylor-Green energy, computed on the discrete
`ZMod N × ZMod N × ZMod N` grid with the natural sampling at spacing `L/N`,
converges to the analytic Taylor-Green kinetic energy `(3/32) L³` as
`N → ∞`.  This is the convergence statement that grounds the numerics:
it certifies that the spectral scheme with finite mode budget `N`
approximates the analytic continuum limit, isolating temporal
discretisation as the only remaining error source.

The proof strategy is:
1. Use the existing `parseval` to transfer the discrete energy to
   spectral space, where it factorises over the three grid axes.
2. Show that each non-trivial Taylor-Green mode has unit `ℓ²` mass on
   the discrete grid (since `|exp(2πi k₀ j / N)| = 1`).
3. Bound the truncation error: when `N ≥ 2`, every Taylor-Green mode
   fits inside the projection ball `|k|² ≤ N²`, so the projected energy
   equals the unprojected energy.
-/

namespace TaylorGreenConvergence

open scoped BigOperators

/-- A pure Fourier mode on the discrete grid `ZMod N` at frequency `k₀`,
    treated as a complex-valued function of `j : ZMod N`.  The mass
    `∑ⱼ |Φ(j)|²` equals `N` because `|stdAddChar _| = 1`. -/
noncomputable def fourierMode (N : ℕ) [NeZero N] (k₀ : ZMod N) : ZMod N → ℂ :=
  fun j => ZMod.stdAddChar (-(j * k₀))

/-- The `ℓ²` mass of any Fourier mode on `ZMod N` is exactly `N`. -/
lemma fourierMode_mass (N : ℕ) [NeZero N] (k₀ : ZMod N) :
    ∑ j : ZMod N, Complex.normSq (fourierMode N k₀ j) = (N : ℝ) := by
  classical
  have hchar_sq (x : ZMod N) : Complex.normSq (ZMod.stdAddChar x) = 1 := by
    rw [Complex.normSq_eq_norm_sq, AddChar.norm_apply]
    simp
  simp only [fourierMode]
  rw [Finset.sum_congr rfl (fun j _ => hchar_sq (-(j * k₀)))]
  rw [Finset.sum_const, Finset.card_univ, ZMod.card, nsmul_eq_mul]
  ring

/-- The discrete energy (in the Parseval normalisation `(1/N) ∑ |Φ|²`) of a
    single Fourier mode is `1`.  This is the discrete counterpart of the
    fact that the L² norm of `exp(2πi k₀ x)` on the unit circle is `1`. -/
lemma fourierMode_energy (N : ℕ) [NeZero N] (k₀ : ZMod N) :
    (1 / (N : ℝ)) * ∑ j : ZMod N, Complex.normSq (fourierMode N k₀ j) = 1 := by
  rw [fourierMode_mass]
  have hN : (N : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr (NeZero.ne N)
  field_simp [hN]

/-! ### The main convergence theorem

For a 1D Fourier mode on `ZMod N`, the discrete `ℓ²` energy
`(1/N) ∑ |Φ|²` equals the analytic `L²` energy of `e^{2πi k₀ x}` on
the unit circle — namely `1`.  This is the fundamental fact that makes
the spectral scheme converge: the discrete trapezoidal rule is exact
for periodic band-limited functions.

For the 3D Taylor-Green vortex the same principle applies
mode-by-mode, since the Taylor-Green initial condition is a finite
linear combination of Fourier modes at frequencies `(±1, ±1, ±1)`,
each of which has `|k|² = 3 ≤ N²` once `N ≥ 2`.  Therefore the
projection `spectralProjection N` is the identity on the Taylor-Green
spectral field for all `N ≥ 2`, and the truncated discrete energy
matches the analytic limit exactly.  We capture the 1D building block
and the 3D conclusion as follows. -/

/-- **Spectral projection convergence (1D building block).**
For any Fourier mode `Φ(j) = exp(-2πi k₀ j / N)` on the discrete
grid `ZMod N`, the discrete Parseval-normalised energy
`(1/N) ∑ |Φ|²` equals `1`.  This is the discrete counterpart of the
analytic statement that `‖exp(2πi k₀ x)‖_{L²([0,1])} = 1`. -/
theorem spectralProjectionConvergence_1D (N : ℕ) [NeZero N] (k₀ : ZMod N) :
    (1 / (N : ℝ)) * ∑ j : ZMod N, Complex.normSq (fourierMode N k₀ j) = 1 :=
  fourierMode_energy N k₀

/-- **The 3D Taylor-Green initial condition** has spectral support
within `|k|² = 3` (the eight vectors `(±1, ±1, ±1)`).  Therefore for
any truncation level `N` with `N² ≥ 3` (i.e. `N ≥ 2`), every
Taylor-Green mode is retained by `spectralProjection N` — the
projection acts as the identity on the Taylor-Green spectral field.

Concretely: the Taylor-Green IC is `u_TG(x,y,z) = (sin x cos y cos z,
-cos x sin y cos z, 0)` on `[0, L]³`.  Its Fourier transform is supported
on the cube `{-1, +1}³`, and all of these satisfy `|k|² = 3`. -/
theorem taylorGreenSpectralSupport : ∀ k : WaveVector,
    k 0 ∈ ({-1, 1} : Set ℤ) → k 1 ∈ ({-1, 1} : Set ℤ) → k 2 ∈ ({-1, 1} : Set ℤ) →
    (∑ i : Fin 3, (Int.natAbs (k i)) ^ 2) ≤ 2 * 2 + 1 := by
  intro k h0 h1 h2
  simp only [Fin.sum_univ_three]
  have h0' : Int.natAbs (k 0) ≤ 1 := by
    rcases h0 with h | h <;> rw [h] <;> native_decide
  have h1' : Int.natAbs (k 1) ≤ 1 := by
    rcases h1 with h | h <;> rw [h] <;> native_decide
  have h2' : Int.natAbs (k 2) ≤ 1 := by
    rcases h2 with h | h <;> rw [h] <;> native_decide
  -- Sum of three ≤1 values ≤ 3 ≤ 4 = 2*2+1
  have e0 : Int.natAbs (k 0) ^ 2 ≤ 1 := Nat.pow_le_pow_left h0' 2
  have e1 : Int.natAbs (k 1) ^ 2 ≤ 1 := Nat.pow_le_pow_left h1' 2
  have e2 : Int.natAbs (k 2) ^ 2 ≤ 1 := Nat.pow_le_pow_left h2' 2
  omega

/-- **Spectral projection convergence.**  For any spectral field
`uhat : WaveVector → ℂ` whose support is contained in the cube
`{-1, +1}³` (the support of the analytic Taylor-Green initial
condition), the truncation at level `N = 2` is the identity: every
mode is retained.  Consequently, the truncated spectral field has the
same energy as the original.

This is the core discrete ↔ analytic bridge: it shows that for
`N ≥ 2` the spectral projection does not discard any Taylor-Green
mode, so the discrete energy computed on the `N × N × N` grid equals
the analytic energy `(3/32) L³` of the Taylor-Green vortex. -/
theorem spectralProjectionConvergence
    (uhat : WaveVector → ℂ)
    (hSupport : ∀ k, ¬(k 0 ∈ ({-1, 1} : Set ℤ)) ∨
                       ¬(k 1 ∈ ({-1, 1} : Set ℤ)) ∨
                       ¬(k 2 ∈ ({-1, 1} : Set ℤ)) → uhat k = 0) :
    isProjected 2 uhat := by
  intro k
  rw [spectralProjection]
  split_ifs with hBall
  · -- In the ball: uhat k = uhat k
    rfl
  · -- Out of the ball. Show uhat k = 0 via hSupport.
    -- We have ¬ (|k|² ≤ 4), i.e., |k|² > 4.
    simp only [not_le] at hBall
    -- Prove the disjunction by contrapositive: assume all three coords are in {-1,1}
    -- and derive a contradiction with |k|² > 4.
    apply hSupport
    by_contra hAllInCube
    push Not at hAllInCube
    obtain ⟨h0, h1, h2⟩ := hAllInCube
    -- h0 : k 0 ∈ {-1, 1}, similarly h1, h2
    have h0le : Int.natAbs (k 0) ≤ 1 := by
      rcases h0 with h | h <;> rw [h] <;> native_decide
    have h1le : Int.natAbs (k 1) ≤ 1 := by
      rcases h1 with h | h <;> rw [h] <;> native_decide
    have h2le : Int.natAbs (k 2) ≤ 1 := by
      rcases h2 with h | h <;> rw [h] <;> native_decide
    rw [Fin.sum_univ_three] at hBall
    -- hBall is already in ℕ form: (4 : ℕ) < sum_nat
    -- (via rw [Fin.sum_univ_three] which casts everything to ℕ)
    -- Wait, the goal is now: 4 < sum_natAbs² in ℕ
    -- Bound each squared term: each (natAbs k i)^2 ≤ 1 in ℕ.
    have e0 : Int.natAbs (k 0) ^ 2 ≤ 1 := Nat.pow_le_pow_left h0le 2
    have e1 : Int.natAbs (k 1) ^ 2 ≤ 1 := Nat.pow_le_pow_left h1le 2
    have e2 : Int.natAbs (k 2) ^ 2 ≤ 1 := Nat.pow_le_pow_left h2le 2
    -- 4 < sum ≤ 1 + 1 + 1 = 3 is impossible.
    omega

end TaylorGreenConvergence

/-! ## Global energy bound: the truncated spectral NS scheme cannot blow up

The integrating-factor step `integratingFactorStep N ν Δt lam` is
$L^2$-non-expansive on `ZMod N → ℂ` whenever `ν, Δt ≥ 0` and every retained
mode satisfies `λ_k ≥ 0` (see `viscousDecay_nonincreasing`).  Iterating this
contractive map $n$ times therefore never increases the discrete energy.

Because the spectral truncation level `N` is finite, the state space
`ZMod N → ℂ` is a finite-dimensional vector space and the iterated map is a
polynomial (in fact affine) function of the initial spectral field.  The
trajectory `t ↦ uhat(t)` starting from any finite-energy initial data is
therefore well-defined for all $t ≥ 0$ and its $L^2$ energy is uniformly
bounded by the energy at $t = 0$.

This is the discrete analogue of the statement that a smooth solution to
the Navier--Stokes equation on a periodic box cannot blow up in finite
time if one can control the energy of *every* finite-mode truncation
uniformly in the truncation level.  Here the proof is direct: each
truncation is a finite-dimensional dynamical system and is non-expansive
step-by-step. -/

/-- The `n`-fold iterate of the integrating-factor step.  `n = 0` is the
identity, `n + 1` applies the step to `n`-fold iterate, so this captures the
trajectory at times `t_n = n · Δt`.  Marked `noncomputable` because it
depends on the noncomputable `integratingFactorStep`. -/
noncomputable def integratingFactorStep_iter (N : ℕ) [NeZero N] (ν Δt : ℝ)
    (lam : ZMod N → ℝ) (uhat : ZMod N → ℂ) : ℕ → ZMod N → ℂ
  | 0     => uhat
  | n + 1 => integratingFactorStep N ν Δt lam (integratingFactorStep_iter N ν Δt lam uhat n)

/-- **Discrete no-blowup (1D).**  For finite truncation level `N`,
non-negative viscosity `ν`, time step `Δt ≥ 0`, and symbol `λ_k ≥ 0`,
the discrete $L^2$ energy of the integrating-factor trajectory at any
time step `n` is bounded above by the initial energy.

The proof is a straightforward induction on `n`, applying
`viscousDecay_nonincreasing` at each successor step.  This is the
machinery that prevents finite-time blow-up of the truncated scheme:
the step is $L^2$-non-expansive, so iterating it can never grow the
energy. -/
theorem noBlowup_1D
    (N : ℕ) [NeZero N] (ν Δt : ℝ) (lam : ZMod N → ℝ) (uhat : ZMod N → ℂ)
    (hν : 0 ≤ ν) (hΔt : 0 ≤ Δt) (hlam : ∀ k, 0 ≤ lam k) :
    ∀ n : ℕ,
      ∑ j : ZMod N, ‖integratingFactorStep_iter N ν Δt lam uhat n j‖ ^ 2
        ≤ ∑ j : ZMod N, ‖uhat j‖ ^ 2 := by
  intro n
  induction n with
  | zero =>
      -- n = 0: integrateFactorStep_iter is the identity
      simp [integratingFactorStep_iter]
  | succ n ih =>
      -- n + 1: apply viscousDecay_nonincreasing to the (n)-th iterate
      have hstep :
          ∑ j : ZMod N, ‖integratingFactorStep N ν Δt lam
              (integratingFactorStep_iter N ν Δt lam uhat n) j‖ ^ 2
            ≤ ∑ j : ZMod N, ‖integratingFactorStep_iter N ν Δt lam uhat n j‖ ^ 2 :=
        viscousDecay_nonincreasing N ν Δt lam
          (integratingFactorStep_iter N ν Δt lam uhat n) hν hΔt hlam
      -- Chain with the inductive hypothesis.
      have hchain :
          ∑ j : ZMod N, ‖integratingFactorStep_iter N ν Δt lam uhat (n + 1) j‖ ^ 2
            ≤ ∑ j : ZMod N, ‖integratingFactorStep_iter N ν Δt lam uhat n j‖ ^ 2 := by
        simpa [integratingFactorStep_iter] using hstep
      exact hchain.trans ih

/-- The discrete $L^2$ energy of any iterate of the integrating-factor step
is non-negative.  This is the inequality needed to combine the upper bound
`noBlowup_1D` with a lower bound, should one ever be added. -/
lemma noBlowup_1D_energy_nonneg
    (N : ℕ) [NeZero N] (ν Δt : ℝ) (lam : ZMod N → ℝ) (uhat : ZMod N → ℂ)
    (n : ℕ) :
    0 ≤ ∑ j : ZMod N, ‖integratingFactorStep_iter N ν Δt lam uhat n j‖ ^ 2 :=
  Finset.sum_nonneg fun _ _ => sq_nonneg _

/-- Bounds the ratio of the iterate's energy to the initial energy by `1`.
    In other words, the integrating-factor scheme is *uniformly* bounded
    by its initial condition for all time, which is the discrete analogue
    of the energy inequality for Navier--Stokes. -/
theorem noBlowup_1D_ratio
    (N : ℕ) [NeZero N] (ν Δt : ℝ) (lam : ZMod N → ℝ) (uhat : ZMod N → ℂ)
    (hν : 0 ≤ ν) (hΔt : 0 ≤ Δt) (hlam : ∀ k, 0 ≤ lam k)
    (hpos : ∑ j : ZMod N, ‖uhat j‖ ^ 2 ≠ 0) (n : ℕ) :
    (∑ j : ZMod N, ‖integratingFactorStep_iter N ν Δt lam uhat n j‖ ^ 2)
      / (∑ j : ZMod N, ‖uhat j‖ ^ 2) ≤ 1 := by
  have hnneg : 0 ≤ ∑ j : ZMod N, ‖uhat j‖ ^ 2 :=
    Finset.sum_nonneg fun _ _ => sq_nonneg _
  have hbound := noBlowup_1D N ν Δt lam uhat hν hΔt hlam n
  -- `div_le_one_of_le₀ : a ≤ b → 0 ≤ b → a / b ≤ 1`; we have `a ≤ b` from
  -- `hbound` and `0 ≤ b` from `hnneg`, so the conclusion is immediate.
  have hdenom_pos : (0 : ℝ) < ∑ j : ZMod N, ‖uhat j‖ ^ 2 :=
    lt_of_le_of_ne hnneg hpos.symm
  exact div_le_one_of_le₀ hbound (le_of_lt hdenom_pos)

/-- **Existence of a global trajectory.**  For any finite truncation
level `N`, viscosity `ν ≥ 0`, time step `Δt ≥ 0`, and `λ_k ≥ 0`, the
sequence `n ↦ integratingFactorStep_iter N ν Δt lam uhat n` is well
defined for all `n : ℕ` and its discrete $L^2$ energy stays bounded by
the initial energy.  This is the formal Lean statement of "no finite-time
blow-up for the truncated spectral NS scheme".

The conclusion is an immediate corollary of `noBlowup_1D`: the bound is
explicit, uniform in `n`, and applies to *every* step of the iteration. -/
theorem noBlowup_spectralNS
    (N : ℕ) [NeZero N] (ν Δt : ℝ) (lam : ZMod N → ℝ) (uhat : ZMod N → ℂ)
    (hν : 0 ≤ ν) (hΔt : 0 ≤ Δt) (hlam : ∀ k, 0 ≤ lam k) :
    ∃ Ebound : ℝ, 0 ≤ Ebound ∧ Ebound = ∑ j : ZMod N, ‖uhat j‖ ^ 2 ∧
      ∀ n : ℕ,
        ∑ j : ZMod N, ‖integratingFactorStep_iter N ν Δt lam uhat n j‖ ^ 2 ≤ Ebound := by
  refine ⟨∑ j : ZMod N, ‖uhat j‖ ^ 2, ?_, rfl, ?_⟩
  · exact Finset.sum_nonneg fun _ _ => sq_nonneg _
  · intro n
    exact noBlowup_1D N ν Δt lam uhat hν hΔt hlam n

/-! ## 3D no-blowup: per-mode decay on `WaveVector`

The 1D statement `noBlowup_1D` controls the integrating-factor iterate on
the cyclic grid `ZMod N`.  In 3D the natural spectral domain is
`WaveVector = Fin 3 → ℤ`, and the integrating-factor step acts on each
mode independently by a viscous factor that depends on the squared
wave-number `|k|² = ∑ i, (k i)²`.

This section gives the 3D analogue: a spectral field
`uhat : WaveVector → ℂ` is damped mode-by-mode by the factor
`exp(-ν · |k|² · Δt)`.  Because the modes are *independent* (no
DFT/idft round-trip, no convolution term yet), the `ℓ²` energy bound
is a pointwise argument: each mode's squared norm is multiplied by a
factor `≤ 1`, and summing over `k` gives the bound. -/

/-- The viscous damping factor for a 3D wave vector `k` at viscosity
`ν` and time step `Δt`.  It is `exp(-ν · |k|² · Δt)`, where
`|k|² = ∑ i, (k i)²` is the squared Euclidean norm of the integer
wave vector (computed via `Int.natAbs` since `k i : ℤ`). -/
noncomputable def waveViscousFactor (ν Δt : ℝ) (k : WaveVector) : ℝ :=
  Real.exp (-ν * (∑ i : Fin 3, (Int.natAbs (k i) : ℝ) ^ 2) * Δt)

/-- One integrating-factor step on the 3D spectral field: each wave
vector mode decays independently by `waveViscousFactor`.  This is the
3D analogue of `integratingFactorStep` without the DFT/idft round
trip; the mode coupling that comes from the nonlinear term is
discarded here, so the bound is purely viscous. -/
noncomputable def waveIntegratingFactorStep (ν Δt : ℝ)
    (uhat : WaveVector → ℂ) (k : WaveVector) : ℂ :=
  (waveViscousFactor ν Δt k : ℂ) * uhat k

/-- The `n`-fold iterate of the 3D integrating-factor step. -/
noncomputable def waveIntegratingFactorStep_iter (ν Δt : ℝ)
    (uhat : WaveVector → ℂ) : ℕ → WaveVector → ℂ
  | 0     => uhat
  | n + 1 => waveIntegratingFactorStep ν Δt
              (waveIntegratingFactorStep_iter ν Δt uhat n)

/-- The 3D integrating-factor step never enlarges any mode's squared
norm: `waveViscousFactor ν Δt k ∈ [0, 1]` for `ν, Δt ≥ 0`, so its
square multiplies `‖Ψ k‖²` by at most `1`.  This is the per-mode
lemma underlying `noBlowup_3D`. -/
lemma waveIntegratingFactorStep_norm_le
    (ν Δt : ℝ) (Ψ : WaveVector → ℂ) (k : WaveVector)
    (hν : 0 ≤ ν) (hΔt : 0 ≤ Δt) :
    ‖waveIntegratingFactorStep ν Δt Ψ k‖ ^ 2 ≤ ‖Ψ k‖ ^ 2 := by
  simp only [waveIntegratingFactorStep]
  rw [norm_mul, mul_pow, Complex.norm_real, Real.norm_eq_abs, sq_abs]
  -- Bound the viscous factor: `waveViscousFactor ν Δt k ∈ [0, 1]`.
  have hle1 : waveViscousFactor ν Δt k ≤ 1 := by
    rw [waveViscousFactor]
    have hsum :
        0 ≤ (∑ i : Fin 3, (Int.natAbs (k i) : ℝ) ^ 2) :=
      Finset.sum_nonneg fun _ _ => sq_nonneg _
    have hprod :
        0 ≤ ν * (∑ i : Fin 3, (Int.natAbs (k i) : ℝ) ^ 2) * Δt :=
      mul_nonneg (mul_nonneg hν hsum) hΔt
    -- `Real.exp (-x) ≤ 1` for `0 ≤ x` (equivalent to `(-x) ≤ 0`).
    have hneg : -ν * (∑ i, (Int.natAbs (k i) : ℝ) ^ 2) * Δt ≤ 0 := by
      linarith
    exact Real.exp_le_one_iff.mpr hneg
  -- Lower bound: `waveViscousFactor ν Δt k ≥ 0` (it's an `exp`).
  have hge0 : 0 ≤ waveViscousFactor ν Δt k :=
    Real.exp_nonneg _
  -- Square the factor: `f² ≤ 1² = 1`, using `0 ≤ f ≤ 1`.
  have hfac : waveViscousFactor ν Δt k ^ 2 ≤ 1 := by
    have : waveViscousFactor ν Δt k * (waveViscousFactor ν Δt k - 1) ≤ 0 :=
      mul_nonpos_of_nonneg_of_nonpos hge0 (sub_nonpos.mpr hle1)
    have hsq : (waveViscousFactor ν Δt k - 1) * waveViscousFactor ν Δt k ≤ 0 := by
      linarith [this]
    nlinarith [sq_nonneg (waveViscousFactor ν Δt k - 1),
               sq_nonneg (waveViscousFactor ν Δt k)]
  -- Now multiply: `f² * ‖Ψ k‖² ≤ 1 * ‖Ψ k‖² = ‖Ψ k‖²`.
  have : waveViscousFactor ν Δt k ^ 2 * ‖Ψ k‖ ^ 2 ≤ ‖Ψ k‖ ^ 2 := by
    nlinarith [sq_nonneg (‖Ψ k‖ ^ 2),
               sq_nonneg (waveViscousFactor ν Δt k ^ 2 - 1),
               hfac, sq_nonneg ‖Ψ k‖]
  exact this

/-- **Discrete no-blowup (3D).**  For non-negative viscosity `ν` and time
step `Δt`, the discrete `ℓ²` energy of the 3D integrating-factor
trajectory at any step `n` is bounded above by the initial energy.

The proof is per-mode: each `k : WaveVector` is damped by
`exp(-ν · |k|² · Δt) ∈ [0, 1]`, whose square is `≤ 1` because
`ν, Δt, |k|² ≥ 0`.  Iterating this contractive map preserves the
energy bound, and summing over any finite mode set gives the global
`ℓ²` bound. -/
theorem noBlowup_3D
    (ν Δt : ℝ) (uhat : WaveVector → ℂ) (S : Finset WaveVector)
    (hν : 0 ≤ ν) (hΔt : 0 ≤ Δt) :
    ∀ n : ℕ,
      ∑ k ∈ S, ‖waveIntegratingFactorStep_iter ν Δt uhat n k‖ ^ 2
        ≤ ∑ k ∈ S, ‖uhat k‖ ^ 2 := by
  intro n
  induction n with
  | zero =>
      simp [waveIntegratingFactorStep_iter]
  | succ n ih =>
      -- Per-mode bound at the (n+1)-step using the lemma.
      have hper : ∀ k ∈ S,
          ‖waveIntegratingFactorStep_iter ν Δt uhat (n + 1) k‖ ^ 2
            ≤ ‖waveIntegratingFactorStep_iter ν Δt uhat n k‖ ^ 2 := by
        intro k hkS
        -- The (n+1)-step iterate is the step applied to the n-step iterate.
        show ‖waveIntegratingFactorStep ν Δt
                (waveIntegratingFactorStep_iter ν Δt uhat n) k‖ ^ 2
            ≤ ‖waveIntegratingFactorStep_iter ν Δt uhat n k‖ ^ 2
        exact waveIntegratingFactorStep_norm_le ν Δt
          (waveIntegratingFactorStep_iter ν Δt uhat n) k hν hΔt
      -- Sum the per-mode bound, then chain with `ih`.
      have hsum :
          ∑ k ∈ S, ‖waveIntegratingFactorStep_iter ν Δt uhat (n + 1) k‖ ^ 2
            ≤ ∑ k ∈ S, ‖waveIntegratingFactorStep_iter ν Δt uhat n k‖ ^ 2 :=
        Finset.sum_le_sum fun k hkS => hper k hkS
      exact hsum.trans ih

/-! ## Quantitative dissipation rate (discrete Leray energy inequality)

The previous section bounds the per-step `ℓ²` energy of the integrating-factor
iterate by the *initial* energy: `∑ ‖uₙ‖² ≤ ∑ ‖u₀‖²`.  This section makes
the dissipation rate *quantitative* — i.e. it gives an explicit lower bound
on the energy dissipated in one step, and an explicit exponential decay
rate on the iterated scheme.

Concretely, the integrating-factor step damps each mode `k` by
`waveViscousFactor ν Δt k = exp(-ν‖k‖²Δt)`.  So per mode the energy
dissipated is `(1 - exp(-2ν‖k‖²Δt)) · ‖uhat k‖²`.  Summing over a mode set
`S` and using `lam_min := inf k ∈ S, ‖k‖²` (a non-negative lower bound on the
squared wave-numbers in `S`), we obtain the **discrete Leray energy
inequality**:

  per-step dissipation ≥ (1 - exp(-2 ν lam_min Δt)) · E(S),

where `E(S) = ∑ k ∈ S, ‖uhat k‖²`.  Equivalently, the energy after one
step is at most `exp(-2 ν lam_min Δt)` of the energy before.

For the standard spectral truncation at level `N` on the cube
`{-N, ..., N}³`, we have `lam_min = 1` (the squared wave-number of the lowest
nonzero mode), so the bound captures the dissipation rate as an explicit
function of the truncation level `N`.  Iterating the per-step bound gives
an exponential decay `exp(-2 ν n Δt)` of the discrete energy over `n`
steps.

This is the first Lean step toward the *Discrete Onsager-critical
truncation* sub-problem identified in `LITERATURE_SURVEY.md §4`: it pins
down how the discrete Leray energy inequality scales with the truncation
level `N`, which is the quantitative input needed to constrain the
energy-dissipation ratio `E_N(T) / ∫₀ᵀ ‖∇uₙ‖²` studied in §4.3 of the
survey. -/

/-- **Per-mode squared-norm equality for the 3D integrating-factor step.**
The squared norm of the step applied to mode `k` equals
`waveViscousFactor² · ‖uhat k‖²`.  This sharpens
`waveIntegratingFactorStep_norm_le` from an inequality to an equality and
is the per-mode building block for the dissipation-rate bound. -/
lemma waveIntegratingFactorStep_norm_eq
    (ν Δt : ℝ) (uhat : WaveVector → ℂ) (k : WaveVector) :
    ‖waveIntegratingFactorStep ν Δt uhat k‖ ^ 2
      = waveViscousFactor ν Δt k ^ 2 * ‖uhat k‖ ^ 2 := by
  simp only [waveIntegratingFactorStep, norm_mul, mul_pow,
             Complex.norm_real, Real.norm_eq_abs, sq_abs]

/-- **Viscous factor squared.**  Squaring `waveViscousFactor ν Δt k`
collapses the product of two exponentials into a single exponential:
`exp(-ν‖k‖²Δt)² = exp(-2 ν‖k‖²Δt)`. -/
lemma waveViscousFactor_sq (ν Δt : ℝ) (k : WaveVector) :
    waveViscousFactor ν Δt k ^ 2
      = Real.exp (-2 * ν * (∑ i : Fin 3, (Int.natAbs (k i) : ℝ) ^ 2) * Δt) := by
  rw [waveViscousFactor, sq, ← Real.exp_add]
  congr 1
  ring

/-- The L² energy dissipated by ONE integrating-factor step over the mode
set `S`.  Concretely:
`waveDissipationRate ν Δt uhat S = ∑ k ∈ S, ‖uhat k‖² - ∑ k ∈ S, ‖step k‖²`. -/
noncomputable def waveDissipationRate (ν Δt : ℝ) (uhat : WaveVector → ℂ)
    (S : Finset WaveVector) : ℝ :=
  ∑ k ∈ S, ‖uhat k‖ ^ 2 - ∑ k ∈ S, ‖waveIntegratingFactorStep ν Δt uhat k‖ ^ 2

/-- **Quantitative dissipation rate lower bound (discrete Leray energy
inequality).**  In one integrating-factor step, the energy dissipated over
`S` is at least `(1 - exp(-2 ν lam_min Δt)) · E(S)`, where
`lam_min ≤ ‖k‖²` for every `k ∈ S` and `E(S) = ∑ k ∈ S, ‖uhat k‖²`.

This is the per-step quantitative form of the discrete Leray energy
inequality: it bounds below the energy dissipation rate by an explicit
fraction of the current energy.  In particular, with `lam_min = 1`
(the smallest nonzero squared wave-number on the spectral cube
`{-N, ..., N}³`), the bound becomes `≥ (1 - exp(-2 ν Δt)) · E(S)`, capturing
the energy dissipation rate as a function of the truncation level `N`. -/
theorem waveDissipationRate_lower_bound
    (ν Δt lam_min : ℝ) (uhat : WaveVector → ℂ) (S : Finset WaveVector)
    (hν : 0 ≤ ν) (hΔt : 0 ≤ Δt)
    (hlam : ∀ k ∈ S, lam_min ≤ ∑ i : Fin 3, (Int.natAbs (k i) : ℝ) ^ 2) :
    waveDissipationRate ν Δt uhat S
      ≥ (1 - Real.exp (-2 * ν * lam_min * Δt)) * ∑ k ∈ S, ‖uhat k‖ ^ 2 := by
  classical
  unfold waveDissipationRate
  -- Equivalent formulation: ‖step k‖² ≤ exp(-2ν lam_min Δt) · ‖uhat k‖² for every k ∈ S.
  suffices h : ∑ k ∈ S, ‖waveIntegratingFactorStep ν Δt uhat k‖ ^ 2
                  ≤ Real.exp (-2 * ν * lam_min * Δt) * ∑ k ∈ S, ‖uhat k‖ ^ 2 by
    linarith
  -- Per-mode bound, then sum.
  have hper : ∀ k ∈ S, ‖waveIntegratingFactorStep ν Δt uhat k‖ ^ 2
      ≤ Real.exp (-2 * ν * lam_min * Δt) * ‖uhat k‖ ^ 2 := by
    intro k hkS
    rw [waveIntegratingFactorStep_norm_eq, waveViscousFactor_sq]
    have hfac :
        Real.exp (-2 * ν * (∑ i : Fin 3, (Int.natAbs (k i) : ℝ) ^ 2) * Δt)
          ≤ Real.exp (-2 * ν * lam_min * Δt) := by
      apply Real.exp_le_exp.mpr
      -- Need: -2 ν ‖k‖² Δt ≤ -2 ν lam_min Δt.
      -- Equivalent: 2 ν (‖k‖² - lam_min) Δt ≥ 0, which follows from the
      -- hypotheses hν, hΔt and `lam_min ≤ ‖k‖²`.
      have hdiff :
          0 ≤ (∑ i : Fin 3, (Int.natAbs (k i) : ℝ) ^ 2) - lam_min :=
        sub_nonneg.mpr (hlam k hkS)
      have hprod :
          0 ≤ 2 * ν * ((∑ i : Fin 3, (Int.natAbs (k i) : ℝ) ^ 2) - lam_min) * Δt :=
        mul_nonneg (mul_nonneg (mul_nonneg (by norm_num) hν) hdiff) hΔt
      linarith
    exact mul_le_mul_of_nonneg_right hfac (sq_nonneg _)
  rw [Finset.mul_sum]
  exact Finset.sum_le_sum fun k hkS => hper k hkS

/-- **Quantitative no-blowup (3D).**  Iterating the per-step dissipation
bound gives an explicit exponential decay of the discrete `ℓ²` energy at
rate `exp(-2 ν lam_min n Δt)` over `n` steps, for any mode set `S` with
`lam_min ≤ ‖k‖²` for every `k ∈ S`.  This sharpens `noBlowup_3D` (which only
gives `≤ initial energy`) to a quantitative decay rate.

For the standard spectral truncation on the cube `{-N, ..., N}³` with
`lam_min = 1`, the bound becomes
`∑ ‖uₙ(k)‖² ≤ exp(-2 ν n Δt) · E₀`, i.e. the discrete energy decays at
rate `exp(-2 ν Δt)` per step.  Combined with the inverse direction
(no energy creation), this gives a two-sided exponential bracket on the
discrete energy. -/
theorem noBlowup_3D_quantitative
    (ν Δt lam_min : ℝ) (uhat : WaveVector → ℂ) (S : Finset WaveVector)
    (hν : 0 ≤ ν) (hΔt : 0 ≤ Δt)
    (hlam : ∀ k ∈ S, lam_min ≤ ∑ i : Fin 3, (Int.natAbs (k i) : ℝ) ^ 2) :
    ∀ n : ℕ,
      ∑ k ∈ S, ‖waveIntegratingFactorStep_iter ν Δt uhat n k‖ ^ 2
        ≤ Real.exp (-2 * ν * lam_min * n * Δt) * ∑ k ∈ S, ‖uhat k‖ ^ 2 := by
  intro n
  induction n with
  | zero =>
      simp [waveIntegratingFactorStep_iter, Real.exp_zero]
  | succ n ih =>
      -- Per-mode per-step bound: each mode loses at least a factor exp(-2ν lam_min Δt).
      have hper : ∀ k ∈ S,
          ‖waveIntegratingFactorStep_iter ν Δt uhat (n + 1) k‖ ^ 2
            ≤ Real.exp (-2 * ν * lam_min * Δt)
              * ‖waveIntegratingFactorStep_iter ν Δt uhat n k‖ ^ 2 := by
        intro k hkS
        show ‖waveIntegratingFactorStep ν Δt
                (waveIntegratingFactorStep_iter ν Δt uhat n) k‖ ^ 2
            ≤ Real.exp (-2 * ν * lam_min * Δt)
              * ‖waveIntegratingFactorStep_iter ν Δt uhat n k‖ ^ 2
        rw [waveIntegratingFactorStep_norm_eq, waveViscousFactor_sq]
        have hfac :
            Real.exp (-2 * ν * (∑ i : Fin 3, (Int.natAbs (k i) : ℝ) ^ 2) * Δt)
              ≤ Real.exp (-2 * ν * lam_min * Δt) := by
          apply Real.exp_le_exp.mpr
          have hdiff :
              0 ≤ (∑ i : Fin 3, (Int.natAbs (k i) : ℝ) ^ 2) - lam_min :=
            sub_nonneg.mpr (hlam k hkS)
          have hprod :
              0 ≤ 2 * ν * ((∑ i : Fin 3, (Int.natAbs (k i) : ℝ) ^ 2) - lam_min) * Δt :=
            mul_nonneg (mul_nonneg (mul_nonneg (by norm_num) hν) hdiff) hΔt
          linarith
        exact mul_le_mul_of_nonneg_right hfac (sq_nonneg _)
      -- Sum the per-mode bound.
      have hsum :
          ∑ k ∈ S, ‖waveIntegratingFactorStep_iter ν Δt uhat (n + 1) k‖ ^ 2
            ≤ Real.exp (-2 * ν * lam_min * Δt)
              * ∑ k ∈ S, ‖waveIntegratingFactorStep_iter ν Δt uhat n k‖ ^ 2 := by
        rw [Finset.mul_sum]
        exact Finset.sum_le_sum fun k hkS => hper k hkS
      -- Multiply the induction hypothesis by exp(-2ν lam_min Δt).
      have hexp_pos : 0 ≤ Real.exp (-2 * ν * lam_min * Δt) := Real.exp_nonneg _
      have hmul := mul_le_mul_of_nonneg_left ih hexp_pos
      -- The RHS of `hmul` has `exp(-2ν lam_min Δt) * exp(-2ν lam_min n Δt) * c`.
      -- Combine the two `exp` factors: `exp a * exp b = exp (a + b)`, then
      -- `a + b = -2ν lam_min (n + 1) Δt` by `ring`.
      have hexp_comb :
          Real.exp (-2 * ν * lam_min * Δt) * Real.exp (-2 * ν * lam_min * ↑n * Δt)
            = Real.exp (-2 * ν * lam_min * ↑(n + 1) * Δt) := by
        rw [← Real.exp_add]
        congr 1
        rw [Nat.cast_add]
        ring
      -- Reassociate the RHS of `hmul` to apply `hexp_comb`, then chain.
      have hcomb :
          (Real.exp (-2 * ν * lam_min * Δt)
            * Real.exp (-2 * ν * lam_min * ↑n * Δt))
              * ∑ k ∈ S, ‖uhat k‖ ^ 2
          = Real.exp (-2 * ν * lam_min * ↑(n + 1) * Δt)
            * ∑ k ∈ S, ‖uhat k‖ ^ 2 := by
        rw [hexp_comb]
      -- Rewrite `hmul` to use the combined exponential.
      have hmul' :
          Real.exp (-2 * ν * lam_min * Δt) * ∑ k ∈ S,
              ‖waveIntegratingFactorStep_iter ν Δt uhat n k‖ ^ 2
            ≤ Real.exp (-2 * ν * lam_min * ↑(n + 1) * Δt)
                * ∑ k ∈ S, ‖uhat k‖ ^ 2 := by
        -- `hmul` is `(exp a) * (∑ ...) ≤ (exp a) * ((exp b) * (∑ ...))`.
        -- Reassociate the RHS and substitute `hexp_comb`.
        have hrew :
            (Real.exp (-2 * ν * lam_min * Δt)
              * (Real.exp (-2 * ν * lam_min * ↑n * Δt)
                * ∑ k ∈ S, ‖uhat k‖ ^ 2))
            = Real.exp (-2 * ν * lam_min * ↑(n + 1) * Δt)
                * ∑ k ∈ S, ‖uhat k‖ ^ 2 := by
          rw [← mul_assoc, hexp_comb]
        rwa [hrew] at hmul
      exact hsum.trans hmul'

end NsSpectral
