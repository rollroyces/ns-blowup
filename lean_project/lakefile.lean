import Lake
open Lake DSL

package «ns_spectral»

@[default_target]
lean_lib «NsSpectral» {
  roots := #[`SpectralNS, `BeiraoDaVeiga, `ConstantinIyer, `CompositeRegularity, `CaoTiti, `TaoNoGo, `UnifiedComposite, `VortexStretching, `VortexRegularity]
}

require mathlib from git "https://github.com/leanprover-community/mathlib4.git"
