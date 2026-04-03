// ParkingEvaluationResult.kt
// DK Parking Engine SDK — Android Version 1 (Phase 9 Android)
// Implements the full output contract per OUTPUT_CONTRACT.md
// Parity: iOS ParkingEvaluationResult.swift (PC-005, PC-007)

package com.dkparking.sdk.core

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable
import java.util.UUID

// MARK: - Top-level result

/**
 * The complete structured output from a single parking evaluation call.
 * All fields are normative per OUTPUT_CONTRACT.md.
 */
@Serializable
data class ParkingEvaluationResult(
    val evaluationId: String = UUID.randomUUID().toString(),
    val timestampEpochMs: Long = System.currentTimeMillis(),
    val decisionState: DecisionState,
    val refusalReasons: List<RefusalReasonCode> = emptyList(),
    /** Top-level rule family being evaluated (REQUIRED per OUTPUT_CONTRACT.md §2). */
    val ruleFamily: RuleFamily,
    val measurement: MeasurementBundle? = null,
    val targetInfo: TargetInfo? = null,
    val featureCandidate: FeatureCandidateInfo? = null,
    val captureQuality: CaptureQualityBundle,
    /** Advisory-first family outputs (empty list if none; REQUIRED per OUTPUT_CONTRACT.md §2). */
    val advisoryOutputs: List<AdvisoryOutput> = emptyList(),
    val unsupportedVisibleRestrictionFlag: Boolean = false,
    /** Locked limitations notice text (REQUIRED per OUTPUT_CONTRACT.md §2). */
    val limitationsNotice: String = "This app evaluates only specific supported Danish stopping and parking rules. Other rules, signs, and restrictions may apply. This is not legal advice.",
    val versionRefs: VersionRefs
)

// MARK: - MeasurementBundle

/**
 * Metric measurement details. Present only when a measurement was successfully computed.
 * Per OUTPUT_CONTRACT.md section 4.
 */
@Serializable
data class MeasurementBundle(
    val ruleFamily: String,
    val legalThresholdM: Double,
    val measuredDistanceM: Double,
    val signedMarginM: Double,
    val totalEstimatedErrorM: Double,
    val confidenceScore: Double,
    val measurementReferenceType: String,
    val boundaryProvenance: BoundaryProvenance,
    /** Which vehicle edge was used as the measurement reference (REQUIRED per OUTPUT_CONTRACT.md §4). */
    val vehicleEdgeUsed: String = "nearest_edge",
    val inNearThresholdZone: Boolean
) {
    companion object {
        fun create(
            ruleFamily: String,
            legalThresholdM: Double,
            measuredDistanceM: Double,
            signedMarginM: Double,
            totalEstimatedErrorM: Double,
            confidenceScore: Double,
            measurementReferenceType: String,
            boundaryProvenance: BoundaryProvenance,
            vehicleEdgeUsed: String = "nearest_edge",
            nearThresholdDowngradeMarginM: Double = 0.30
        ): MeasurementBundle = MeasurementBundle(
            ruleFamily = ruleFamily,
            legalThresholdM = legalThresholdM,
            measuredDistanceM = measuredDistanceM,
            signedMarginM = signedMarginM,
            totalEstimatedErrorM = totalEstimatedErrorM,
            confidenceScore = confidenceScore,
            measurementReferenceType = measurementReferenceType,
            boundaryProvenance = boundaryProvenance,
            vehicleEdgeUsed = vehicleEdgeUsed,
            inNearThresholdZone = kotlin.math.abs(signedMarginM) < (totalEstimatedErrorM + nearThresholdDowngradeMarginM)
        )
    }
}

// MARK: - BoundaryProvenance

/**
 * The provenance tier of the legal boundary used in measurement.
 * Locked values per legal_boundary_localization_strategy.md section 5.
 */
@Serializable
enum class BoundaryProvenance(val rawValue: String) {
    @SerialName("visual_detection")
    VISUAL_DETECTION("visual_detection"),

    @SerialName("map_prior_assisted")
    MAP_PRIOR_ASSISTED("map_prior_assisted"),

    @SerialName("map_prior_only")
    MAP_PRIOR_ONLY("map_prior_only")
}

// MARK: - TargetInfo

/**
 * Information about the confirmed target vehicle.
 * Per OUTPUT_CONTRACT.md section 5.
 */
@Serializable
data class TargetInfo(
    /** Identifier of the confirmed active target (REQUIRED per OUTPUT_CONTRACT.md §5). */
    val targetId: String = UUID.randomUUID().toString(),
    val targetConfirmationSource: TargetConfirmationSource,
    val footprintQualityScore: Double,
    val partialOcclusionDetected: Boolean
)

@Serializable
enum class TargetConfirmationSource(val rawValue: String) {
    @SerialName("auto_selected_unambiguous")
    AUTO_SELECTED_UNAMBIGUOUS("auto_selected_unambiguous"),

    @SerialName("user_confirmed")
    USER_CONFIRMED("user_confirmed")
}

// MARK: - FeatureCandidateInfo

/**
 * Information about the matched dataset feature candidate.
 * Per OUTPUT_CONTRACT.md section 6.
 */
@Serializable
data class FeatureCandidateInfo(
    val candidateFeatureId: String,
    val candidateFeatureType: String,
    val candidateSelectionBasis: String,
    val alternativeCandidatesRejected: Int,
    val candidateConfidenceScore: Double
)

// MARK: - CaptureQualityBundle

/**
 * AR session quality indicators at time of capture.
 * Per OUTPUT_CONTRACT.md section 8.
 */
@Serializable
data class CaptureQualityBundle(
    /** Camera focus quality score (REQUIRED per OUTPUT_CONTRACT.md §8). */
    val focusScore: Double = 1.0,
    /** Scene brightness quality score (REQUIRED per OUTPUT_CONTRACT.md §8). */
    val brightnessScore: Double = 1.0,
    val arPlaneStabilityScore: Double,
    val arMetricScaleValid: Boolean,
    val arMetricScaleScore: Double
)

// MARK: - AdvisoryOutput

/**
 * Advisory-first family output.
 * Per OUTPUT_CONTRACT.md section 9.
 */
@Serializable
data class AdvisoryOutput(
    /** The advisory family name (e.g., "driveway_obstruction"). */
    val advisoryFamily: String,
    /** "ADVISORY_CONCERN" or "ADVISORY_NO_CONCERN_DETECTED". */
    val advisoryState: String,
    /** Display label — MUST include the word "advisory". */
    val advisoryLabel: String,
    /** Optional additional context. */
    val advisoryNotes: String? = null
)

// MARK: - VersionRefs

/**
 * Version references for full traceability per VERSIONING_POLICY.md.
 * All fields are mandatory in every result.
 */
@Serializable
data class VersionRefs(
    val sdkVersion: String,
    val policyVersion: String,
    val datasetVersion: String,
    val datasetRegionId: String,
    val modelVersion: String,
    val legalSourceBaselineDate: String
)
