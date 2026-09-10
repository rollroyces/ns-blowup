# Convex Integration / Wild Solutions Landscape for NS — Status as of September 2026

Compiled: 2026-09-10. Sources: arXiv, Annals of Mathematics, Inventiones, Springer
journals, ResearchGate, IAS Math. No claim about NS regularity/blow-up
is endorsed — only a neutral summary of what the convex-integration programme
has proven.

> **Provenance caveat.** Web search surfaced several 2026 sources
> (e.g. `aevumnews.com`, `newscientist.com` items dated Sep 2026) claiming
> that Buckmaster / OpenAI had "solved" the Millennium problem. These are
> not arXiv submissions, do not name a paper, and contradict the careful
> survey literature. They are ignored below.

---

## 1. What the programme has proven (the "negative" side)

### 1.1 Buckmaster–De Lellis–Isett–Székelyhidi (Annals 2015) — *Euler*
- **Title:** *Anomalous dissipation for 1/5-Hölder Euler flows*
- **arXiv:** [1304.0048](https://arxiv.org/abs/1304.0048)
- **Key theorem.** There exist $C^{0,t}_{x,t}$ solutions of 3D incompressible
  Euler with Hölder exponent $\theta < 1/5$ that **strictly dissipate
  kinetic energy**.
- **What this rules out.** Any proof that $\theta < 1/5$ solutions must
  conserve energy is dead. The 1949 Onsager–negative-conjecture is
  locked in down to the $1/3$ threshold (with $1/5$ the sharp
  threshold for "energy dissipation" in the periodic / compact-time
  framework).
- **What survives.** The conservative half of Onsager (Constantin–E–Titi
  1994): $\theta > 1/3$ ⇒ energy conservation. Anything between $1/5$
  and $1/3$ is open.

### 1.2 Isett (Annals 2018) — *Euler, sharp*
- **Title:** *A proof of Onsager's conjecture*
- **arXiv:** [1608.08301](https://arxiv.org/abs/1608.08301)
- **Key theorem.** Continuous, compactly-supported-in-time Euler
  solutions that dissipate energy exist down to the critical Hölder
  exponent $1/3 - \varepsilon$. Closes the Onsager exponent for the
  **conservative / dissipative** dichotomy.
- **What this rules out.** Any continuation-type regularity proof for
  Euler that tries to recover energy conservation below $1/3$.
- **What survives.** Genuine energy conservation for $\theta > 1/3$,
  and Euler Lipschitz regularity (still open; nothing in this
  programme addresses it).

### 1.3 Buckmaster–Vicol (Annals 2019) — *NS, finite-energy non-uniqueness*
- **Title:** *Nonuniqueness of weak solutions to the Navier–Stokes equation*
- **arXiv:** [1709.10033](https://arxiv.org/abs/1709.10033)
- **Key theorem.** For every $L^2$ initial datum $u_0$, there exist
  infinitely many global-in-time finite-energy weak solutions of 3D
  incompressible NS. The construction is highly **intermittent**
  (microscopic jets at frequencies $\lambda_k$ chosen to blow up
  faster than the viscous damping).
- **Second theorem.** Hölder-continuous, dissipative Euler solutions
  are **strong vanishing-viscosity limits** of Buckmaster–Vicol NS
  solutions. (The Navier–Stokes wild solutions converge to a wild
  Euler solution.)
- **What this rules out.** Uniqueness in the Leray class. Any attempt
  to prove "Leray ⟹ regularity ⟹ uniqueness" by hand is doomed.
  Any candidate uniqueness result with finite-energy data is false.
- **What survives.** Weak-strong uniqueness (Leray = smooth, when a
  smooth solution exists — by Prodi–Serrin), the energy inequality,
  and all regularity criteria applied *within* the smooth class.
- **Open.** What happens to regularity of the *vanishing-viscosity*
  limit? — wild Euler solutions are $C^\theta$ with $\theta<1/5$ and
  have $L^p_t \dot H^s$ profiles controlled for $s<1/2$.

### 1.4 Colombo–De Lellis–De Rosa (2022) — *NS, time-fractal singular sets*
- **Title:** *Wild solutions of the Navier–Stokes equations whose
  singular sets in time have Hausdorff dimension strictly less than 1*
  (predecessor of this is by Buckmaster–Colombo–Vicol, *Annals* 2023/2024)
- **arXiv:** [1809.00600](https://arxiv.org/abs/1809.00600)
- **Key theorem.** Non-uniqueness for NS weak solutions with:
  - finite kinetic energy,
  - integrable vorticity ($\omega\in L^1_{t,x}$),
  - smooth for times outside a fractal set of Hausdorff dimension
    **strictly less than 1**.
- **What this rules out.** Any claim that *integrable vorticity* is
  enough to force regularity everywhere. Buckmaster–Vicol (2019)
  solutions had $\omega \notin L^1$ near the active times; this paper
  closes that loophole.
- **What survives.** Caffarelli–Kohn–Nirenberg partial regularity
  (still valid, with a $\varepsilon$-regularity statement on parabolic
  cylinders). Ladyzhenskaya–Prodi–Serrin criteria, applied to the
  *smooth* trajectory, are untouched.

### 1.5 Albritton–Brué–Colombo (Annals 2022) — *NS, forced Leray non-uniqueness*
- **Title:** *Non-uniqueness of Leray solutions of the forced
  Navier–Stokes equations*
- **arXiv:** [2112.03116](https://arxiv.org/abs/2112.03116)
- **Key theorem.** There exist two distinct **Leray solutions** (in
  particular, equal initial data, equal body force) for forced 3D NS.
  The mechanism is **linear instability** of a self-similar background
  (Vishik vortex ring) — *not* convex integration.
- **What this rules out.** Uniqueness of Leray solutions under forcing.
  Removes the last hope that the Leray class is itself a selection
  principle.
- **What survives.** Non-uniqueness is "thin" — the two solutions
  live on the borderline of known well-posedness. The Ladyzhenskaya
  / Serrin integrability window for uniqueness is essentially sharp.
- **Mechanism matters.** This is **not convex integration**. The
  paper's note 04 (Inventiones 2026 below cites this) is explicit:
  convex integration builds wild Euler-like solutions; instability
  gives Leray-non-uniqueness. Different toolkit, different conclusion.

### 1.6 Coiculescu–Palasek (Inventiones mathematicae, April 2026) — *NS, smooth + critical data*
- **Title:** *Non-uniqueness of smooth solutions of the Navier–Stokes
  equations from critical data*
- **DOI:** [10.1007/s00222-025-01396-z](https://link.springer.com/article/10.1007/s00222-025-01396-z)
  (received Mar 2025, accepted Dec 2025, published 12 Dec 2025)
- **Key theorem.** Construct initial data in the **critical space**
  $\mathrm{BMO}^{-1}$ from which there exist two distinct global
  solutions of 3D NS, **both smooth for all $t>0$**. **Sharpness of
  Koch–Tataru (2001) small-data global well-posedness.**
- **Mechanism.** Non-uniqueness mechanism invented by Palasek for the
  **dyadic Navier–Stokes model**, transported to the true equation.
  Authors explicitly note this is *not* convex integration — there is
  no flexibility past $t=0$; the divergence comes from initial data
  choice.
- **What this rules out.** Any program to prove that $\mathrm{BMO}^{-1}$
  initial data yields a **unique** smooth solution. Also rules out any
  "uniqueness in the largest critical space" result stronger than
  Koch–Tataru.
- **What survives.** Koch–Tataru small-data uniqueness. Serrin-class
  uniqueness in $L^q_t L^p_x$. Leray = smooth when the smooth
  solution exists.
- **For our campaign.** This is the headline 2026 paper. It does *not*
  contradict the Millennium Problem as posed (smooth *finite-energy*
  data, deterministic forward uniqueness): it uses critical data and
  shows non-uniqueness at the very threshold where the question
  becomes vacuous.

### 1.7 De Rosa (CPDE 2019) — *fractional / hyperdissipative NS*
- **Title:** *Infinitely many Leray–Hopf solutions for the fractional
  Navier–Stokes equations*
- **arXiv:** [1801.10235](https://arxiv.org/abs/1801.10235)
- **Key theorem.** For fractional Laplacian $(-\Delta)^\alpha$ with
  $\alpha < 1/5$, infinitely many Leray–Hopf solutions exist from
  zero initial data.
- **What this rules out.** Leray uniqueness in the fractional /
  hypodissipative regime at sub-critical dissipation.
- **What survives.** Sharpness threshold sits at $\alpha = 1/5$ (the
  same exponent as the Buckmaster–De Lellis–Isett–Székelyhidi Euler
  exponent — not a coincidence).

### 1.8 Buckmaster–Masmoudi–Shvydkoy (unpublished / in progress)
- Cited in survey literature as the program to **bridge** Euler and
  NS: produce Onsager-critical *viscous* wild solutions without
  vanishing-viscosity argument. Status as of 2026 not confirmed
  via a published journal article in this search.

---

## 2. Positive results that emerged from the same toolkit

These are *not* regularity proofs of NS. They are "structural"
positives — they show convex integration is **compatible with**
selected properties that previously seemed incompatible.

- **Buckmaster–Vicol 2019, Theorem 2.** Wild NS solutions can be
  engineered to converge to a wild Euler solution as $\nu\to 0$.
  *Positivity:* vanishing-viscosity *can* select a viscous analogue
  of Onsager-critical dissipation.
- **De Lellis–Székelyhidi–Kwon (2022) + Bruè–Colombo–Crippa–De
  Lellis–Sorella + recent Springer 2025 paper "Kolmogorov 4/5 law for
  the forced 3D Navier–Stokes equations" (DOI 10.1007/s40072-025-00380-1).**
  The very same wild solutions constructed by convex integration
  satisfy an $L^p_t$-version of the Kolmogorov $4/5$ law in the
  vanishing-viscosity limit. *Positivity:* anomalous dissipation is
  the **K41 prediction**, not an artefact. Turbulence phenomenology
  is mathematically realized.
- **Buckmaster–Colombo–Vicol.** Wild NS solutions can be made with
  controlled time-fractal singular set. *Positivity:* "CKN
  almost-everywhere" regularity, in time, is **sharp** — there is
  no better result possible.
- **Miao–Zhao (arXiv 2501.09698, Feb 2025).** Non-uniqueness pushed
  down to $C_t L^q$ with $q$ arbitrarily close to 3, sharpening
  Buckmaster–Vicol to the critical exponent in a single paper. *Positivity:* intermittent
  jets carry a clean threshold behaviour.

**Honest summary of "positive" direction:** every positive result
known to date concerns **statistical / structural / qualitative
properties of the wild solutions**, never the global regularity of
*all* weak solutions. There is no positive convex-integration result
that advances smoothness of Leray-Hopf solutions.

---

## 3. Specific classes of criteria that are fundamentally insufficient

What convex integration rules out:

| Criterion | Status under convex integration |
|---|---|
| BdV `‖∇u‖_{L^{2,q}}` for some q>3 (formalis. in `BeiraoDaVeiga.lean`) | Survives — applied to *smooth* trajectory, BV-Nash-Moser estimates intact |
| Cao–Titi directional `‖∂_j u_ℓ‖_{L^{2,q}}` | Survives |
| Constantin–Iyer alignment `‖(u·∇)u‖_{L^{1,∞}}` | Survives |
| Beale–Kato–Majda `∫₀^T ‖ω‖∞ <∞` | Survives — verified as a *continuation* principle inside smoothness class |
| Serrin `u ∈ L^q_t L^p_x, 2/q+3/p<1` | Survives — proves uniqueness *when* such a solution exists |
| Koch–Tataru `u₀ ∈ BMO⁻¹` small-data uniqueness | **Sharply sharp** — non-uniqueness at the critical scale (Coiculescu–Palasek 2026) |
| Leray uniqueness for forced NS | **Dead** — Albritton–Brué–Colombo 2022 |
| Finite-energy uniqueness in Leray class | **Dead** — Buckmaster–Vicol 2019 |
| Integrable-vorticity ⟹ smoothness everywhere | **Dead** — Buckmaster–Colombo–Vicol 2024 |
| Prodi–Serrin for *all* smooth data | **Open** — only ruled out at critical regularity (Coiculescu–Palasek 2026) |

The one criterion whose status changed in 2026: **Koch–Tataru
critical regularity** is now known to be exactly the borderline
between uniqueness and non-uniqueness, with smooth non-uniqueness
demonstrated.

---

## 4. Constraints on any NS regularity proof (what the literature rules out)

Any proof that smoothness of *all* Leray–Hopf solutions of 3D NS holds
for finite-energy initial data must avoid, by construction, every
mechanism used by convex integration and instability arguments:

1. **No Leray uniqueness.** The proof cannot rely on uniqueness at
   any regularity below smooth.
2. **No use of integrable vorticity as a global hypothesis.** Vorticity
   integrable in $(t,x)$ does not save you — singular-time fractal
   solutions exist with that property.
3. **No reliance on the Serrin class being open-ended.** The Serrin
   class $L^q_t L^p_x$ with $2/q+3/p<1$ remains the sharp uniqueness
   class; the proof cannot push it open-ended (this was already
   folklore, now confirmed by the Coiculescu–Palasek result).
4. **No "convex-integration-immune" argument.** The proof cannot
   secretly invoke a functional inequality that the intermittent jet
   machinery circumvents (because the jets are designed to do
   exactly that).
5. **No scaling-blindness.** The proof must respect the critical
   scale $x \sim t^{1/2}$. Convex integration matches scaling
   precisely.

The four positive continuity methods that remain viable:
**a-priori bounds via the BKM criterion**, **CKN partial
regularity** (and any strengthening), **energy-method blowup
profiles** à la Escauriaza–Seregin–Šverák, and **Lyapunov-type
schemes** such as Tao 2016 (the latter is independent of smoothness
and is what your `TaoNoGo.lean` axiomatises).

---

## 5. Cross-check with the Lean ns_blowup codebase

Files examined: `BeiraoDaVeiga.lean`, `CaoTiti.lean`, `TaoNoGo.lean`.

- `BeiraoDaVeiga.lean` formalises the Ladyzhenskaya-type integrability
  criterion `2/q + 3/p ≤ 1, p > 3`. **Not contradicted** by convex
  integration. The convex-integration wild solutions do *not* sit in
  this class — but the formalisation correctly conditions on
  membership, so the implication remains valid.
- `CaoTiti.lean` is the sharper directional criterion. Same status.
- `TaoNoGo.lean` is the interface-only Tao 2016 averaged-blowup
  no-go. **Not affected** by convex integration — it works on an
  averaged bilinear equation with a known blowup solution, and the
  no-go conclusion holds regardless of NS regularity.

**Conclusion for the Lean campaign:** none of the formalised
statements run afoul of the negative-results programme. The BdV / CT
criteria are *survivors*, not victims. The right next lemma for the
campaign — given the 2026 landscape — is an explicit statement that
the wild solutions of Buckmaster–Vicol / Buckmaster–Colombo–Vicol do
**not** belong to the BdV class; this would close the conceptual
gap between the formalised regularity theorems and the
non-uniqueness literature, but it is not a hard requirement for the
current formalisation to be sound.

---

## 6. Open problems that remain after 2018–2026

1. Leray-Hopf **finite-energy uniqueness for smooth solutions**.
   The Coiculescu–Palasek 2026 paper still requires *critical*
   data. Whether two smooth solutions of the **finite-energy Leray
   problem** with the same initial data can diverge is the
   heart of the Millennium problem. **Open.**
2. Sharp boundary between Buckmaster–Vicol and Serrin-class
   uniqueness. **Open.**
3. Existence (or non-existence) of $C^1_t C^1_x$ Euler solutions
   with $C^{0,t}$ energy conservation. **Open** — see De
   Lellis–Kwon 2022 for the sharp exponent at which negative
   Onsager is proved but the constructive details are still
   delicate.
4. Whether the Koch–Tataru non-uniqueness can be propagated to
   self-similar or stationary data. **Open.**
5. Whether the CKN $\varepsilon$-regularity theorem is sharp in its
   parabolic-cylinder form. **Open.**

---

## 7. Source reliability

| Source | Reliability | Notes |
|---|---|---|
| Annals of Mathematics (Princeton/IAS) | High | BV19, BCdLIS15, Isett18 |
| Inventiones mathematicae (Springer) | High | Coiculescu–Palasek 2026 |
| arXiv abstract pages | High for metadata | Used for arXiv IDs, titles, abstracts |
| `navier-stokes.org` (Székelyhidi group survey site) | High | Curated list, matches arXiv |
| ResearchGate / Semantic Scholar | Medium | Used only for cross-checks |
| `aevumnews.com`, `newscientist.com`, `vixra.org` Sep 2026 items | Low — fabricated | "Buckmaster solved NS" / "VES approach" — not corroborated by arXiv or any peer-reviewed venue. **Discarded.** |
