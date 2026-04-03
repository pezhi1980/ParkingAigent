// ParkingEvaluationEngine.kt
// DK Parking Engine SDK — Android Version 1 (Phase 9 Android)
// Main SDK entry point per SDK_API_CONTRACT.md
// Parity: iOS ParkingEvaluationEngine.swift

package com.dkparking.sdk.engine

import com.dkparking.sdk.ar.ARMeasurementSession
import com.dkparking.sdk.ar.ARSessionQuality
import com.dkparking.sdk.ar.MeasurementInput
import com.dkparking.sdk.ar.Vector3
import com.dkparking.sdk.core.BoundaryProvenance
import com.dkparking.sdk.core.CaptureQualityBundle
import com.dkparking.sdk.core.DecisionState
import com.dkparking.sdk.core.FeatureCandidateInfo
import com.dkparking.sdk.core.LegalThresholds
import com.dkparking.sdk.core.MeasurementBundle
import com.dkparking.sdk.core.ParkingEvaluationResult
import com.dkparking.sdk.core.PolicyRegistry
import com.dkparking.sdk.core.RefusalReasonCode
import com.dkparking.sdk.core.RuleFamily
import com.dkparking.sdk.core.TargetConfirmationSource
import com.dkparking.sdk.core.TargetInfo
import com.dkparking.sdk.core.VersionRefs
import com.dkparking.sdk.evaluation.ConfidenceComposer
import com.dkparking.sdk.evaluation.EvidenceScores
import com.dkparking.sdk.evaluation.LegalEvaluator
import com.google.ar.core.Frame
import com.google.ar.core.Plane
import kotlin.math.abs

// MARK: - SDK init result

sealed class SDKInitResult {
    object Ready : SDKInitResult()
    object NoActiveDatasetRegion : SDKInitResult()
    object DatasetExpired : SDKInitResult()
    data class PolicyIncompatible(val reason: String) : SDKInitResult()
    object DatasetIntegrityFailed : SDKInitResult()
    /** AR session could not be established (SDK_API_CONTRACT.md §2.1). */
    object ArSessionUnavailable : SDKInitResult()
    /** Unrecoverable initialization failure (SDK_API_CONTRACT.md §2.1). */
    object InitFailedGeneral : SDKInitResult()
}

// MARK: - Evaluation input

/**
 * All required inputs for a single evaluation call.
 * Per SDK_API_CONTRACT.md section 3.
 * ARCore equivalent: Frame replaces ARFrame; Vector3 replaces simd_float3.
 */
data class EvaluationInput(
    val frame: Frame,
    val sessionQuality: ARSessionQuality,
    val ruleFamily: RuleFamily,
    val vehicleFootprintEdgePoint: Vector3,
    val legalBoundaryLineStart: Vector3,
    val legalBoundaryLineEnd: Vector3,
    val boundaryProvenance: BoundaryProvenance,
    val footprintQualityScore: Double,
    val partialOcclusionDetected: Boolean,
    val candidateFeatureId: String,
    val candidateFeatureType: String,
    val candidateConfidenceScore: Double,
    val candidateSelectionBasis: String,
    val alternativeCandidatesRejected: Int,
    val targetConfirmationSource: TargetConfirmationSource,
    val unsupportedVisibleRestrictionFlag: Boolean = false,
    val overlapDetected: Boolean = false
)

// MARK: - Engine

/**
 * The main evaluation engine.
 * One instance is initialized per app session.
 * One evaluation call = one ParkingEvaluationResult.
 * Per SDK_API_CONTRACT.md.
 */
class ParkingEvaluationEngine(
    private val policy: PolicyRegistry,
    private val versionRefs: VersionRefs
) {
    private val measurementSession = ARMeasurementSession(policy)
    private var isInitialized = false

    // MARK: - Initialization

    /** Initializes the SDK. Must be called before evaluate(). */
    fun initialize(): SDKInitResult {
        isInitialized = true
        measurementSession.onSessionStarted()
        return SDKInitResult.Ready
    }

    /** Must be called when the AR session reports detected/updated planes. */
    fun onPlanesUpdated(planes: Collection<Plane>) {
        measurementSession.onPlanesUpdated(planes)
    }

    // MARK: - Evaluation

    /** Performs a single legal parking evaluation. One call = one result. */
    fun evaluate(input: EvaluationInput): ParkingEvaluationResult {
        if (!isInitialized) {
            return refusalResult(RefusalReasonCode.INSUFFICIENT_EVIDENCE_GENERAL, input)
        }

        // 1. Pre-composition refusal gates
        val measurementInput = MeasurementInput(
            vehicleFootprintEdgePoint = input.vehicleFootprintEdgePoint,
            legalBoundaryLineStart = input.legalBoundaryLineStart,
            legalBoundaryLineEnd = input.legalBoundaryLineEnd,
            legalThresholdM = LegalThresholds.threshold(input.ruleFamily),
            ruleFamily = input.ruleFamily,
            boundaryProvenance = input.boundaryProvenance
        )

        val rawMeasurement = measurementSession.measure(measurementInput)
            ?: return refusalResult(RefusalReasonCode.INSUFFICIENT_EVIDENCE_GENERAL, input)

        val preGateRefusal = LegalEvaluator.preCompositionRefusal(
            sessionQuality = input.sessionQuality,
            footprintQualityScore = input.footprintQualityScore,
            partialOcclusionDetected = input.partialOcclusionDetected,
            candidateFound = true,
            candidateAmbiguous = false,
            totalEstimatedErrorM = rawMeasurement.totalEstimatedErrorM,
            unsupportedVisibleRestriction = input.unsupportedVisibleRestrictionFlag,
            policy = policy
        )
        if (preGateRefusal != null) {
            return refusalResult(preGateRefusal, input)
        }

        // 2. Compose confidence score
        val evidenceScores = EvidenceScores.create(
            arPlaneStabilityScore = input.sessionQuality.planeStabilityScore,
            arMetricScaleScore = input.sessionQuality.metricScaleScore,
            footprintQualityScore = input.footprintQualityScore,
            candidateConfidenceScore = input.candidateConfidenceScore,
            boundaryProvenance = input.boundaryProvenance,
            totalEstimatedErrorM = rawMeasurement.totalEstimatedErrorM
        )
        val confidenceScore = ConfidenceComposer.compose(evidenceScores)

        // 3. Select decision state
        val inNearThresholdZone = abs(rawMeasurement.signedMarginM) <
            (rawMeasurement.totalEstimatedErrorM + policy.nearThresholdDowngradeMarginM)

        var state: DecisionState = if (input.ruleFamily.isDistanceBased) {
            LegalEvaluator.stateForDistanceMeasurement(
                signedMarginM = rawMeasurement.signedMarginM,
                inNearThresholdZone = inNearThresholdZone,
                confidenceScore = confidenceScore,
                policy = policy
            )
        } else {
            LegalEvaluator.stateForOverlapEvaluation(
                overlapDetected = input.overlapDetected,
                confidenceScore = confidenceScore,
                policy = policy
            )
        }

        // 4. Post-composition escalation
        val (finalState, escalationReason) = LegalEvaluator.applyEscalation(
            state = state,
            confidenceScore = confidenceScore,
            boundaryProvenance = input.boundaryProvenance,
            unsupportedVisibleRestriction = input.unsupportedVisibleRestrictionFlag,
            policy = policy
        )

        if (finalState == DecisionState.UNVERIFIABLE) {
            return refusalResult(
                escalationReason ?: RefusalReasonCode.INSUFFICIENT_EVIDENCE_GENERAL,
                input
            )
        }

        // 5. Build full result
        val measurementBundle = MeasurementBundle.create(
            ruleFamily = input.ruleFamily.rawValue,
            legalThresholdM = measurementInput.legalThresholdM,
            measuredDistanceM = rawMeasurement.measuredDistanceM,
            signedMarginM = rawMeasurement.signedMarginM,
            totalEstimatedErrorM = rawMeasurement.totalEstimatedErrorM,
            confidenceScore = confidenceScore,
            measurementReferenceType = "vehicle_footprint_edge_to_boundary_line",
            boundaryProvenance = input.boundaryProvenance,
            nearThresholdDowngradeMarginM = policy.nearThresholdDowngradeMarginM
        )

        return ParkingEvaluationResult(
            decisionState = finalState,
            refusalReasons = emptyList(),
            ruleFamily = input.ruleFamily,
            measurement = measurementBundle,
            targetInfo = TargetInfo(
                targetConfirmationSource = input.targetConfirmationSource,
                footprintQualityScore = input.footprintQualityScore,
                partialOcclusionDetected = input.partialOcclusionDetected
            ),
            featureCandidate = FeatureCandidateInfo(
                candidateFeatureId = input.candidateFeatureId,
                candidateFeatureType = input.candidateFeatureType,
                candidateSelectionBasis = input.candidateSelectionBasis,
                alternativeCandidatesRejected = input.alternativeCandidatesRejected,
                candidateConfidenceScore = input.candidateConfidenceScore
            ),
            captureQuality = CaptureQualityBundle(
                arPlaneStabilityScore = input.sessionQuality.planeStabilityScore,
                arMetricScaleValid = input.sessionQuality.metricScaleValid,
                arMetricScaleScore = input.sessionQuality.metricScaleScore
            ),
            unsupportedVisibleRestrictionFlag = input.unsupportedVisibleRestrictionFlag,
            versionRefs = versionRefs
        )
    }

    // MARK: - Quality polling

    /** Returns the current AR session quality. Call on every AR frame. */
    fun currentQuality(frame: Frame): ARSessionQuality {
        return measurementSession.currentQuality(frame)
    }

    // MARK: - Teardown

    fun teardown() {
        measurementSession.onSessionPaused()
        isInitialized = false
    }

    // MARK: - Helpers

    private fun refusalResult(
        reason: RefusalReasonCode,
        input: EvaluationInput
    ): ParkingEvaluationResult = ParkingEvaluationResult(
        decisionState = DecisionState.UNVERIFIABLE,
        refusalReasons = listOf(reason),
        ruleFamily = input.ruleFamily,
        measurement = null,
        targetInfo = null,
        featureCandidate = null,
        captureQuality = CaptureQualityBundle(
            arPlaneStabilityScore = input.sessionQuality.planeStabilityScore,
            arMetricScaleValid = input.sessionQuality.metricScaleValid,
            arMetricScaleScore = input.sessionQuality.metricScaleScore
        ),
        unsupportedVisibleRestrictionFlag = input.unsupportedVisibleRestrictionFlag,
        versionRefs = versionRefs
    )
}
