// PolicyRegistry.swift
// DK Parking Engine SDK — Phase 9 Vertical Slice
// Locked parameters per POLICY_REGISTRY_SPEC.md

import Foundation

/// Read-only policy configuration loaded at SDK initialization.
/// All parameters are from POLICY_REGISTRY_SPEC.md.
/// Legal thresholds (5m, 10m, 12m) are NOT here — see LegalThresholds.swift.
public struct PolicyRegistry: Codable {

    // PR-001: Minimum confidence score to produce LEGAL_WITH_BUFFER
    public let minConfidenceForLegalWithBuffer: Double

    // PR-002: Minimum confidence score to produce ILLEGAL
    public let minConfidenceForIllegal: Double

    // PR-003: Candidate confidence score minimum for use in evaluation
    public let minCandidateConfidenceScore: Double

    // PR-004: Near-threshold downgrade margin (metres)
    public let nearThresholdDowngradeMarginM: Double

    // PR-005: Flag — if true, VISIBLE_UNSUPPORTED_RESTRICTION escalates positive results to UNVERIFIABLE
    public let unsupportedRestrictionEscalatesPositive: Bool

    // PR-006: Minimum AR plane stability score to proceed
    public let minArPlaneStabilityScore: Double

    // PR-007: Minimum AR metric scale validity score to proceed
    public let minArMetricScaleScore: Double

    // PR-008: Minimum footprint quality score when partial occlusion is detected
    public let minFootprintQualityScoreOccluded: Double

    // PR-009: Maximum candidate search radius (metres)
    public let maxCandidateSearchRadiusM: Double

    // PR-010: Maximum dataset bundle validity (days)
    public let datasetMaxValidityDays: Int

    /// Default V1 policy parameters.
    public static let v1Default = PolicyRegistry(
        minConfidenceForLegalWithBuffer: 0.80,
        minConfidenceForIllegal: 0.80,
        minCandidateConfidenceScore: 0.0,
        nearThresholdDowngradeMarginM: 0.30,
        unsupportedRestrictionEscalatesPositive: true,
        minArPlaneStabilityScore: 0.70,
        minArMetricScaleScore: 0.75,
        minFootprintQualityScoreOccluded: 0.40,
        maxCandidateSearchRadiusM: 50.0,
        datasetMaxValidityDays: 180
    )

    public init(
        minConfidenceForLegalWithBuffer: Double,
        minConfidenceForIllegal: Double,
        minCandidateConfidenceScore: Double,
        nearThresholdDowngradeMarginM: Double,
        unsupportedRestrictionEscalatesPositive: Bool,
        minArPlaneStabilityScore: Double,
        minArMetricScaleScore: Double,
        minFootprintQualityScoreOccluded: Double,
        maxCandidateSearchRadiusM: Double,
        datasetMaxValidityDays: Int
    ) {
        self.minConfidenceForLegalWithBuffer = minConfidenceForLegalWithBuffer
        self.minConfidenceForIllegal = minConfidenceForIllegal
        self.minCandidateConfidenceScore = minCandidateConfidenceScore
        self.nearThresholdDowngradeMarginM = nearThresholdDowngradeMarginM
        self.unsupportedRestrictionEscalatesPositive = unsupportedRestrictionEscalatesPositive
        self.minArPlaneStabilityScore = minArPlaneStabilityScore
        self.minArMetricScaleScore = minArMetricScaleScore
        self.minFootprintQualityScoreOccluded = minFootprintQualityScoreOccluded
        self.maxCandidateSearchRadiusM = maxCandidateSearchRadiusM
        self.datasetMaxValidityDays = datasetMaxValidityDays
    }
}
