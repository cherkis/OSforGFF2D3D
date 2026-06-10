# Foundational Definitions: 3D / 2D — what's different from 4D

This document catalogs the definitions, structures, and axioms that change between the 4D
library and the 3D / 2D libraries, plus the few that are wholly new. Helper lemmas and
theorems are mostly omitted; only the load-bearing objects are listed.

For the 4D originals see `https://github.com/mrdouglasny/OSforGFF/tree/main/docs/foundational_definitions.md`
(or `@../OSforGFFin3D/docs/foundational_definitions.md` if you have the local clone).

---

## Axioms — none assumed

Neither library introduces any `axiom`, and neither does the reachable part of the 4D
dependency. The GFF construction is fully proved: `minlos_theorem`
(`BochnerMinlos/Minlos/Main.lean`) is a `theorem`, not an axiom. `#print axioms` on the
master theorem `OSforGFF.gaussianFreeField_satisfies_all_OS_axioms` returns, in both
dimensions, only Lean's standard `propext`, `Classical.choice`, `Quot.sound`.

---

## Spacetime types — only the dimension changes

The single source of dimension dependence is `Spacetime/Basic.lean`. The literal change is
the value of `STDimension`; all dependent abbreviations are unchanged in body and re-emit
the right Lean type because `STDimension` is an `abbrev`.

| Name | 4D | OSforGFFin3D | OSforGFFin2D |
|------|----|--------------|--------------|
| `STDimension` | `4` | `3` | `2` |
| `SpaceTime` | `EuclideanSpace ℝ (Fin 4)` | `EuclideanSpace ℝ (Fin 3)` | `EuclideanSpace ℝ (Fin 2)` |
| `TestFunction` | `S(ℝ⁴, ℝ)` | `S(ℝ³, ℝ)` | `S(ℝ², ℝ)` |
| `TestFunctionℂ` | `S(ℝ⁴, ℂ)` | `S(ℝ³, ℂ)` | `S(ℝ², ℂ)` |
| `FieldConfiguration` | `S'(ℝ⁴)` | `S'(ℝ³)` | `S'(ℝ²)` |
| `SpatialCoords` | `EuclideanSpace ℝ (Fin 3)` | `EuclideanSpace ℝ (Fin 2)` | `EuclideanSpace ℝ (Fin 1)` |
| `SpatialL2` | $L^2(\mathbb{R}^3)$ | $L^2(\mathbb{R}^2)$ | $L^2(\mathbb{R}^1)$ |

Notes:

- `spatialPart` in 2D has only one component (`Fin 1`). The proof
  `spatialPart_proof = by have := i.isLt; simp [STDimension] at this ⊢` collapses correctly.
- `Spacetime/Decomposition.lean` gives $\mathbb{R}^d \cong \mathbb{R} \times \mathbb{R}^{d-1}$
  via `MeasurableEquiv.piFinSuccAbove`; the proof structure is identical to 4D, but the
  norm-decomposition lemma `spacetime_norm_sq_decompose` uses `Fin.sum_univ_three` (3D) or
  `Fin.sum_univ_two` (2D) instead of `Fin.sum_univ_four`. This is one of the few places where
  the dimension enters the proof body explicitly.

The pairings, generating functionals, and complex extensions
(`distributionPairing`, `GJGeneratingFunctional`, `distributionPairingℂ_real`,
`GJGeneratingFunctionalℂ`, `GJMean`) are restated verbatim with no body changes.

---

## Discrete symmetries and Euclidean group — only the dimension changes

| Name | Body | What changes |
|------|------|--------------|
| `QFT.timeReflection` | $(t, \bar x) \mapsto (-t, \bar x)$ | acts on $\mathbb{R}^d$ for current $d$ |
| `QFT.timeReflectionIsometry` | element of $O(d)$ | $O(3)$ in 3D, $O(2)$ in 2D |
| `QFT.compTimeReflection` | pullback on complex test functions | unchanged |
| `QFT.O4` (renamed convention) | `LinearIsometry ℝ SpaceTime SpaceTime` | name retained for compatibility; means $O(3)$ / $O(2)$ in this project |
| `QFT.E` | semidirect product $\mathbb{R}^d \rtimes O(d)$ | $E(3) = O(3) \ltimes \mathbb{R}^3$ in 3D, $E(2)$ in 2D |
| `QFT.act`, `QFT.euclidean_action`, `QFT.euclidean_action_CLM` | pullback by inverse | unchanged |
| `timeShift`, `timeTranslationSchwartzCLM`, `timeTranslationDistribution` | shift index 0 | unchanged |
| `HasPositiveTime`, `PositiveTimeTestFunction(ℂ)` | $x_0 > 0$ | unchanged |
| `starTestFunction` | $(\star f)(x) = \overline{f(\Theta x)}$ | unchanged |

The name `QFT.O4` is preserved for diff compatibility with the 4D upstream; it does **not**
denote $O(4)$ in these libraries.

---

## Free covariance — dimension-specific closed form

The position-space covariance is defined directly via the dimension-appropriate Bessel form
and proved equal to the Schwinger integral.

### Common (all dimensions)

| Name | Definition |
|------|------------|
| `freePropagatorMomentum` | $P(k) = 1/(\|k\|^2 + m^2)$ |
| `freePropagatorMomentum_mathlib` | $1/((2\pi)^2 \|k\|^2 + m^2)$ — Mathlib Fourier convention |
| `schwingerIntegrand` | $\exp(-t(\|k\|^2 + m^2))$ |
| `covarianceSchwingerRep` | $\int_0^\infty e^{-tm^2}\, H(t, r)\, dt$ |
| `freeCovariance` | alias for `freeCovarianceBessel` |
| `momentumWeightSqrt` | $1/\sqrt{\|k\|^2 + m^2}$ |
| `momentumWeightSqrt_mul_CLM` | multiplication by $\sqrt{P}$ as bounded op on $L^2$ |

### `heatKernelPositionSpace`

The Lean definition is dimension-uniform — it writes $(4\pi t)^{-d/2}$ symbolically — but
each library has its own evaluation lemma:

| Library | Evaluation lemma |
|---------|------------------|
| 4D | `heatKernelPositionSpace_4D` : $(4\pi t)^{-2}$ |
| 3D | `heatKernelPositionSpace_3D` : $(4\pi t)^{-3/2}$ |
| 2D | `heatKernelPositionSpace_2D` : $(4\pi t)^{-1}$ |

### `freeCovarianceBessel` — the closed form

| Library | Body (for $r = \|x - y\| \neq 0$) |
|---------|-----------------------------------|
| 4D | $\dfrac{m}{4\pi^2 r}\, K_1(m r)$ |
| 3D | $\dfrac{1}{(4\pi)^{3/2}} \cdot 2 \cdot (2m/r)^{1/2}\, K_{1/2}(m r)$ |
| 2D | $\dfrac{1}{2\pi}\, K_0(m r)$ |

All three implementations return `0` at $r = 0$ for definedness. Symmetry, positivity,
real-coercion lemmas (`freeCovarianceBessel_symm`, `freeCovarianceBessel_pos`,
`freeCovariance_star`) follow the same template in every dimension.

---

## Bessel apparatus — new in 3D and 2D

### `OSforGFFin3D/General/BesselFunction.lean`

The 4D library exposes only `besselK1`. The 3D library generalises:

| Line | Name | Definition |
|------|------|------------|
| 46 | `besselK ν z` | $\int_0^\infty e^{-z \cosh t}\cosh(\nu t)\,dt$ — generic order |
| 51 | `besselKhalf z` | `besselK (1/2) z` — d=3 Bessel index |
| 81 | `besselK_integrableOn_Ioi` | integrability of the cosh integrand |
| 171 | `besselK_integrableOn_Ici` | **new** — needed only by the UV divergence proof |
| 368 | `besselK_pos`, … | positivity, continuity, asymptotic bounds |
| 569 | `besselK_mul_self_le`, `besselK_near_origin_bound` | small-$z$ bounds |
| 715 | `radial_besselK_integrable` | radial integrability of $K_\nu(mr)$ |
| 992 | `schwingerIntegral_eq_besselK` | $\int_0^\infty t^{-\nu-1} e^{-t - z^2/(4t)}\,dt = K_\nu$ identity |
| 1045 | `besselKhalf_pos`, … | $K_{1/2}$-specialised analogues of the generic lemmas |
| 1099 | `besselK_tendsto_atTop_at_zero` | **new** — $K_\nu(z) \to +\infty$ as $z \to 0^+$ |
| 1157 | `besselKhalf_tendsto_atTop_at_zero` | **new** — specialisation used by `NonTrivial.lean` |

The closed form $K_{1/2}(z) = \sqrt{\pi/(2z)}\, e^{-z}$ is not used as a definition; it is
recovered through `schwingerIntegral_eq_besselKhalf` plus algebraic manipulation in
`Covariance/Momentum.lean`.

### `OSforGFFin2D/General/BesselFunction.lean` + `BesselK0Proofs.lean`

The 2D library splits Bessel apparatus across two files. `BesselFunction.lean` keeps the
4D-aligned $K_1$ apparatus (the 2D MixedRep proof still threads through $K_1$ identities at
intermediate steps) plus the basic $K_0$ definition. `BesselK0Proofs.lean` collects
$K_0$-specific results that have no 4D analog:

| File | Name | Notes |
|------|------|-------|
| BesselFunction.lean | `besselK0`, `besselK1`, `besselK1_properTime` | definitions |
| BesselFunction.lean | `besselK1_eq_properTime`, `besselK1_asymptotic` | shared with 4D |
| BesselFunction.lean | `schwingerIntegral_eq_besselK1` | shared with 4D |
| BesselK0Proofs.lean | `besselK0_integrand_Ioi_integrable` | **new** integrability of cosh integrand |
| BesselK0Proofs.lean | `Ici_split`, `Icc_disjoint_Ioi` | **new** helpers |
| BesselK0Proofs.lean | `besselK0_pos`, `besselK0_continuousOn` | **new** basic properties |
| BesselK0Proofs.lean | `besselK0_asymptotic` | **new** decay for $z \ge 1$ |
| BesselK0Proofs.lean | `besselK0_near_origin_bound` | **new** logarithmic small-$z$ bound |
| BesselK0Proofs.lean | `besselK0_integrable_near_zero` | **new** integrability around 0 |
| BesselK0Proofs.lean | `schwingerIntegral_eq_besselK0` | **new** Schwinger identity for $K_0$ |
| BesselK0Proofs.lean | `besselK0_integrand_Ici_integrable` | **new** — needed only by UV divergence |
| BesselK0Proofs.lean | `besselK0_tendsto_atTop_at_zero` | **new** — used by `NonTrivial.lean` |

---

## Schwinger functions and Measure layer — unchanged

`SchwingerFunction`, `SchwingerFunction₁`, `SchwingerFunction₂`, `CovarianceBilinear`,
`IsGaussianMeasure`, `SmearedTwoPointFunction`, `SchwingerTwoPointFunction`,
`IsNuclearMap`, `NuclearSpace`, `gaussian_characteristic_functional`, `CovarianceForm`,
`isCenteredGJ`, `isGaussianGJ`, `gaussianFreeField_free`, `freeCovarianceForm` all retain
their 4D definitions verbatim — only the underlying `SpaceTime` type changes.

---

## OS axiom statements — unchanged

`OS0_Analyticity`, `OS1_Regularity`, `OS2_EuclideanInvariance`, `OS3_ReflectionPositivity`,
`OS3_ReflectionPositivity_real`, `OS4_Clustering`, `OS4_Ergodicity`, `SatisfiesAllOS`
remain verbatim. The master theorem in each library is

```lean
theorem gaussianFreeField_satisfies_all_OS_axioms (m : ℝ) [Fact (0 < m)] :
    SatisfiesAllOS (μ_GFF m)
```

For a per-axiom correctness audit see `@../OSforGFFin3D/docs/definitions_entering_OS_axioms.md` —
the assessment carries over unchanged to 3D and 2D because the body of every axiom statement
is identical. See `definitions_entering_OS_axioms.md` (this directory) for a brief restatement.

---

## Nontriviality

### `OSforGFFin3D/OS/NonTrivial.lean` and `OSforGFFin2D/OS/NonTrivial.lean`

This file exists in the 4D library too; ours are copied, dimension-adapted versions (it is
listed as a copied file in `dimension_dependence_*.md`). The theorems and their locations:

| Line | Name | Definition / claim |
|------|------|--------------------|
| 61 | `toComplex_injective` | embedding $\mathcal{S}(\mathbb{R}^d, \mathbb{R}) \hookrightarrow \mathcal{S}(\mathbb{R}^d, \mathbb{C})$ is injective |
| 72 | `fourierTransform_schwartz_injective` | Fourier transform is injective on complex Schwartz space |
| 96 | `eq_zero_of_continuous_ae_zero` | continuous $f \equiv_{ae} 0 \Rightarrow f \equiv 0$ (uses `IsOpenPosMeasure` on volume) |
| 118 | `sqrtPropagatorMap_eq_zero_iff` | $\sqrt{P}\cdot \widehat{f} \equiv 0 \iff f \equiv 0$ |
| 157 | `embeddingMap_injective` | the square-root propagator embedding $T : \mathcal{S}(\mathbb{R}^d, \mathbb{R}) \hookrightarrow L^2$ is injective |
| 197 | `freeCovarianceFormR_strictPos` | $C(f, f) > 0$ for $f \neq 0$ |
| 210 | `gaussianFreeField_variance_pos` | $\operatorname{Var}[\langle \omega, f\rangle] > 0$ under $\mu_{\text{GFF}}$ for $f \neq 0$ |
| 222 | `gaussianFreeField_not_dirac` | $\mu_{\text{GFF}} \neq \delta_0$ |
| 247 (3D) / 246 (2D) | `freeCovariance_tendsto_atTop` | $C(x, y) \to +\infty$ as $x \to y$ |

The first eight theorems are dimension-independent in proof structure; only `SpaceTime`
type changes. The ninth — UV divergence at coincident points — is the only theorem in this
file whose proof differs between 3D and 2D:

- **3D** combines `besselKhalf_tendsto_atTop_at_zero` with a constant lower bound on the
  prefactor $(2m/r)^{1/2} \ge (2m)^{1/2}$ for $r \le 1$ (the $r^{-1/2}$ factor only helps).
- **2D** uses `besselK0_tendsto_atTop_at_zero` and multiplies by the constant prefactor
  $1/(2\pi)$. The proof is shorter because the closed form is $C \cdot K_0(mr)$ with no
  $r$-dependent prefactor.

Both proofs share the same outer scaffolding: lift $x \to x_0$ to $r \to 0^+$, push through
$r \mapsto m r$, compose with the Bessel limit, multiply by the positive constant, and
filter-upwards to identify with `freeCovarianceBessel`.

---

## General mathematics — mostly unchanged

The dimension-agnostic `General/` files (`SchurProduct`, `FrobeniusPositivity`, `HadamardExp`,
`PositiveDefinite`, `GaussianRBF`, `FourierTransforms`, `LaplaceIntegral`, `QuantitativeDecay`,
`SchwartzTranslationDecay`, `L2TimeIntegral`) are imported from the 4D library unchanged.

Only `General/FunctionalAnalysis.lean` is copied and adapted:

| Library | `polynomial_decay_integrable_*d` |
|---------|----------------------------------|
| 4D | `_3d` with required decay $> 3$ (4D Plancherel needs spatial integrability on $\mathbb{R}^3$) |
| 3D | `_2d` with required decay $> 2$ (3D Plancherel needs spatial integrability on $\mathbb{R}^2$) |
| 2D | `_1d` with required decay $> 1$ (2D Plancherel needs spatial integrability on $\mathbb{R}^1$) |

The `schwartzToL2` continuous embedding and `SchwartzMap.translate` are restated unchanged.
