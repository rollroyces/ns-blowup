/-
  TaoNoGo.lean

  Speculative formalisation of Tao's 2016 averaged-Navier--Stokes no-go
  principle.  This is deliberately an interface-level axiomatisation, not a
  mechanisation of Tao's PDE theorem.

  Tao's theorem supplies a bilinear averaged equation and smooth data with
  finite-time blow-up.  The averaging is arranged so that the energy identity
  and the standard harmonic-analysis estimates are shared with the true NS
  bilinear equation.  Consequently, a proof which uses only those two packages
  would also prove regularity for the averaged equation, contradicting the
  blow-up conclusion.

  The full Tao existence/blow-up statement is the single explicit axiom below.
  Replacing it by a proof is the substantive 20--40-hour research task.  The
  remaining definitions and theorems are elementary consequences of the
  interface and are fully checked by Lean.  In particular, this file does not
  assert regularity or irregularity of the true Navier--Stokes equation.
-/

import Mathlib

namespace TaoNoGo

universe u

/-- A deliberately coarse model of a bilinear Navier--Stokes-like equation.

`X` is the common state space.  Initial data, the solution map, the regularity
predicate, and the two analytic packages are exposed.  The energy and harmonic
analysis fields are propositions because a full formalisation would replace
these placeholders by the actual energy identity and a list of Sobolev,
interpolation, and bilinear estimates. -/
structure BilinearNSLike (X : Type u) where
  finalTime : ℝ
  solution : X → ℝ → X
  regular : X → Prop
  energyIdentity : Prop
  harmonicAnalysis : Prop

/-- The universal conclusion that a regularity method is trying to prove. -/
def RegularityConclusion {X : Type u} (M : BilinearNSLike X) : Prop :=
  ∀ d : X, M.regular (M.solution d M.finalTime)

/-- The only data available to a harmonic-analysis + energy-identity method. -/
structure HAEnergyAssumptions {X : Type u} (M : BilinearNSLike X) : Prop where
  energyIdentity : M.energyIdentity
  harmonicAnalysis : M.harmonicAnalysis

/-- A proof object for a method using only the two packages above.  There is no
field for vortex stretching, a special algebraic form of the bilinear term, or
any other finer structure. -/
def UsesOnlyHarmonicAnalysisAndEnergy
    {X : Type u} (M : BilinearNSLike X) : Prop :=
  ∀ _assumptions : HAEnergyAssumptions M, RegularityConclusion M

/-- The part of Tao's counterexample needed below.  The first two fields make
the averaged model share the allowed packages; the last two state the existence
of a datum and its failure of regularity at the final time.  This is a data
structure, not a proposition, because it contains the witness datum. -/
structure TaoAveragedBlowup (X : Type u) (averaged : BilinearNSLike X) : Type (u + 1) where
  averagedEnergy : averaged.energyIdentity
  averagedHarmonicAnalysis : averaged.harmonicAnalysis
  initialData : X
  notRegularAtFinalTime :
    ¬ averaged.regular (averaged.solution initialData averaged.finalTime)

/-- Tao's 2016 averaged-equation existence/blow-up theorem, abstracted at the
level of the interface.  This is the substantive external input.  It would
require formalising the averaged PDE, the smooth initial datum, and Tao's
finite-time blow-up argument (including the relevant convex-integration /
self-similar-construction details).  It is not derivable from the project's
earlier finite-spectral energy bounds. -/
axiom tao_averaged_blowup
    (X : Type u) (averaged : BilinearNSLike X) :
    TaoAveragedBlowup X averaged

/-- A method using only the shared energy and harmonic-analysis packages
transfers from the true model to the averaged model.  The regularity
equivalence is explicit rather than hidden: otherwise the two models could
use different meanings of “regular”. -/
theorem ha_energy_method_transfers
    {X : Type u} {trueNS averaged : BilinearNSLike X}
    (hEnergy : trueNS.energyIdentity ↔ averaged.energyIdentity)
    (hHarmonic : trueNS.harmonicAnalysis ↔ averaged.harmonicAnalysis)
    (hFinalTime : trueNS.finalTime = averaged.finalTime)
    (hRegular : ∀ d : X,
      trueNS.regular (trueNS.solution d trueNS.finalTime) ↔
        averaged.regular (averaged.solution d averaged.finalTime)) :
    UsesOnlyHarmonicAnalysisAndEnergy trueNS →
      UsesOnlyHarmonicAnalysisAndEnergy averaged := by
  intro hMethod averagedAssumptions
  have trueAssumptions :
      HAEnergyAssumptions trueNS :=
    ⟨hEnergy.mpr averagedAssumptions.energyIdentity,
      hHarmonic.mpr averagedAssumptions.harmonicAnalysis⟩
  have trueConclusion := hMethod trueAssumptions
  intro d
  have htrue : trueNS.regular (trueNS.solution d trueNS.finalTime) :=
    trueConclusion d
  simpa only [hFinalTime] using (hRegular d).mp htrue

/-- A convenient corollary of `ha_energy_method_transfers`. -/
theorem ha_energy_method_transfers_conclusion
    {X : Type u} {trueNS averaged : BilinearNSLike X}
    (hEnergy : trueNS.energyIdentity ↔ averaged.energyIdentity)
    (hHarmonic : trueNS.harmonicAnalysis ↔ averaged.harmonicAnalysis)
    (hFinalTime : trueNS.finalTime = averaged.finalTime)
    (hRegular : ∀ d : X,
      trueNS.regular (trueNS.solution d trueNS.finalTime) ↔
        averaged.regular (averaged.solution d averaged.finalTime))
    (hMethod : UsesOnlyHarmonicAnalysisAndEnergy trueNS) :
    UsesOnlyHarmonicAnalysisAndEnergy averaged :=
  ha_energy_method_transfers hEnergy hHarmonic hFinalTime hRegular hMethod

/-- Tao's 2016 no-go principle in this narrow formal interface.

A regularity proof for the true model, if it uses only the shared energy
identity and harmonic-analysis package, transfers to the averaged model.  Tao's
blow-up axiom then contradicts the transferred regularity conclusion.  This is
a statement about the insufficiency of the specified proof class; it is not a
claim that the true NS solution is irregular. -/
theorem tao_no_go
    {X : Type u} {trueNS averaged : BilinearNSLike X}
    (hEnergy : trueNS.energyIdentity ↔ averaged.energyIdentity)
    (hHarmonic : trueNS.harmonicAnalysis ↔ averaged.harmonicAnalysis)
    (hFinalTime : trueNS.finalTime = averaged.finalTime)
    (hRegular : ∀ d : X,
      trueNS.regular (trueNS.solution d trueNS.finalTime) ↔
        averaged.regular (averaged.solution d averaged.finalTime))
    (hMethod : UsesOnlyHarmonicAnalysisAndEnergy trueNS) :
    False := by
  have hAveragedMethod :
      UsesOnlyHarmonicAnalysisAndEnergy averaged :=
    ha_energy_method_transfers hEnergy hHarmonic hFinalTime hRegular hMethod
  obtain ⟨hEnergyA, hHarmonicA, d, hd⟩ :=
    tao_averaged_blowup X averaged
  have hAveragedAssumptions :
      HAEnergyAssumptions averaged :=
    ⟨hEnergyA, hHarmonicA⟩
  exact hd (hAveragedMethod hAveragedAssumptions d)

/-- A named alias for the same logical conclusion. -/
theorem tao2016_no_go
    {X : Type u} {trueNS averaged : BilinearNSLike X}
    (hEnergy : trueNS.energyIdentity ↔ averaged.energyIdentity)
    (hHarmonic : trueNS.harmonicAnalysis ↔ averaged.harmonicAnalysis)
    (hFinalTime : trueNS.finalTime = averaged.finalTime)
    (hRegular : ∀ d : X,
      trueNS.regular (trueNS.solution d trueNS.finalTime) ↔
        averaged.regular (averaged.solution d averaged.finalTime))
    (hMethod : UsesOnlyHarmonicAnalysisAndEnergy trueNS) :
    False :=
  tao_no_go hEnergy hHarmonic hFinalTime hRegular hMethod

/-- The model-level form: there cannot be a universal regularity proof in the
specified method class whenever the two abstract packages agree. -/
theorem no_regularity_proof_from_HA_energy
    {X : Type u} {trueNS averaged : BilinearNSLike X}
    (hEnergy : trueNS.energyIdentity ↔ averaged.energyIdentity)
    (hHarmonic : trueNS.harmonicAnalysis ↔ averaged.harmonicAnalysis)
    (hFinalTime : trueNS.finalTime = averaged.finalTime)
    (hRegular : ∀ d : X,
      trueNS.regular (trueNS.solution d trueNS.finalTime) ↔
        averaged.regular (averaged.solution d averaged.finalTime)) :
    ¬ UsesOnlyHarmonicAnalysisAndEnergy trueNS := by
  intro hMethod
  exact tao_no_go hEnergy hHarmonic hFinalTime hRegular hMethod

end TaoNoGo
