# OS for GFF in 3 and 2 Dimensions

## Goal

Formalize, in Lean 4, the Osterwalder–Schrader axioms **OS0, OS1, OS2, OS3, OS4** for the **massive** Gaussian Free Field (m > 0) in spacetime dimensions **d = 3** and **d = 2**. The 4D version of this work lives at `https://github.com/mrdouglasny/OSforGFF`; this project reuses it as a Lean dependency and supplies *only* the files whose proofs depend on the dimension.

Definition of done: `lake build` succeeds for both library targets `OSforGFFin3D` and `OSforGFFin2D`, with the same theorem statements as the 4D library and no `sorry` in OS0–OS4 for either dimension.

## Pre-edit gate

Before editing any Lean file:

0. Read `PROGRESS.md` to see what has already been done, what failed, and what is currently in flight.
1. Post a written plan with: (a) the exact list of files to copy, derived from `docs/dimension_dependence.md` in the 4D library (every file listed under **Essential** or **Spatial** for the dimension being worked on); (b) the proposed `lakefile.lean` content (pin SHA, library declarations); (c) the expected mathematical divergences from the 4D case (e.g., the d=3 covariance uses K_{1/2}; the d=2 covariance uses K_0).

Do not modify any code until that plan exists and has been approved. At the end of every work session, update `PROGRESS.md` (milestones, per-file checklist, decisions log, failed attempts, session log) before closing.

## References (read-only)

- `@../OSforGFFin3D/` — a local, *exact* copy of the current 4D library. Use it to read source, run `grep`, and consult `docs/dimension_dependence.md`. **Do not import from this path** — use the git dependency instead.
- `@../OSforGFFin3Dand2D/` — a prior, completed 3D+2D project against an *older* version of the 4D library. Useful as a worked example, but file structure and dependencies are out of date.

## Project layout

```
OSforGFF2D3D/
├── lakefile.lean            # requires OSforGFF (4D) pinned to a SHA, declares two libs
├── lean-toolchain           # matches the 4D library's toolchain exactly
├── OSforGFFin3D.lean        # root: imports every file under OSforGFFin3D/
├── OSforGFFin2D.lean        # root: imports every file under OSforGFFin2D/
├── OSforGFFin3D/            # 3D-specific copies of Essential ∪ Spatial files
├── OSforGFFin2D/            # 2D-specific copies of Essential ∪ Spatial files
└── docs/
    ├── dimension_dependence_3D.md
    └── dimension_dependence_2D.md
```

`lakefile.lean` declares two sibling libraries (`OSforGFFin3D` and `OSforGFFin2D`), each depending on `OSforGFF` via `require ... from git "https://github.com/mrdouglasny/OSforGFF.git" @ "<commit-sha>"`. The SHA is pinned and updated only by deliberate commit.

## File selection rule

The 4D library hardcodes `abbrev STDimension := 4` and `abbrev SpaceTime := EuclideanSpace ℝ (Fin STDimension)` in `Spacetime/Basic.lean`. Because `abbrev` unfolds transparently, every file that references `SpaceTime`, `STDimension`, `TestFunction`, or `FieldConfiguration` — *either directly or via transitive import of `Spacetime.Basic`* — bakes in d=4 at the type level. Such files cannot be imported unchanged at d=3 or d=2.

The corrected rule, applied per file in the 4D library:

- **COPY and adapt** if any of the following holds:
  1. Listed as **Essential** or **Spatial** in 4D `docs/dimension_dependence.md` (dimension-specific formula or estimate).
  2. The file mentions `SpaceTime`, `STDimension`, `TestFunction`, or `FieldConfiguration` (direct dependence on d=4 types).
  3. The file transitively imports `OSforGFF.Spacetime.Basic` (or any other COPY file).
- **IMPORT directly** otherwise. In practice, only the truly dimension-agnostic `General/*` lemmas (`SchurProduct`, `FrobeniusPositivity`, `HadamardExp`, `PositiveDefinite`, `GaussianRBF`, `FourierTransforms`, `LaplaceIntegral`, `QuantitativeDecay`, `SchwartzTranslationDecay`, `L2TimeIntegral`) plus `Measure/Minlos` and `Measure/NuclearSpace` qualify.

The authoritative per-dimension copy lists live in `docs/dimension_dependence_3D.md` and `docs/dimension_dependence_2D.md`. If a file's classification looks wrong while you're working, update the relevant doc and the `PROGRESS.md` per-file checklist in the same PR.

## Process

Work in this order:

1. **Set up the lake project.** Author `lakefile.lean`, `lean-toolchain`, empty `OSforGFFin3D.lean` and `OSforGFFin2D.lean`. Confirm `lake build` succeeds against the pinned 4D dependency before any proof work.
2. **Author `docs/dimension_dependence_3D.md`.** Start from the 4D doc; for each Essential/Spatial file, record the d=3 substitution (e.g., K_1 → K_{1/2}, (4π t)^{-d/2} → (4π t)^{-3/2}). This *is* the file-copy list for 3D.
3. **3D: copy and adapt, file by file.** For each file on the list, create `OSforGFFin3D/<File>.lean`, adjust formulas, fix proofs. Re-run `lake build` after each file. Do not introduce `sorry` outside of clearly marked TODOs.
4. **3D verification.** All five axioms `OS0`–`OS4` for the GFF should compile in `OSforGFFin3D` without `sorry`.
5. **2D: author `docs/dimension_dependence_2D.md`,** then repeat steps 3–4 in `OSforGFFin2D/`. Expect K_0 to replace K_1, and the d=2 Plancherel factor (2π)^2 to replace (2π)^4.

## Verification

- `lake build OSforGFFin3D` succeeds with no errors and no `sorry` in OS0–OS4.
- `lake build OSforGFFin2D` succeeds with no errors and no `sorry` in OS0–OS4.
- A `grep -r "sorry" OSforGFFin3D OSforGFFin2D` reports only entries explicitly marked as out-of-scope TODOs (if any).
- Theorem statements in `OSforGFFin{3D,2D}/OS*_GFF.lean` are isomorphic to those in the 4D library, only with `STDimension := 3` or `STDimension := 2`.
