# Post-2016 Search: Constructive Use of Tao's Averaged-NS No-Go

**Project:** `ns_blowup/`
**Date:** September 2026
**Scope:** Search for any post-2016 paper that combines Tao's averaged-NS no-go result with a *constructive* regularity argument (i.e. uses non-HA+energy structure, not just refines the no-go negatively).

---

## TL;DR — Honest Answer to the Hypothesis

**The hypothesis as stated ("someone has since proposed a constructive argument using non-TAO structure") is *not* supported by the literature in its strong form.** No post-2016 paper has produced a constructive regularity proof for the un-averaged 3D NS that explicitly invokes Tao's no-go as a starting point.

What *has* happened, in roughly decreasing relevance to the hypothesis:

1. **Sept 2026 (very recent):** The community has essentially *abandoned the constructive-regularity programme*. Buckmaster–Alpöge (2026) have announced finite-time blowup for the unforced **3D Euler** equation using the Córdoba–Martínez-Zoroa (2024) iterative "background + high-frequency plane wave" ansatz, with Tao confirming this is the new dominant approach. Tao's averaging machinery is being **inverted**: rather than use the no-go to design a regularity proof, the field now uses Tao's cascade-as-blowup ideas *positively* to produce blowup examples for related equations. For NS itself the problem remains open as of Sept 2026 (navier-stokes.org: "2026: Open").
2. **Tao 2019 (quantitative ESS)** is Tao's only direct follow-up that uses NS-specific structure (Carleman inequalities) — this is a *quantitative refinement* of the ESS $L^3$ regularity criterion, not a constructive proof that any new criterion holds for all smooth ICs.
3. **Lange 2022** is the only paper in the dataset that takes Tao's averaged NS *positively* (tries to "fix" it via stochastic transport noise). Result: **negative** — the continuity/growth/local-monotonicity conditions needed for the Flandoli–Galeati–Luo regularization theory *fail* for the averaged NS on the velocity level. Gives a lower bound on the *order* of derivatives needed, no full regularization.
4. **Coiculescu 2023** is the only post-2016 paper that explicitly proposes a *Tao-averaged-equation analogue of CKN-style partial regularity* — but the partial regularity theorem was *weakened* during revision (after an error was found), and it now applies only to the hyperdissipative range $\alpha \in ((n+1)/4, (n+2)/4)$. The companion blowup result covers *all* $\alpha \in (0, 5/4)$. Net message: "improving partial regularity will not solve NS regularity; you need specific nonlinearity structure."
5. **Buckmaster–Vicol 2019** and **Buckmaster–Colombo–Vicol 2018** (joint convex integration) are about *non-uniqueness of weak solutions*. They use Tao's averaged blowup as a conceptual ancestor (cf. "intermittent convex integration") but **do not** provide any constructive regularity criterion. Their message is the opposite: NS has *too many* weak solutions, so regularity (if true) must come from restricting to *smooth* solutions with structural conditions (Serrin, ESS $L^3$, signed pressure, etc.).

**Bottom line for the campaign:** The Lean `tao_averaged_blowup` axiom correctly formalises a real and presently uncontested barrier. No post-2016 paper has *defeated* this barrier. Any future regularity proof MUST use non-HA+energy structure (the corollary to Tao 2016 still holds), and the most likely route is the structural / Serëgin-type / $L^3$-type regularity program, not a constructive scheme on the truncated spectral NS.

---

## Paper-by-Paper Inventory (Read 7 + cited 3)

### 1. Tao 2019 — Quantitative bounds for critically bounded solutions
- **Authors / venue / year:** Terence Tao; arXiv:1908.04958 (v2 10 Jul 2020); Analysis of PDEs.
- **What non-TAO structure it uses:** Carleman inequalities for backwards uniqueness / unique continuation of the heat equation. Replaces compactness-method profile decomposition with quantitative substitutes.
- **Specific criterion:** If a classical NS solution satisfies $\|u\|_{L^\infty_t L^3_x} \le A$, then for $0 < t \le T$ and $j=0,1$:
  $$|\nabla_x^j u(t,x)| \le \exp\exp\exp(A^{O(1)}) \, t^{-(j+1)/2}, \quad |\nabla_x^j \omega(t,x)| \le \exp\exp\exp(A^{O(1)}) \, t^{-(j+2)/2}.$$
  And the blowup criterion: if $T_* < \infty$, then
  $$\limsup_{t \to T_*^-} \frac{\|u(t)\|_{L^3_x}}{(\log\log\log \tfrac{1}{T_* - t})^c} = +\infty$$
  for an absolute constant $c > 0$.
- **Claim of regularity for all smooth ICs?** **No.** This is a *quantitative refinement* of the ESS (Escauriaza–Seregin–Šverák 2003) endpoint of the Prodi–Serrin–Ladyzhenskaya criterion. The bound is *triple-exponential*, so it does not give regularity from $L^3_t L^3_x$ alone (only $L^\infty_t L^3_x$), and the blowup-rate is a *lower* bound on how fast $L^3$ must blow up — it does not prove blowup.
- **Relevance to our hypothesis:** Tao's *only* post-2016 NS paper that uses specific NS structure. It reinforces, rather than defeats, the no-go: the analysis is still *quantitative* blowup criterion, not a *constructive* regularity proof for arbitrary smooth ICs.

### 2. Buckmaster–Vicol 2019 — Nonuniqueness of weak solutions (Buckmaster 2021 Bulletin)
- **Authors / venue / year:** Tristan Buckmaster, Vlad Vicol; Annals of Math. 189 (2019), 101–144 (arXiv:1709.10033). Review: AMS Bulletin 58 (2021), 1–44.
- **What non-TAO structure it uses:** *Convex integration*, building "Mikado flows" with intermittent Beltrami building blocks in Sobolev spaces. Does *not* use HA+energy in the standard sense — it explicitly produces solutions that violate the energy equality.
- **Specific criterion:** Non-uniqueness of Leray–Hopf weak solutions (finite kinetic energy, satisfying the energy inequality). Constructed solutions can fail the energy equality (anomalous dissipation).
- **Claim of regularity for all smooth ICs?** **No.** Opposite message: NS weak solutions are wildly non-unique. *If* regularity is to hold, it must be proved for the *smooth* solutions, with the smoothness hypothesis being load-bearing.
- **Relevance to our hypothesis:** Uses Tao's averaged-equation as a conceptual ancestor (Tao cascade → convex integration pipeline). The Buckmaster–Vicol 2021 Bulletin review explicitly credits "Tao's earlier averaged-equation blowup" as a precursor. But the *technique* — convex integration — is the most anti-constructive tool in the field: it produces solutions *without* controlling them.

### 3. Buckmaster–Colombo–Vicol 2018/2022 — Wild solutions with fractal singular time set
- **Authors / venue / year:** Tristan Buckmaster, Maria Colombo, Vlad Vicol; arXiv:1809.00600 (v2 8 Jul 2020); JEMS 24 (2022), 3333–3378.
- **What non-TAO structure it uses:** Joint convex integration (extends Buckmaster–Vicol to produce *two* distinct weak solutions with bounded energy, integrable vorticity, smooth outside a fractal singular set in *time* of Hausdorff dimension $< 1$).
- **Specific criterion:** Non-uniqueness among weak solutions whose singular set in time has Hausdorff dimension $< 1$ (compatible with CKN).
- **Claim of regularity for all smooth ICs?** **No.** Strictly weaker than full regularity — produces Leray–Hopf solutions, not smooth ones.
- **Relevance to our hypothesis:** "Joint convex integration" line — confirms that convex integration has matured into a multi-author program, but still no constructive regularity.

### 4. Lange 2022 — Regularization by noise of an averaged NS
- **Authors / venue / year:** Theresa Lange; arXiv:2205.14941 (30 May 2022); Probability / Analysis of PDEs.
- **What non-TAO structure it uses:** **Stochastic transport noise** (Flandoli–Franco–Luo 2021; Flandoli–Galeati–Luo 2021). Adds a *Stratonovich* transport perturbation to the averaged Tao equation.
- **Specific criterion:** Tests whether the three Flandoli–Luo conditions (continuity, growth, local monotonicity) hold for the *averaged* NSE on $\mathbb{T}^3$ (after periodising the averaged NSE blowup result).
- **Claim of regularity for all smooth ICs?** **No — negative result.** Lange proves:
  1. The averaged-NS blowup result of Tao 2016 *carries over* to the periodised torus $\mathbb{T}^3$.
  2. The three Flandoli–Luo conditions fail on the velocity level (analogous to true NS).
  3. A *lower bound* on the order of Sobolev derivatives needed for regularization is given.
  No global existence result for stochastic averaged-NS is established.
- **Relevance to our hypothesis:** **Most directly relevant paper to our question.** It is the *only* paper in the dataset that asks "what additional structure (here: stochastic noise) can prevent the Tao blowup?" Answer: standard transport noise does not suffice; the failure mode is precisely the same as for the true NS.
- **Implication for our Lean axiom:** Reinforces `tao_averaged_blowup`. Even adding stochastic transport noise does not recover regularity for the averaged equation. The barrier is robust.

### 5. Coiculescu 2023 — Partial regularity and blowup for averaged NS
- **Authors / venue / year:** Matei P. Coiculescu; arXiv:2307.15986 (v4 8 Sep 2024); Analysis of PDEs.
- **What non-TAO structure it uses:** Defines a *class* of bilinear operators $\mathfrak{B}$ containing the Euler bilinear operator, and proves (1) a *partial regularity* result for the pseudodifferential equation $\partial_t u + (-\Delta)^\alpha u + B(u,u) = 0$ for $B \in \mathfrak{B}$, $\alpha \in ((n+1)/4, (n+2)/4)$; and (2) a *blowup* result for $\alpha \in (0, 5/4)$ for a *specific* $C \in \mathfrak{B}$ that satisfies the Tao cancellation identity $\langle C(u,u), u \rangle = 0$.
- **Specific criterion:** Partial regularity for the averaged pseudodifferential equation in the *hyperdissipative* range $\alpha \in ((n+1)/4, (n+2)/4)$, with singular set of Hausdorff dimension at most $n + 2 - 4\alpha$.
- **Claim of regularity for all smooth ICs?** **No.** Crucial caveat from the v4 comments: the original partial regularity result had an error and was *weakened* using an "energy-barrier" construction. The theorem now applies only to the hyperdissipative range, not to the standard $\alpha = 1$ NS case. The blowup companion result *strengthens* the no-go to *all* $\alpha \in (0, 5/4)$.
- **Relevance to our hypothesis:** Most "constructive" post-2016 follow-up. But the *net* message is the opposite of constructive: "improving partial regularity will not solve NS regularity unless you use more specific structural properties of the NS nonlinearity." This is essentially a *sharpening* of Tao's no-go message, not a defeat of it.

### 6. Jin–Zhou 2018 (withdrawn) — Finite time blowup for a simple model NS
- **Authors / venue / year:** Zhentao Jin, Yi Zhou; arXiv:1811.09394 (v1 23 Nov 2018); withdrawn 15 Dec 2018.
- **What non-TAO structure it uses:** A simple model NS in space dimensions $n \ge 5$, retaining the energy identity.
- **Specific criterion:** Finite-time blowup with energy conservation, but only in $n \ge 5$.
- **Claim of regularity for all smooth ICs?** **No.** Negative result for $n \ge 5$ only — explicitly cites prior results by Du–Lv 2009 (Chinese Annals) and Plecháč–Šverák 2003 (Nonlinearity) as prior art.
- **Relevance to our hypothesis:** None for our purposes — withdrawn, no new constructive tool.

### 7. Buckmaster–Alpöge 2026 + Córdoba–Martínez-Zoroa 2024 — Finite-time blowup for unforced 3D Euler (with Tao commentary, Sept 2026)
- **Authors / venue / year:**
  - Córdoba–Martínez-Zoroa (foundational), arXiv:2410.22920v3, Oct 2024.
  - Levent Alpöge (Anthropic) and Tristan Buckmaster (NYU/Courant), Sep 2026 (preprints being finalised, forced early release).
  - Tao's summary commentary on his What's New blog, 7 Sep 2026.
- **What non-TAO structure it uses:** The Córdoba–Martínez-Zoroa "background + high-frequency plane wave" iterative construction. The "background" $u_{\text{lo}}$ is designed so that the linearised operator $N'(u_{\text{lo}})$ has an *instability* in which a perturbation $u_{\text{hi}}$ starts exponentially small and grows large near the blowup time. For Boussinesq, the ansatz is explicit: $u_{\text{lo}}$ linear in space, $u_{\text{hi}}$ a high-frequency plane wave, exactly solvable. AI-assisted Lean formalisation is also being attempted.
- **Specific criterion:** Finite-time blowup with smooth forcing term for the **incompressible porous medium (IPM)** equation, the **2D Boussinesq** equation, and (most relevantly for our project) the **unforced 3D incompressible Euler** equation. *Not yet* the unforced 3D NS, but Tao writes: "it has a high likelihood of also extending to Navier-Stokes as well." Independent preprint by Ganeshram–Duruisseaux–Anandkumar (Sept 2026) attacks the same goal via PINN-discovered self-similar profiles.
- **Claim of regularity for all smooth ICs?** **Opposite direction.** This is a *blowup* result, not a regularity result. It uses Tao-averaging-style *cascade* ideas *positively* to construct singularities.
- **Relevance to our hypothesis:** This is the **most important post-2016 development**. It represents the *paradigm shift* away from "find a constructive regularity proof" toward "construct the blowup explicitly." For the `ns_blowup` campaign:
  - The Tao-averaged cascade (originally a *negative* result) is being reused as the *positive* skeleton of an explicit blowup construction for related equations.
  - The 3D NS unforced problem remains open as of 7 Sep 2026.
  - Tao's 2016 averaged-blowup machinery is the direct intellectual ancestor of the 2026 Euler-blowup machinery.

### 8. Buckmaster–Vicol 2021 Bulletin — Convex Integration Constructions in Hydrodynamics (review)
- **Authors / venue / year:** Buckmaster, Vicol; AMS Bulletin 58 No. 1 (Jan 2021), 1–44.
- **What non-TAO structure it uses:** Review of the three flavours of convex integration (De Lellis–Székelyhidi $L^\infty_{t,x}$; Nash–Kuiper $C^\alpha_{t,x}$; intermittent Lebesgue-space).
- **Specific criterion:** Survey, no new criterion. Notes that convex integration is *anti-regularity*: it produces solutions *without* controlling their smoothness.
- **Claim of regularity for all smooth ICs?** **No.**
- **Relevance to our hypothesis:** Confirms that the joint-convex-integration line has matured into a *review article* (Buckmaster–Vicol 2021) and a *book* (Buckmaster 2023, "Convex Integration Methods in PDE"). This is now an established sub-field, not a new tool for regularity.

---

## What Has Not Been Found

- **No paper that takes Tao's no-go as input and uses *specific NS nonlinearity structure* (e.g., vorticity stretching, helicity conservation, Biot–Savart, Serrin-type condition) to prove a *constructive regularity criterion for all smooth ICs*.**
- **No refinement of Tao's averaging operator that "saves" regularity.** Every post-2016 attempt (Lange 2022 noise; Coiculescu 2023 partial regularity for averaged NS; Jin–Zhou 2018 model in high dimensions) either confirms the no-go or weakens the result.
- **No use of Tao's insight *positively for regularity* on the true NS.** The closest is Tao's own 2019 quantitative ESS refinement, which is a *quantitative blowup rate* rather than a constructive regularity result.
- **Isett's "H¹ perturbations" line** (Isett 2018 "non-conservative H¹ perturbations") is cited in the Buckmaster–Vicol convex-integration review as part of the convex-integration pipeline; it is *anti-regularity*, not for-constructive-regularity.

---

## Recommended Citation in `ns_blowup` Documentation

The most directly relevant citations for the **Tao 2016 no-go barrier** sub-section of `ns_blowup` documentation are:

1. **Tao 2019 (arXiv:1908.04958)** — Tao's own quantitative follow-up. Reinforces the barrier.
2. **Lange 2022 (arXiv:2205.14941)** — Direct test of "can we beat the no-go with stochastic noise?" Answer: no, on the velocity level. Most directly relevant to the campaign's TaoNoGo.lean interface.
3. **Coiculescu 2023 (arXiv:2307.15986)** — The only post-Tao paper that tries a *positive* structural analysis of the averaged equation. Result: *partial regularity only in the hyperdissipative regime*; blowup for the standard regime.
4. **Buckmaster–Alpöge 2026 + Córdoba–Martínez-Zoroa 2024 (Sept 2026)** — Latest paradigm shift. Uses cascade ideas *positively for blowup* on related equations; NS unforced remains open.
5. **Buckmaster–Vicol 2019 (Annals) / 2021 (Bulletin)** — Joint convex integration programme. Opposite direction (non-uniqueness, not regularity).

---

## Concrete Next Steps for the Campaign

Given this survey, the campaign's existing strategy (formalise the Tao 2016 no-go in Lean via `tao_averaged_blowup`) remains the correct framing. Specifically:

1. **Add a survey section to `TAO_2016_NOGO.md`** referencing the post-2016 literature above. This strengthens the *motivating context* for `tao_averaged_blowup` as an axiom: not just "Tao proved this in 2016," but "Tao's result has been *tested* six times in 2017–2026 and remains the most direct statement of the barrier."

2. **Cite Lange 2022 explicitly** in the docstring of `tao_averaged_blowup`. Lange proves the no-go carries over to the torus and survives adding stochastic transport noise — i.e. the barrier is *robust*. This makes the axiom less arbitrary: it is the best available sharp form of the obstruction.

3. **Note the Sept 2026 paradigm shift.** The Buckmaster–Alpöge / Córdoba–Martínez-Zoroa work shows the field is now investing in *constructive blowup*, not constructive regularity. For the campaign's positioning, this is a strong argument that a *Lean-formalised regularity criterion* (even a partial one like CKN or ESS) is exactly the missing piece that the field needs but no one has produced.

4. **Reconsider the "Onsager-critical truncation" target** (LITERATURE_SURVEY.md §4) in light of Lange 2022 and Coiculescu 2023. Both papers strengthen the case that *abstract* schemes (spectral, averaged) cannot be used to prove regularity — so a *computational confirmation of CKN-style partial regularity* is exactly the right kind of result. No new work needed on the recommended sub-problem.

---

*Survey compiled for `ns_blowup/` at `/Users/hermes/.hermes/projects/ns_blowup/`.*
*Wall-clock time: ~15 minutes. Web-search driven; arXiv abstracts and Tao's blog post read in full; AMS Bulletin review (Buckmaster–Vicol 2021) read in full.*
