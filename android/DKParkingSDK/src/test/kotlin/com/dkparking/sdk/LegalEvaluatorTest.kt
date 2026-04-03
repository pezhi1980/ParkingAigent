// LegalEvaluatorTest.kt
// DK Parking Engine SDK — Android Unit Tests
// Parity: iOS LegalEvaluatorTests.swift

package com.dkparking.sdk

import com.dkparking.sdk.ar.ARSessionQuality
import com.dkparking.sdk.core.BoundaryProvenance
import com.dkparking.sdk.core.DecisionState
import com.dkparking.sdk.core.PolicyRegistry
import com.dkparking.sdk.core.RefusalReasonCode
import com.dkparking.sdk.evaluation.LegalEvaluator
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Test

class LegalEvaluatorTest {

    private val policy = PolicyRegistry.v1Default
    private val goodQuality = ARSessionQuality(
        isValid = true,
        planeStabilityScore = 0.85,
        metricScaleScore = 0.90,
        metricScaleValid = true
    )
    private val poorQuality = ARSessionQuality(
        isValid = false,
        planeStabilityScore = 0.50,
        metricScaleScore = 0.60,
        metricScaleValid = false
    )

    // MARK: - Pre-composition refusal gates

    @Test
    fun `poor metric scale returns AR_SCALE_UNTRUSTED`() {
        val result = LegalEvaluator.preCompositionRefusal(
            sessionQuality = poorQuality,
            footprintQualityScore = 0.9,
            partialOcclusionDetected = false,
            candidateFound = true,
            candidateAmbiguous = false,
            totalEstimatedErrorM = 0.4,
            unsupportedVisibleRestriction = false,
            policy = policy
        )
        assertEquals(RefusalReasonCode.AR_SCALE_UNTRUSTED, result)
    }

    @Test
    fun `low plane stability returns PLANE_UNSTABLE`() {
        val lowPlane = ARSessionQuality(
            isValid = false,
            planeStabilityScore = 0.40,
            metricScaleScore = 0.90,
            metricScaleValid = true
        )
        val result = LegalEvaluator.preCompositionRefusal(
            sessionQuality = lowPlane,
            footprintQualityScore = 0.9,
            partialOcclusionDetected = false,
            candidateFound = true,
            candidateAmbiguous = false,
            totalEstimatedErrorM = 0.4,
            unsupportedVisibleRestriction = false,
            policy = policy
        )
        assertEquals(RefusalReasonCode.PLANE_UNSTABLE, result)
    }

    @Test
    fun `no candidate found returns BOUNDARY_UNRESOLVED`() {
        val result = LegalEvaluator.preCompositionRefusal(
            sessionQuality = goodQuality,
            footprintQualityScore = 0.9,
            partialOcclusionDetected = false,
            candidateFound = false,
            candidateAmbiguous = false,
            totalEstimatedErrorM = 0.4,
            unsupportedVisibleRestriction = false,
            policy = policy
        )
        assertEquals(RefusalReasonCode.BOUNDARY_UNRESOLVED, result)
    }

    @Test
    fun `all gates pass returns null`() {
        val result = LegalEvaluator.preCompositionRefusal(
            sessionQuality = goodQuality,
            footprintQualityScore = 0.9,
            partialOcclusionDetected = false,
            candidateFound = true,
            candidateAmbiguous = false,
            totalEstimatedErrorM = 0.4,
            unsupportedVisibleRestriction = false,
            policy = policy
        )
        assertNull(result)
    }

    // MARK: - State selection (distance-based)

    @Test
    fun `clear positive margin high confidence produces LEGAL_WITH_BUFFER`() {
        val state = LegalEvaluator.stateForDistanceMeasurement(
            signedMarginM = 2.0,
            inNearThresholdZone = false,
            confidenceScore = 0.90,
            policy = policy
        )
        assertEquals(DecisionState.LEGAL_WITH_BUFFER, state)
    }

    @Test
    fun `positive margin but near threshold produces PROBABLY_LEGAL`() {
        val state = LegalEvaluator.stateForDistanceMeasurement(
            signedMarginM = 0.1,
            inNearThresholdZone = true,
            confidenceScore = 0.90,
            policy = policy
        )
        assertEquals(DecisionState.PROBABLY_LEGAL, state)
    }

    @Test
    fun `clear negative margin high confidence produces ILLEGAL`() {
        val state = LegalEvaluator.stateForDistanceMeasurement(
            signedMarginM = -1.5,
            inNearThresholdZone = false,
            confidenceScore = 0.90,
            policy = policy
        )
        assertEquals(DecisionState.ILLEGAL, state)
    }

    @Test
    fun `negative margin near threshold produces PROBABLY_ILLEGAL`() {
        val state = LegalEvaluator.stateForDistanceMeasurement(
            signedMarginM = -0.1,
            inNearThresholdZone = true,
            confidenceScore = 0.90,
            policy = policy
        )
        assertEquals(DecisionState.PROBABLY_ILLEGAL, state)
    }

    // MARK: - Escalation

    @Test
    fun `map prior only caps LEGAL_WITH_BUFFER to PROBABLY_LEGAL`() {
        val (state, reason) = LegalEvaluator.applyEscalation(
            state = DecisionState.LEGAL_WITH_BUFFER,
            confidenceScore = 0.85,
            boundaryProvenance = BoundaryProvenance.MAP_PRIOR_ONLY,
            unsupportedVisibleRestriction = false,
            policy = policy
        )
        assertEquals(DecisionState.PROBABLY_LEGAL, state)
        assertNull(reason)
    }

    @Test
    fun `map prior only caps ILLEGAL to PROBABLY_ILLEGAL`() {
        val (state, _) = LegalEvaluator.applyEscalation(
            state = DecisionState.ILLEGAL,
            confidenceScore = 0.85,
            boundaryProvenance = BoundaryProvenance.MAP_PRIOR_ONLY,
            unsupportedVisibleRestriction = false,
            policy = policy
        )
        assertEquals(DecisionState.PROBABLY_ILLEGAL, state)
    }

    @Test
    fun `unsupported restriction escalates LEGAL_WITH_BUFFER to UNVERIFIABLE`() {
        val (state, reason) = LegalEvaluator.applyEscalation(
            state = DecisionState.LEGAL_WITH_BUFFER,
            confidenceScore = 0.85,
            boundaryProvenance = BoundaryProvenance.VISUAL_DETECTION,
            unsupportedVisibleRestriction = true,
            policy = policy
        )
        assertEquals(DecisionState.UNVERIFIABLE, state)
        assertEquals(RefusalReasonCode.VISIBLE_UNSUPPORTED_RESTRICTION, reason)
    }

    @Test
    fun `very low confidence escalates to UNVERIFIABLE`() {
        val (state, reason) = LegalEvaluator.applyEscalation(
            state = DecisionState.LEGAL_WITH_BUFFER,
            confidenceScore = 0.10,
            boundaryProvenance = BoundaryProvenance.VISUAL_DETECTION,
            unsupportedVisibleRestriction = false,
            policy = policy
        )
        assertEquals(DecisionState.UNVERIFIABLE, state)
        assertNotNull(reason)
    }
}
