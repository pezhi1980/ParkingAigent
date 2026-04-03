// LegalEvaluator.kt
// DK Parking Engine SDK — Android Version 1 (Phase 9 Android)
// Core decision-state logic per uncertainty_and_confidence_strategy.md sections 5–7
// Parity: iOS LegalEvaluator.swift

package com.dkparking.sdk.evaluation

import com.dkparking.sdk.ar.ARSessionQuality
import com.dkparking.sdk.core.BoundaryProvenance
import com.dkparking.sdk.core.DecisionState
import com.dkparking.sdk.core.PolicyRegistry
import com.dkparking.sdk.core.RefusalReasonCode

/**
 * Produces a DecisionState from measurement outputs and evidence scores.
 * Implements the full gate → composition → state selection → escalation pipeline.
 */
object LegalEvaluator {

    // MARK: - Pre-composition refusal gates

    /**
     * Checks all pre-composition refusal gates.
     * Returns the first failing reason code, or null if all gates pass.
     * Per uncertainty_and_confidence_strategy.md section 5.
     */
    fun preCompositionRefusal(
        sessionQuality: ARSessionQuality,
        footprintQualityScore: Double,
        partialOcclusionDetected: Boolean,
        candidateFound: Boolean,
        candidateAmbiguous: Boolean,
        totalEstimatedErrorM: Double,
        unsupportedVisibleRestriction: Boolean,
        policy: PolicyRegistry
    ): RefusalReasonCode? {

        if (!sessionQuality.metricScaleValid || sessionQuality.metricScaleScore < policy.minArMetricScaleScore) {
            return RefusalReasonCode.AR_SCALE_UNTRUSTED
        }
        if (sessionQuality.planeStabilityScore < policy.minArPlaneStabilityScore) {
            return RefusalReasonCode.PLANE_UNSTABLE
        }
        if (partialOcclusionDetected && footprintQualityScore < policy.minFootprintQualityScoreOccluded) {
            return RefusalReasonCode.TARGET_EDGE_OCCLUDED
        }
        if (!candidateFound) {
            return RefusalReasonCode.BOUNDARY_UNRESOLVED
        }
        if (candidateAmbiguous) {
            return RefusalReasonCode.FEATURE_CANDIDATE_AMBIGUOUS
        }
        if (totalEstimatedErrorM > 2.0) {
            return RefusalReasonCode.INSUFFICIENT_EVIDENCE_GENERAL
        }

        return null
    }

    // MARK: - Decision state selection (distance-based)

    /**
     * Selects the decision state for distance-based rule families.
     * Per uncertainty_and_confidence_strategy.md section 6 (step 2).
     */
    fun stateForDistanceMeasurement(
        signedMarginM: Double,
        inNearThresholdZone: Boolean,
        confidenceScore: Double,
        policy: PolicyRegistry
    ): DecisionState {
        return if (signedMarginM >= 0) {
            if (!inNearThresholdZone && confidenceScore >= policy.minConfidenceForLegalWithBuffer) {
                DecisionState.LEGAL_WITH_BUFFER
            } else {
                DecisionState.PROBABLY_LEGAL
            }
        } else {
            if (!inNearThresholdZone && confidenceScore >= policy.minConfidenceForIllegal) {
                DecisionState.ILLEGAL
            } else {
                DecisionState.PROBABLY_ILLEGAL
            }
        }
    }

    // MARK: - Decision state selection (overlap-based)

    /**
     * Selects the decision state for overlap-based rule families (direct_prohibited_surfaces).
     * Per uncertainty_and_confidence_strategy.md section 6 (overlap table).
     */
    fun stateForOverlapEvaluation(
        overlapDetected: Boolean,
        confidenceScore: Double,
        policy: PolicyRegistry
    ): DecisionState {
        return if (overlapDetected) {
            if (confidenceScore >= policy.minConfidenceForIllegal) DecisionState.ILLEGAL
            else DecisionState.PROBABLY_ILLEGAL
        } else {
            if (confidenceScore >= policy.minConfidenceForLegalWithBuffer) DecisionState.LEGAL_WITH_BUFFER
            else DecisionState.PROBABLY_LEGAL
        }
    }

    // MARK: - Post-composition escalation

    /**
     * Applies post-composition escalation rules.
     * Per uncertainty_and_confidence_strategy.md section 7.
     */
    fun applyEscalation(
        state: DecisionState,
        confidenceScore: Double,
        boundaryProvenance: BoundaryProvenance,
        unsupportedVisibleRestriction: Boolean,
        policy: PolicyRegistry
    ): Pair<DecisionState, RefusalReasonCode?> {

        if (confidenceScore < 0.30) {
            return Pair(DecisionState.UNVERIFIABLE, RefusalReasonCode.INSUFFICIENT_EVIDENCE_GENERAL)
        }

        if (boundaryProvenance == BoundaryProvenance.MAP_PRIOR_ONLY && state == DecisionState.LEGAL_WITH_BUFFER) {
            return Pair(DecisionState.PROBABLY_LEGAL, null)
        }

        if (boundaryProvenance == BoundaryProvenance.MAP_PRIOR_ONLY && state == DecisionState.ILLEGAL) {
            return Pair(DecisionState.PROBABLY_ILLEGAL, null)
        }

        if (unsupportedVisibleRestriction
            && policy.unsupportedRestrictionEscalatesPositive
            && (state == DecisionState.LEGAL_WITH_BUFFER || state == DecisionState.PROBABLY_LEGAL)) {
            return Pair(DecisionState.UNVERIFIABLE, RefusalReasonCode.VISIBLE_UNSUPPORTED_RESTRICTION)
        }

        return Pair(state, null)
    }
}
