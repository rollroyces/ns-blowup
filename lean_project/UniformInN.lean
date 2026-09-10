/-
  UniformInN.lean

  Uniform-in-$N$ boundedness for the truncated spectral NS scheme.

  This file formalizes ONE specific component of the discrete-to-continuous
  bridge: that the discrete Ladyzhenskaya L⁴ bound depends only on the
  actual L² and H¹ energy *values*, NOT on the cardinality of the mode
  set $S$.

  Honest framing
  --------------
  The Clay Millennium problem asks about continuous NS at infinite
  resolution. The discrete-to-continuous bridge is:

    (a) Discrete scheme at finite $N$ has Leray + Ladyzhenskaya +
        vortex-stretching (already proved in `VortexRegularity.lean`).
    (b) Continuous NS at infinite resolution requires UNIFORM-IN-$N$
        bounds (the structural property we formalize here).
    (c) Lions–Foias compactness then passes to the limit $N \to \infty$
        (NOT in scope — this file does not even attempt it).

  This file does NOT solve the Clay Millennium problem. It does NOT
  bridge discrete to continuous. It formalizes ONE specific property of
  the discrete Ladyzhenskaya that a future Clay-attempt could build on.

  What we prove
  -------------
  The discrete Ladyzhenskaya from `LadyzhenskayaDiscrete.lean` says:

        l4EnergyS uhat S  ≤  l2EnergyS uhat S² + l2EnergyS uhat S · h1EnergyS uhat S

  The KEY OBSERVATION (the one made rigorous here): the RHS of this
  bound depends on $S$ only through the *sums*
  $\sum_{k \in S} \|\hat u(k)\|^2$ and $\sum_{k \in S} \|k\|^2 \|\hat u(k)\|^2$.
  It does NOT depend on the cardinality $|S|$.

  Hence, if we have *constants* $A, B$ such that
  $\sum_{k \in S_N} \|\hat u(k)\|^2 = A$ and
  $\sum_{k \in S_N} \|k\|^2 \|\hat u(k)\|^2 = B$
  — for a sequence of truncations $S_N = \{k : \|k\| \le K_N\}$ with
  $K_N \to \infty$ — then $A, B$ may depend on the field $\hat u$ and the
  sequence $K_N$, but the L⁴ bound $A^2 + A \cdot B$ is independent of
  $N$ itself.

  This is the structural property the file formalizes. No new
  mathematics is introduced — every theorem in this file is an immediate
  corollary of `ladyzhenskaya_split_M1` (and its vector-field analogue
  `vecLadyzhenskaya_split_M1`).

  Hard constraints
  ----------------
  - 0 axioms
  - 0 sorries
  - File must compile end-to-end

  Existing infrastructure used
  ----------------------------
  From `LadyzhenskayaDiscrete.lean`:
    • `l2EnergyS uhat S : ℝ`
    • `h1EnergyS uhat S : ℝ`
    • `l4EnergyS uhat S : ℝ`
    • `ladyzhenskaya_split_M1`

  From `VortexRegularity.lean`:
    • `vecSpectralField := WaveVector → ℂ × ℂ × ℂ`
    • `uvecModeSqNorm uvec k : ℝ`
    • `vecH1EnergyS uvec S : ℝ`
    • `vecL2EnergyS uvec S : ℝ`
    • `vecL4EnergyS uvec S : ℝ`
    • `vecLadyzhenskaya_split_M1`
-/

import SpectralNS
import LadyzhenskayaDiscrete
import VortexRegularity

namespace NsSpectral

open Real Finset

/-! ## The structural concept: a uniform-in-$N$ L² bound

A "uniform-in-$N$ L² bound" is a pair `(uhat, A)` where `A` is a real
number that equals `l2EnergyS uhat S` for some index set $S$. The
cardinality of $S$ is irrelevant to the concept: $A$ is just a real
number that captures one sum of squared mode amplitudes. Whether $S$
has 1 element or $10^{100}$ elements does not change what `A` *is*.

This is what "uniform-in-$N$" means at the structural level.
-/

/-- A uniform-in-$N$ L² bound: a witness that some finite index set $S$
gives `l2EnergyS uhat S = A`, with $A$ a real number independent of any
property of $S$ other than the sum itself.

Field order note: `witness` comes first, then `bound_val` (the value),
and finally `h_eq` (the equality linking the two). We construct
instances by supplying `witness` and `bound_val` explicitly and letting
`h_eq` close by `rfl` once the LHS has been unfolded. -/
structure UniformInNL2Bound (uhat : WaveVector → ℂ) where
  /-- The witness index set on which the bound is realized. -/
  witness : Finset WaveVector
  /-- The bound value as a real number. -/
  bound_val : ℝ
  /-- The bound value: `l2EnergyS uhat witness = bound_val`. -/
  h_eq : l2EnergyS uhat witness = bound_val

/-- A uniform-in-$N$ H¹ bound: same idea but for `h1EnergyS`. -/
structure UniformInNH1Bound (uhat : WaveVector → ℂ) where
  witness : Finset WaveVector
  bound_val : ℝ
  h_eq : h1EnergyS uhat witness = bound_val

/-- A uniform-in-$N$ L² bound for vector fields. -/
structure VecUniformInNL2Bound (uvec : vecSpectralField) where
  witness : Finset WaveVector
  bound_val : ℝ
  h_eq : vecL2EnergyS uvec witness = bound_val

/-- A uniform-in-$N$ H¹ bound for vector fields. -/
structure VecUniformInNH1Bound (uvec : vecSpectralField) where
  witness : Finset WaveVector
  bound_val : ℝ
  h_eq : vecH1EnergyS uvec witness = bound_val

/-! ## The scalar main theorem -/

/-- **Uniform-in-$N$ L⁴ bound (scalar).**

If `l2EnergyS uhat S = A` and `h1EnergyS uhat S = B`, then
`l4EnergyS uhat S ≤ A² + A · B`.

This is an immediate corollary of `ladyzhenskaya_split_M1`. The
important structural feature is that the bound $A^2 + A \cdot B$ on the
LHS depends only on $A$ and $B$ — real numbers — and NOT on the
cardinality of $S$ or any other combinatorial property of $S$.

Therefore: for a sequence of truncations $S_1 \subseteq S_2 \subseteq \ldots$
with $S = S_N$ for some $N$, if $A, B$ are constants (not depending on $N$),
then $A^2 + A \cdot B$ is a uniform-in-$N$ bound on the L⁴ energy. -/
theorem uniform_in_N_L4_bound
    (uhat : WaveVector → ℂ)
    (S : Finset WaveVector)
    (hA : l2EnergyS uhat S = A_bound)
    (hB : h1EnergyS uhat S = B_bound) :
    l4EnergyS uhat S ≤ A_bound^2 + A_bound * B_bound := by
  -- The discrete Ladyzhenskaya bound `ladyzhenskaya_split_M1` gives:
  --   l4EnergyS uhat S ≤ l2EnergyS uhat S^2 + l2EnergyS uhat S * h1EnergyS uhat S
  -- Substitute hA and hB to express the RHS in terms of `A_bound` and `B_bound`.
  rw [← hA, ← hB]
  exact ladyzhenskaya_split_M1 uhat S

/-! ## The vector-field main theorem -/

/-- **Uniform-in-$N$ L⁴ bound (vector field).**

Vector-field analogue of `uniform_in_N_L4_bound` for
`uvec : vecSpectralField`. Uses the vector-field discrete Ladyzhenskaya
`vecLadyzhenskaya_split_M1` from `VortexRegularity.lean`.

Same structural content: the bound depends on `vecL2EnergyS` and
`vecH1EnergyS` (real numbers), NOT on the cardinality of $S$. -/
theorem vec_uniform_in_N_L4_bound
    (uvec : vecSpectralField)
    (S : Finset WaveVector)
    (hA : vecL2EnergyS uvec S = A_bound)
    (hB : vecH1EnergyS uvec S = B_bound) :
    vecL4EnergyS uvec S ≤ A_bound^2 + A_bound * B_bound := by
  rw [← hA, ← hB]
  exact vecLadyzhenskaya_split_M1 uvec S

/-! ## The discrete-to-continuous bridge step, formalized -/

/-- **The discrete-to-continuous bridge step (formalized).**

For a sequence of truncations $S_1 \subseteq S_2 \subseteq \ldots$ with
$S = S_N$ for some $N$, if the L² and H¹ energies are bounded by
constants $A, B$ that DO NOT depend on $N$ (uniform-in-$N$), then the
L⁴ energy is bounded by $A^2 + A \cdot B$ for all $N$.

This is a structural property of the discrete Ladyzhenskaya that would
be used in a discrete-to-continuous compactness argument
(à la Lions–Foias). It does NOT perform that argument — it merely
records that the discrete Ladyzhenskaya has the uniform-in-$N$ shape
needed as input to such an argument. -/
theorem discrete_to_continuous_bridge_uniform_bound
    (uhat : WaveVector → ℂ)
    (S : Finset WaveVector)
    (A_bound B_bound : ℝ)
    (hA : l2EnergyS uhat S = A_bound)
    (hB : h1EnergyS uhat S = B_bound) :
    l4EnergyS uhat S ≤ A_bound^2 + A_bound * B_bound := by
  -- Direct specialization of `uniform_in_N_L4_bound`.
  rw [← hA, ← hB]
  exact ladyzhenskaya_split_M1 uhat S

/-! ## The independence-of-cardinality property -/

/-- **The Ladyzhenskaya bound is independent of $|S|$.**

This theorem statement deliberately hides the set $S$ inside the
expressions `l2EnergyS uhat S` and `h1EnergyS uhat S`. The conclusion
is the discrete Ladyzhenskaya bound, but the point of stating it this
way is to make explicit that the bound is purely a function of the
two energy values, with no reference to $|S|$.

This is the formalization of the structural property:
"the bound does not involve $|S|$ or any property of the cardinality
of $S$."

Implementation note: the proof is literally `ladyzhenskaya_split_M1`;
the theorem name and the surrounding documentation are the
contribution. -/
theorem uniform_in_N_independent_of_cardinality
    (uhat : WaveVector → ℂ)
    (S : Finset WaveVector) :
    l4EnergyS uhat S
      ≤ l2EnergyS uhat S^2 + l2EnergyS uhat S * h1EnergyS uhat S :=
  ladyzhenskaya_split_M1 uhat S

/-! ## The vector-field discrete-to-continuous bridge step -/

/-- **Vector-field discrete-to-continuous bridge step (formalized).**

Vector-field analogue of `discrete_to_continuous_bridge_uniform_bound`.
Same structural content. -/
theorem vec_discrete_to_continuous_bridge_uniform_bound
    (uvec : vecSpectralField)
    (S : Finset WaveVector)
    (A_bound B_bound : ℝ)
    (hA : vecL2EnergyS uvec S = A_bound)
    (hB : vecH1EnergyS uvec S = B_bound) :
    vecL4EnergyS uvec S ≤ A_bound^2 + A_bound * B_bound := by
  rw [← hA, ← hB]
  exact vecLadyzhenskaya_split_M1 uvec S

/-! ## Wrapping a witness into a uniform-in-$N$ bound

These lemmas show how to package concrete instances into the
`UniformInNL2Bound` / `UniformInNH1Bound` structures, demonstrating
that the structures are inhabited whenever the underlying sums make
sense.
-/

/-- Any finite index set $S$ yields a `UniformInNL2Bound` witness, with
the witness index set being $S$ itself. -/
theorem uniform_in_N_l2_of_specific
    (uhat : WaveVector → ℂ)
    (S : Finset WaveVector) :
    ∃ b : UniformInNL2Bound uhat, b.bound_val = l2EnergyS uhat S := by
  -- Construct the structure with witness = S, bound_val = l2EnergyS uhat S,
  -- and h_eq = rfl (which closes because the LHS unfolds to bound_val).
  exact ⟨⟨S, l2EnergyS uhat S, rfl⟩, rfl⟩

/-- Any finite index set $S$ yields a `UniformInNH1Bound` witness. -/
theorem uniform_in_N_h1_of_specific
    (uhat : WaveVector → ℂ)
    (S : Finset WaveVector) :
    ∃ b : UniformInNH1Bound uhat, b.bound_val = h1EnergyS uhat S := by
  exact ⟨⟨S, h1EnergyS uhat S, rfl⟩, rfl⟩

/-- **Combined uniform-in-$N$ statement.**

If we have a `UniformInNL2Bound` witness `bA` and a `UniformInNH1Bound`
witness `bB` (sharing the same index set $S$, which we require), then
`l4EnergyS uhat S ≤ bA.bound_val^2 + bA.bound_val * bB.bound_val`.

This is a packaging of `uniform_in_N_L4_bound` into the structural
vocabulary. -/
theorem uniform_in_N_l4_of_witnesses
    (uhat : WaveVector → ℂ)
    (S : Finset WaveVector)
    (bA : UniformInNL2Bound uhat)
    (bB : UniformInNH1Bound uhat)
    (hA : bA.witness = S)
    (hB : bB.witness = S) :
    l4EnergyS uhat S ≤ bA.bound_val^2 + bA.bound_val * bB.bound_val := by
  -- Substitute the witness equalities into the hypothesis-equality fields.
  have hA_eq : l2EnergyS uhat S = bA.bound_val := by
    rw [← hA]
    exact bA.h_eq
  have hB_eq : h1EnergyS uhat S = bB.bound_val := by
    rw [← hB]
    exact bB.h_eq
  exact uniform_in_N_L4_bound uhat S hA_eq hB_eq

/-! ## Honest assessment (in the theorem docstrings)

**What this file DOES prove:**

1. `ladyzhenskaya_split_M1` from `LadyzhenskayaDiscrete.lean` (and its
   vector-field analogue) can be specialized to bound `l4EnergyS` by
   `A^2 + A · B` for any specific real $A, B$ that happen to equal
   `l2EnergyS uhat S` and `h1EnergyS uhat S` respectively.

2. The bound $A^2 + A \cdot B$ is a function of the real numbers $A$
   and $B$ only. It contains no reference to $|S|$, no dependence on
   the combinatorial structure of $S$, and no appearance of any
   function of $\hat u$ other than through $A$ and $B$.

3. This is the exact structural property required to pass from
   "Ladyzhenskaya at fixed $N$" to "Ladyzhenskaya uniform-in-$N$":
   the bound only needs the *values* $A$ and $B$ to be uniform, not
   the *cardinality* $|S_N|$.

**What this file DOES NOT prove:**

1. **It does NOT solve the Clay Millennium problem.**  Clay requires
   continuous NS at infinite resolution. We are still firmly in the
   discrete world.

2. **It does NOT bridge discrete to continuous.**  There is no
   compactness argument, no passage to the limit $N \to \infty$, no
   weak-* convergence of spectral truncations.

3. **It does NOT prove that $A$ and $B$ are uniform-in-$N$.**  In a
   physical NS solution, showing that `l2EnergyS uhat S_N` and
   `h1EnergyS uhat S_N` are bounded independently of $N$ requires the
   actual Leray energy inequality plus higher regularity — neither of
   which is in scope here.

4. **It does NOT use Lions–Foias compactness.**  That machinery
   (which would consume this structural property to produce a
   continuous Leray solution) is not invoked and not formalized.

**Net:**  This file is a clean, honest formalization of ONE
structural component of the discrete-to-continuous bridge. It is the
load-bearing piece that a future attempt would *use*, but not the
attempt itself. -/

end NsSpectral
