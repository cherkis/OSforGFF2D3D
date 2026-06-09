# Dimension Dependence — d = 3 spacetime

This document inventories how the 4D library's content is adapted for **spacetime dimension d = 3**. Spatial dimension is d − 1 = 2. The 4D classification (`Essential`, `Spatial`, `Structural`) is preserved, with two changes:

1. **All Structural files that mention `SpaceTime`, `STDimension`, `TestFunction`, or `FieldConfiguration` — directly or via transitive import of `Spacetime.Basic` — must also be copied.** They are reclassified as **Structurally bound (d=3)**: the proof body is mechanical, but the *type* `SpaceTime = EuclideanSpace ℝ (Fin 3)` differs. Reason: `abbrev` unfolding bakes the dimension into types, so `import OSforGFF.Spacetime.Basic` would pull in d=4 transparently.
2. **Truly dimension-agnostic files** are imported from the 4D library unchanged. The list is small: see §4 below.

This doc IS the copy-list for the 3D port. When you adapt a file, update the per-file checklist in `PROGRESS.md`.

---

## 1. Essential (d=3) — formulas specific to d = 3

These files contain formulas whose closed form changes at d = 3.

### `General/BesselFunction.lean`
- 4D uses `K₁`. At d=3 the relevant Bessel index is `d/2 − 1 = 1/2`. Define `besselKhalf := besselK (1/2)`.
- Closed form: `K_{1/2}(z) = √(π/(2z)) · e^{-z}`. This yields **Yukawa**:
  `C(x, y) = e^{−m r} / (4 π r)` (with `r = ‖x − y‖`).
- Plan: introduce `besselKhalf` and prove its decay/bounds. Many proofs will simplify because of the explicit form.

### `Covariance/Momentum.lean`
- Heat kernel: `heatKernelPositionSpace` writes `(4π t)^{−d/2}`; at d=3 this is `(4π t)^{−3/2}`.
- Bessel representation `freeCovarianceBessel`: at d=3 reduces to the Yukawa form `(4π r)^{−1} · e^{−m r}` (i.e., uses `besselKhalf`).
- `covarianceSchwingerRep_eq_besselFormula` and `freeCovariance_regulated_tendsto_bessel` rewritten with the d=3 closed form.

### `Covariance/Parseval.lean`
- Plancherel scaling `(2π)^d` becomes `(2π)^3` in `regulated_fubini_factorization`, `parseval_covariance_schwartz_regulated`, and the physics/Mathlib Fourier change of variables.

### `OS/OS3_MixedRepInfra.lean`
- `heatKernelPositionSpace_4D` → `heatKernelPositionSpace_3D`, converting `(4π t)^{−3/2}` explicitly.
- Schwinger proper-time Laplace `s`-integral uses the d=3 heat kernel.

### `OS/OS3_MixedRep.lean`
- Normalization identity: `(2π)^3 / (2π) = (2π)^2` (d=3 analog of `(2π)^4 / (2π) = (2π)^3`).
- Schwinger-to-Bessel reduction uses `besselKhalf`.

## 2. Spatial (d=2) — uses spatial dim = d − 1 = 2

### `General/FunctionalAnalysis.lean`
- 4D's `polynomial_decay_integrable_3d` becomes `polynomial_decay_integrable_2d`: `(1 + ‖x‖)^{−α}` is integrable on `ℝ²` iff `α > 2`. Pick `α = 3` (analog of 4D's `α = 4 > 3`).

### `Spacetime/ProdIntegrable.lean`
- `SpatialCoords3` → `SpatialCoords2 := EuclideanSpace ℝ (Fin 2)`.
- `spatialNormIntegral_linear_bound` uses 2D spatial integrals.

### `OS/OS1_Regularity.lean`
- `locallyIntegrable_of_rpow_decay_real` with `α = 2`: the singularity at d=3 is `‖x‖^{−(d−2)} = ‖x‖^{−1}`. Condition `α < d` ⇒ `α < 3`, still holds for `α = 2`.

### `OS/OS4_Clustering.lean`
- `Fin.sum_univ_four` (expanding `‖k‖² = k₀² + k₁² + k₂² + k₃²`) becomes `Fin.sum_univ_three` (`‖k‖² = k₀² + k₁² + k₂²`).

## 3. Structurally bound (d=3) — proof body mechanical, types changed

These files reference `SpaceTime`/`STDimension`/`TestFunction`/`FieldConfiguration` or import a file that does. Adaptation is typically *just* re-stating with `STDimension := 3`. Watch for `Fin 4`-specific arithmetic (`Fin.sum_univ_four`, explicit index `⟨3, _⟩` lookups) — those break and need replacement.

| File | Adaptation cue |
|------|----------------|
| `Spacetime/Basic.lean` | `abbrev STDimension := 3` (and `SpaceTime := EuclideanSpace ℝ (Fin 3)`); rest unchanged |
| `Spacetime/ComplexTestFunction.lean` | Re-statement only |
| `Spacetime/Decomposition.lean` | `ℝ³ ≅ ℝ × ℝ²` instead of `ℝ⁴ ≅ ℝ × ℝ³` |
| `Spacetime/DiscreteSymmetry.lean` | Time-reflection matrix in `O(3)`; index 0 unchanged |
| `Spacetime/Euclidean.lean` | `E(3) = O(3) ⋊ ℝ³` |
| `Spacetime/PositiveTimeTestFunction.lean` | Re-statement only |
| `Spacetime/TimeTranslation.lean` | Time-translation `Tₛ` shifts index 0; works for any d |
| `Spacetime/Tonelli.lean` | Re-statement only |
| `Schwinger/Defs.lean` | Schwinger n-point on `SpaceTime`-tuples |
| `Schwinger/TwoPoint.lean` | Re-statement only |
| `Schwinger/GaussianMoments.lean` | Re-statement only |
| `Covariance/Position.lean` | Inherits d=3 via `Covariance/Parseval` (Essential) |
| `Covariance/RealForm.lean` | Re-statement only |
| `Measure/Construct.lean` | Uses `SpaceTime` and `Spacetime/ComplexTestFunction` (both copied) |
| `Measure/GaussianFreeField.lean` | Imports `Covariance/Position` (Structurally bound), `FunctionalAnalysis` (Spatial), `OS/Axioms` (Structurally bound) |
| `Measure/IsGaussian.lean` | Imports `OS0_Analyticity`, `GaussianMoments` (both Structurally bound) |
| `Measure/MinlosAnalytic.lean` | Imports `Spacetime.Basic` |
| `OS/Axioms.lean` | Axiom statements quantify over `TestFunction` |
| `OS/Master.lean` | Aggregates OS0–OS4 — re-statement only |
| `OS/NonTrivial.lean` | Re-statement only |
| `OS/OS0_Analyticity.lean` | Re-statement only |
| `OS/OS2_Invariance.lean` | Re-statement only |
| `OS/OS3_CovarianceRP.lean` | Inherits d=3 via `OS3_MixedRep` |
| `OS/OS3_ReflectionPositivity.lean` | Re-statement only |
| `OS/OS4_Ergodicity.lean` | Re-statement only |
| `OS/OS4_MGF.lean` | Re-statement only |

## 4. Imported unchanged from the 4D library

These files are truly dimension-agnostic — they don't mention `SpaceTime`/`STDimension`/`TestFunction`/`FieldConfiguration` and don't transitively import `Spacetime.Basic`. Importing them from `OSforGFF` is safe and keeps us aligned with upstream improvements.

```
OSforGFF.General.SchurProduct
OSforGFF.General.FrobeniusPositivity
OSforGFF.General.HadamardExp
OSforGFF.General.PositiveDefinite
OSforGFF.General.GaussianRBF
OSforGFF.General.FourierTransforms
OSforGFF.General.LaplaceIntegral
OSforGFF.General.QuantitativeDecay
OSforGFF.General.SchwartzTranslationDecay
OSforGFF.General.L2TimeIntegral
OSforGFF.Measure.Minlos
OSforGFF.Measure.NuclearSpace
```

Verified via: (a) grep for `SpaceTime|STDimension|TestFunction|FieldConfiguration` returns nothing, (b) no transitive `import OSforGFF.Spacetime.Basic`. If you adapt a file and find a usage that breaks this assumption, demote the affected file into §3 above and copy it.

## 5. Generalization notes

To port from d=4 to d=3, in order:

1. Change `abbrev STDimension := 4` → `:= 3` in the copied `Spacetime/Basic.lean`.
2. Replace `K₁` with `K_{1/2}` (use the closed form `√(π/(2z)) e^{−z}`) — most proofs in `BesselFunction.lean` simplify.
3. Update the heat kernel normalization `(4π t)^{−d/2}` to `(4π t)^{−3/2}`.
4. Update Plancherel scaling factors `(2π)^d → (2π)^3`.
5. Spatial integrability: decay rate must exceed `d − 1 = 2` (e.g., `α = 3`).
6. Replace `Fin.sum_univ_four` with `Fin.sum_univ_three`.
