/-
Copyright (c) 2025 Michael R. Douglas, Sarah Hoback, Anna Mei, Ron Nissim. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Michael R. Douglas, Sarah Hoback, Anna Mei, Ron Nissim
-/
import OSforGFFin2D.Measure.Construct
import OSforGFFin2D.Covariance.RealForm
import OSforGFFin2D.Spacetime.ComplexTestFunction
import Mathlib.Analysis.Distribution.SchwartzSpace.Fourier

/-!
# Nontriviality of the Gaussian Free Field

The OS axiom verification in `OS.Master` would be trivially satisfied by the Dirac
measure at ω = 0 (the "zero field").  This file closes that loophole by proving
the GFF measure is **strictly non-degenerate**:

1. The square-root propagator embedding `T : S(ℝ⁴) → L²` is injective.
2. The smeared covariance `C(f,f) > 0` for every nonzero test function `f`.
3. Every field pairing `⟨ω,f⟩` has strictly positive variance under `μ_GFF`.
4. The pointwise kernel `C(x,y) → +∞` as `x → y` (UV divergence).

## Proof strategy

Injectivity of T follows from:
- Fourier transform is injective on Schwartz space (Mathlib's `FourierPair` instance
  gives a left inverse `𝓕⁻ ∘ 𝓕 = id`).
- The momentum-space weight `1/√(‖k‖² + m²)` is everywhere positive, so
  multiplication by it cannot create new zeros.
- A continuous function that vanishes a.e. with respect to Lebesgue measure
  vanishes everywhere (volume is an `IsOpenPosMeasure`).

## Main results

- `toComplex_injective` : embedding `S(ℝ⁴,ℝ) ↪ S(ℝ⁴,ℂ)` is injective
- `fourierTransform_schwartz_injective` : `𝓕` on Schwartz space is injective
- `embeddingMap_injective` : the square-root propagator embedding is injective
- `freeCovarianceFormR_strictPos` : `C(f,f) > 0` for `f ≠ 0`
- `gaussianFreeField_variance_pos` : `Var[⟨ω,f⟩] > 0` for `f ≠ 0`
- `gaussianFreeField_not_dirac` : `μ_GFF ≠ δ₀`
- `besselKhalf_ge_at_one` : `K_{1/2}(z) ≥ K_{1/2}(1)` for `z ∈ (0, 1]` (monotonicity)
- `freeCovariance_tendsto_atTop` : `C(x,y) → +∞` as `x → y`

## References

- Glimm–Jaffe, *Quantum Physics*, §6.1 (nondegeneracy of the free field)
- Reed–Simon, *Methods of Modern Mathematical Physics* II, §IX.8
-/

open MeasureTheory Complex QFT
open scoped Real BigOperators SchwartzMap

noncomputable section

namespace OSforGFF

/-! ## Injectivity of the real-to-complex embedding -/

/-- The embedding `toComplex : S(ℝ⁴,ℝ) → S(ℝ⁴,ℂ)` is injective.
    Follows from injectivity of `ℝ → ℂ` applied pointwise. -/
theorem toComplex_injective : Function.Injective (toComplex : TestFunction → TestFunctionℂ) := by
  intro f g h
  ext x
  have : toComplex f x = toComplex g x := congr_fun (congr_arg _ h) x
  simp only [toComplex_apply, Complex.ofReal_inj] at this
  exact this

/-! ## Injectivity of the Fourier transform on Schwartz space -/

/-- The Fourier transform is injective on complex Schwartz space.
    Proof: `FourierPair` gives `𝓕⁻(𝓕 f) = f`, so `𝓕` has a left inverse. -/
theorem fourierTransform_schwartz_injective :
    Function.Injective
      (SchwartzMap.fourierTransformCLM ℂ : TestFunctionℂ → TestFunctionℂ) := by
  intro f g h
  -- SchwartzMap.fourierTransformCLM agrees with FourierTransform.fourier
  have hf' : (SchwartzMap.fourierTransformCLM ℂ f : TestFunctionℂ) =
    FourierTransform.fourier f := rfl
  have hg' : (SchwartzMap.fourierTransformCLM ℂ g : TestFunctionℂ) =
    FourierTransform.fourier g := rfl
  rw [hf', hg'] at h
  -- FourierPair gives 𝓕⁻ ∘ 𝓕 = id on Schwartz space
  calc f = FourierTransform.fourierInv (FourierTransform.fourier f) :=
        (FourierTransform.fourierInv_fourier_eq f).symm
    _ = FourierTransform.fourierInv (FourierTransform.fourier g) := by rw [h]
    _ = g := FourierTransform.fourierInv_fourier_eq g

/-! ## Continuous functions that vanish a.e. vanish everywhere -/

/-- A continuous function `SpaceTime → ℂ` that is zero a.e. with respect to
    Lebesgue measure is zero everywhere.

    Proof: if `f(x₀) ≠ 0`, then `U = f⁻¹(ℂ \ {0})` is open and nonempty.
    Since volume on `ℝ⁴` is an `IsOpenPosMeasure`, `μ(U) > 0`,
    contradicting `f = 0` a.e. -/
private lemma eq_zero_of_continuous_ae_zero
    {f : SpaceTime → ℂ} (hcont : Continuous f) (hae : f =ᵐ[volume] 0) :
    f = 0 := by
  funext x
  by_contra hx
  have hU_open : IsOpen {y : SpaceTime | f y ≠ 0} :=
    hcont.isOpen_preimage _ isOpen_compl_singleton
  have hU_ne : Set.Nonempty {y : SpaceTime | f y ≠ 0} := ⟨x, hx⟩
  have hU_pos : 0 < volume {y : SpaceTime | f y ≠ 0} :=
    hU_open.measure_pos volume hU_ne
  have hU_zero : volume {y : SpaceTime | f y ≠ 0} = 0 := by
    rw [← ae_iff]
    exact hae.mono fun y hy => by simpa using hy
  exact absurd hU_zero (ne_of_gt hU_pos)

/-! ## Injectivity of the square-root propagator embedding -/

/-- The square-root propagator map is zero pointwise only if f = 0.

    `sqrtPropagatorMap m f k = 𝓕(toComplex f)(k) · w(k)` where `w(k) > 0`,
    so vanishing of the product forces `𝓕(toComplex f) = 0`, hence `f = 0`
    by Fourier injectivity. -/
theorem sqrtPropagatorMap_eq_zero_iff (m : ℝ) [Fact (0 < m)] (f : TestFunction) :
    (∀ k : SpaceTime, sqrtPropagatorMap m f k = 0) ↔ f = 0 := by
  constructor
  · intro h
    -- Each factor: 𝓕(toComplex f)(k) * w(k) = 0, and w(k) > 0, so 𝓕(toComplex f)(k) = 0
    have h_ft_zero : ∀ k, (SchwartzMap.fourierTransformCLM ℂ (toComplex f)) k = 0 := by
      intro k
      have := h k
      unfold sqrtPropagatorMap at this
      have hw_pos : (momentumWeightSqrt_mathlib m k : ℂ) ≠ 0 := by
        simp only [Complex.ofReal_ne_zero]
        exact ne_of_gt (momentumWeightSqrt_mathlib_pos m k)
      exact (mul_eq_zero.mp this).resolve_right hw_pos
    -- 𝓕(toComplex f) = 0 as a Schwartz function
    have h_ft_zero_fn : SchwartzMap.fourierTransformCLM ℂ (toComplex f) = 0 := by
      ext k; exact h_ft_zero k
    -- By Fourier injectivity, toComplex f = 0
    have h_tc_zero : toComplex f = 0 := by
      have : SchwartzMap.fourierTransformCLM ℂ (toComplex f) =
             SchwartzMap.fourierTransformCLM ℂ 0 := by
        rw [h_ft_zero_fn, map_zero]
      exact fourierTransform_schwartz_injective this
    -- By toComplex injectivity, f = 0
    have h_tc_0 : toComplex (0 : TestFunction) = 0 := by ext x; simp [toComplex_apply]
    exact toComplex_injective (h_tc_zero.trans h_tc_0.symm)
  · intro h; subst h; intro k
    unfold sqrtPropagatorMap
    have h1 : toComplex (0 : TestFunction) = 0 := by ext x; simp [toComplex_apply]
    rw [h1]
    have h2 : SchwartzMap.fourierTransformCLM ℂ (0 : TestFunctionℂ) = 0 :=
      ContinuousLinearMap.map_zero _
    simp only [h2, SchwartzMap.zero_apply, zero_mul]

/-- The embedding `T : S(ℝ⁴,ℝ) → L²(ℝ⁴,ℂ)` is injective.

    If `T f = T g` then `‖T(f−g)‖ = 0`, so `∫ |sqrtPropagatorMap m (f−g)|² = 0`.
    The integrand is continuous and nonneg, so it vanishes a.e., hence everywhere
    (volume is `IsOpenPosMeasure`).  Since the momentum weight is positive, the
    Fourier transform of `f−g` vanishes, giving `f = g`. -/
theorem embeddingMap_injective (m : ℝ) [Fact (0 < m)] :
    Function.Injective (embeddingMap m) := by
  intro f g h
  suffices f - g = 0 from eq_of_sub_eq_zero this
  -- T(f-g) = 0 in L²
  have h_zero : embeddingMap m (f - g) = 0 := by
    rw [map_sub, h, sub_self]
  -- ‖T(f-g)‖² = ∫ |sqrtPropagatorMap|² = 0
  have h_norm_zero : ‖embeddingMap m (f - g)‖ = 0 := by rw [h_zero, norm_zero]
  have h_int_zero : ∫ k, ‖sqrtPropagatorMap m (f - g) k‖ ^ 2 ∂volume = 0 := by
    have := embeddingMap_norm_sq m (f - g)
    rw [h_norm_zero, zero_pow (by norm_num : 2 ≠ 0)] at this
    linarith
  -- Nonneg continuous integrand with zero integral vanishes a.e.
  have h_int := sqrtPropagatorMap_sq_integrable (m := m) (f := f - g)
  have h_ae_zero : ∀ᵐ k ∂volume, ‖sqrtPropagatorMap m (f - g) k‖ ^ 2 = 0 := by
    exact (integral_eq_zero_iff_of_nonneg_ae
      (Filter.Eventually.of_forall fun k => sq_nonneg _) h_int).mp h_int_zero
  -- ‖·‖² = 0 implies · = 0
  have h_ae_zero' : ∀ᵐ k ∂volume, sqrtPropagatorMap m (f - g) k = 0 :=
    h_ae_zero.mono fun k hk => by rwa [sq_eq_zero_iff, norm_eq_zero] at hk
  -- Continuous function zero a.e. is zero everywhere
  have h_cont : Continuous (fun k => sqrtPropagatorMap m (f - g) k) := by
    unfold sqrtPropagatorMap
    exact ((SchwartzMap.fourierTransformCLM ℂ (toComplex (f - g))).continuous).mul
      (continuous_ofReal.comp (momentumWeightSqrt_mathlib_continuous m))
  have h_ptwise : ∀ k, sqrtPropagatorMap m (f - g) k = 0 := by
    have h_eq := eq_zero_of_continuous_ae_zero h_cont
      (h_ae_zero'.mono fun k hk => by simp [hk])
    exact fun k => congr_fun h_eq k
  exact (sqrtPropagatorMap_eq_zero_iff m (f - g)).mp h_ptwise

/-! ## Strict positivity of the covariance -/

/-- **Strict positive definiteness**: the smeared covariance `C(f,f) > 0` for any
    nonzero test function `f`.  This rules out the Dirac-at-zero measure as
    a model satisfying the OS axioms.

    Proof: `C(f,f) = ‖T f‖²` where `T` is injective, so `f ≠ 0 ⟹ T f ≠ 0
    ⟹ ‖T f‖ > 0 ⟹ ‖T f‖² > 0`. -/
theorem freeCovarianceFormR_strictPos (m : ℝ) [Fact (0 < m)]
    (f : TestFunction) (hf : f ≠ 0) :
    0 < freeCovarianceFormR m f f := by
  rw [freeCovarianceFormR_eq_normSq m f]
  have h_ne : embeddingMap m f ≠ 0 := by
    intro h_abs
    exact hf (embeddingMap_injective m (h_abs.trans (map_zero (embeddingMap m)).symm))
  exact sq_pos_of_pos (norm_pos_iff.mpr h_ne)

/-! ## Nontriviality of the GFF measure -/

/-- The variance of `⟨ω,f⟩` under the GFF is strictly positive for `f ≠ 0`.
    Equivalently, the pushforward by the pairing is a non-degenerate Gaussian. -/
theorem gaussianFreeField_variance_pos (m : ℝ) [Fact (0 < m)]
    (f : TestFunction) (hf : f ≠ 0) :
    0 < ∫ ω, (distributionPairingCLM f ω) ^ 2 ∂(μ_GFF m).toMeasure := by
  rw [gff_second_moment_eq_covariance]
  exact freeCovarianceFormR_strictPos m f hf

/-- **The GFF is not a Dirac measure**: there exists a test function whose pairing
    with ω has nonzero variance.  This is the formal statement that the OS axiom
    verification in `Master.lean` is nontrivial.

    Any nonzero Schwartz function witnesses this.  We use a standard bump
    function on ℝ⁴, which exists by `ContDiff.exists_eq_one_of_isOpen`. -/
theorem gaussianFreeField_not_dirac (m : ℝ) [Fact (0 < m)] :
    ∃ f : TestFunction, f ≠ 0 ∧
      0 < ∫ ω, (distributionPairingCLM f ω) ^ 2 ∂(μ_GFF m).toMeasure := by
  -- Schwartz space on ℝ⁴ is nontrivial: exhibit a nonzero element.
  -- This uses the existence of smooth compactly-supported bump functions.
  have ⟨f, hf⟩ : ∃ f : TestFunction, f ≠ 0 := by
    let φ : ContDiffBump (0 : SpaceTime) := ⟨1, 2, by norm_num, by norm_num⟩
    refine ⟨φ.hasCompactSupport.toSchwartzMap φ.contDiff, fun h => ?_⟩
    have h1 : φ (0 : SpaceTime) = 1 :=
      φ.one_of_mem_closedBall (Metric.mem_closedBall_self φ.rIn_pos.le)
    have h2 : (φ.hasCompactSupport.toSchwartzMap φ.contDiff) (0 : SpaceTime) =
              φ (0 : SpaceTime) := rfl
    rw [h] at h2; simp at h2; linarith
  exact ⟨f, hf, gaussianFreeField_variance_pos m f hf⟩


/-! ## UV divergence at coincident points (d=2)

At d=2 the covariance is `C(x,y) = (1/(2π)) · K₀(m·r)` where `r = ‖x-y‖`.
The modified Bessel function `K₀` has a *logarithmic* singularity at 0:
`K₀(z) ∼ -log(z/2) - γ` as `z → 0⁺`, in particular `K₀(z) → +∞`. So
`C(x,y) → +∞` as `x → y`. -/

/-- **The free covariance `C(x,y) → +∞` as `x → y` (logarithmic UV divergence at d=2).** -/
theorem freeCovariance_tendsto_atTop (m : ℝ) [Fact (0 < m)] (x₀ : SpaceTime) :
    Filter.Tendsto (fun x => freeCovarianceBessel m x₀ x)
      (nhdsWithin x₀ {x₀}ᶜ) Filter.atTop := by
  have hm := Fact.out (self := ‹Fact (0 < m)›)
  -- ‖x₀ - x‖ → 0⁺ as x → x₀ through {x₀}ᶜ
  have h_norm : Filter.Tendsto (fun x => ‖x₀ - x‖)
      (nhdsWithin x₀ {x₀}ᶜ) (nhdsWithin 0 (Set.Ioi 0)) := by
    apply tendsto_nhdsWithin_of_tendsto_nhds_of_eventually_within
    · have hc : ContinuousAt (fun x : SpaceTime => ‖x₀ - x‖) x₀ :=
        (continuous_norm.comp (continuous_const.sub continuous_id)).continuousAt
      have := hc.tendsto; simp only [sub_self, norm_zero] at this
      exact this.mono_left nhdsWithin_le_nhds
    · exact eventually_nhdsWithin_of_forall fun x hx =>
        norm_pos_iff.mpr (sub_ne_zero.mpr fun h => hx (Set.mem_singleton_iff.mpr h.symm))
  -- m·r → 0⁺ as r → 0⁺
  have h_mr : Filter.Tendsto (fun x => m * ‖x₀ - x‖)
      (nhdsWithin x₀ {x₀}ᶜ) (nhdsWithin 0 (Set.Ioi 0)) := by
    apply tendsto_nhdsWithin_of_tendsto_nhds_of_eventually_within
    · have : Filter.Tendsto (fun x => m * ‖x₀ - x‖)
          (nhdsWithin x₀ {x₀}ᶜ) (nhds (m * 0)) :=
        Filter.Tendsto.const_mul m (h_norm.mono_right nhdsWithin_le_nhds)
      simpa using this
    · refine (h_norm.eventually self_mem_nhdsWithin).mono fun x hx => ?_
      exact mul_pos hm hx
  -- K₀(m·r) → +∞
  have h_K0 : Filter.Tendsto (fun x => besselK0 (m * ‖x₀ - x‖))
      (nhdsWithin x₀ {x₀}ᶜ) Filter.atTop :=
    besselK0_tendsto_atTop_at_zero.comp h_mr
  -- Multiply by positive prefactor 1/(2π)
  have h_prefactor_pos : 0 < 1 / (2 * Real.pi) := by positivity
  have h_prod : Filter.Tendsto (fun x => 1 / (2 * Real.pi) * besselK0 (m * ‖x₀ - x‖))
      (nhdsWithin x₀ {x₀}ᶜ) Filter.atTop :=
    Filter.Tendsto.const_mul_atTop h_prefactor_pos h_K0
  -- Identify with freeCovarianceBessel for x ≠ x₀
  rw [Filter.tendsto_atTop]; intro M
  have h_ev := Filter.tendsto_atTop.mp h_prod M
  filter_upwards [h_ev, h_norm.eventually self_mem_nhdsWithin] with x hxM hx_pos
  have hr_ne : ‖x₀ - x‖ ≠ 0 := ne_of_gt hx_pos
  show M ≤ freeCovarianceBessel m x₀ x
  unfold freeCovarianceBessel
  simp only [hr_ne, ↓reduceIte]
  exact hxM

end OSforGFF
