// ConfidenceComposerTest.kt
// DK Parking Engine SDK — Android Unit Tests
// Parity: iOS ConfidenceComposerTests.swift

package com.dkparking.sdk

import com.dkparking.sdk.core.BoundaryProvenance
import com.dkparking.sdk.evaluation.ConfidenceComposer
import com.dkparking.sdk.evaluation.EvidenceScores
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class ConfidenceComposerTest {

    @Test
    fun `all perfect scores produce score near 1_0`() {
        val scores = EvidenceScores.create(
            arPlaneStabilityScore = 1.0,
            arMetricScaleScore = 1.0,
            footprintQualityScore = 1.0,
            candidateConfidenceScore = 1.0,
            boundaryProvenance = BoundaryProvenance.VISUAL_DETECTION,
            totalEstimatedErrorM = 0.0
        )
        val result = ConfidenceComposer.compose(scores)
        assertEquals(1.0, result, 0.01)
    }

    @Test
    fun `zero in any dimension produces zero`() {
        val scores = EvidenceScores.create(
            arPlaneStabilityScore = 0.0,
            arMetricScaleScore = 1.0,
            footprintQualityScore = 1.0,
            candidateConfidenceScore = 1.0,
            boundaryProvenance = BoundaryProvenance.VISUAL_DETECTION,
            totalEstimatedErrorM = 0.0
        )
        val result = ConfidenceComposer.compose(scores)
        assertEquals(0.0, result, 0.001)
    }

    @Test
    fun `map prior only provenance lowers score vs visual detection`() {
        val scoresVisual = EvidenceScores.create(
            arPlaneStabilityScore = 0.9,
            arMetricScaleScore = 0.9,
            footprintQualityScore = 0.9,
            candidateConfidenceScore = 0.9,
            boundaryProvenance = BoundaryProvenance.VISUAL_DETECTION,
            totalEstimatedErrorM = 0.3
        )
        val scoresMapOnly = EvidenceScores.create(
            arPlaneStabilityScore = 0.9,
            arMetricScaleScore = 0.9,
            footprintQualityScore = 0.9,
            candidateConfidenceScore = 0.9,
            boundaryProvenance = BoundaryProvenance.MAP_PRIOR_ONLY,
            totalEstimatedErrorM = 0.3
        )
        val visualScore = ConfidenceComposer.compose(scoresVisual)
        val mapOnlyScore = ConfidenceComposer.compose(scoresMapOnly)
        assertTrue("Visual score should be > map-only score", visualScore > mapOnlyScore)
    }

    @Test
    fun `result is always in 0_0 to 1_0 range`() {
        val scores = EvidenceScores.create(
            arPlaneStabilityScore = 0.5,
            arMetricScaleScore = 0.5,
            footprintQualityScore = 0.5,
            candidateConfidenceScore = 0.5,
            boundaryProvenance = BoundaryProvenance.MAP_PRIOR_ASSISTED,
            totalEstimatedErrorM = 0.8
        )
        val result = ConfidenceComposer.compose(scores)
        assertTrue("Score must be >= 0", result >= 0.0)
        assertTrue("Score must be <= 1", result <= 1.0)
    }

    @Test
    fun `large error budget lowers score`() {
        val lowError = EvidenceScores.create(
            arPlaneStabilityScore = 0.9,
            arMetricScaleScore = 0.9,
            footprintQualityScore = 0.9,
            candidateConfidenceScore = 0.9,
            boundaryProvenance = BoundaryProvenance.VISUAL_DETECTION,
            totalEstimatedErrorM = 0.3
        )
        val highError = EvidenceScores.create(
            arPlaneStabilityScore = 0.9,
            arMetricScaleScore = 0.9,
            footprintQualityScore = 0.9,
            candidateConfidenceScore = 0.9,
            boundaryProvenance = BoundaryProvenance.VISUAL_DETECTION,
            totalEstimatedErrorM = 1.8
        )
        assertTrue(
            "Low error should produce higher confidence than high error",
            ConfidenceComposer.compose(lowError) > ConfidenceComposer.compose(highError)
        )
    }
}
