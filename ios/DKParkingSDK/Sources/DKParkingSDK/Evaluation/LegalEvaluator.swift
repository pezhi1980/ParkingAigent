// LegalEvaluator.swift
// DK Parking Engine SDK — Phase 9 Vertical Slice
// Core decision-state logic per uncertainty_and_confidence_strategy.md sections 5–7

import Foundation

/// Produces a DecisionState from measurement outputs and evidence scores.
/// Implements the full gate → composition → state selection → escalation pipeline.
public enum LegalEvaluator {

    // MARK: - Pre-composition refusal gates

    /// Checks all pre-composition refusal gates.
    /// Returns the first failing reason code, or nil if all gates pass.
    /// Per uncertainty_and_confidence_strategy.md section 5.
    public static func preCompositionRefusal(
        sessionQuality: ARSessionQuality,
        footprintQualityScore: Double,
        partialOcclusionDetected: Bool,
        candidateFound: Bool,
        candidateAmbiguous: Bool,
        totalEstimatedErrorM: Double,
        unsupportedVisibleRestriction: Bool,
        policy: PolicyRegistry
    ) -> RefusalReasonCode? {

        if !sessionQuality.metricScaleValid || sessionQuality.metricScaleScore < policy.minArMetricScaleScore {
            return .arScaleUntrusted
        }
        if sessionQuality.planeStabilityScore < policy.minArPlaneStabilityScore {
            return .planeUnstable
        }
        if partialOcclusionDetected && footprintQualityScore < policy.minFootprintQualityScoreOccluded {
            return .targetEdgeOccluded
        }
        if !candidateFound {
            return .boundaryUnresolved
        }
        if candidateAmbiguous {
            return .featureCandidateAmbiguous
        }
        if totalEstimatedErrorM > 2.0 {
            return .insufficientEvidenceGeneral
        }

        return nil
    }

    // MARK: - Decision state selection (distance-based)

    /// Selects the decision state for distance-based rule families.
    /// Per uncertainty_and_confidence_strategy.md section 6 (step 2).
    public static func stateForDistanceMeasurement(
        signedMarginM: Double,
        inNearThresholdZone: Bool,
        confidenceScore: Double,
        policy: PolicyRegistry
    ) -> DecisionState {

        if signedMarginM >= 0 {
            if !inNearThresholdZone && confidenceScore >= policy.minConfidenceForLegalWithBuffer {
                return .legalWithBuffer
            } else {
                return .probablyLegal
            }
        } else {
            if !inNearThresholdZone && confidenceScore >= policy.minConfidenceForIllegal {
                return .illegal
            } else {
                return .probablyIllegal
            }
        }
    }

    // MARK: - Decision state selection (overlap-based)

    /// Selects the decision state for overlap-based rule families (direct_prohibited_surfaces).
    /// Per uncertainty_and_confidence_strategy.md section 6 (overlap table).
    public static func stateForOverlapEvaluation(
        overlapDetected: Bool,
        confidenceScore: Double,
        policy: PolicyRegistry
    ) -> DecisionState {
        if overlapDetected {
            return confidenceScore >= policy.minConfidenceForIllegal ? .illegal : .probablyIllegal
        } else {
            return confidenceScore >= policy.minConfidenceForLegalWithBuffer ? .legalWithBuffer : .probablyLegal
        }
    }

    // MARK: - Post-composition escalation

    /// Applies post-composition escalation rules.
    /// Per uncertainty_and_confidence_strategy.md section 7.
    public static func applyEscalation(
        state: DecisionState,
        confidenceScore: Double,
        boundaryProvenance: BoundaryProvenance,
        unsupportedVisibleRestriction: Bool,
        policy: PolicyRegistry
    ) -> (state: DecisionState, refusalReason: RefusalReasonCode?) {

        // Confidence floor near zero → UNVERIFIABLE
        if confidenceScore < 0.30 {
            return (.unverifiable, .insufficientEvidenceGeneral)
        }

        // Map-prior-only hard positive cap
        if boundaryProvenance == .mapPriorOnly && state == .legalWithBuffer {
            return (.probablyLegal, nil)
        }

        // Map-prior-only hard negative cap
        if boundaryProvenance == .mapPriorOnly && state == .illegal {
            return (.probablyIllegal, nil)
        }

        // Unsupported restriction escalates positive result to UNVERIFIABLE
        if unsupportedVisibleRestriction
            && policy.unsupportedRestrictionEscalatesPositive
            && (state == .legalWithBuffer || state == .probablyLegal) {
            return (.unverifiable, .visibleUnsupportedRestriction)
        }

        return (state, nil)
    }
}
