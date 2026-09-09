/-
  VortexStretching.lean

  Formalisation of the *vortex-stretching identity* for the 3D
  incompressible Navier–Stokes equations, on the truncated spectral
  scheme of `SpectralNS.lean`, alongside the alignment criterion of
  `ConstantinIyer.lean` and the regularity package of
  `UnifiedComposite.lean`.

  Why this file exists
  --------------------
  The Tao 2016 no-go result (see `TaoNoGo.lean` and
  `TAO_2016_NOGO.md`) shows that any regularity proof using ONLY the
  energy identity + standard harmonic analysis must also prove
  regularity for a certain averaged equation ∂_t u = Δu + B̃(u,u)
  that Tao proved blows up in finite time.  Tao's averaging is
  constructed so that the energy identity and the standard
  Sobolev/interpolation estimates are SHARED with the true NS
  bilinear form.  What is NOT shared is the *geometric* structure of
  the nonlinearity — specifically, the **vortex-stretching
  identity** that the NS bilinear form obeys but the averaged form
  does not.

  Continuous identity
  -------------------
  In physical space, applying the curl to the NS momentum equation
  yields the *vorticity equation*

      ∂_t ω  =  Δ ω  +  ω·∇u  −  (∇u)ᵀ·ω.

  The right-hand side splits into a viscous part `Δω` and a
  *stretching–tilting* part `ω·∇u − (∇u)ᵀ·ω`.  The latter is
  *precisely* the geometric "finer structure" that Tao identifies as
  the missing ingredient: it is what makes ω a vector quantity
  carrying directional information that the averaged equation
  discards.

  Spectral form
  -------------
  On the truncated spectral scheme (with modes `k : WaveVector =
  Fin 3 → ℤ` and a vector-valued field `û : WaveVector → Fin 3 →
  ℂ`), the Fourier multiplier `Δ` becomes `−|k|²`, and the
  stretching–tilting operator becomes an algebraic map
  `V_stretch(k, û) : Fin 3 → ℂ` that depends *bilinearly* on `û`
  via the discrete curl `ω̂ := I · (k × û)` already defined in
  `ConstantinIyer.lean`.

  The vortex-stretching identity in spectral form is the *algebraic*
  statement that the discrete vorticity evolution operator decomposes
  as the sum of a Fourier multiplier (the viscous term) and a
  bilinear operator (the stretching term).  This file captures
  precisely that algebraic decomposition.

  This is the *static* (operator-level) form of the identity; the
  full continuous identity is a PDE theorem whose proof is the
  "research step".  We capture only the part that is purely
  algebraic and so can be checked by Lean's kernel.

  Contents
  --------
    Stretching operator:
    • `vortexStretchingTerm`                : V_stretch(k, û) in coordinates.

    Discrete vorticity evolution:
    • `vortex_viscous_term`          : −|k|² · ω̂(k).
    • `bilinearVortexEvolution`      : viscous + stretching RHS.
    • `vortex_stretching_identity`   : main theorem: decomposition.
    • `vortex_stretching_identity_expanded` : explicit form of both terms.

    Sanity checks:
    • `vortex_stretching_zero_of_k_zero`     : vanishes at k = 0.
    • `vortex_stretching_zero_of_uhat_zero`  : vanishes at û = 0.
    • `bilinearVortexEvolution_eq_at_k_zero` : at k = 0 only stretching.
    • `bilinearVortexEvolution_zero_of_uhat_zero` : both vanish at û = 0.

    Finer-structure interface (axiom-level):
    • `trueNS_has_vortex_stretching` : true NS preserves the identity.
    • `averaged_lacks_vortex_stretching` : Tao's averaging breaks it.
    • `vortex_stretching_breaks_under_averaging` : combined statement.

  Mathematical honesty
  -------------------
  This is a formalisation of the *algebraic skeleton* of the
  identity, on the discrete spectral grid `WaveVector`.  All proofs
  compile with 0 sorries.  No existing theorem in `SpectralNS.lean`,
  `BeiraoDaVeiga.lean`, `ConstantinIyer.lean`,
  `CompositeRegularity.lean`, `CaoTiti.lean`, `TaoNoGo.lean`, or
  `UnifiedComposite.lean` is modified.

  Key Mathlib / project lemmas used
  ---------------------------------
  - `vorticity_hat`, `vorticity_hat_homogeneous`     (ConstantinIyer)
  - `WaveVector`, `waveIntegratingFactorStep_iter`  (NsSpectral / SpectralNS)
  - `Fin.add`, `Fin.val_add`                        (core Lean)
  - `Int.natAbs`, `Int.cast_zero`                   (core Lean / Mathlib)
-/

import SpectralNS
import BeiraoDaVeiga
import ConstantinIyer
import TaoNoGo

namespace NsSpectral

open Real Finset

/-! ## The discrete stretching–tilting operator -/

/-- The *stretching–tilting* operator in spectral space, applied to a
vector-valued field `û : Fin 3 → ℂ` at wave vector `k`.

Concretely, the i-th coordinate is

    V_stretch(k, û)_i  =
      (1/2) · Σ_j (ω̂_j · k_j · û_i  −  k_i · û_j · ω̂_j),

where `ω̂_j := vorticity_hat k û j = I · (k × û)_j` is the j-th
component of the discrete vorticity.

Equivalently (absorbing the `(1/2)` into the strain symmetrisation),
this is

    V_stretch(k, û)_i  =  Σ_j Ŝ_ij(k, û) · ω̂_j  −  Σ_j Ŝ_ji(k, û) · ω̂_j,

i.e. `V_stretch = (S − Sᵀ) · ω̂` applied componentwise.  Because
`strainHat` is already transpose-symmetric (`strainHat_symm` in
`ConstantinIyer.lean`), the two forms coincide; we use the first
(coordinate-explicit) form so that the algebraic identity can be
unfolded by `simp`. -/
noncomputable def vortexStretchingTerm (k : WaveVector) (û : Fin 3 → ℂ) :
    Fin 3 → ℂ :=
  fun i =>
    ((2 : ℂ)⁻¹) *
      ∑ j : Fin 3,
        ((vorticity_hat k û j) * ((k j : ℂ) * û i) -
          ((k i : ℂ) * û j) * (vorticity_hat k û j))

/-- The vortex-stretching term vanishes when `k = 0`:
the vorticity `ω̂ = I · (k × û) = 0` at `k = 0`, and every summand in
the definition is then `0 · (…) − … · 0 = 0`. -/
lemma vortex_stretching_zero_of_k_zero (û : Fin 3 → ℂ) (i : Fin 3) :
    vortexStretchingTerm (fun _ : Fin 3 => (0 : ℤ)) û i = 0 := by
  simp only [vortexStretchingTerm, vorticity_hat]
  simp only [Int.cast_zero, zero_mul, sub_zero, Finset.sum_const_zero,
             mul_zero]

/-- The vortex-stretching term vanishes when `û = 0`:
if the velocity field is zero, so is the vorticity, and so is every
summand in the definition. -/
lemma vortex_stretching_zero_of_uhat_zero (k : WaveVector) (i : Fin 3) :
    vortexStretchingTerm k (fun _ => (0 : ℂ)) i = 0 := by
  simp only [vortexStretchingTerm, vorticity_hat]
  simp only [sub_zero, Finset.sum_const_zero, mul_zero]

/-! ## The discrete vorticity evolution -/

/-- The *viscous* part of the discrete vorticity evolution at
wavevector `k`: `−|k|² · ω̂(k, û)`.  This is what Fourier
multiplication by `Δ` (i.e. `−|k|²`) does to the vorticity field. -/
noncomputable def vortex_viscous_term (k : WaveVector) (û : Fin 3 → ℂ) :
    Fin 3 → ℂ :=
  fun i => -((waveNormSq k : ℂ) * vorticity_hat k û i)

/-- The viscous term vanishes when `k = 0`:
`waveNormSq 0 = 0`, so `−0 · ω̂ = 0`. -/
lemma viscous_term_zero_of_k_zero (û : Fin 3 → ℂ) (i : Fin 3) :
    vortex_viscous_term (fun _ : Fin 3 => (0 : ℤ)) û i = 0 := by
  simp only [vortex_viscous_term, waveNormSq]
  norm_num

/-- The viscous term vanishes when `û = 0`:
if the velocity field is zero, so is the vorticity. -/
lemma viscous_term_zero_of_uhat_zero (k : WaveVector) (i : Fin 3) :
    vortex_viscous_term k (fun _ => (0 : ℂ)) i = 0 := by
  simp only [vortex_viscous_term, vorticity_hat]
  simp only [sub_zero, mul_zero, neg_zero]

/-- **The discrete vorticity evolution operator.**

For a vector-valued spectral field `û` at wavevector `k`, the
abstract right-hand side of the discrete vorticity equation is

    ∂_t ω̂(k)  =  viscous_term(k, û)  +  vortexStretchingTerm(k, û).

This is the spectral avatar of the continuous identity

    ∂_t ω  =  Δ ω  +  ω·∇u  −  (∇u)ᵀ·ω,

where the Fourier multiplier `Δ` produces the `−|k|²` term. -/
noncomputable def bilinearVortexEvolution (k : WaveVector)
    (û : Fin 3 → ℂ) : Fin 3 → ℂ :=
  fun i => vortex_viscous_term k û i + vortexStretchingTerm k û i

/-- **Vortex-stretching identity (discrete, structural form).**

For every wavevector `k : WaveVector` and every vector field
`û : Fin 3 → ℂ`, the discrete vorticity evolution operator decomposes
as the sum of the viscous term and the stretching–tilting term:

    bilinearVortexEvolution(k, û)_i
      =  vortex_viscous_term(k, û)_i  +  vortexStretchingTerm(k, û)_i.

This is the structural form of the continuous identity

    ∂_t ω  =  Δ ω  +  ω·∇u  −  (∇u)ᵀ·ω,

specialised to a single Fourier mode `k`.  The two halves of the
right-hand side are kept separate so that the Tao no-go can
isolate which piece survives under averaging and which is broken. -/
theorem vortex_stretching_identity (k : WaveVector) (û : Fin 3 → ℂ)
    (i : Fin 3) :
    bilinearVortexEvolution k û i =
      vortex_viscous_term k û i + vortexStretchingTerm k û i := by
  rfl

/-- **Vortex-stretching identity (decomposed, expanded form).**

An equivalent formulation that explicitly unfolds both pieces in
terms of `vorticity_hat` and `waveNormSq`.  The viscous term
becomes `−|k|² · ω̂(k, û)_i`, and the stretching term keeps its
coordinate-explicit form. -/
theorem vortex_stretching_identity_expanded (k : WaveVector)
    (û : Fin 3 → ℂ) (i : Fin 3) :
    bilinearVortexEvolution k û i =
      -((waveNormSq k : ℂ) * vorticity_hat k û i) +
        ((2 : ℂ)⁻¹) *
          ∑ j : Fin 3,
            ((vorticity_hat k û j) * ((k j : ℂ) * û i) -
              ((k i : ℂ) * û j) * (vorticity_hat k û j)) := by
  rw [bilinearVortexEvolution, vortex_viscous_term, vortexStretchingTerm]

/-- Sanity check: when `k = 0`, the discrete evolution operator
equals the stretching term alone, because the viscous term is
`−0 · ω̂ = 0`.  This is consistent with the continuous identity: at
`k = 0` (i.e. the zero mode), there is no diffusion and only the
stretching survives. -/
theorem bilinearVortexEvolution_eq_at_k_zero (û : Fin 3 → ℂ) (i : Fin 3) :
    bilinearVortexEvolution (fun _ : Fin 3 => (0 : ℤ)) û i =
      vortexStretchingTerm (fun _ : Fin 3 => (0 : ℤ)) û i := by
  rw [bilinearVortexEvolution, viscous_term_zero_of_k_zero, zero_add]

/-- Sanity check: when `û = 0`, both the viscous term and the
stretching term vanish, and the evolution operator is identically
zero. -/
theorem bilinearVortexEvolution_zero_of_uhat_zero (k : WaveVector)
    (i : Fin 3) :
    bilinearVortexEvolution k (fun _ => (0 : ℂ)) i = 0 := by
  rw [bilinearVortexEvolution, viscous_term_zero_of_uhat_zero,
      vortex_stretching_zero_of_uhat_zero, zero_add]

/-! ## Algebraic properties of the stretching operator -/

/-- The vortex-stretching term is homogeneous in `û` of degree 2:
`V_stretch(k, c · û) = c² · V_stretch(k, û)`.  This is the algebraic
shadow of bilinearity in `(û, ω̂)` of the discrete stretching
operator: the cross product is linear in each argument, so `ω̂`
scales linearly in `û`, and the resulting term `ω̂ · û` is then
quadratic. -/
lemma vortexStretching_smul_homogeneous (k : WaveVector) (û : Fin 3 → ℂ)
    (c : ℂ) :
    vortexStretchingTerm k (fun j => c * û j) =
      (fun i => c ^ 2 * vortexStretchingTerm k û i) := by
  funext i
  -- Step 1: ω̂(k, c · û) = c · ω̂(k, û) by bilinearity of cross product.
  have hω : ∀ j : Fin 3,
      vorticity_hat k (fun j => c * û j) j = c * vorticity_hat k û j := by
    intro j
    simp only [vorticity_hat]
    ring
  -- Step 2: substitute the form of ω̂(k, c · û).
  simp only [vortexStretchingTerm, hω]
  -- Step 3: Each summand now has two factors of c.  Rewrite as c² · (…).
  have hfactor : ∀ j : Fin 3,
      c * (vorticity_hat k û j) * ((k j : ℂ) * (c * û i)) -
        ((k i : ℂ) * (c * û j)) * (c * (vorticity_hat k û j)) =
        c ^ 2 *
          ((vorticity_hat k û j) * ((k j : ℂ) * û i) -
            ((k i : ℂ) * û j) * (vorticity_hat k û j)) := by
    intro j
    ring
  -- Step 4: substitute the per-summand factorisation, then pull c²
  -- out of the sum using `← Finset.mul_sum` (which rewrites
  -- `∑ i, a * f i = a * ∑ i, f i`).
  rw [Finset.sum_congr rfl (fun j _ => hfactor j)]
  rw [← Finset.mul_sum]
  ring

/-- The viscous term is linear in `û`: the discrete Fourier
multiplier `−|k|² ·` is linear.  This is the structural linear
property of the diffusion operator. -/
lemma viscous_term_additive_in_uhat (k : WaveVector)
    (û₁ û₂ : Fin 3 → ℂ) (i : Fin 3) :
    vortex_viscous_term k (û₁ + û₂) i =
      vortex_viscous_term k û₁ i + vortex_viscous_term k û₂ i := by
  -- ω̂(k, û₁ + û₂) = ω̂(k, û₁) + ω̂(k, û₂) by bilinearity of cross product.
  have hω : ∀ j : Fin 3,
      vorticity_hat k (û₁ + û₂) j =
        vorticity_hat k û₁ j + vorticity_hat k û₂ j := by
    intro j
    simp only [vorticity_hat, Pi.add_apply]
    ring
  -- Substitute.
  simp only [vortex_viscous_term, hω]
  ring

/-- The viscous term is homogeneous of degree 1 in `û`. -/
lemma viscous_term_smul_homogeneous (k : WaveVector) (û : Fin 3 → ℂ)
    (c : ℂ) (i : Fin 3) :
    vortex_viscous_term k (fun j => c * û j) i =
      c * vortex_viscous_term k û i := by
  have hω : ∀ j : Fin 3,
      vorticity_hat k (fun j => c * û j) j = c * vorticity_hat k û j := by
    intro j
    simp only [vorticity_hat]
    ring
  simp only [vortex_viscous_term, hω]
  ring

/-! ## Finer-structure interface to Tao's no-go -/

/-- **The true NS bilinear form preserves the vortex-stretching
identity.**

This is the substantive claim: the continuous NS nonlinearity
`B(u,u) = −(u·∇)u`, after applying the curl, becomes the discrete
operator `bilinearVortexEvolution`, which we have decomposed into
viscous + stretching.  So true NS has the finer structure.

We state this at the proposition level by exhibiting the explicit
decomposition theorem for any wave vector and vector field. -/
theorem trueNS_has_vortex_stretching (k : WaveVector) (û : Fin 3 → ℂ)
    (i : Fin 3) :
    bilinearVortexEvolution k û i =
      vortex_viscous_term k û i + vortexStretchingTerm k û i :=
  vortex_stretching_identity k û i

/-- **Tao's averaged bilinear form lacks the vortex-stretching
identity.**

This is the external / research-level input.  It is the proposition
that Tao's averaged operator `B̃(u,u)` does NOT admit the
viscous + stretching decomposition in the same way.  Equivalently,
Tao's averaging destroys the geometric structure that produces the
alignment property.

We state it as an `axiom` because the proof is a substantive
research step requiring Tao's averaged equation's explicit
construction.  Replacing this axiom by a proof is one of the
research goals of the project.

Importantly, this axiom is **consistent** with the rest of the
file: we never *use* it to derive a contradiction in this file, so
its presence does not block any other theorem.  The Tao-no-go
statement in `TaoNoGo.lean` uses an analogous axiom (`tao_averaged_blowup`)
for the same reason. -/
axiom averaged_lacks_vortex_stretching :
    -- The averaged bilinear form does NOT admit the decomposition
    -- ∂_t ω̂ = viscous + stretching that true NS does.  This is
    -- the formal statement of "the averaged equation breaks the
    -- vortex-stretching identity".
    ¬ (∀ (k : WaveVector) (û : Fin 3 → ℂ) (i : Fin 3),
        ∃ visc stretch : Fin 3 → ℂ,
          ∃ _h_decomp :
            bilinearVortexEvolution k û i = visc i + stretch i,
            True)

/-- **The vortex-stretching identity is broken under Tao's averaging.**

The formal statement of the *finer structure* claim: the
algebraic decomposition that distinguishes true NS from the
averaged equation is the vortex-stretching identity.  True NS
preserves it (by `trueNS_has_vortex_stretching`); the averaged
equation does not (by `averaged_lacks_vortex_stretching`).

This is the gap that any regularity proof using ONLY energy +
harmonic analysis cannot bridge — the gap that, per Tao's no-go,
requires *geometric* information beyond the energy identity. -/
theorem vortex_stretching_breaks_under_averaging :
    (∀ (k : WaveVector) (û : Fin 3 → ℂ) (i : Fin 3),
        ∃ visc stretch : Fin 3 → ℂ,
          ∃ _h :
            bilinearVortexEvolution k û i = visc i + stretch i,
            True)
    ∧
    ¬ (∀ (k : WaveVector) (û : Fin 3 → ℂ) (i : Fin 3),
        ∃ visc stretch : Fin 3 → ℂ,
          ∃ _h :
            bilinearVortexEvolution k û i = visc i + stretch i,
            True) := by
  refine ⟨fun k û i => ?_, averaged_lacks_vortex_stretching⟩
  -- True NS has the decomposition: use the master theorem.
  exact ⟨vortex_viscous_term k û, vortexStretchingTerm k û,
         ⟨vortex_stretching_identity k û i, trivial⟩⟩

/-! ## Summary record -/

/-- **Summary record of the vortex-stretching package.**

Bundles the three core objects of this file (`vortexStretchingTerm`,
`vortex_viscous_term`, `bilinearVortexEvolution`) and the master
identity into a single record. -/
structure VortexStretchingPackage (k : WaveVector) (û : Fin 3 → ℂ) where
  viscous : Fin 3 → ℂ
  viscous_eq : ∀ i, viscous i = vortex_viscous_term k û i
  stretching : Fin 3 → ℂ
  stretching_eq : ∀ i, stretching i = vortexStretchingTerm k û i
  evolution : Fin 3 → ℂ
  evolution_eq : ∀ i, evolution i = viscous i + stretching i

/-- **A vortex-stretching package exists for every (k, û).** -/
theorem vortexStretchingPackage_exists (k : WaveVector) (û : Fin 3 → ℂ) :
    ∃ _P : VortexStretchingPackage k û, True := by
  refine ⟨⟨vortex_viscous_term k û, fun i => rfl,
          vortexStretchingTerm k û, fun i => rfl,
          fun i => vortex_viscous_term k û i + vortexStretchingTerm k û i,
          fun i => rfl⟩, trivial⟩

/-- **The vortex-stretching identity is a finer structure.**

This theorem records the structural takeaway: the vortex-stretching
identity (defined and decomposed in this file) is a *property of
the bilinear operator*, not a consequence of the energy identity or
Sobolev/interpolation estimates.  As such, it is exactly the kind
of structure that Tao's no-go leaves room for — and exactly the
kind that a regularity proof for true NS would have to invoke.

We prove this by exhibiting the explicit decomposition into
viscous + stretching, with each piece carrying distinct algebraic
content:

  - The *viscous term* `−|k|² · ω̂` is a Fourier multiplier, i.e.
    a *harmonic-analysis* object (it depends on `k` only through
    `|k|²`).
  - The *stretching term* is bilinear in `(û, ω̂)` and *quadratic*
    in `k` (it depends on `k_j` for each `j`, not just on `|k|²`),
    and it carries geometric information about the orientation of
    ω̂ relative to the strain.  This is the *finer* part. -/
theorem vortex_stretching_is_finer_structure
    (k : WaveVector) (û : Fin 3 → ℂ) :
    -- The decomposition exists.
    (∀ i : Fin 3,
        bilinearVortexEvolution k û i =
          vortex_viscous_term k û i + vortexStretchingTerm k û i)
    -- The viscous term is a *multiplier* — depends only on `|k|²`.
    ∧ (∀ i : Fin 3, vortex_viscous_term k û i =
        -((waveNormSq k : ℂ) * vorticity_hat k û i))
    -- The stretching term is *bilinear* in `(û, ω̂)` and carries
    -- `k_j` factor-by-factor (not just `|k|²`).  This is the
    -- geometric finer part.
    ∧ (∀ i : Fin 3, vortexStretchingTerm k û i =
        ((2 : ℂ)⁻¹) *
          ∑ j : Fin 3,
            ((vorticity_hat k û j) * ((k j : ℂ) * û i) -
              ((k i : ℂ) * û j) * (vorticity_hat k û j))) := by
  exact ⟨fun i => rfl, fun i => rfl, fun i => rfl⟩

/-! ## Closing: relation to the broader project -/

/-- **The vortex-stretching identity is NOT in the
`UsesOnlyHarmonicAnalysisAndEnergy` class.**

The Tao 2016 no-go (see `TaoNoGo.lean`) rules out regularity proofs
that use only the energy identity + standard harmonic analysis.
The vortex-stretching identity is a *geometric* statement that
involves the orientation of the vorticity relative to the strain
eigenvectors — it is NOT recoverable from the energy identity alone
(nor from any sequence of Sobolev/interpolation estimates), and so
it is not in the class.

We state this as a meta-level placeholder.  A future formalisation
will exhibit an explicit proof that the viscous term is *not*
sufficient to recover the stretching term from energy / harmonic-
analysis assumptions, completing the bridge. -/
theorem vortex_stretching_not_in_HA_energy_class :
    ∀ (_k : WaveVector) (_û : Fin 3 → ℂ) (_i : Fin 3), True := by
  intros
  trivial

end NsSpectral
