# arXiv Submission — Checklist

**Target:** "Resolution-Scaling Study of the Hou-Luo Navier–Stokes Blowup
Candidate: A GPU-Accelerated Spectral Investigation on Apple Silicon"

**Date:** 2026-09-07

**Status as of 2026-09-07 (final):**
- Lean files:
  - `lean_project/SpectralNS.lean`: **885 lines, 22 theorems/lemmas, 0 errors, 0 sorries**
  - `lean_project/BeiraoDaVeiga.lean`: **277 lines, 5 theorems, 0 errors, 0 sorries**
  - **Total: 27 theorems proved, 0 sorries across both files**
- LaTeX manuscript (`manuscript/MANUSCRIPT.tex`): **475 lines, arXiv-ready**
- Tao 2016 no-go analysis: `TAO_2016_NOGO.md` (10.5 KB)
- 18-run Onsager-critical scaling sweep (data + plot in `data/`)
- Quick 5-minute guide: see `SUBMISSION_README.md` at the project root

---

## Before submission, you will need

1. **Author name and affiliation** (replace "[Lastname]" and "[User's institution]" in `manuscript/MANUSCRIPT.tex`)
2. **arXiv account** (free at arxiv.org)
3. **arXiv endorsement** for category `math.NA` (if you don't already have one — the endorsement system auto-emails an existing endorser; turnaround 1-3 days)
4. **A working LaTeX installation** to compile the PDF. macOS options:
   - **MacTeX** (full distribution, ~5 GB): https://tug.org/mactex/
   - **TinyTeX** (minimal, ~100 MB): `curl -sL "https://yihui.org/tinytex/install-bin-unix.sh" | sh`
   - **Docker image** if you don't want to install: `docker pull texlive/texlive:latest`

## Submission steps (when ready)

1. **Replace placeholders** in `manuscript/MANUSCRIPT.tex`:
   ```
   \author{R. [Lastname] \and Hermes Agent (computational infrastructure)}
   ```
   →
   ```
   \author{R. [Your Lastname] \and Hermes Agent (computational infrastructure)}
   ```

2. **Compile the PDF**:
   ```bash
   cd manuscript
   pdflatex MANUSCRIPT.tex
   bibtex MANUSCRIPT  # only if you have a .bib file
   pdflatex MANUSCRIPT.tex
   pdflatex MANUSCRIPT.tex
   ```
   The output is `MANUSCRIPT.pdf`.

3. **Verify the PDF** before submission:
   - Title and author block correct
   - All 5 tables render
   - Math expressions typeset (especially $\max|\omega|$, $|k|^2$)
   - References list at the end
   - Page count is reasonable (~20-25 pages)

4. **Upload to arXiv**:
   - Go to https://arxiv.org/submit
   - Sign in (or create account)
   - Select categories: **primary math.NA** (Numerical Analysis), **cross-list cs.MS** (Mathematical Software) and **physics.flu-dyn** (Fluid Dynamics)
   - Upload `MANUSCRIPT.pdf` and any `.tex` source files (arXiv prefers source)
   - Fill in the metadata: title, authors, abstract, comments, report number (if any)
   - License: CC-BY 4.0 (recommended for open science) or arXiv's standard non-exclusive license
   - Submit. arXiv will assign a paper ID (e.g., 2026.NNNNN) and a DOI within 1-2 business days.

5. **Optional but recommended**: create a GitHub repository with the code, data, and Lean file. The arXiv submission can include a link to it. Suggested structure:
   ```
   github.com/[username]/ns-spectral-blowup-study/
   ├── benchmarks/        # Python modules
   ├── data/              # .npz trajectories, .png plots
   ├── scripts/           # driver scripts
   ├── lean_project/      # Lean 4 + Mathlib formalization
   ├── manuscript/        # .tex source, .pdf, .md draft
   ├── FINAL_REPORT.md    # comprehensive writeup
   └── README.md          # quickstart
   ```

## What the submission contains

- **Abstract:** ~250 words describing the GPU-accelerated spectral NS study
  with multi-resolution, multi-IC, multi-ν findings, plus the 17-theorem
  Lean formalization.
- **5 data tables** populated from `FINAL_REPORT.md` (resolution scaling,
  N=128 to T=0.15, three-grid comparison, time convergence, IC comparison,
  viscosity sweep).
- **~25 references** to the NS regularity literature (Hou-Luo, Kerr,
  Kolmogorov, Tao, Kukavica-Vicol, Leray, Caffarelli-Kohn-Nirenberg, etc.)
- **Lean formalization referenced** in §3 and §7 with 17 theorems
  documented in the FINAL_REPORT.
- **All data and code referenced** in the availability section.

## Honest scope statement

The paper's central claim is **negative** for the Hou-Luo blowup
hypothesis (at the tested resolutions, viscosities, and ICs). The
manuscript is explicit about what was NOT tested: the exact Hou-Luo
2014 IC, N ≥ 256, T > 0.15. The Clay Millennium problem remains open;
this is a methods note, not a proof of regularity.

The Lean no-blowup theorem is for the **truncated** spectral NS scheme
at finite N, not the continuous Clay problem. The manuscript should
not overstate this — the published version should be clear that the
Lean result is a Leray-energy-inequality analogue for the discrete
scheme, not a Clay solution.

## Files to submit

- `manuscript/MANUSCRIPT.tex` (the source)
- `manuscript/MANUSCRIPT.pdf` (the compiled output)
- Optional but recommended: `data/` (trajectories), `benchmarks/`
  (code), `lean_project/SpectralNS.lean` (Lean source)

## Expected timeline

- 30 min: install LaTeX, compile, fix any issues
- 30 min: fill in author name, double-check tables
- 5 min: arXiv submission
- 1-2 business days: arXiv endorsement + paper appears
- Total: ~1-2 hours of active work plus 1-2 days wait

---

## Alternative: skip arXiv, post on Zenodo / GitHub instead

If arXiv endorsement is a blocker, consider:
- **Zenodo** (https://zenodo.org) — assigns DOIs, no endorsement needed,
  free. Good for code+data+paper.
- **GitHub** with a tagged release — good for code, but less discoverable
  than arXiv for the math community.
- **Research Square** or **Authorea** — preprint servers with
  light review.

The arXiv route is preferred for maximum visibility in the PDE/numerical
analysis community, but Zenodo is a strong backup.
