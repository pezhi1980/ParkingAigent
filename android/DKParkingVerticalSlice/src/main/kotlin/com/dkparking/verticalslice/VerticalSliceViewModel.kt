// VerticalSliceViewModel.kt
// DK Parking Engine — Android Vertical Slice
// Per SDK_API_CONTRACT.md and user_disclosures_and_copy.md

package com.dkparking.verticalslice

import androidx.lifecycle.ViewModel
import com.dkparking.sdk.ar.ARSessionQuality
import com.dkparking.sdk.ar.Vector3
import com.dkparking.sdk.core.BoundaryProvenance
import com.dkparking.sdk.core.DecisionState
import com.dkparking.sdk.core.PolicyRegistry
import com.dkparking.sdk.core.RuleFamily
import com.dkparking.sdk.core.TargetConfirmationSource
import com.dkparking.sdk.core.VersionRefs
import com.dkparking.sdk.engine.EvaluationInput
import com.dkparking.sdk.engine.ParkingEvaluationEngine
import com.dkparking.sdk.engine.SDKInitResult
import com.google.ar.core.Frame
import com.google.ar.core.Plane
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow

// MARK: - UI State

sealed class EvaluationUiState {
    object Idle : EvaluationUiState()
    object Initializing : EvaluationUiState()
    data class InitFailed(val message: String) : EvaluationUiState()
    object WaitingForARQuality : EvaluationUiState()
    object ReadyToEvaluate : EvaluationUiState()
    data class Result(
        val decisionState: DecisionState,
        val displayLabel: String,
        val explanationBody: String,
        val refusalExplanation: String?,
        val retryGuidance: String?,
        val familyDisclosure: String,
        val limitationsNotice: String,
        val measurementSummary: String?
    ) : EvaluationUiState()
}

class VerticalSliceViewModel : ViewModel() {

    private val versionRefs = VersionRefs(
        sdkVersion = "sdk-v1.0.0-android",
        policyVersion = "policy-v1.0.0",
        datasetVersion = "REG-DK-001-STUB",
        datasetRegionId = "REG-DK-001",
        modelVersion = "STUB-V1-android",
        legalSourceBaselineDate = "2026-03-25"
    )

    private val engine = ParkingEvaluationEngine(
        policy = PolicyRegistry.v1Default,
        versionRefs = versionRefs
    )

    private val _uiState = MutableStateFlow<EvaluationUiState>(EvaluationUiState.Idle)
    val uiState: StateFlow<EvaluationUiState> = _uiState.asStateFlow()

    private val _sessionQuality = MutableStateFlow(ARSessionQuality.invalid)
    val sessionQuality: StateFlow<ARSessionQuality> = _sessionQuality.asStateFlow()

    fun initializeEngine() {
        _uiState.value = EvaluationUiState.Initializing
        when (val result = engine.initialize()) {
            is SDKInitResult.Ready -> _uiState.value = EvaluationUiState.WaitingForARQuality
            is SDKInitResult.NoActiveDatasetRegion ->
                _uiState.value = EvaluationUiState.InitFailed("No dataset region active for this location.")
            is SDKInitResult.DatasetExpired ->
                _uiState.value = EvaluationUiState.InitFailed("Dataset expired. Please update the app.")
            is SDKInitResult.PolicyIncompatible ->
                _uiState.value = EvaluationUiState.InitFailed("Policy incompatible: ${result.reason}")
            is SDKInitResult.ArSessionUnavailable ->
                _uiState.value = EvaluationUiState.InitFailed("AR session unavailable. Check camera permissions.")
            else ->
                _uiState.value = EvaluationUiState.InitFailed("Initialization failed.")
        }
    }

    fun onArFrame(frame: Frame, planes: Collection<Plane>) {
        engine.onPlanesUpdated(planes)
        val quality = engine.currentQuality(frame)
        _sessionQuality.value = quality

        if (_uiState.value is EvaluationUiState.WaitingForARQuality) {
            if (quality.isValid) {
                _uiState.value = EvaluationUiState.ReadyToEvaluate
            }
        } else if (_uiState.value is EvaluationUiState.ReadyToEvaluate) {
            if (!quality.isValid) {
                _uiState.value = EvaluationUiState.WaitingForARQuality
            }
        }
    }

    fun evaluate(frame: Frame) {
        val quality = _sessionQuality.value

        val input = EvaluationInput(
            frame = frame,
            sessionQuality = quality,
            ruleFamily = RuleFamily.PEDESTRIAN_CROSSING_5M,
            vehicleFootprintEdgePoint = Vector3(0f, 0f, -2f),
            legalBoundaryLineStart = Vector3(-3f, 0f, -6.5f),
            legalBoundaryLineEnd = Vector3(3f, 0f, -6.5f),
            boundaryProvenance = BoundaryProvenance.MAP_PRIOR_ASSISTED,
            footprintQualityScore = 0.85,
            partialOcclusionDetected = false,
            candidateFeatureId = "STUB-FEATURE-001",
            candidateFeatureType = "pedestrian_crossing",
            candidateConfidenceScore = 0.90,
            candidateSelectionBasis = "nearest_in_heading",
            alternativeCandidatesRejected = 0,
            targetConfirmationSource = TargetConfirmationSource.AUTO_SELECTED_UNAMBIGUOUS,
            unsupportedVisibleRestrictionFlag = false,
            overlapDetected = false
        )

        val result = engine.evaluate(input)

        val displayLabel = displayLabel(result.decisionState)
        val explanationBody = explanationBody(result.decisionState)
        val refusalExplanation = if (result.decisionState == DecisionState.UNVERIFIABLE) {
            result.refusalReasons.firstOrNull()?.let { refusalExplanation(it.rawValue) }
        } else null
        val retryGuidance = if (result.decisionState == DecisionState.UNVERIFIABLE) {
            result.refusalReasons.firstOrNull()?.let { retryGuidance(it.rawValue) }
        } else null
        val measurementSummary = result.measurement?.let {
            "%.2fm measured (threshold: %.1fm, margin: %.2fm)".format(
                it.measuredDistanceM, it.legalThresholdM, it.signedMarginM
            )
        }

        _uiState.value = EvaluationUiState.Result(
            decisionState = result.decisionState,
            displayLabel = displayLabel,
            explanationBody = explanationBody,
            refusalExplanation = refusalExplanation,
            retryGuidance = retryGuidance,
            familyDisclosure = "Pedestrian crossing 5m rule only. Other restrictions may apply.",
            limitationsNotice = result.limitationsNotice,
            measurementSummary = measurementSummary
        )
    }

    fun reset() {
        val quality = _sessionQuality.value
        _uiState.value = if (quality.isValid) EvaluationUiState.ReadyToEvaluate
                         else EvaluationUiState.WaitingForARQuality
    }

    override fun onCleared() {
        super.onCleared()
        engine.teardown()
    }

    // MARK: - Locked vocabulary per user_disclosures_and_copy.md §2

    private fun displayLabel(state: DecisionState): String = when (state) {
        DecisionState.LEGAL_WITH_BUFFER -> "Appears compliant"
        DecisionState.PROBABLY_LEGAL    -> "Likely compliant"
        DecisionState.PROBABLY_ILLEGAL  -> "Likely violation"
        DecisionState.ILLEGAL           -> "Violation detected"
        DecisionState.UNVERIFIABLE      -> "Could not evaluate"
    }

    private fun explanationBody(state: DecisionState): String = when (state) {
        DecisionState.LEGAL_WITH_BUFFER ->
            "The vehicle footprint appears to be outside the 5-metre restricted zone from the pedestrian crossing, with a meaningful safety margin."
        DecisionState.PROBABLY_LEGAL ->
            "The vehicle footprint is likely outside the restricted zone, but proximity or evidence quality limits certainty."
        DecisionState.PROBABLY_ILLEGAL ->
            "The vehicle footprint is likely inside the restricted zone, but proximity or evidence quality limits certainty."
        DecisionState.ILLEGAL ->
            "The vehicle footprint appears to be inside the 5-metre restricted zone from the pedestrian crossing."
        DecisionState.UNVERIFIABLE ->
            "The system could not produce a safe supported evaluation for this scene."
    }

    private fun refusalExplanation(code: String): String = when (code) {
        "AR_SCALE_UNTRUSTED"              -> "AR metric scale is not yet reliable. Move slowly to improve tracking."
        "PLANE_UNSTABLE"                  -> "Ground plane not yet stable. Point the camera at the road surface."
        "BOUNDARY_UNRESOLVED"             -> "The pedestrian crossing boundary could not be located."
        "FEATURE_CANDIDATE_AMBIGUOUS"     -> "Multiple crossing candidates detected. Move to clarify which applies."
        "TARGET_EDGE_OCCLUDED"            -> "The vehicle edge is partially obscured. Move for a clearer view."
        "TARGET_AMBIGUOUS"                -> "The target vehicle could not be confirmed. Retry after repositioning."
        "VISIBLE_UNSUPPORTED_RESTRICTION" -> "An unsupported restriction is visible. This app cannot evaluate all restrictions."
        "NO_ACTIVE_DATASET_REGION"        -> "This location is not covered by the active dataset region."
        else                              -> "Insufficient evidence for a safe evaluation."
    }

    private fun retryGuidance(code: String): String = when (code) {
        "AR_SCALE_UNTRUSTED"              -> "Move slowly and keep the camera pointed at the road for 2–3 seconds, then retry."
        "PLANE_UNSTABLE"                  -> "Point the camera at a flat road surface and wait for the plane to stabilise."
        "BOUNDARY_UNRESOLVED"             -> "Point the camera toward the pedestrian crossing markings and retry."
        "FEATURE_CANDIDATE_AMBIGUOUS"     -> "Move further from intersecting crossings to reduce ambiguity, then retry."
        "TARGET_EDGE_OCCLUDED"            -> "Reposition for a clear view of the vehicle's nearest edge, then retry."
        "TARGET_AMBIGUOUS"                -> "Reposition to clearly face the vehicle, then retry."
        "VISIBLE_UNSUPPORTED_RESTRICTION" -> "Check all visible signs and markings manually before parking."
        "NO_ACTIVE_DATASET_REGION"        -> "This location is not supported in this version."
        else                              -> "Ensure the road surface, vehicle, and crossing are all visible, then retry."
    }
}
