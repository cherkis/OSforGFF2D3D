# Dimension Dependence — d = 2 spacetime

This document inventories how the 4D library's content is adapted for **spacetime dimension d = 2**. Spatial dimension is d − 1 = 1. The 4D classification (`Essential`, `Spatial`, `Structural`) is preserved, with the same caveat as the 3D doc:

1. **All Structural files that mention `SpaceTime`, `STDimension`, `TestFunction`, or `FieldConfiguration` — directly or via transitive import of `Spacetime.Basic` — must also be copied.** They are reclassified as **Structurally bound (d=2)**: the proof body is mechanical, but the *type* `SpaceTime = EuclideanSpace ℝ (Fin 2)` differs.
2. **Truly dimension-agnostic files** are imported from the 4D library unchanged. The list is identical to §4 of `dimension_dependence_3D.md`.

This doc IS the copy-list for the 2D port. When you adapt a file, update the per-file checklist in `PROGRESS.md`.

---

## 1. Essential (d=2) — formulas specific to d = 2

These files contain formulas whose closed form changes at d = 2.

### `General/BesselFunction.lean`
- 4D uses `K₁`; 3D uses `K_{1/2}`. At d=2 the relevant Bessel index is `d/2 − 1 = 0`, so the kernel is `K_0`.
- Define `besselK0 := besselK 0`. Unlike `K_{1/2}` (which has the Yukawa closed form `√(π/(2z))·e^{−z}`), `K_0` has no elementary closed form — it grows like `−log(z)` as z → 0⁺ and decays like `√(π/(2z))·e^{−z}` as z → ∞.
- The reference 2D project keeps a separate `BesselK0Proofs.lean` file for the d=2-specific properties; consider that pattern if `besselK0` grows large.

### `Covariance/Momentum.lean`
- Heat kernel: `heatKernelPositionSpace` writes `(4π t)^{−d/2}`; at d=2 this is `(4π t)^{−1}`.
- Bessel representation `freeCovarianceBessel`: at d=2 the formula is
  `C(x, y) = (1 / (2π)) · K₀(m · ‖x − y‖)`
  (up to normalization conventions — confirm against the reference).
- `covarianceSchwingerRep_eq_besselFormula` and `freeCovariance_regulated_tendsto_bessel` rewritten with the d=2 form.
- **Logarithmic singularity at coincidence.** Unlike d=3 (Yukawa, finite away from r=0 but bounded for r → ∞) and d=4 (1/r²), the d=2 covariance has a *logarithmic* divergence as r → 0⁺ because `K₀(z) ∼ −log(z/2) − γ` (Euler–Mascheroni). This is harmless for the smeared correlator since `−log(r)` is integrable on ℝ¹ near 0, but pointwise statements need care.

### `Covariance/Parseval.lean`
- Plancherel scaling `(2π)^d` becomes `(2π)^2` in `regulated_fubini_factorization`, `parseval_covariance_schwartz_regulated`, and the physics/Mathlib Fourier change of variables.

### `OS/OS3_MixedRepInfra.lean`
- `heatKernelPositionSpace_4D` → `heatKernelPositionSpace_2D`, converting `(4π t)^{−1}` explicitly.
- Schwinger proper-time Laplace `s`-integral uses the d=2 heat kernel.

### `OS/OS3_MixedRep.lean`
- Normalization identity: `(2π)^2 / (2π) = (2π)^1 = 2π` (d=2 analog of the d=4 identity `(2π)^4 / (2π) = (2π)^3` and d=3 identity `(2π)^3 / (2π) = (2π)^2`).
- Schwinger-to-Bessel reduction uses `besselK0`.

## 2. Spatial (d−1 = 1) — uses spatial dim = 1

### `General/FunctionalAnalysis.lean`
- 4D's `polynomial_decay_integrable_3d` (and 3D's `_2d`) becomes `polynomial_decay_integrable_1d`: `(1 + ‖x‖)^{−α}` is integrable on `ℝ¹ = ℝ` iff `α > 1`. Pick `α = 2` (the 3D port used `α = 4`; for d=2 spatial we can use `α = 2` or `α = 3` — either works, but consult downstream callers).

### `Spacetime/ProdIntegrable.lean`
- `SpatialCoords2` (3D port's name) → `SpatialCoords1 := EuclideanSpace ℝ (Fin 1)`, or simply use the `SpatialCoords` abbrev from `Spacetime/Basic.lean` directly. At d=2, `SpatialCoords ≡ EuclideanSpace ℝ (Fin 1) ≅ ℝ`.
- `spatialNormIntegral_linear_bound` uses 1D spatial integrals.
- **Edge case:** `Fin 1` has only one element (`⟨0, _⟩`), so spatial sums degenerate. Lemmas using `Fin.sum_univ_two` (3D) become `Fin.sum_univ_one` at d=2. Some proofs may simplify; others may need `Fin.cases` adjustments.

### `OS/OS1_Regularity.lean`
- `locallyIntegrable_of_rpow_decay_real` with `α = 2`: the singularity at d=2 is `‖x‖^{−(d−2)} = ‖x‖^0 = const`. Condition `α < d` ⇒ `α < 2`, so we need `α < 2`. (At d=3 we used `α = 2 < 3`, which doesn't carry over.) Pick `α = 1` or a fractional value. **Watch for this asymmetry** — d=2 is the borderline case where the OS1 power-decay singularity becomes constant.

### `OS/OS4_Clustering.lean`
- `Fin.sum_univ_four` (expanding `‖k‖² = k₀² + k₁² + k₂² + k₃²`) becomes `Fin.sum_univ_two` (`‖k‖² = k₀² + k₁²`).

## 3. Structurally bound (d=2) — proof body mechanical, types changed

These files reference `SpaceTime`/`STDimension`/`TestFunction`/`FieldConfiguration` or import a file that does. Adaptation is typically *just* re-stating with `STDimension := 2`. Watch for `Fin 3`-specific arithmetic (`Fin.sum_univ_three`, explicit index `⟨2, _⟩` lookups in spatial code — these break at d=2 spatial=1).

| File | Adaptation cue |
|------|----------------|
| `Spacetime/Basic.lean` | `abbrev STDimension := 2` (and `SpaceTime := EuclideanSpace ℝ (Fin 2)`); rest unchanged |
| `Spacetime/ComplexTestFunction.lean` | Re-statement only |
| `Spacetime/Decomposition.lean` | `ℝ² ≅ ℝ × ℝ¹ ≅ ℝ × ℝ`; the `spacetime_norm_sq_decompose` lemma reduces to `‖k‖² = (k 0)² + (k 1)²`; spatial part has one component |
| `Spacetime/DiscreteSymmetry.lean` | Time-reflection matrix in `O(2)`; index 0 unchanged |
| `Spacetime/Euclidean.lean` | `E(2) = O(2) ⋊ ℝ²` |
| `Spacetime/PositiveTimeTestFunction.lean` | Re-statement only |
| `Spacetime/TimeTranslation.lean` | Time-translation `Tₛ` shifts index 0; works for any d |
| `Spacetime/Tonelli.lean` | Re-statement only |
| `Schwinger/Defs.lean` | Schwinger n-point on `SpaceTime`-tuples |
| `Schwinger/TwoPoint.lean` | Re-statement only |
| `Schwinger/GaussianMoments.lean` | Re-statement only |
| `Covariance/Position.lean` | Inherits d=2 via `Covariance/Parseval` (Essential) |
| `Covariance/RealForm.lean` | Re-statement only |
| `Measure/Construct.lean` | Uses `SpaceTime` and `Spacetime/ComplexTestFunction` (both copied) |
| `Measure/GaussianFreeField.lean` | Imports `Covariance/Position`, `FunctionalAnalysis`, `OS/Axioms` (all copied) |
| `Measure/IsGaussian.lean` | Imports `OS0_Analyticity`, `GaussianMoments` (both copied) |
| `Measure/MinlosAnalytic.lean` | Imports `Spacetime.Basic` |
| `OS/Axioms.lean` | Axiom statements quantify over `TestFunction` |
| `OS/Master.lean` | Aggregates OS0–OS4 — re-statement only |
| `OS/NonTrivial.lean` | Same caveat as 3D: dim-agnostic chain (1–7) works; UV-divergence theorem needs `besselK0` divergence at the origin (which is logarithmic). At d=2 the divergence is *milder* than 3D — the prefactor is just `K₀(mr)` (no `1/r^(1/2)` factor), and `K₀(z) → +∞` as `z → 0⁺` carries the divergence alone. |
| `OS/OS0_Analyticity.lean` | Re-statement only |
| `OS/OS2_Invariance.lean` | Re-statement only |
| `OS/OS3_CovarianceRP.lean` | Inherits d=2 via `OS3_MixedRep` |
| `OS/OS3_ReflectionPositivity.lean` | Re-statement only |
| `OS/OS4_Ergodicity.lean` | Re-statement only |
| `OS/OS4_MGF.lean` | Re-statement only |

## 4. Imported unchanged from the 4D library

Same list as `dimension_dependence_3D.md` §4 — 12 truly dimension-agnostic files:

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

## 5. Generalization notes

To port from d=4 to d=2, in order:

1. Change `abbrev STDimension := 4` → `:= 2` in the copied `Spacetime/Basic.lean`.
2. Replace `K₁` (or 3D's `K_{1/2}`) with `K₀`. No elementary closed form; use `besselK0 := besselK 0` and prove the d=2-specific properties (`besselK0_continuousOn`, `besselK0_pos`, asymptotic / near-origin bounds). The reference 2D project keeps these in a separate `BesselK0Proofs.lean`.
3. Update the heat kernel normalization `(4π t)^{−d/2}` to `(4π t)^{−1}`.
4. Update Plancherel scaling factors `(2π)^d → (2π)^2`.
5. Spatial integrability: decay rate must exceed `d − 1 = 1` (e.g., `α = 2`).
6. Replace `Fin.sum_univ_four` (spacetime, 4 components) with `Fin.sum_univ_two`. Replace `Fin.sum_univ_three` (spatial, 4D's spatial=3) with `Fin.sum_univ_one`. **Fin 1 is degenerate** — there's only one element; many spatial proofs simplify but some `Fin.cases` patterns need adjustment.
7. **`OS/OS1_Regularity.lean` borderline case:** at d=2 the singularity `‖x‖^{−(d−2)}` becomes constant; pick `α < 2` (not `α = 2` as in d=3).
8. **`OS/NonTrivial.lean` UV divergence:** at d=2 the divergence is purely logarithmic (carried by `K₀(z) → +∞ ~ −log(z)` as `z → 0⁺`), no `1/r^(1/2)` prefactor. Simpler than 3D once a `besselK0_tendsto_atTop_at_zero` lemma is available.

## 6. Notes on the reference 2D project

The reference at `../OSforGFFin3Dand2D/OSforGFFin2D/` has all files ported (against an older mathlib). Useful patterns to port:

- `BesselFunction.lean` — defines both `besselK0` and `besselK1` (the K_1 stuff is leftover/generic; use `besselK0` for the d=2 covariance).
- `BesselK0Proofs.lean` — d=2-specific properties of `K₀` (separated for organizational reasons; we can inline them in our `General/BesselFunction.lean` if cleaner).
- `LatticeSpacetime.lean` — only present in the 2D reference; likely a lattice-regularization helper. Not needed for OS axiom verification — skip unless explicitly required.
- `CovarianceMomentum.lean` — the d=2 momentum/Bessel infrastructure; expect mathlib drift fixes similar to those we applied in the 3D Momentum port (see PROGRESS.md decisions log).
