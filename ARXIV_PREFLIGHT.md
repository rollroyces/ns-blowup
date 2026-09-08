# arXiv Pre-Flight Checklist — Tick Before Submitting

**Target paper:** "Resolution-Scaling Study of the Hou-Luo Navier–Stokes Blowup Candidate: A GPU-Accelerated Spectral Investigation on Apple Silicon"

**Date prepared:** 2026-09-08

Print this, tick every box, then start submission.

---

## Section A — LaTeX install (Royce's machine, ~30 min)

- [ ] **LaTeX compiler installed.** macOS options:
  - [ ] **MacTeX** (full, ~5 GB): https://tug.org/mactex/
  - [ ] **TinyTeX** (minimal, ~100 MB): `curl -sL "https://yihui.org/tinytex/install-bin-unix.sh" | sh`
  - [ ] **Docker** if avoiding install: `docker pull texlive/texlive:latest`
- [ ] `which pdflatex` returns a path (or equivalent for chosen compiler)

## Section B — Author info (Royce, ~5 min)

- [ ] **`MANUSCRIPT.tex` line 10** has your actual last name, not `[Lastname]`. Current state:
  ```
  \author{Royce \and Hermes Agent (computational infrastructure)}
  ```
  If you want to add institution, also fill line ~425 (`\institute{...}` if present, or add `\affil` block).
- [ ] (Optional) Decide whether to credit "Hermes Agent" as co-author or acknowledge only in the Acknowledgments section.

## Section C — Compile the PDF (~5 min)

- [ ] `cd /Users/hermes/.hermes/projects/ns_blowup/manuscript`
- [ ] `pdflatex MANUSCRIPT.tex` → produces `MANUSCRIPT.pdf` with 0 errors
- [ ] (If you have a .bib) `bibtex MANUSCRIPT` then `pdflatex MANUSCRIPT.tex` twice more
- [ ] `MANUSCRIPT.pdf` is 15–25 pages

## Section D — Visual check (5 min)

- [ ] Title and author block render correctly on page 1
- [ ] Abstract paragraph on page 1 reads correctly
- [ ] All 5 data tables (in §4) render with correct numbers
- [ ] Math expressions render correctly: $\max|\omega|$, $|k|^2$, $\|\cdot\|$, $\nu$
- [ ] References list at the end is properly numbered and formatted
- [ ] No "Undefined control sequence" or "[?]" placeholders anywhere

## Section E — arXiv account (~10 min, one-time)

- [ ] arXiv account exists at https://arxiv.org (register if not)
- [ ] Logged in

## Section F — Endorsement (~1-3 days)

- [ ] **math.NA endorsement**: required for primary submission. If you don't have one, the endorsement system auto-emails existing endorsers; turnaround 1-3 days. The endorsement form is at https://arxiv.org/auth/endorse?paper=... (only appears when you upload without endorsement).
- [ ] If you are the first person to submit from your institution in math.NA, you may need to wait. Alternative: ask a collaborator with endorsement.

## Section G — Submission (~10 min)

- [ ] Go to https://arxiv.org/submit
- [ ] Sign in
- [ ] **Categories**:
  - [ ] Primary: **math.NA** (Numerical Analysis)
  - [ ] Cross-list: **cs.MS** (Mathematical Software)
  - [ ] Cross-list: **physics.flu-dyn** (Fluid Dynamics)
- [ ] Upload **both**:
  - [ ] `MANUSCRIPT.pdf` (the compiled output)
  - [ ] `MANUSCRIPT.tex` and any `.bib` (arXiv prefers source for indexing)
- [ ] Fill metadata: title, authors, abstract, comments
- [ ] **License**: CC-BY 4.0 (recommended for open science) OR arXiv's standard non-exclusive license
- [ ] Click Submit
- [ ] arXiv assigns a paper ID (e.g., `2026.NNNNN`) and a DOI within 1–2 business days

## Section H — Optional but recommended

- [ ] **GitHub repo** with code, data, Lean files. Suggested structure:
  ```
  github.com/[username]/ns-spectral-blowup-study/
  ├── benchmarks/        # Python modules
  ├── data/              # .npz trajectories, .png plots
  ├── scripts/           # driver scripts
  ├── lean_project/      # Lean 4 + Mathlib formalization
  │   ├── SpectralNS.lean
  │   ├── BeiraoDaVeiga.lean
  │   └── lakefile.lean
  ├── manuscript/        # .tex source, .pdf
  ├── FINAL_REPORT.md
  ├── TAO_2016_NOGO.md
  ├── LITERATURE_SURVEY.md
  └── README.md
  ```
- [ ] Link the GitHub repo in the arXiv "Comments" field
- [ ] Tag a release `v1.0` on GitHub
- [ ] (Optional) Post on social media: Twitter/Mastodon, r/math, MathOverflow

## Section I — Sanity check — Lean files

Before submitting, verify the Lean component is consistent with the abstract:

- [ ] `cd /Users/hermes/.hermes/projects/ns_blowup/lean_project`
- [ ] `PATH=~/.elan/bin:$PATH lake build 2>&1 | tail -3`
  - Expected: `Build completed successfully (8877 jobs).`
- [ ] `wc -l SpectralNS.lean BeiraoDaVeiga.lean`
  - Expected: `885 SpectralNS.lean`, `277 BeiraoDaVeiga.lean`
- [ ] `grep -c "^sorry" SpectralNS.lean BeiraoDaVeiga.lean`
  - Expected: `0 SpectralNS.lean`, `0 BeiraoDaVeiga.lean`

If any of these fail, do not submit — fix first.

---

## If arXiv endorsement is a blocker

Alternatives:
- [ ] **Zenodo** (https://zenodo.org): assigns DOIs, no endorsement needed, free. Good for code+data+paper.
- [ ] **GitHub** with a tagged release: good for code, less discoverable than arXiv for the math community.
- [ ] **Research Square** or **Authorea**: preprint servers with light review.

arXiv is preferred for maximum visibility in the PDE/numerical analysis community. Zenodo is a strong backup.

---

## After submission

- [ ] Watch your email for the arXiv endorsement decision (1-3 days)
- [ ] Once paper appears, share the link on Twitter/Mastodon, MathOverflow, etc.
- [ ] (Optional) Submit to a journal: J. Comput. Phys., J. Fluid Mech., SIAM J. Numer. Anal.

---

**Estimated total time:** 30-60 minutes of active work (excluding the 1-3 day endorsement wait).
