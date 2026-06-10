# Architecture (d = 3 and d = 2)

How the two libraries fit together, and where they differ from the 4D reference at
`https://github.com/mrdouglasny/OSforGFF`. Each row below names the directory that holds
the dimension-specific copy; the row count records how many files survive the dimension
audit. The truly dimension-agnostic files (mostly `General/*` plus `Measure/Minlos` and
`Measure/NuclearSpace`) are imported from the 4D library and are not re-counted here.

For the per-file copy list see `dimension_dependence_3D.md` and `dimension_dependence_2D.md`.

## Dependency layers

Both libraries reuse the same layering as the 4D library:

```
General ──→ Spacetime ──→ Covariance ──→ Schwinger ──→ Measure ──→ OS
```

| Layer          | 4D files | OSforGFFin3D | OSforGFFin2D |
|----------------|---------:|-------------:|-------------:|
| General        |       12 |            2 |            3 |
| Spacetime      |        9 |            9 |            9 |
| Covariance     |        4 |            4 |            4 |
| Schwinger      |        3 |            3 |            3 |
| Measure        |        6 |            4 |            4 |
| OS             |       13 |           13 |           13 |
| **Total**      |   **47** |       **35** |       **36** |

The 2D library carries one extra `General/` file (`BesselK0Proofs.lean`), and its
dimension-specific Bessel apparatus (`besselKhalf`, `besselK0`, generic `besselK`) is new
relative to 4D, which exposes only `besselK1` — see §3. `OS/NonTrivial.lean` exists in all
three libraries (it is a copied, dimension-adapted file, not new); the dimension enters only
in its UV-divergence proof — see §4.

## Cross-cutting edge

Same as 4D: `Measure/IsGaussian` imports `OS/OS0_Analyticity` to use the proved analyticity
for the identity-theorem argument S₂ = C. Not circular: OS0 depends on `Measure/Construct`
(the measure must exist before we can prove analyticity), and `IsGaussian` feeds back into
OS1–OS4 (which need S₂ = C).

## Foundational axioms (none assumed)

The GFF construction is fully proved — in particular `minlos_theorem`
(`BochnerMinlos/Minlos/Main.lean`) is a `theorem`, not an axiom, and the GFF measure's
existence and uniqueness are derived, not posited.

`#print axioms` on the master theorem `OSforGFF.gaussianFreeField_satisfies_all_OS_axioms`
returns, in **both** dimensions, only Lean's three standard foundational axioms:

```
propext, Classical.choice, Quot.sound
```

There are no project-specific assumed axioms — neither in these libraries nor in the
reachable part of the 4D dependency. (Some `axiom` declarations exist in unrelated
experimental/test modules of deeper dependencies — e.g. `GaussianField/Cylinder/*` and
`BochnerMinlos/Test/WhiteNoise.lean` — but none are imported by the OS proof chain, as the
axiom check above confirms.)

## What changes by dimension

### 1. The closed-form covariance

The massive scalar propagator $C(x,y)$ in $d$ Euclidean dimensions involves the modified
Bessel function $K_{d/2 - 1}$. The libraries fix the closed form:

| $d$ | Bessel index | Closed form $C(x,y)$, $r = \|x - y\|$ |
|-----|------|--------------|
| 4   | $\nu = 1$   | $\dfrac{m}{4\pi^2 r}\,K_1(mr)$ |
| 3   | $\nu = 1/2$ | $\dfrac{1}{(4\pi)^{3/2}}\cdot 2\,(2m/r)^{1/2}\,K_{1/2}(mr) \;=\; \dfrac{e^{-mr}}{4\pi r}$ |
| 2   | $\nu = 0$   | $\dfrac{1}{2\pi}\,K_0(mr)$ |

The 3D form is the **Yukawa potential** because $K_{1/2}$ admits the closed expression
$K_{1/2}(z) = \sqrt{\pi/(2z)}\,e^{-z}$. The 2D form retains a transcendental $K_0$ — there
is no elementary closed form.

### 2. The UV singularity

The closed form gives the leading short-distance behaviour:

| $d$ | $C(x,y)$ as $r \to 0^+$ |
|-----|--------------------------|
| 4   | $\sim r^{-2}$  (quadratic) |
| 3   | $\sim r^{-1}$  (Coulomb) |
| 2   | $\sim -\log r$ (logarithmic) |

In every dimension $C(x,y) \to +\infty$, so $\mu_{\text{GFF}}$ does not concentrate on
functions — its support consists of genuine distributions. The proofs of this divergence
live in `OS/NonTrivial.lean` (3D and 2D); see §4.

### 3. Heat-kernel and Plancherel constants

Both libraries thread the dimension constant through every place where the 4D library
hardcoded `Fin.sum_univ_four`, $(4\pi t)^{-d/2}$, or $(2\pi)^d$:

| Constant      | $d = 4$            | $d = 3$            | $d = 2$         |
|---------------|--------------------|--------------------|-----------------|
| Heat kernel   | $(4\pi t)^{-2}$    | $(4\pi t)^{-3/2}$  | $(4\pi t)^{-1}$ |
| Plancherel    | $(2\pi)^4$         | $(2\pi)^3$         | $(2\pi)^2$      |
| Norm expansion| `Fin.sum_univ_four`| `Fin.sum_univ_three` | `Fin.sum_univ_two` |

### 4. Spatial integrability

`OS1_Regularity` needs $r \mapsto C(x, y)$ to be locally integrable. The singularity is
$r^{-(d-2)}$, the spatial dimension is $d - 1$, and integrability holds iff $d - 2 < d - 1 + 1$,
i.e. always. The Lean lemma `polynomial_decay_integrable_*d` is restated per dimension with
the relevant decay rate ($\alpha > d - 1$). At $d = 2$ it becomes "decay $>\!1$"; at $d = 3$,
"decay $>\!2$".

## OS3: the longest proof chain (per-dimension specifics)

Both libraries carry the full Schwinger / mixed-representation / reflection-positivity
chain. The dimension enters in three predictable places:

1. **MixedRepInfra**: the explicit heat-kernel expansion. 3D produces `(4π t)^{-3/2}`;
   2D produces `(4π t)^{-1}`. The Schwinger proper-time Laplace integral uses the
   dimension-correct heat kernel.

2. **MixedRep**: a constant identity. 4D uses $(2\pi)^4 / (2\pi) = (2\pi)^3$;
   3D uses $(2\pi)^3 / (2\pi) = (2\pi)^2$; 2D uses $(2\pi)^2 / (2\pi) = (2\pi)$.

3. **The Schwinger-to-Bessel reduction**: 3D collapses to the elementary Yukawa form;
   2D retains $K_0$ via `schwingerIntegral_eq_besselK0`.

The structural arguments — Schwinger parametrization to make all integrals absolutely
convergent, the Gaussian UV regulator, the Schur–Hadamard lift for the reflection-positive
matrix, the bridge from real to complex test functions — are unchanged.

## OS4: two-stage argument (unchanged in structure)

1. **Clustering**: Gaussian factorization reduces clustering to estimating
   $S_2(f, T_{-s} g)$, which decays as $(1 + |s|)^{-\alpha}$ by Schwartz convolution decay
   with the exponential kernel $e^{-m|x|}$.

2. **Ergodicity**: Polynomial clustering with $\alpha = 6$ feeds into the $L^2$ time-average
   bound $\|(1/t) \int_0^t A(T_s \varphi)\,ds - \mathbb{E}[A]\|^2 \le C/t \to 0$.

The $\alpha = 6$ figure is dimension-independent: it comes from picking $\alpha$ large enough
that $\sum_n n^{d-1} (1 + n)^{-\alpha}$ converges in the relevant decomposition. The
dimension enters only through `Fin.sum_univ_*` in the norm expansion.

## Key design choices (with per-dimension notes)

- **Schwartz over $\mathcal{D}$**: We continue to use $\mathcal{S}(\mathbb{R}^d)$ rather than
  $\mathcal{D}(\mathbb{R}^d)$ because Mathlib has `SchwartzSpace` but not compactly-supported
  test functions. Since $\mathcal{D} \subset \mathcal{S}$ and $\mathcal{S}' \subset \mathcal{D}'$,
  our axioms imply the Glimm–Jaffe versions.

- **Schwinger parametrization for OS3**: Identical structure in 3D and 2D. The integral
  $C = \int_0^\infty e^{-sm^2} H_s\,ds$ is convergent in any dimension; only the closed form
  of $H_s$ changes.

- **Gaussian regulator for Parseval**: Same justification. In 3D and 2D the bare propagator
  $1/(\|k\|^2 + m^2)$ is *more* integrable than at $d = 4$ (it lies in $L^p$ for $p > d/2$),
  but we keep the regulator for proof uniformity.

- **Bessel kernel choice**: We define $C$ in position space via the closed form and then
  prove it equals the Schwinger integral. 3D uses `besselKhalf := besselK (1/2)`; 2D uses
  `besselK0` (defined directly via the cosh integral, with no detour through a general
  `besselK ν`). See §3 below.

## §3 — New Bessel infrastructure

The 4D library has a single `General/BesselFunction.lean` providing `besselK1`. Each of the
3D and 2D libraries replaces this with the apparatus they actually need.

### `OSforGFFin3D/General/BesselFunction.lean`

Generalises 4D's `besselK1` to arbitrary order:

- `besselK ν z := ∫₀^∞ exp(-z cosh t) cosh(ν t) dt` — generic order, used for both the d=3
  Bessel index $\nu = 1/2$ and for stating the index-dependent asymptotic bound.
- `besselKhalf z := besselK (1/2) z` — the 3D kernel.
- `besselKhalf_pos`, `besselKhalf_continuousOn`, `besselKhalf_asymptotic`,
  `besselKhalf_mul_self_le`, `besselKhalf_near_origin_bound`,
  `radial_besselKhalf_integrable`, `schwingerIntegral_eq_besselKhalf` — drop-in analogs of
  the 4D `besselK1_*` lemmas, used by `Covariance/Momentum.lean` and `OS3_MixedRep*`.
- `besselK_tendsto_atTop_at_zero` and its specialisation
  `besselKhalf_tendsto_atTop_at_zero` — **new** lemmas asserting the divergence
  $K_\nu(z) \to +\infty$ as $z \to 0^+$. Used by `OS/NonTrivial.lean`; no analog in 4D.
- `besselK_integrableOn_Ici` — **new** lemma needed only by the divergence proof.

### `OSforGFFin2D/General/BesselFunction.lean` and `BesselK0Proofs.lean`

The 2D library splits Bessel work across two files:

- `BesselFunction.lean` carries `besselK0`, `besselK1`, the proper-time representation
  `besselK1_properTime`, equivalence `besselK1_eq_properTime`, positivity, the cosh
  integrability lemmas, and `schwingerIntegral_eq_besselK1`.
- `BesselK0Proofs.lean` contains the $K_0$-specific apparatus that has no $K_1$ counterpart:
  `besselK0_pos`, `besselK0_continuousOn`, `besselK0_asymptotic`,
  `besselK0_near_origin_bound`, `besselK0_integrable_near_zero`,
  `schwingerIntegral_eq_besselK0`, plus the **new** `besselK0_integrand_Ici_integrable` and
  `besselK0_tendsto_atTop_at_zero` for the UV divergence proof.

Splitting this off keeps `BesselFunction.lean` aligned line-by-line with the 4D file so
upstream changes can still be tracked.

## §4 — `OS/NonTrivial.lean` (nontriviality + UV divergence)

`OS/NonTrivial.lean` is present in all three libraries (4D, 3D, 2D); ours are copied,
dimension-adapted versions. Like 4D, each proves the GFF measure is non-Dirac.
The file proves (i) `embeddingMap_injective` — the square-root propagator embedding
$T : \mathcal{S}(\mathbb{R}^d, \mathbb{R}) \hookrightarrow L^2$ is injective; (ii) strict
positivity `C(f,f) > 0` for $f \neq 0$; (iii) strict positivity of the variance under
$\mu_{\text{GFF}}$; (iv) `gaussianFreeField_not_dirac`; and (v) the UV divergence
`freeCovariance_tendsto_atTop`: $C(x,y) \to +\infty$ as $x \to y$.

The UV divergence is the only OS-axiom-adjacent statement in the project where 3D and 2D
proofs diverge structurally:

- **3D** uses `besselKhalf_tendsto_atTop_at_zero` and then bounds the prefactor
  $(2m/r)^{1/2}$ from below by the constant $(2m)^{1/2}$ for $r \le 1$.
- **2D** uses `besselK0_tendsto_atTop_at_zero` and multiplies by the positive constant
  $1/(2\pi)$. The bound is cleaner because the closed form has no $r$-dependent prefactor.

Both proofs share the same outer scaffold (continuity of $r$, push to $\to 0^+$, compose
with the Bessel limit, use `Filter.Tendsto.const_mul_atTop`).

## §5 — What stayed the same (and why)

Every theorem statement in `OSforGFFin3D/OS/Axioms.lean` and `OSforGFFin2D/OS/Axioms.lean`
matches the 4D version verbatim, modulo the value of `STDimension`. The Lean type
`SpaceTime = EuclideanSpace ℝ (Fin STDimension)` is the only object that changes; everything
quantified over `SpaceTime`, `TestFunction`, `FieldConfiguration` inherits the new dimension
transparently.

This means: a paper proof of OS0–OS4 for the massive GFF — whether stated for $d = 4$,
$d = 3$, or $d = 2$ — translates to the same Lean theorem statement, only with a different
`STDimension`. The master theorem in each library is

```lean
theorem gaussianFreeField_satisfies_all_OS_axioms (m : ℝ) [Fact (0 < m)] :
    SatisfiesAllOS (μ_GFF m)
```

with `μ_GFF m : ProbabilityMeasure FieldConfiguration` built over the dimension-appropriate
`SpaceTime`.
