// PolicyRegistry.kt
// DK Parking Engine SDK — Android Version 1 (Phase 9 Android)
// Locked parameters per POLICY_REGISTRY_SPEC.md
// Parity: iOS PolicyRegistry.swift (PC-006)

package com.dkparking.sdk.core

import kotlinx.serialization.Serializable

/**
 * Read-only policy configuration loaded at SDK initialization.
 * All parameters are from POLICY_REGISTRY_SPEC.md.
 * Legal thresholds (5m, 10m, 12m) are NOT here — see LegalThresholds in RuleFamily.kt.
 */
@Serializable
data class PolicyRegistry(
    // PR-001: Minimum confidence score to produce LEGAL_WITH_BUFFER
    val minConfidenceForLegalWithBuffer: Double,
    // PR-002: Minimum confidence score to produce ILLEGAL
    val minConfidenceForIllegal: Double,
    // PR-003: Candidate confidence score minimum for use in evaluation
    val minCandidateConfidenceScore: Double,
    // PR-004: Near-threshold downgrade margin (metres)
    val nearThresholdDowngradeMarginM: Double,
    // PR-005: Flag — if true, VISIBLE_UNSUPPORTED_RESTRICTION escalates positive results to UNVERIFIABLE
    val unsupportedRestrictionEscalatesPositive: Boolean,
    // PR-006: Minimum AR plane stability score to proceed
    val minArPlaneStabilityScore: Double,
    // PR-007: Minimum AR metric scale validity score to proceed
    val minArMetricScaleScore: Double,
    // PR-008: Minimum footprint quality score when partial occlusion is detected
    val minFootprintQualityScoreOccluded: Double,
    // PR-009: Maximum candidate search radius (metres)
    val maxCandidateSearchRadiusM: Double,
    // PR-010: Maximum dataset bundle validity (days)
    val datasetMaxValidityDays: Int
) {
    companion object {
        /** Default V1 policy parameters. */
        val v1Default = PolicyRegistry(
            minConfidenceForLegalWithBuffer = 0.80,
            minConfidenceForIllegal = 0.80,
            minCandidateConfidenceScore = 0.0,
            nearThresholdDowngradeMarginM = 0.30,
            unsupportedRestrictionEscalatesPositive = true,
            minArPlaneStabilityScore = 0.70,
            minArMetricScaleScore = 0.75,
            minFootprintQualityScoreOccluded = 0.40,
            maxCandidateSearchRadiusM = 50.0,
            datasetMaxValidityDays = 180
        )
    }
}
