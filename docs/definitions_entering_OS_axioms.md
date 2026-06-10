# Definitions Entering the OS Axiom Statements (d = 3 and d = 2)

The master theorems are:

```lean
-- OSforGFFin3D/OS/Master.lean
theorem gaussianFreeField_satisfies_all_OS_axioms (m : ℝ) [Fact (0 < m)] :
    SatisfiesAllOS (μ_GFF m)        -- μ_GFF : ProbabilityMeasure (S'(ℝ³))

-- OSforGFFin2D/OS/Master.lean
theorem gaussianFreeField_satisfies_all_OS_axioms (m : ℝ) [Fact (0 < m)] :
    SatisfiesAllOS (μ_GFF m)        -- μ_GFF : ProbabilityMeasure (S'(ℝ²))
```

A correct proof guarantees the theorem statement is true only relative to the definitions
it references. The 4D library's audit at
`@../OSforGFFin3D/docs/definitions_entering_OS_axioms.md` checks each of the thirteen
definitions entering OS0–OS4. **That audit carries over verbatim to the 3D and 2D
libraries**: every axiom statement and every supporting definition is copied unchanged,
modulo `STDimension`.

This short companion document records that fact explicitly and notes the (few) places where
the dimension is observable in the *statement* rather than only in the underlying type.

---

## The audit applies unchanged

The thirteen items checked in the 4D audit — sign of $i$, $\mathbb{C}$-linearity of the
complex pairing, the OS3 matrix entry $Z_\mathbb{C}[f_i - \Theta f_j]$, the
time-reflection convention, the Euclidean action sign, the semidirect product structure,
the clustering direction, the OS4 observable class, the positive-time support condition,
and the OS0/OS1/OS2 statements — all use *only* the dimension-agnostic types
`TestFunction`, `TestFunctionℂ`, `FieldConfiguration`, `QFT.E`, `QFT.timeReflection`,
`PositiveTimeTestFunction(ℂ)`. The only change is that these types now resolve to functions
on $\mathbb{R}^3$ (resp. $\mathbb{R}^2$).

| # | Definition | 4D verdict | 3D / 2D verdict |
|---|------------|------------|-----------------|
| 1 | `GJGeneratingFunctional` (sign of $i$) | ✓ | ✓ (unchanged) |
| 2 | `distributionPairingℂ_real` ($\mathbb{C}$-linearity) | ✓ | ✓ (unchanged) |
| 3 | `distributionPairing` (evaluation) | ✓ | ✓ (unchanged) |
| 4 | `OS3_ReflectionPositivity` (complex coeff + test fns) | ✓ | ✓ (unchanged) |
| 5 | `timeReflection` (negates coord 0) | ✓ | ✓ (unchanged) |
| 6 | `euclidean_action` (pullback by $g^{-1}$) | ✓ | ✓ (unchanged) |
| 7 | `QFT.E` (semidirect product) | ✓ | ✓ (now $E(3)$ / $E(2)$) |
| 8 | `OS4_Clustering` (all directions) | ✓ | ✓ (unchanged) |
| 9 | `OS4_Ergodicity` (observable class) | ✓ | ✓ (unchanged) |
| 10 | `PositiveTimeTestFunction` (`tsupport`) | ✓ | ✓ (unchanged) |
| 11 | `OS0_Analyticity` (entire on $\mathbb{C}^n$) | ✓ | ✓ (unchanged) |
| 12 | `OS1_Regularity` ($L^p$ bound) | ✓ | ✓ (unchanged) |
| 13 | `OS2_EuclideanInvariance` ($Z[f] = Z[g \cdot f]$) | ✓ | ✓ (unchanged) |

---

## Where the dimension is observable in statements

Three places in the supporting infrastructure show the dimension explicitly:

1. **The closed form for the free covariance** `freeCovarianceBessel m x y`. The
   *statement* of `Schwinger/TwoPoint.lean` lemmas equating
   `SchwingerTwoPointFunction = freeCovariance` is dimension-agnostic, but the body of
   `freeCovariance` differs:

   | $d$ | `freeCovariance m x y` for $r = \|x - y\| \neq 0$ |
   |-----|---------------------------------------------------|
   | 4   | $(m / 4\pi^2 r)\, K_1(m r)$ |
   | 3   | $(4\pi)^{-3/2} \cdot 2 \cdot (2m/r)^{1/2}\, K_{1/2}(m r)$ |
   | 2   | $(2\pi)^{-1}\, K_0(m r)$ |

   The dimension does not appear in the *theorem* `SchwingerTwoPointFunction = freeCovariance`,
   only in the definition that *both sides* now expand to. This is the intended behaviour:
   the OS0–OS4 statements quantify over a measure, and the measure's two-point function
   takes the dimension-correct closed form by construction.

2. **`spacetime_norm_sq_decompose`** in `Spacetime/Decomposition.lean`. Used inside the OS3
   and OS4 proofs to expand $\|k\|^2 = k_0^2 + \|\bar k\|^2$. The statement is the same
   in every dimension; the proof uses `Fin.sum_univ_three` (3D) or `Fin.sum_univ_two` (2D)
   instead of `Fin.sum_univ_four`. This is invisible to a user of OS0–OS4.

3. **`polynomial_decay_integrable_*d`** in `General/FunctionalAnalysis.lean`. It states that
   $1/(1 + \|x\|)^{\alpha}$ is integrable on a spatial slice $\mathbb{R}^{d-1}$, where
   $\alpha$ is the decay exponent at infinity; `integrable_one_add_norm` requires $\alpha$ to
   exceed the slice dimension. What changes per dimension is the slice and its threshold:

   | $d$ | spatial slice | threshold | instance used |
   |-----|---------------|-----------|---------------|
   | 4   | $\mathbb{R}^3$ | $\alpha > 3$ | `_3d` |
   | 3   | $\mathbb{R}^2$ | $\alpha > 2$ | `_2d` |
   | 2   | $\mathbb{R}^1$ | $\alpha > 1$ | `_1d` |

   All three instances fix $\alpha = 4$ (above every threshold). Used in
   `Spacetime/ProdIntegrable.lean` for product/Tonelli integrability behind the Schwinger
   representation — **not** in `OS1_Regularity`, whose own local integrability of the singular
   kernel comes from `locallyIntegrable_of_rpow_decay_real` (3D) or global
   `freeCovarianceKernel_integrable` (2D).

None of these observable-dimension points changes the *correctness* of OS0–OS4. Items 2 and
3 are entirely internal to the proof. Item 1 is a definition change that makes the OS
axioms apply to the actual $d$-dimensional GFF rather than the 4D one.

---

## Non-axiom statements that *do* differ by dimension

Outside the OS axioms themselves, two theorems have dimension-specific content:

### `OS/NonTrivial.lean` — `freeCovariance_tendsto_atTop`

The UV-divergence claim
`Filter.Tendsto (fun x => freeCovarianceBessel m x₀ x) (nhdsWithin x₀ {x₀}ᶜ) Filter.atTop`
is identical as a Lean statement, but its proof goes through
`besselKhalf_tendsto_atTop_at_zero` in 3D and `besselK0_tendsto_atTop_at_zero` in 2D —
because the prefactors differ. See `architecture.md` §4 and `foundational_definitions.md`
("Nontriviality") for the proof shape.

The 4D library proves the d=4 instance of this theorem in its own `OS/NonTrivial.lean`; the
3D and 2D proofs differ only in the Bessel input (`besselKhalf` / `besselK0` vs 4D's `besselK1`).

### `Spacetime/Tonelli.lean` and `Spacetime/ProdIntegrable.lean`

Statement bodies are unchanged. Proofs invoke `Fin.sum_univ_succ` in a few places where the
4D versions invoke `Fin.sum_univ_four` directly. The lemma `SpatialCoords3` (4D) becomes
`SpatialCoords2` (3D) or `SpatialCoords1` (2D) inside the proof, but the user-facing form is
the same `SpatialCoords` abbreviation defined in `Spacetime/Basic.lean`.

---

## Summary

The 13 audit verdicts in the 4D `definitions_entering_OS_axioms.md` apply unchanged. The
dimension is visible in three places (closed-form covariance, norm-decomposition lemma,
spatial decay threshold), none of which alters the OS axiom statements. One non-axiom
theorem (`freeCovariance_tendsto_atTop`) is the only result with dimension-divergent proof
structure.
