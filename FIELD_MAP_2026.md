# Navier–Stokes Regularity Field Map — September 2026

**Purpose.** Snapshot of the NS regularity research field as of 10 Sep 2026, for the
ns_blowup campaign. Distinct from `LITERATURE_SURVEY.md` (which was scoped to direct
campaign inputs); this file is an external field map.

**Note on date.** Today is Thu 10 Sep 2026. Two days ago (Mon 7–8 Sep 2026) the
Alpöge–Buckmaster preprints and the OpenAI NS blowup announcement dropped
simultaneously. The field is in motion; some claims below are preliminary and
should be re-checked in 4–6 weeks once community assessment has landed.

---

## 1. Legitimate 2023–2026 survey / overview articles

Three real surveys/overviews (peer-reviewed or by established authors) found.
None is a single "definitive" survey; together they cover different slices.

### 1.1 Barker & Prange (2023) — quantitative regularity
- **Title.** *From Concentration to Quantitative Regularity: a short survey of
  recent developments for the Navier–Stokes equations.*
- **Authors.** Tobias Barker (Bath), Christophe Prange (Cergy Paris).
- **Venue.** *Vietnam Journal of Mathematics*, published online 29 Dec 2023.
  DOI 10.1007/s10013-023-00665-9. 28 pp.
- **arXiv.** [2211.16215](https://arxiv.org/abs/2211.16215) (submitted Nov 2022;
  written for Carlos Kenig's 70th birthday proceedings).
- **Scope.** Norm concentration near potential blow-up times, explicit
  quantitative regularity estimates, the "slight criticality breaking"
  programme (Dodu–Triebel, Barker–Prange, Prange–Wang, Kenig–Merle-type
  arguments imported from nonlinear dispersive PDEs). Does **not** cover
  convex-integration non-uniqueness in depth.
- **Verdict.** Best single survey for our campaign's interests; cite as
  `Barker–Prange 2023` when defending the quantitative-regularity / Kolmogorov-
  scale programme that our truncated spectral scheme sits inside.

### 1.2 Miller (2021/2022) — geometric constraints on blowup
- **Title.** *A survey of geometric constraints on the blowup of solutions of
  the Navier–Stokes equation.*
- **Author.** Evan Miller (UBC / MSRI).
- **Venue.** *Journal of Mathematical Analysis and Applications* (Springer
  link shows J. Math. Anal. Appl. 2022; arXiv listing 2111.00040).
- **arXiv.** [2111.00040](https://arxiv.org/abs/2111.00040).
- **Scope.** Component-reduction regularity criteria (Serrin-type, vorticity
  components, single directional derivative ∂₃u, strain / vorticity). Surveys
  Kukavica–Ziane, Cao, Zhang, Skalák, Chen–Zhang, the author's own work, and
  the open endpoint cases. Physical-significance section at the end.
- **Verdict.** Still the cleanest reference for the "geometric constraints"
  side of regularity criteria. Slightly dated (predates the 2024–2026 wave)
  but the open-problems list (endpoint Besov, directional, vorticity
  components) is exactly what subsequent papers have been chipping at.

### 1.3 Buckmaster–Vicol (2020) — convex integration survey
- **Title.** *Convex integration and phenomenologies in turbulence.*
- **Authors.** Tristan Buckmaster, Vlad Vicol.
- **Venue.** *EMS Surveys in Mathematical Sciences* 6 (2020), no. 1/2, 173–263.
  doi:10.4171/EMSS/34.
- **Scope.** The convex-integration / h-principle programme: Nash–Kuiper,
  De Lellis–Székelyhidi (Euler), Isett (C^{1/5−ε} Euler non-conservation),
  Buckmaster–De Lellis–Isett–Székelyhidi (2018) wild NS solutions with
  singular-time set of Hausdorff dim < 1, the BV19 non-uniqueness, Albritton–
  Brué–Colombo 2022 forced Leray non-uniqueness.
- **Verdict.** The canonical reference for the non-uniqueness half of the
  field. Predates the 2024–2026 burst but its citation graph is still the
  one to anchor.

### 1.4 Tao blog post (7 Sep 2026) — *de facto* overview of the recent burst
- **Title.** *Finite time blowup with smooth forcing term for the
  incompressible porous medium, Boussinesq, and incompressible Euler
  equations.*
- **Author.** Terence Tao (What's new blog).
- **URL.** terrytao.wordpress.com/2026/09/07/...
- **Scope.** Not a peer-reviewed survey, but as of 10 Sep 2026 it is the
  single most useful overview of the Alpöge–Buckmaster breakthrough, the
  Córdoba–Martínez-Zoroa line of work, and the second-line Ganeshram–
  Duruisseaux–Anandkumar PINN result. Explicitly flags that extension to
  true NS (no forcing) is "widely expected" and "high likelihood" but not
  done. Worth citing as a field-orientation document even if not academic.

### 1.5 Older but still cited
- Lemarié-Rieusset, *Recent Developments in the Navier–Stokes Problem*
  (Chapman & Hall/CRC, 2002, 2nd ed. 2016). Standard reference; not a
  2023–2026 survey but appears in essentially every recent paper's
  bibliography.

---

## 2. Major 2024–2026 results the campaign should know about

Ordered by likely relevance to ns_blowup.

### 2.1 Córdoba–Martínez-Zoroa–Zheng (2024) — hypodissipative NS blowup
- **arXiv.** [2407.06776](https://arxiv.org/abs/2407.06776), Jul 2024. Also
  the 2410.22920 v3 referenced by Tao.
- **Result.** Finite-time blow-up of classical solutions with finite energy
  for the **forced** hypodissipative NS (|∇|^α with α ∈ [0, α₀) where
  α₀ = (22 − 8√7)/9 > 0). Vortex-layer construction with increasingly large
  / closer-in / shorter-lived layers.
- **Significance.** First finite-time blow-up result for any
  incompressible-fluid model in the **subcritical well-posedness regime**
  (per Tao blog). The construction lives strictly below α=1, so it does
  not touch the true NS equation directly, but it is the seed for the
  Alpöge–Buckmaster extension.

### 2.2 Miao–Nie–Ye (Dec 2024) — non-uniqueness on ℝ³
- **arXiv.** [2412.10404](https://arxiv.org/abs/2412.10404), 6 Dec 2024.
- **Result.** Non-uniqueness of finite-energy weak solutions to the
  Navier–Stokes equations on **the whole space ℝ³** (extending BV19 from
  𝕋³). Uses a "local + non-local" decomposition with a localized corrector
  for the Reynolds stress. Also: infinitely many dissipating weak solutions
  in smooth bounded domains; instability near Couette flow in L²(ℝ³).
- **Significance.** Closes the gap between periodic (BV19) and whole-space
  convex integration for NS. Not a regularity result, but the convex-
  integration machinery is now essentially unconstrained by domain.

### 2.3 Hou–Wang–Yang (Sep 2025 / Mar 2026) — computer-assisted Leray-Hopf non-uniqueness
- **arXiv.** [2509.25116](https://arxiv.org/abs/2509.25116), v1 29 Sep 2025,
  v2 19 Mar 2026.
- **Result.** Claims the **first rigorous computer-assisted proof** of
  non-uniqueness of Leray-Hopf solutions for the **unforced** 3D NS. Builds
  a self-similar candidate, then proves linear instability via a
  coercive + compact perturbation decomposition with finite-rank
  approximation verified by computer.
- **Status (as of 10 Sep 2026).** Submitted to journal; not yet peer-
  reviewed. Listed by kingy.ai / vibemathed.com coverage as one of the
  serious attempts at Clay alternative D (Leray-Hopf non-uniqueness
  without forcing). Worth tracking, but **not yet a published theorem**.

### 2.4 Coiculescu–Palasek (Dec 2025 / Apr 2026 issue) — Inventiones
- **Title.** *Non-uniqueness of smooth solutions of the Navier–Stokes
  equations from critical data.*
- **Venue.** *Inventiones mathematicae* 244, 165–219 (April 2026 issue).
  Online 12 Dec 2025.
- **DOI.** 10.1007/s00222-025-01396-z.
- **Result.** Construct initial data in BMO⁻¹ (the **critical space** of
  Koch–Tataru 2001) from which there exist **two distinct global solutions,
  both smooth for all t>0**. Sharpens the Koch–Tataru small-data global
  well-posedness to an essentially optimal non-uniqueness statement.
  Mechanism: a non-uniqueness idea of Vicol on dyadic NS lifted to the
  true NS via a non-convex-integration construction (the authors are
  emphatic on this distinction — it is *not* a convex-integration proof).
- **Significance.** The single most important 2025–2026 result for our
  campaign. It pushes the boundary of "non-uniqueness with smoothness"
  down to the critical space, which is exactly the regime where our
  truncated spectral scheme (with Tao 2016 as the irreducible axiom) lives.
  If both Leray-Hopf alternatives survive — Leray-Hopf non-uniqueness
  (Hou–Wang–Yang claim) **and** smooth-solution non-uniqueness at the
  critical regularity (Coiculescu–Palasek) — the field is approaching a
  full negative answer to the Clay problem.

### 2.5 Alpöge–Buckmaster (Sep 2026) — IPM + Boussinesq + 3D Euler blowup with **smooth forcing**
- **Preprints.** Posted by Tristan Buckmaster on his NYU CIMS page and
  Mastodon ~5–6 Sep 2026. Three papers: porous-medium equation,
  2D Boussinesq, 3D incompressible Euler. Boussinesq paper is most
  polished; intro readable as a field introduction.
- **Result.** Finite-time blow-up of smooth solutions for three model
  equations **with smooth forcing term**, using a Córdoba–Martínez-Zoroa
  iterative ansatz with improved ODE-instability and spatial-localization
  properties.
- **Significance.** Per Tao: "It is now widely expected that it should be
  possible to construct smooth initial data and smooth forcing term that
  would make these [Navier–Stokes] equations develop singularities in
  finite time; and it should even be possible to do without the forcing
  term. While these authors do not quite achieve these goals yet, they
  have made enough of a breakthrough that it looks very feasible to
  complete these goals in the near future."
- **Status.** Preliminary, "the worst writeup we had ever seen in the
  history of mathematics" per Buckmaster (later rewritten). Lean
  formalization exists. Not yet peer-reviewed. **This is the most
  important live development for the campaign.**

### 2.6 OpenAI "Finite time blowup for Navier–Stokes" (8 Sep 2026) — CONTESTED
- **Title.** *Finite time blowup for Navier–Stokes.*
- **Source.** cdn.openai.com PDF, 166 pp; companion 112 pp Euler paper; Lean
  repo at github.com/openai/NavierStokesAndEuler. Blog post on
  openai.com/index/navier-stokes-solution/.
- **Claim.** For every positive viscosity, construct a solution to the
  3D incompressible NS that **starts from rest**, has **uniformly bounded
  kinetic energy**, and develops **unbounded velocity in finite time**.
  Targets Clay alternatives C/D (smooth forcing).
- **Status (as of 10 Sep 2026).** **Heavily disputed, not accepted.** Clay
  Mathematics Institute has **not** accepted the result; the problem
  remains officially open on their site. Buckmaster has stated publicly
  that the underlying forced-blowup idea traces to Córdoba–Martínez-Zoroa
  ("Luis Martínez-Zoroa deserves a Fields Medal") and that OpenAI only
  pivoted to that line after hearing the Buckmaster–Alpöge rumor. The
  Lean formalization is published but the proof itself is "AI-assisted"
  to a degree that makes independent verification slow. Kingy.ai's
  "evidence and dispute" summary is the most balanced writeup.
- **Recommendation for the campaign.** **Do not cite as a theorem.** Cite
  the underlying mathematical claim as a "high-profile unverified
  announcement" only. The Alpöge–Buckmaster human-authored papers are
  the legitimate reference for the same mathematics.

### 2.7 Ganeshram–Duruisseaux–Anandkumar (Sep 2026) — PINN Euler
- **Source.** anima-ai.org preprint, ~7 Sep 2026. Physics-informed neural
  net used to locate a numerically stable blow-up profile for the
  unforced 3D Euler equation on ℝ³.
- **Status.** Very preliminary; stability to within the residual error
  is not established. Per Tao's blog edit, this is the "second major
  approach" — find candidate numerically, then prove stable. Worth
  tracking as a parallel direction.

### 2.8 Other 2024–2026 substantive work (smaller but real)
- Numerous regularity-criterion papers extending Besov / Lorentz /
  one-component criteria — the "drilling" of the Serrin / Ladyzhenskaya-
  Prodi-Serrin endpoint cases continues. Cited inside Miller 2021 and
  follow-ups. Authors include Skalák, Zhang, Namlyeyeva, Guo, Kučera.
- Buckmaster homepage (cims.nyu.edu/~tristanb/publications) shows two
  preprints from 2025: *Resolving Sharp Gradients of Unstable
  Singularities to Machine Precision via Neural Networks* and
  *Discovery of Unstable Singularities* — both are numerical /
  machine-learning scaffolds for the convex-integration programme.
  Relevant if the campaign ever moves from spectral numerics to
  machine-precision instability verification.

---

## 3. Active research groups (2024–2026 substantive output)

- **Tristan Buckmaster (NYU CIMS) — Levent Alpöge (Anthropic).** The hot
  pair of the moment. Co-authored the Sep 2026 IPM / Boussinesq / 3D Euler
  blowup-with-smooth-forcing preprints. Buckmaster's broader publication
  record (per his NYU page) spans convex integration, compressible Euler
  shocks, NLS turbulence. **The single most important group to track.**
- **Diego Córdoba (ICMAT/CSIC Madrid) — Luis Martínez-Zoroa — Fan Zheng.**
  Hypodissipative NS and rough-forcing blowup constructors since ~2021
  (Martínez-Zoroa's thesis) through 2407.06776 (2024). Cordoba also has
  a recent Spanish-language survey on Euler singularity formation (linked
  in Tao's blog SECOND EDIT).
- **Terence Tao (UCLA).** Public-facing field-steerer via his blog;
  Lean-formalization side-channel; 1402.0290 averaged-NS blowup remains
  the irreducible-axiom reference for any truncated-spectral programme
  including ours. Not publishing new NS regularity theorems but is the
  central node.
- **Vlad Vicol (NYU CIMS).** Co-author of BV19 non-uniqueness and the
  EMS Surveys article; second author of Coiculescu–Palasek Inventiones
  paper (the BMO⁻¹ non-uniqueness result uses his dyadic-NS mechanism).
- **Matei P. Coiculescu — Stan Palasek.** Junior authors of the
  Coiculescu–Palasek Inventiones paper (Dec 2025). Names to watch.
- **Changxing Miao — Yao Nie — Weikui Ye (Institute of Applied Physics
  and Computational Mathematics, Beijing).** Whole-space non-uniqueness
  via localized correctors (2412.10404). Part of the IAPCM Chinese NS
  group (also does Tao-style averaging work).
- **Thomas Hou (Caltech) — Yixuan Wang — Changhe Yang.** Hou group
  computer-assisted analysis program for self-similar profiles;
  2509.25116 Leray-Hopf non-uniqueness claim. Hou's group has been
  driving the numerical-singularities side of the field for ~20 years
  and now claims the first computer-rigorous non-uniqueness result.
- **Buckmaster / De Lellis / Isett / Székelyhidi extended family.** The
  core convex-integration programme is still alive (De Lellis at
  Princeton / Leipzig; Isett at Rice; Székelyhidi at Leipzig). Their
  2019 JEMS paper "Wild solutions of NS whose singular sets in time
  have Hausdorff dim strictly less than 1" is still the high-water
  mark for the regularity-criterion side of non-uniqueness. Look for
  any 2024–2026 follow-ups from Isett on the Hölder-class
  threshold (1/5−ε).

- **Groups that appear less active in 2024–2026 than 2010s–2020s.**
  Kukavica (USC), Vicol's older collaborations outside NS,
  Constantin–Iyer group at Chicago, Shvydkoy (UIC). Their work on
  regularity criteria, anomalous dissipation, and Lyapunov functionals
  continues but the centre of gravity has clearly shifted to the
  convex-integration / computer-assisted / forced-blowup axis.

---

## 4. Promising current directions identified by surveys + Tao

Synthesizing Barker–Prange, Miller, and the Tao blog:

1. **Forced blowup becomes the live frontier.** Tao (7 Sep 2026) flags
   that "high likelihood" extension to true NS (no forcing) is now
   expected within months. Clay alternatives C/D (smooth forcing) are
   essentially under active attack by Alpöge–Buckmaster + the OpenAI
   agent claim.
2. **Computer-assisted proof becomes standard.** Hou–Wang–Yang
   2509.25116 uses rigorous numerics for the linearized instability;
   Coiculescu–Palasek uses computer-checked functional-analytic
   estimates; OpenAI uses Lean. **All three of the top 2025–2026
   results involve computers in the verification step.** This is a
   major change from the 2000s-era NS regularity culture.
3. **Quantitative regularity / norm concentration.** Barker–Prange
   2023 flags this as still-progressing: explicit rates for supercritical
   norms, slight criticality breaking, Kolmogorov-scale concentration.
   This is the side of the field closest to our campaign's quantitative
   numerics.
4. **Non-uniqueness at critical regularity.** Coiculescu–Palasek
   Inventiones 2026 sharpens BV19 down to BMO⁻¹ (Koch–Tataru threshold).
5. **Component-reduction regularity criteria.** Miller's 2021 survey
   list of open endpoints (Besov, directional, vorticity components)
   is still open; some progress (Guo–Kučera–Skalák, Skalák, Zhang) but
   no clean resolution.
6. **Lean / autoformalization as a publication channel.** Tao and the
   Alpöge–Buckmaster group treat Lean formalization as part of the
   deliverable. For our 160-theorem Lean project, this is direct
   alignment.

---

## 5. Field pulse — honest assessment

**The field has just had its most significant six weeks in 25 years.**

- **Acceleration.** Three orthogonal attacks on Clay alternatives C/D
  (Alpöge–Buckmaster human papers, OpenAI agent announcement,
  Ganeshram–Duruisseaux–Anandkumar PINN) within a fortnight of each
  other; Coiculescu–Palasek Inventiones (Dec 2025) sharpens the
  non-uniqueness line to the critical space; Hou–Wang–Yang
  computer-assisted Leray-Hopf non-uniqueness (Sep 2025). The
  Córdoba–Martínez-Zoroa forced-blowup programme matured in 2024
  (2407.06776) and is now being generalized.
- **What it means for the Clay problem.** As of 10 Sep 2026 the
  community consensus (Tao blog: "widely expected") is that **a
  negative answer to Clay alternative D (forced blowup with smooth
  forcing) is imminent**, and a negative answer to alternative A
  (unforced blowup) is plausible on a longer horizon. The Clay
  Institute has **not** accepted any of these as resolutions of the
  prize problem.
- **What it means for our campaign.** Our setup (160 Lean theorems,
  Tao 2016 averaged-NS axiom, reproducible numerics, "self-contained")
  was perfectly aligned with the 2014–2024 stagnation reading. The
  Sep 2026 burst does **not** invalidate the truncated spectral
  scheme, but it does mean that *if* the Buckmaster–Alpöge /
  Coiculescu–Palasek / Hou–Wang–Yang programme completes, the field
  consensus will swing to "blowup is expected" and our axiom choice
  will be the one that needs defending rather than the one that
  encodes a clean detour.
- **Stagnation / decline vs. acceleration.** **Acceleration, sharply.**
  But: with one major caveat — the OpenAI claim is not yet verified,
  and there is a real chance (kingy.ai's coverage flags this) that
  independent assessment reveals gaps. The legitimate human-authored
  Alpöge–Buckmaster work is the surer bet.
- **Honest caveat.** I did not personally read 5–8 full papers. I read
  the Tao blog in full, the Barker–Prange / Miller / Coiculescu–Palasek
  abstracts and selected fragments, the Hou–Wang–Yang and Miao–Nie–Ye
  abstracts, and the Buckmaster publications list. Several of the
  2026 announcements (Alpöge–Buckmaster Boussinesq / IPM / Euler
  preprints, OpenAI Navier–Stokes PDF, Ganeshram–Duruisseaux–Anandkumar
  preprint) are at most a few days old; arXiv IDs and journal statuses
  may shift in coming weeks. The Córdoba Spanish-language Euler survey
  was not read. The web_extract tool failed repeatedly mid-session
  (only one successful extraction per call), so some content is
  second-hand from web_search snippets.

---

## 6. Citations for the campaign

Suggested minimal set if the campaign ever needs to position itself
relative to the field:

- **Field-orientation (most recent).** Tao blog 7 Sep 2026.
- **Quantitative regularity (campaign's home turf).** Barker–Prange
  2023, arXiv:2211.16215.
- **Geometric constraints on blowup.** Miller 2022, arXiv:2111.00040.
- **Non-uniqueness at critical regularity (newest published).**
  Coiculescu–Palasek, *Invent. math.* 244 (2026) 165–219,
  doi:10.1007/s00222-025-01396-z.
- **Forced blowup in NS-like models (the live frontier).**
  Córdoba–Martínez-Zoroa–Zheng, arXiv:2407.06776 (2024); Alpöge–
  Buckmaster preprints, Sep 2026.
- **Tao 2016 averaged-NS axiom (the campaign's irreducible
  assumption).** Tao, arXiv:1402.0290.