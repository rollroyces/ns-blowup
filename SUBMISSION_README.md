# Submission README — Quick Guide

**Target:** "Resolution-Scaling Study of the Hou-Luo Navier–Stokes Blowup
Candidate: A GPU-Accelerated Spectral Investigation on Apple Silicon"

**Status as of 2026-09-07:**

- Lean file (`lean_project/SpectralNS.lean`): **683 lines, 19 proved theorems, 0 errors, 0 sorries**
- LaTeX manuscript (`manuscript/MANUSCRIPT.tex`): **471 lines, arXiv-ready, abstract mentions all 19 theorems including the 3D Leray energy inequality**
- 12 trajectory `.npz` files in `data/`, 7 plots
- 6 Python solver/IC modules in `benchmarks/`, 7 driver scripts in `scripts/`
- **Author filled in:** `Royce` (replace with full last name in the LaTeX `\author{}` line if desired)
- **Affiliation:** not filled in (no institution in the project metadata; add to LaTeX if submitting with affiliation)
- **Project is NOT a git repository** — see "Optional: Version control" below

---

## Quick submission (5 minutes)

1. **Open https://arxiv.org/submit** and sign in (or create a free account).
2. **Upload the manuscript.** If you have a compiled PDF, upload that. If not:
   - Install LaTeX: `brew install --cask mactex-no-gui` (or use `tectonic`
     if you prefer a zero-install Rust toolchain: `brew install tectonic`)
   - Then: `cd manuscript && tectonic MANUSCRIPT.tex` → produces `MANUSCRIPT.pdf`
3. **Select categories:**
   - **Primary:** `math.NA` (Numerical Analysis)
   - **Cross-list:** `cs.MS` (Mathematical Software) and `physics.flu-dyn` (Fluid Dynamics)
4. **Paste metadata** (title and abstract are already in `MANUSCRIPT.tex` lines 8-9 and the abstract block):
   - Title: "Resolution-Scaling Study of the Hou-Luo Navier–Stokes Blowup Candidate: A GPU-Accelerated Spectral Investigation on Apple Silicon"
   - Authors: "Royce" (or your full name)
5. **Submit.** arXiv assigns a paper ID (e.g., `2026.NNNNN`) within 1-2 business days.

## Endorsement

If you don't already have an arXiv endorser for `math.NA`, the submission
system will auto-request one. Turnaround is 1-3 days. If you'd rather not
wait, you can submit with **only `cs.MS`** as primary (which is closer to
the AI/math-software community) and skip the endorsement step.

## License

Recommend **CC-BY 4.0** for open science, or arXiv's standard non-exclusive
license. arXiv will ask during submission.

---

## Optional: Version control (recommended before any public release)

The project is NOT under git. To set up:

```bash
cd /Users/hermes/.hermes/projects/ns_blowup
git init
cat > .gitignore << 'EOF'
# Python
__pycache__/
*.pyc
*.pyo
.pytest_cache/

# Virtual env
venv/
.env/

# Lean build artifacts
lean_project/.lake/
lean_project/Scratch*.lean
lean_project/Test*.lean
lean_project/TODO.txt

# OS
.DS_Store
EOF

git add -A
git commit -m "Initial commit: NS spectral NS blowup study

- 19-theorem Lean 4 + Mathlib formalization of the spectral NS scheme
- 12 trajectory .npz files at N=64, 128, 192 with T up to 0.15
- 3 ICs (simplified Hou-Luo, antiparallel vortex, single vortex + pert)
- 2 viscosities (0.001, 0.0005)
- 471-line LaTeX manuscript for arXiv submission
"
```

If you want a public GitHub repo: `gh repo create ns-spectral-blowup --public --source=.` then `git push -u origin main`.

## Optional: Public repo structure

```
ns-spectral-blowup-study/   (or wherever you put it)
├── README.md                # 200 words: what this is, how to reproduce
├── ARXIV_SUBMISSION.md      # existing detailed checklist
├── SUBMISSION_README.md     # this file (quick 5-min submission guide)
├── manuscript/
│   ├── MANUSCRIPT.tex       # main manuscript
│   ├── MANUSCRIPT.pdf       # compiled (after running tectonic)
│   └── MANUSCRIPT_DRAFT.md  # markdown source
├── lean_project/            # Lean 4 + Mathlib formalization
│   ├── SpectralNS.lean      # the 683-line file with 19 theorems
│   ├── lakefile.lean
│   └── lean-toolchain
├── benchmarks/              # 6 Python modules
├── scripts/                 # 7 driver scripts
├── data/                    # 12 .npz + 7 .png
├── FINAL_REPORT.md          # working notes (not for submission)
└── PHASE*_STATUS.md          # phase logs
```

## What to put in the README.md

200 words. Suggested:

> This repository contains a Lean 4 + Mathlib formalization of a
> spectral Navier–Stokes scheme on a periodic box, together with the
> GPU-accelerated numerics on Apple M-series hardware that it grounds.
>
> The Lean file (`lean_project/SpectralNS.lean`) contains 19 proved
> theorems, including the **discrete Leray energy inequality** for the
> truncated spectral NS scheme (no finite-time blow-up at finite
> truncation $N$). The numerics (`benchmarks/`, `scripts/`, `data/`)
> test this on a 3D spectral solver with three initial conditions
> across grid sizes $N = 64, 128, 192$ and viscosities $\nu = 10^{-3}, 5 \cdot 10^{-4}$.
>
> **Reproducing the numerics:** `source venv/bin/activate && python
> benchmarks/taylor_green_mps.py && python benchmarks/hou_louo_ic.py`
>
> **Reproducing the Lean proofs:** `cd lean_project && lake env lean
> SpectralNS.lean`
>
> **Companion paper:** see `manuscript/MANUSCRIPT.pdf` (to be
> submitted to arXiv).

---

## Files needed for arXiv submission (only one)

You need **only `manuscript/MANUSCRIPT.pdf`** to submit. Optionally
include `manuscript/MANUSCRIPT.tex` as the source. Everything else
(data, code, Lean) is referenced in the paper's availability section
and can live on GitHub.

The paper text does NOT need to reference a GitHub URL for arXiv
submission — arXiv allows supplementary material upload, and the
code/data can be linked from the paper later if you want.
