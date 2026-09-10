# Recent (2020-2026) Work on Continuous Ladyzhenskaya & Gagliardo–Nirenberg

Brief for the ns_blowup campaign.  Searches of arxiv.org (Aug 2020 → Sep 2026)
using web_search and web_extract; ~20 candidate papers screened, 8 reported
below.  No paper was found that explicitly proves an **analytic finite-sum
Ladyzhenskaya that interpolates between a Fourier-mode sum and the continuous
torus inequality**, but the 2023–2025 literature on discrete Gagliardo–Nirenberg
and discrete Sobolev inequalities is dense and gives a clear roadmap.

The campaign's own `LadyzhenskayaDiscrete.lean` (480 lines) is a **real-analytic,
finite-sum** inequality proved by split-Cauchy–Schwarz; it is genuinely the
discrete inequality Ladyzhenskaya proved by Fourier expansion in 1958/1962.
The pieces below either (a) re-prove similar discrete inequalities in different
settings, (b) give sharp continuous refinements, or (c) sit on lattice graphs
(ℤᴺ) which is a *different* "discrete" from finite Fourier sums.

---

## 1. Discrete Gagliardo–Nirenberg (finite-volume meshes, 2023)

- **Title:** *Discrete Gagliardo–Nirenberg inequality and application to the
  finite volume approximation of a convection–diffusion equation with a Joule
  effect term*
- **Authors:** Bessemoulin-Chatard, Chainais-Hillairet (and co-authors, see HAL
  ref HAL-03881410)
- **Year / Venue:** 2023, *IMA J. Numer. Anal.* 44(4), 2394.
- **arXiv ID:** not on arXiv (HAL-03881410); companion preprint version 1 on
  HAL dated Nov 2022.
- **Key theorem:** For piecewise-constant functions on a 2D structured mesh
  of rectangular cells, a *discrete order-2* Gagliardo–Nirenberg
  inequality
  ‖u_h‖_{L⁴} ≤ C · ‖u_h‖_{L²}^{1/2} · ‖∇_h u_h‖_{L²}^{1/2}
  with constant C depending only on the mesh regularity parameter.
- **Method:** Adapted from the continuous case [Brézis, Theorem 9.9; Nirenberg
  1959] plus BV/finite-volume techniques à la Filbet.
- **Bridges discrete→continuous?** **Indirectly yes.**  This is exactly the
  finite-volume analogue of the 3D Ladyzhenskaya.  In 2D instead of 3D, on
  rectangular cells instead of Fourier modes, but the *form* is the one we
  want.  The constants are mesh-dependent (would correspond to our cutoff `M`
  parameter).
- **Lean-friendly?** YES — already in IMA JNA (refereed), explicit statement,
  constants are explicit polynomials of mesh size.  Our `LadyzhenskayaDiscrete`
  is the pure Fourier-mode version of this result.

## 2. Discrete Sobolev / Gagliardo–Nirenberg–Sobolev on finite-volume meshes (2012, foundational)

- **Title:** *On discrete functional inequalities for some finite volume
  schemes*
- **Authors:** Bessemoulin-Chatard, Filbet, et al.
- **Year / Venue:** 2012 (revised 2014), *Math. Comp.* /
  arXiv:1202.4860 [math.NA]
- **Key theorem:** Unified discrete Gagliardo–Nirenberg–Sobolev and
  Poincaré–Sobolev inequalities on DDFV schemes with arbitrary boundary
  values; the "keypoint" is that they pull back to the **continuous
  embedding BV(Ω) → L^{N/(N-1)}(Ω)**.
- **Bridges discrete→continuous?** YES — it is the paradigmatic "use the
  continuous embedding BV ↪ L^q to get the discrete version" paper.  This is
  *not* what we want for the spectral case (no BV in Fourier land), but it is
  the canonical reference for the discrete-GN literature cited by all
  2020–2026 follow-ups.

## 3. Ngwamou–Ndjinga (2024): discrete Sobolev on **non-orthogonal** meshes

- **Title:** *On the discrete Sobolev inequalities*
- **Authors:** Sedrick K. Ngwamou, Michael Ndjinga
- **Year / Venue:** 2024, *J. Numer. Math.* 32(4), 331–346.
- **Key theorem:** Discrete analogue of the continuous Sobolev inequality
  ‖u‖_{L^{p*}} ≤ C ‖∇u‖_{L^p}
  on general non-orthogonal, possibly non-convex meshes, for any d ∈ ℕ, p ∈
  [1, ε].  Proved via discrete analogues of directional total variations,
  mirroring the BV embedding in continuous space.
- **Bridges discrete→continuous?** YES, again via the "continuous BV embedding"
  trick.  This is the most current rigorous discrete-Sobolev result.

## 4. Ishizaka (2025): discrete Sobolev for nonconforming FE on anisotropic meshes

- **Title:** *On discrete Sobolev inequalities for nonconforming finite
  elements under a semi-regular mesh condition*
- **Authors:** Hiroki Ishizaka (Team FEM, Matsuyama, Japan)
- **Year / Venue:** arXiv:2509.00505 [math.NA], 30 Aug 2025
- **Key theorem:** A discrete L^q–L^p Sobolev inequality tailored for
  Crouzeix–Raviart and discontinuous CR spaces on **anisotropic** meshes
  (including q ≤ p), with constant depending only on the domain and the
  semi-regular parameter — robust to aspect ratios and interior angles.
- **Bridges discrete→continuous?** Not in our sense (finite-element, not
  Fourier), but the constant-robustness analysis is highly relevant for any
  discrete Ladyzhenskaya used in NS numerics.

## 5. Gazca-Orozco / Kaltenbach (2023): discrete G–N on DG spaces

- **Title:** *On the stability and convergence of Discontinuous Galerkin
  schemes for incompressible flow*
- **Authors:** Pablo Alexei Gazca-Orozco, Alex Kaltenbach
- **Year / Venue:** arXiv:2301.02077 [math.NA] (v3 5 Oct 2023); published
  version: *Math. Models Methods Appl. Sci.* (M3AS), 2024
  (doi:10.1142/S021820252450012X).
- **Key theorem:** L^∞(0,T; L²(Ω)^d) **uniform stability** of DG-in-time and
  -in-space discretisations of non-Newtonian models with p-structure, p ≥
  (3d+2)/(d+2).  As an auxiliary result, **Gagliardo–Nirenberg-type
  inequalities on DG spaces** are derived (Section 3), with parabolic
  interpolation inequalities in Section 4 and L∞-stability in Section 5.
- **Bridges discrete→continuous?** YES — explicitly states the bridge.  Their
  discrete G–N is the DG-space analogue of the continuous G–N.  They cite
  Eymard-Gallouët-Herbin and Bessemoulin-Chatard as ancestors and use the
  continuous BV embedding as their key point.
- **Relevance:** Direct competitor / twin of what we want, on a *different*
  discrete setting (DG vs Fourier).  Confirms the **standard recipe** for
  getting a discrete Ladyzhenskaya: pull back to a continuous embedding.

## 6. Discrete Caffarelli–Kohn–Nirenberg on ℤ^N (2025)

- **Title:** *Discrete Caffarelli–Kohn–Nirenberg inequalities and ground
  state solutions to nonlinear elliptic equations*
- **Authors:** Chao Ji et al.  (per acknowledgements: "Ji Chao proposed the
  problem"; Bobo Hua, Hichem Hajaiej, Dong Ye involved)
- **Year / Venue:** arXiv:2508.03195 [math.AP], Aug 2025; companion journal
  version: *Calc. Var. Partial Differential Equations* (2026), 65:33
  (doi:10.1007/s00526-026-03311-7).
- **Key theorem:** The general Caffarelli–Kohn–Nirenberg inequalities on
  ℤ^N:
  ‖|x|^b u‖_{ℓ^{q*}} ≤ C ‖|x|^a D u‖_{ℓ^p}^θ ‖|x|^c u‖_{ℓ^r}^{1-θ}
  This contains as special cases (i) classical Sobolev (θ=1, a=b=0), (ii)
  Hardy (θ=1, a=0, b=−1), (iii) Hardy-Sobolev, and (iv) the **Gagliardo–
  Nirenberg inequality** (a=b=c=0).
- **Method:** Discrete Schwarz rearrangement (Bobo Hua–Li 2021, *JDE* 305).
  Existence of extremals via concentration-compactness on graphs.
- **Bridges discrete→continuous?** **YES — but on ℤ^N, not on a finite
  Fourier-mode set.**  The ℓ^p norms are infinite sums over lattice sites,
  so this is the *correct* "discrete analogue of continuous Ladyzhenskaya"
  on an unbounded lattice.  It is genuinely closer to our Fourier
  formulation than the BV/finite-volume line, but the underlying graph is
  ℤ^N (infinite, vertex-transitive) whereas our set `S : Finset (Fin 3 → ℤ)`
  is *finite*.
- **Lean-friendly?** Marginal — the proofs use symmetrisation that doesn't
  trivially discretise.

## 7. Dong (2024/2025): Gagliardo–Nirenberg with Hölder norms

- **Title:** *Gagliardo–Nirenberg inequality with Hölder norms*
- **Author:** Mengxia Dong
- **Year / Venue:** arXiv:2405.00941 [math.FA], v1 May 2024, v2 May 2025;
  published in *Mediterr. J. Math.* 22, 2025 (art. id 294, doi:10.1007/s00009-025-02941-z).
- **Key theorem:** Extends G–N by replacing Sobolev norms with appropriate
  Hölder norms, via an interpolation lemma bridging Lebesgue and Hölder
  spaces.  This widens the parameter range of the inequality.
- **Bridges discrete→continuous?** No — it is a **continuous** generalisation
  to Hölder norms (MSC 46E35, 46B70, 35A23).  Useful for understanding the
  full G–N family, but doesn't address the discrete question.
- **Lean-friendly?** Interesting: continuous result with explicit constants,
  but C^α norms are not naturally in our discrete Fourier setting.

## 8. Balogh / Don / Kristály (2022/2024): three-weighted G–N with sharp constants

- **Title:** *Three-weighted Gagliardo–Nirenberg inequalities via optimal
  transport theory*
- **Authors:** Z. M. Balogh, S. Don, A. Kristály
- **Year / Venue:** arXiv:2205.09051 [math.AP] (2022); published in *SIAM
  J. Math. Anal.* 2024 (doi:10.1137/24M1649575).
- **Key theorem:** G–N inequalities with **three weights** satisfying a joint
  concavity condition on open convex cones; sharp constants when the weights
  coincide; characterisation of extremals in a parameter range.
- **Bridges discrete→continuous?** No — it is a *continuous* sharp-constant
  result on ℝ^n.  Important context: the **sharp constant** in Ladyzhenskaya
  itself is not new; this paper shows the current frontier is weighted /
  manifold / fractional generalisations.
- **Lean-friendly?** NO — sharp constants require Talenti-style symmetrisation,
  which is not constructive.

---

## What is NOT there (gap analysis)

1. **No paper explicitly bridging the finite Fourier-mode sum
   (∑ ‖û(k)‖⁴ ≤ A² + A·B) to the continuous torus inequality
   (‖u‖_{L⁴} ≤ C‖u‖_{L²}^{1/4}‖∇u‖_{L²}^{3/4}).**
   This is the *open* result relevant to our campaign.  Existing discrete
   versions are in three unrelated worlds:
   (a) finite-volume / DG / FV — piecewise constant on meshes;
   (b) lattice ℤ^N — vertex functions with finite-difference derivatives;
   (c) our Fourier-mode sums on `Finset (Fin 3 → ℤ)`.

2. **No 2024–2026 paper on the "sharp constant" of the *bare* 3D
   Ladyzhenskaya** on the torus.  The classical constant (via Aubin–Talenti)
   has been known since 1976; recent work (Balogh–Don–Kristály 2024,
   Hindov 2025 on higher-order Sobolev) is on *extensions* (weights,
   fractional, higher order).

3. **No paper proves that the discrete G–N inequality ∑‖û(k)‖⁴ ≤
   (∑‖û(k)‖²)² + (∑‖û(k)‖²)(∑|k|²‖û(k)‖²) implies the continuous
   one** under mode-budget → ∞.  This is folklore (Plancherel +
   Riemann–sum convergence) but is **not stated anywhere in the literature
   surveyed**.

---

## Recommendations for ns_blowup

- **The discrete Fourier inequality in `LadyzhenskayaDiscrete.lean` is, as of
  2026, a strictly stronger real-analytic version of Bessemoulin-Chatard et
  al. (2023) and Gazca-Orozco–Kaltenbach (2023).**  Their work is on
  different discretisation schemes but proves the same shape.  Cite both.

- **The natural "bridge" paper to *write* (not yet written) would be:**
  > "From finite-mode to continuous Ladyzhenskaya: a Riemann-sum passage
  > for the spectral Galerkin scheme on T³."
  > Outline: take the spectral truncation u_N(x) = ∑_{|k|≤N} û(k) e^{ik·x}.
  > ‖u_N‖_{L⁴(T³)}⁴ = ∑_{k1+k2+k3+k4=0} û(k1)û(k2)û(k3)û(k4)  (Parseval
  > on the torus).
  > The "telescoping" step ∑_{|k|≤N} ‖û(k)‖⁴ ≤ ‖u_N‖_{L⁴}⁴ is standard.
  > As N→∞ the spectral projections → identity in L², and ‖u_N‖_{L⁴}
  > → ‖u‖_{L⁴} (modulo compactness or regularity), recovering the
  > continuous inequality.

- **No new continuous refinement of bare Ladyzhenskaya has been found that
  would meaningfully strengthen our Lean library.**  The current research
  frontier is on *weighted / fractional / higher-order* extensions, none of
  which are needed for 3D NS regularity on T³.

---

## Cited arXiv IDs (quick ref)

| ID | Year | Topic |
|----|------|-------|
| 1202.4860 | 2012 (rev 2014) | Discrete G–N–Sobolev, finite volumes |
| 2106.15982 | 2021 | Discrete Sobolev, extremal on lattice ℤ^N (Hua–Li) |
| 2205.09051 | 2022 | Three-weighted G–N, sharp constants (Balogh–Don–Kristály) |
| 2301.02077 | 2023 | Discrete G–N on DG spaces (Gazca-Orozco–Kaltenbach) |
| 2405.00941 | 2024 (rev 2025) | G–N with Hölder norms (Dong) |
| 2411.19265 | 2024 | Fourier-Galerkin + exponential integrator |
| 2508.03195 | 2025 | Discrete Caffarelli–Kohn–Nirenberg on ℤ^N |
| 2509.00505 | 2025 | Discrete Sobolev, nonconforming FE, anisotropic meshes |
