// ConfidenceComposer.kt
// DK Parking Engine SDK — Android Version 1 (Phase 9 Android)
// Confidence composition per uncertainty_and_confidence_strategy.md
// Parity: iOS ConfidenceComposer.swift

package com.dkparking.sdk.evaluation

import com.dkparking.sdk.core.BoundaryProvenance
import kotlin.math.exp
import kotlin.math.ln
import kotlin.math.max
import kotlin.math.min

/**
 * All individual evidence quality scores used in confidence composition.
 * Per uncertainty_and_confidence_strategy.md section 3.
 */
data class EvidenceScores(
    val arPlaneStabilityScore: Double,
    val arMetricScaleScore: Double,
    val footprintQualityScore: Double,
    val candidateConfidenceScore: Double,
    val boundaryLocalizationScore: Double,
    val measurementErrorBudgetScore: Double
) {
    companion object {
        fun create(
            arPlaneStabilityScore: Double,
            arMetricScaleScore: Double,
            footprintQualityScore: Double,
            candidateConfidenceScore: Double,
            boundaryProvenance: BoundaryProvenance,
            totalEstimatedErrorM: Double
        ): EvidenceScores {
            val boundaryLocalizationScore = when (boundaryProvenance) {
                BoundaryProvenance.VISUAL_DETECTION -> 0.90
                BoundaryProvenance.MAP_PRIOR_ASSISTED -> 0.70
                BoundaryProvenance.MAP_PRIOR_ONLY -> 0.50
            }
            val measurementErrorBudgetScore = max(0.0, 1.0 - totalEstimatedErrorM / 2.0)

            return EvidenceScores(
                arPlaneStabilityScore = arPlaneStabilityScore,
                arMetricScaleScore = arMetricScaleScore,
                footprintQualityScore = footprintQualityScore,
                candidateConfidenceScore = candidateConfidenceScore,
                boundaryLocalizationScore = boundaryLocalizationScore,
                measurementErrorBudgetScore = measurementErrorBudgetScore
            )
        }
    }
}

/**
 * Computes the overall confidence_score from individual evidence scores.
 * Uses geometric-mean composition per uncertainty_and_confidence_strategy.md section 4.
 *
 * Weights: plane=0.15, scale=0.20, footprint=0.20, candidate=0.20, boundary=0.15, error=0.10
 * A score of 0.0 in any dimension drives the overall score to 0.0 (no masking).
 */
object ConfidenceComposer {

    fun compose(from scores: EvidenceScores): Double {
        val terms = listOf(
            Pair(scores.arPlaneStabilityScore,      0.15),
            Pair(scores.arMetricScaleScore,          0.20),
            Pair(scores.footprintQualityScore,       0.20),
            Pair(scores.candidateConfidenceScore,    0.20),
            Pair(scores.boundaryLocalizationScore,   0.15),
            Pair(scores.measurementErrorBudgetScore, 0.10)
        )

        var logSum = 0.0
        for ((score, weight) in terms) {
            val clamped = max(0.0, min(1.0, score))
            if (clamped == 0.0) return 0.0
            logSum += weight * ln(clamped)
        }

        return max(0.0, min(1.0, exp(logSum)))
    }
}
