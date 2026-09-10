# FINAL SUBMISSION GUIDE — arXiv submission

**Status (2026-09-10):** Manuscript, Lean code, and supporting documentation are all ready for arXiv submission.

---

## 1. What we are submitting

**Title:** "Lean~4 Formalization and Reproducible Empirical Study of the Hou--Luo Navier--Stokes Blowup Candidate on Apple Silicon: A Spectral Investigation with 170 Proved Theorems"

**Author:** Royce

**Co-author:** Hermes Agent (computational infrastructure) — *acknowledge in arXiv metadata*

**Primary category:** `math.NA` (Numerical Analysis)

**Cross-list categories:** `cs.LO` (Logic in Computer Science), `physics.flu-dyn` (Fluid Dynamics)

---

## 2. Files to upload to arXiv

### Required

- `manuscript/MANUSCRIPT.pdf` — 11 pages, 120 KB, recompiled just now
- `manuscript/MANUSCRIPT.tex` — LaTeX source for indexing

### Optional supplementary (recommended)

You can upload the Lean code as a single `.tar.gz` archive:

```bash
cd /Users/hermes/.hermes/projects/ns_blowup
tar czf ns_blowup_lean_v1.tar.gz lean_project/
# Upload this as "ancillary file" in arXiv
```

This lets readers reproduce the Lean verification:
- 12 files, 6248 lines
- 170 theorems, 0 sorries, 1 axiom
- `lake build` succeeds with 8919 jobs

---

## 3. Manuscript state (verified)

| Metric | Value |
|---|---|
| Lean files | **12** |
| Theorems | **170** |
| Sorries | **0** |
| Axioms | **1** (only `tao_averaged_blowup` in TaoNoGo.lean) |
| Lines | **6,248** |
| `lake build` | ✓ 8919 jobs |
| `MANUSCRIPT.pdf` | ✓ 11 pages, 120 KB |
| Date | 2026-09-10 |

All 12 file entries in Section 7 match actual state. Title, abstract, Section 6 (Limitations), and Section 7 (Conclusion) totals are all consistent.

---

## 4. Honest scope of what is published

**What this work IS:**

- A Lean 4 / Mathlib 4 formalization of the truncated spectral NS scheme (12 files, 170 theorems)
- A reproducible empirical study at $N \in \{64, 128, 192\}$, $T \leq 0.15$
- A documentation of the Tao 2016 no-go interface (1 irreducible axiom)
- A discrete-to-continuous bridge file (one concrete Lean step on the $L^2$ side)
- An empirical observation ($\alpha_\theta \in [0.7, 2.4]$ for alignment tightening) that has no published analytic counterpart

**What this work is NOT:**

- A solution to the Clay Millennium problem (officially open as of 10 Sep 2026)
- A direct contribution to the OpenAI / Alpöge--Buckmaster forced-blowup claims
- A proof of NS regularity (or NS blowup)
- A claim that our work is closer to Clay than it is

The abstract, Section 6 (Limitations), and Section 7 (Conclusion) all make this scoping explicit.

---

## 5. arXiv submission steps

1. Go to **https://arxiv.org/submit**
2. Sign in (or create a free arXiv account if you don't have one)
3. **Categories**:
   - Primary: **math.NA**
   - Cross-list: **cs.LO** (Logic in CS), **physics.flu-dyn** (Fluid Dynamics)
4. **Title**: copy from `manuscript/MANUSCRIPT.tex` line 8-10
5. **Authors**: Royce, Hermes Agent (computational infrastructure)
6. **Abstract**: copy from `manuscript/MANUSCRIPT.tex` abstract block
7. **Comments**: "170 proved theorems across 12 Lean files. Source code: https://github.com/rollroyces/ns-blowup"
8. **Upload files**:
   - `MANUSCRIPT.pdf` (required)
   - `MANUSCRIPT.tex` (source, recommended)
   - Optional: `ns_blowup_lean_v1.tar.gz` (Lean supplementary)
9. **License**: CC-BY 4.0 (recommended for open science)
10. **Submit**

Endorsement (for math.NA): if you don't have one, arXiv auto-requests it; turnaround is 1-3 days.

---

## 6. After submission

- arXiv assigns a paper ID (e.g., `2026.NNNNN`) within 1-2 business days
- Watch email for endorsement decision
- Share link on MathOverflow, Twitter/Mastodon, r/math, etc.
- (Optional) Submit to a journal: J. Comput. Phys., J. Fluid Mech., SIAM J. Numer. Anal.

---

## 7. What this work enables for future campaigns

The campaign has produced:

1. **160 + 10 theorems of formal Lean infrastructure** for the truncated spectral NS scheme
2. **9 literature integration files** documenting the 2018-2026 field state (see `LITERATURE_2026.md`)
3. **A precise bottleneck identification** (`CLAY_BOTTLENECK_2026.md`) — the dyadic closure estimate with uniform margin
4. **Honest framing** that survives community scrutiny

The next researcher who wants to work toward Clay has:

- A clean Lean formalization to build on
- A literature map showing what's been tried
- A precise statement of what's missing (the closure estimate)
- A reference benchmark (the empirical $\alpha_\theta$ finding) that any new regularity criterion should reproduce in the discrete setting

This is the kind of "preceding infrastructure" that, while not solving Clay, makes the next attempt easier.

---

## 8. Final commit on GitHub

**Commit hash:** `fd8e663`

**GitHub:** https://github.com/rollroyces/ns-blowup (public)

**Branches:** main (1 commit ahead of origin at time of writing, but no uncommitted changes)

---

## 9. Contact

If anything in the manuscript needs adjustment before submission:

- Title, abstract, author block — edit `manuscript/MANUSCRIPT.tex` lines 8-10 and abstract
- File entries — edit `manuscript/MANUSCRIPT.tex` Section 7
- Lean file content — files are in `lean_project/`, recompile with `lake build`

The campaign is complete. What you do with it from here is your call.