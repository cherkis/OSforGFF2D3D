# Progress

Living log of the `OSforGFF` port to d=3 and d=2. Update at the end of every work session. Stale entries are worse than no entries — if a status no longer reflects reality, fix it before closing the session.

Status legend: `TODO` · `WIP` · `DONE` · `BLOCKED`

## Current state

**Both libraries fully compile and prove OS0–OS4 with no `sorry`.**

| Library | Modules | Build | Sorries in OS0–OS4 | UV divergence |
|---|---|---|---|---|
| `OSforGFFin3D` | 35 | `lake build` green (3788 jobs) | 0 | proved (`freeCovariance_tendsto_atTop` via `besselKhalf_tendsto_atTop_at_zero`) |
| `OSforGFFin2D` | 36 | `lake build` green | 0 | proved (via `besselK0_tendsto_atTop_at_zero`) |

Last commits (`main` branch):
```
64a3ea8 Align comments with each library's actual spacetime dimension
9ddc9dc Prove UV divergence of free covariance in d=3 and d=2
dcc48d2 Initial OS axioms for GFF in d=3 and d=2
```

## Milestones

| # | Milestone | Status | Notes |
|---|---|---|---|
| 1 | Lake skeleton: `lakefile.lean`, `lean-toolchain`, empty root modules, `lake build` green | DONE | Both root libs compile from start. |
| 2 | `docs/dimension_dependence_3D.md` authored | DONE | Authoritative 3D copy list (35 files) + truly-importable list (12 files). |
| 3 | 3D: all SpaceTime-bound files adapted | DONE | 35/35 modules built. |
| 4 | 3D verification: `lake build OSforGFFin3D` green, no `sorry` in OS0–OS4 | DONE | Green; zero sorries. UV divergence proved (commit `9ddc9dc`). |
| 5 | `docs/dimension_dependence_2D.md` authored | DONE | Same structure as 3D doc. Key contrasts: K₀ instead of K_{1/2}, no closed form; (2π)² Plancherel; spatial dim 1 (`Fin 1` quirks). |
| 6 | 2D: all SpaceTime-bound files adapted | DONE | 36/36 modules built (includes extra `General/BesselK0Proofs.lean`). |
| 7 | 2D verification: `lake build OSforGFFin2D` green, no `sorry` in OS0–OS4 | DONE | Green; zero sorries. UV divergence proved (commit `9ddc9dc`). |

## Per-file checklist

Full COPY list is in `docs/dimension_dependence_3D.md` and `docs/dimension_dependence_2D.md`. Re-derive (don't trust this table) if the 4D library changes upstream.

| Category | 4D file | 3D | 2D |
|---|---|---|---|
| Essential | `General/BesselFunction.lean` | DONE | DONE |
| Essential | `Covariance/Momentum.lean` | DONE | DONE |
| Essential | `Covariance/Parseval.lean` | DONE | DONE |
| Essential | `OS/OS3_MixedRepInfra.lean` | DONE | DONE |
| Essential | `OS/OS3_MixedRep.lean` | DONE | DONE |
| Spatial | `General/FunctionalAnalysis.lean` | DONE | DONE |
| Spatial | `Spacetime/ProdIntegrable.lean` | DONE | DONE |
| Spatial | `OS/OS1_Regularity.lean` | DONE | DONE |
| Spatial | `OS/OS4_Clustering.lean` | DONE | DONE |
| Bound | `Spacetime/Basic.lean` | DONE | DONE |
| Bound | `Spacetime/ComplexTestFunction.lean` | DONE | DONE |
| Bound | `Spacetime/Decomposition.lean` | DONE | DONE |
| Bound | `Spacetime/DiscreteSymmetry.lean` | DONE | DONE |
| Bound | `Spacetime/Euclidean.lean` | DONE | DONE |
| Bound | `Spacetime/PositiveTimeTestFunction.lean` | DONE | DONE |
| Bound | `Spacetime/TimeTranslation.lean` | DONE | DONE |
| Bound | `Spacetime/Tonelli.lean` | DONE | DONE |
| Bound | `Schwinger/Defs.lean` | DONE | DONE |
| Bound | `Schwinger/TwoPoint.lean` | DONE | DONE |
| Bound | `Schwinger/GaussianMoments.lean` | DONE | DONE |
| Bound | `Covariance/Position.lean` | DONE | DONE |
| Bound | `Covariance/RealForm.lean` | DONE | DONE |
| Bound | `Measure/Construct.lean` | DONE | DONE |
| Bound | `Measure/GaussianFreeField.lean` | DONE | DONE |
| Bound | `Measure/IsGaussian.lean` | DONE | DONE |
| Bound | `Measure/MinlosAnalytic.lean` | DONE | DONE |
| Bound | `OS/Axioms.lean` | DONE | DONE |
| Bound | `OS/Master.lean` | DONE | DONE |
| Bound | `OS/NonTrivial.lean` | DONE | DONE |
| Bound | `OS/OS0_Analyticity.lean` | DONE | DONE |
| Bound | `OS/OS2_Invariance.lean` | DONE | DONE |
| Bound | `OS/OS3_CovarianceRP.lean` | DONE | DONE |
| Bound | `OS/OS3_ReflectionPositivity.lean` | DONE | DONE |
| Bound | `OS/OS4_Ergodicity.lean` | DONE | DONE |
| Bound | `OS/OS4_MGF.lean` | DONE | DONE |

Plus one extra file added during the 2D port that doesn't exist in the 4D library:
| Category | File | 2D |
|---|---|---|
| Essential | `OSforGFFin2D/General/BesselK0Proofs.lean` (d=2-specific K₀ proofs) | DONE |

## Decisions log

Append-only. One line per decision: date, decision, why.

- 2026-06-08 — Pin OSforGFF to `mrdouglasny/OSforGFF` @ `60ab679e09b764de6dfe01767ae361ac1bea30b8` (current upstream main; confirmed via `git ls-remote`).
- 2026-06-08 — Toolchain `leanprover/lean4:v4.29.0` to match the 4D library's `lean-toolchain`.
- 2026-06-08 — Each root module imports `OSforGFF.Spacetime.Basic` as a Structural-dep smoke test so the build actually exercises the dependency link instead of compiling empty files.
- 2026-06-08 — Mathlib and other transitive deps left unpinned in our lakefile; resolved via Lake's transitive resolution.
- 2026-06-08 — **Selection rule revised.** The 4D library hardcodes `abbrev STDimension := 4`, which unfolds transparently. Any file mentioning `SpaceTime`/`STDimension`/`TestFunction`/`FieldConfiguration` or transitively importing `Spacetime/Basic` is d=4-bound and must be copied — not just Essential/Spatial. Truly importable list shrinks to ~12 General/Measure files. Full rationale in `docs/dimension_dependence_3D.md`.
- 2026-06-08 — **ProdIntegrable: use exponent 4 in `polynomial_decay_integrable_2d`.** The spatial pointwise bound from `schwartz_vanishing_ftc_decay` is `C·t/(1+‖x‖)^4`. Integrability of `1/(1+‖x‖)^4` on ℝ² holds since 4 > 2.
- 2026-06-08 — **`linfty_mul_L2_CLM` API changed**: old API took `(g, hg_meas, C, hM_pos : 0 < C, hg_bound : ∀ᵐ x, ‖g x‖ ≤ C)`; current API takes `(g, hg_meas, C, hg_bound)` (positivity dropped). `linfty_mul_L2_CLM_spec` correspondingly takes 5 not 6 explicit args.
- 2026-06-08 — **`rw [← integral_const_mul]` fails on set integrals and plain integrals**: `MeasureTheory.integral_const_mul` uses `∂μ` notation in its pattern; Lean 4's `rw` does NOT see through the `∫ x in S, f x` sugar OR through plain `∫ x, f x` (implicit measure). Fixes: for plain integrals use `set C := …; simp_rw [← smul_eq_mul (a := C)]; rw [← integral_smul]; simp …`. For set integrals: provide `μ := volume.restrict S` explicitly in term-mode.
- 2026-06-08 — **`RCLike.inner_apply` not applicable to `@inner ℝ ℝ _`**: The instance for `@inner ℝ ℝ _` is `RCLike.toInnerProductSpaceReal`, not `RCLike.innerProductSpace`. Fix: `simp [real_inner_eq_re_inner (𝕜 := ℝ), RCLike.inner_apply, mul_comm]`.
- 2026-06-08 — **`Covariance/Momentum.lean` 2D parametrized-type mismatch**: the reference `OSforGFFin3Dand2D` used `SpaceTime (d : ℕ)` and `TestFunctionℂ (d : ℕ)` as parametrized types; our new library uses non-parametric `abbrev SpaceTime`. Global `sed` to strip `STDimension` argument from these types. Lesson: verify type-application syntax matches the target library's abbrev structure when porting.
- 2026-06-08 — **`positivity` fails on `0 < m * r` when context has `1 < r`**: requires `0 < r` explicitly. Fix: `exact mul_pos hm (lt_trans one_pos hr)`.
- 2026-06-08 — **`besselK_integrableOn_Ici` made public + added** in `OSforGFFin3D/General/BesselFunction.lean`. Plus `besselK0_integrand_Ici_integrable` + `Ici_split` + `besselK0_integrand_Ioi_integrable` made public in `OSforGFFin2D/General/BesselK0Proofs.lean`. Used by the UV-divergence proofs.

## Failed attempts / dead-ends

Append-only. Short entries: what was tried, why it didn't work, what to try next.

- 2026-06-08 — **`lake exe shake` for unused-import cleanup unreliable on this project.** Tried two configurations: (a) no whitelist — shake stripped `OSforGFFin3D.Spacetime.Basic` from `Spacetime/Decomposition.lean` (which uses `SpaceTime`, `SpatialCoords`); (b) whitelist all `OSforGFFin{2D,3D}.*` and used `OSforGFF.*` upstream — shake removed only Mathlib imports, but still broke the build with 63 errors because the removed Mathlib modules were carrying instance/simp/elaboration dependencies invisible to shake's syntactic analysis. Two stashes preserved at the time (now dropped). **Verdict: leave imports as-is.** Future approach if needed: per-declaration `#min_imports in` (Mathlib's `Tactic.MinImports`) or hand-bisect per file — both slow.

## Session log

Append-only. One entry per work session: date, what was attempted, what landed, what remains.

- 2026-06-08 — Milestones 1 + 2 done. Lake skeleton stood up against 4D dependency pinned to `60ab679`. `docs/dimension_dependence_3D.md` authored with full file inventory (35 COPY, 12 truly importable). Selection rule revised in CLAUDE.md after discovering `STDimension := 4` is hardcoded and unfolds transparently — every file referencing `SpaceTime` is d=4-bound and must be copied. Per-file checklist in PROGRESS.md expanded to 35 rows.
- 2026-06-08 — Milestones 3 + 4 done. 3D port complete: 35/35 modules green. Hand-adapted `Spacetime/Basic.lean` (set `STDimension := 3`); bulk-copied remaining 33 files with python import-rewriter pointing them at `OSforGFFin3D.*`; iteratively fixed `Spacetime/Decomposition` (Fin sum_univ shifts), `Spacetime/ProdIntegrable` (Spatial: spatial dim 3→2), `Covariance/Momentum` (Essential: Bessel K₁ → K_{1/2} via reference port + 5 mathlib drift fixes), `OS3_MixedRep` (calc chain `(2π)^4→(2π)^3` → `(2π)^3→(2π)^2`), `OS3_MixedRepInfra` (3 mathlib drift fixes), `OS4_Clustering`, `NonTrivial` (kept dim-agnostic chain; UV divergence deferred at this point).
- 2026-06-08 — Milestones 5 + 6 + 7 done. 2D port complete: 36/36 modules green. `docs/dimension_dependence_2D.md` authored. Cloned 3D files to 2D with `STDimension := 2`; ported reference `BesselFunction`/`BesselK0Proofs`/`CovarianceMomentum` from `OSforGFFin3Dand2D` for d=2 (besselK0 form); delegated Momentum mathlib drift (~100 errors → 0) and three OS files to lean4:proof-repair agents; manual fixes to Basic (spatial dim 1 quirks), Decomposition (1-term spatial sum), ProdIntegrable (Fin 1 degenerate), OS3_MixedRep (final calc step needs `field_simp` not `ring` because of d=2 multiplicative inverses).
- 2026-06-08 — **UV divergence proved in both 3D and 2D** (commit `9ddc9dc`). Added `besselK_integrableOn_Ici` + `besselK_tendsto_atTop_at_zero` + `besselKhalf_tendsto_atTop_at_zero` to 3D `General/BesselFunction.lean`. Added `besselK0_integrand_Ici_integrable` + `besselK0_tendsto_atTop_at_zero` to 2D `General/BesselK0Proofs.lean`. Proof strategy: for any T > 0, on [0,T] cosh(t) ≤ cosh(T) so exp(-z cosh t) ≥ exp(-z cosh T); integrate to get `K(z) ≥ T · exp(-z cosh T) → T` as z → 0+. NonTrivial's `freeCovariance_tendsto_atTop` then composes with `m·r` → 0+ for both 3D (Yukawa: bound prefactor below for r ≤ 1) and 2D (logarithmic; pure K₀ form).
- 2026-06-08 — **Comments aligned to each library's actual dimension** (commit `64a3ea8`). 25 files updated, ~82 substitutions: ℝ⁴/O(4)/E(4)/Fin 4 → dim-appropriate value in describe-what-this-file-does docstrings; OS3_MixedRepInfra Gaussian-FT example formula updated to d-specific form; OS1 local-integrability notes; OS Axioms OS4 docstring; NonTrivial Main Results lists; 3D-cloned 2D references (ProdIntegrable header `ℝ × ℝ³ → ℝ × ℝ¹`, TimeTranslation, DiscreteSymmetry). Intentionally-comparative comments (e.g., "unlike d=4 where C ~ 1/r²") preserved.
- 2026-06-08 — **Unused-import cleanup attempted and abandoned.** Two shake runs both broke the build (see Failed attempts). Reverted via stash. Project remains at the green state from commit `64a3ea8`. Decision: leave imports as bulk-copied — cost/risk ratio of safe minimization is poor given Lean's invisible transitive instance dependencies.
