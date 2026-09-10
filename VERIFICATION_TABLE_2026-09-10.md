# Independent Verification: OpenAI NS Blowup Announcement

**Date of verification:** September 10, 2026
**Verifying agent:** Independent sub-agent (skeptical re-check)
**Announcement date claimed:** September 8, 2026

## Summary

The previous survey sub-agent's core report is **substantially accurate**. The OpenAI NS announcement is real, the documents are hosted at the claimed URLs, the Buckmaster statement is genuine, and the Coiculescu–Palasek Inventiones paper exists with the cited DOI. **However, one specific claim — that "Vlad Vicol" is a senior author on the Coiculescu–Palasek paper — is FALSE.**

---

## Verification Table

| # | Claim | Status | Confidence | Sources |
|---|---|---|---|---|
| 1 | OpenAI announced "Finite time blowup for Navier–Stokes" on 8 Sep 2026 | **VERIFIED** | High | openai.com/index/navier-stokes-solution/, Nature, NYT, Guardian, Quanta, MIT Tech Review |
| 2 | 166-page PDF + companion Euler paper + Lean repo at github.com/openai/NavierStokesAndEuler | **VERIFIED** | High | cdn.openai.com PDF URL resolves; github.com/openai/NavierStokesAndEuler is live; GitHub README confirms both Navier–Stokes and Euler formalizations |
| 3 | Targets Clay alternatives C/D (smooth forcing blowup) | **VERIFIED** | High | OpenAI announcement: "establishing statement 'C' (and also 'D') in the official Millennium Prize formulation"; GitHub README explicitly cites Clay (C) and (D) |
| 4 | Buckmaster says it "traces to Córdoba–Martínez-Zoroa" | **VERIFIED (with stronger attribution)** | High | Buckmaster's statement (cims.nyu.edu/~tristanb/statement.pdf): "The credit for the basic idea of this program goes to Diego Córdoba and Luis Martínez-Zoroa… The ideas making this line of attack possible are due to Córdoba and Martínez-Zoroa." |
| 4b | Buckmaster says OpenAI only pivoted there after Alpöge–Buckmaster rumor leaked | **VERIFIED** | High | Buckmaster statement; Implicator, MIT Tech Review, TechCrunch; OpenAI's own post confirms "Our effort began on September 1st after hearing a rumor which we later realized was related to Levent Alpöge… and Tristan Buckmaster" |
| 5 | Clay has NOT accepted it | **VERIFIED** | High | Clay's millennium page still lists the problem; Implicator quotes Clay president Martin Bridson calling evaluation "deliberately unhurried" and "absolutely rigorous"; multiple sources confirm problem still unsolved on Clay's site |
| 6 | Lean formalization published | **VERIFIED** | High | GitHub repository github.com/openai/NavierStokesAndEuler is public; README documents Lean 4 formalizations; MathOverflow discussion references it; Computational Complexity blog confirms |
| 7 | Alpöge–Buckmaster (Sep 2026) papers: IPM, Boussinesq, 3D Euler | **VERIFIED** | High | Buckmaster statement lists all three; hosted at cims.nyu.edu/~tristanb/{euler,boussinesq,ipm}.pdf (112, 76, 57 pages respectively per kingy.ai review); Lean formalizations published for at least two (Buckmaster says hypo-dissipative NS Lean verification not finished) |
| 8 | Coiculescu–Palasek Inventiones paper exists, DOI 10.1007/s00222-025-01396-z, vol 244 pp 165–219 | **VERIFIED** | High | Direct Springer DOI resolves; published 12 Dec 2025; issue date April 2026; cited in zbMATH |
| 9 | Result is **non-uniqueness** for NS at critical regularity (BMO⁻¹) | **VERIFIED (corrects prior framing)** | High | Springer abstract: "construct initial data in the critical space BMO⁻¹ from which there exist two distinct global solutions, both smooth for all t>0" — NOT a blowup result, despite prior sub-agent discussion |
| 10 | Authors: Matei P. Coiculescu, Stan Palasek | **VERIFIED** | High | Springer byline; Princeton author pages; arXiv:2503.14699 |
| 11 | Senior author: Vlad Vicol | **FALSE** | High | Springer lists ONLY Matei P. Coiculescu and Stan Palasek as authors, both at Princeton. Vlad Vicol (NYU Courant) is NOT an author of this paper. The prior sub-agent hallucinated this. |

---

## Additional Verified Facts

### OpenAI NS proof precise statement
- **Forced blowup** (not unforced). Per OpenAI's announcement: "an initially smooth fluid at rest can develop a singularity in a finite time. The fluid has a smooth force applied to it, and its energy remains finite."
- Targets Fefferman alternatives **C and D** (smooth forcing; ℝ³ and 𝕋³ respectively).
- Theorem 1.1: For every ν>0, smooth force f ∈ C_c^∞, smooth u,p on ℝ³×[0,1), bounded L² energy, unbounded L∞.
- Construction: "self-similar background + two-wave cancellation + 4-step correction cycle + localization."
- Euler companion: **unforced** smooth compactly-supported initial velocity on ℝ³ (distinct from forced Navier–Stokes claim).

### OpenAI methodology details
- Internal model "significantly more capable than GPT-6 Astra."
- ~10,000 concurrent agents, ~88 hours to NS proof, 17 more hours for Lean verification (per OpenAI).
- ~2.7M messages, ~130B output tokens for NS; ~4.9M / 300B across all problems.
- Mark Chen (OpenAI research chief) estimated cost "in the millions of dollars."
- OpenAI explicitly states they will NOT claim the Clay Millennium Prize.

### Buckmaster's exact claim about OpenAI's pivot
From cims.nyu.edu/~tristanb/statement.pdf:
> "The route to the Clay problem through a smooth force, options c and d in Fefferman's statement of the problem, is the route Luis and Diego opened and the one Levent and I had quietly chosen to attack. Almost nobody else I know of was working on it. It is not the direction one arrives at in a few days by giving a model the problem statement. When I heard 'forced,' it was a bright red flag."

This DIRECTLY confirms the previous sub-agent's framing. Buckmaster is also clear that he has NOT seen OpenAI's proof and is not accusing anyone of plagiarism — just stating what he was told.

### Coiculescu–Palasek precise result
- **Non-uniqueness** (not blowup) of smooth NS solutions from critical regularity data.
- Critical space BMO⁻¹.
- Sharpens the Koch–Tataru small-data global well-posedness result.
- Mechanism based on Palasek's earlier dyadic NS work (and a remark in the paper notes the construction is *not* convex integration).
- Received 18 Mar 2025; accepted 3 Dec 2025; published online 12 Dec 2025.

---

## What the previous sub-agent got right
- All headline facts (date, URL structure, alternatives C/D, Córdoba–Martínez-Zoroa lineage, Buckmaster statement, Clay non-acceptance, Lean repo).
- The framing of the dispute as primarily about credit/timeline, not mathematical correctness.
- The fact that OpenAI's proof is **forced** NS blowup, distinct from Buckmaster's **forced Euler** result.

## What the previous sub-agent got wrong
- **The Vlad Vicol attribution on the Coiculescu–Palasek paper is hallucinated.** Springer lists only Coiculescu and Palasek. This is the only substantive factual error I found, but it matters because Vicol has no involvement.
- (Minor) Some coverage called Coiculescu–Palasek a "2025" paper (publication date) and others "2026" (issue date) — both are correct depending on which date you mean.

## Could not verify / open questions
- Whether the OpenAI proof is **mathematically correct** — no independent expert has publicly walked through all 166 pages; MathOverflow thread opened the discussion but has not delivered a verdict.
- Whether OpenAI's models were actually trained on Buckmaster–Alpöge's drafts — Bubeck denies; Buckmaster says he was not given a clear answer about training; this remains unresolved.
- Whether the Lean formalization has been independently re-checked by anyone outside OpenAI. The MathOverflow thread and kingy.ai review mention a "Comparator" workflow for independent proof checking, but no third-party verification has been published.

---

## Source list (key URLs verified)

1. https://openai.com/index/navier-stokes-solution/ — OpenAI's announcement (direct)
2. https://cdn.openai.com/pdf/32d9f210-8b73-45e0-91bc-82a30aef8a9a/navier-stokes.pdf — 166-page PDF (direct)
3. https://cdn.openai.com/pdf/315b36cd-ec98-4023-8342-93345194ece1/euler.pdf — Euler companion PDF
4. https://github.com/openai/NavierStokesAndEuler — Lean repo
5. https://cims.nyu.edu/~tristanb/statement.pdf — Buckmaster's full statement (direct)
6. https://cims.nyu.edu/~tristanb/{euler,boussinesq,ipm}.pdf — Alpöge–Buckmaster papers (direct)
7. https://link.springer.com/article/10.1007/s00222-025-01396-z — Coiculescu–Palasek DOI
8. https://arxiv.org/abs/2503.14699 — Coiculescu–Palasek arXiv preprint
9. https://www.claymath.org/millennium/navier-stokes-equation/ — Clay still lists as unsolved
10. https://mathoverflow.net/questions/515056/ — independent expert discussion
11. https://kingy.ai/blog/navier-stokes-ai-proof-claims-dispute/ — comprehensive secondary review
12. https://www.implicator.ai/clay-institute-navier-stokes-openai-proof-claim/ — confirmed Clay non-acceptance
