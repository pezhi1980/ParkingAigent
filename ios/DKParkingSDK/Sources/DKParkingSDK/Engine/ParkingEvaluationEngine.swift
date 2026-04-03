// ParkingEvaluationEngine.swift
// DK Parking Engine SDK — Phase 9 Vertical Slice
// Main SDK entry point per SDK_API_CONTRACT.md

import ARKit
import Foundation

// MARK: - SDK init result

public enum SDKInitResult {
    case ready
    case noActiveDatasetRegion
    case datasetExpired
    case policyIncompatible(reason: String)
    case datasetIntegrityFailed
    /// AR session could not be established (SDK_API_CONTRACT.md §2.1).
    case arSessionUnavailable
    /// Unrecoverable initialization failure (SDK_API_CONTRACT.md §2.1).
    case initFailedGeneral
}

// MARK: - Evaluation input

/// All required inputs for a single evaluation call.
/// Per SDK_API_CONTRACT.md section 3.
public struct EvaluationInput {
    public let arFrame: ARFrame
    public let sessionQuality: ARSessionQuality
    public let ruleFamily: RuleFamily
    public let vehicleFootprintEdgePoint: simd_float3
    public let legalBoundaryLineStart: simd_float3
    public let legalBoundaryLineEnd: simd_float3
    public let boundaryProvenance: BoundaryProvenance
    public let footprintQualityScore: Double
    public let partialOcclusionDetected: Bool
    public let candidateFeatureId: String
    public let candidateFeatureType: String
    public let candidateConfidenceScore: Double
    public let candidateSelectionBasis: String
    public let alternativeCandidatesRejected: Int
    public let targetConfirmationSource: TargetConfirmationSource
    public let unsupportedVisibleRestrictionFlag: Bool
    public let overlapDetected: Bool

    public init(
        arFrame: ARFrame,
        sessionQuality: ARSessionQuality,
        ruleFamily: RuleFamily,
        vehicleFootprintEdgePoint: simd_float3,
        legalBoundaryLineStart: simd_float3,
        legalBoundaryLineEnd: simd_float3,
        boundaryProvenance: BoundaryProvenance,
        footprintQualityScore: Double,
        partialOcclusionDetected: Bool,
        candidateFeatureId: String,
        candidateFeatureType: String,
        candidateConfidenceScore: Double,
        candidateSelectionBasis: String,
        alternativeCandidatesRejected: Int,
        targetConfirmationSource: TargetConfirmationSource,
        unsupportedVisibleRestrictionFlag: Bool = false,
        overlapDetected: Bool = false
    ) {
        self.arFrame = arFrame
        self.sessionQuality = sessionQuality
        self.ruleFamily = ruleFamily
        self.vehicleFootprintEdgePoint = vehicleFootprintEdgePoint
        self.legalBoundaryLineStart = legalBoundaryLineStart
        self.legalBoundaryLineEnd = legalBoundaryLineEnd
        self.boundaryProvenance = boundaryProvenance
        self.footprintQualityScore = footprintQualityScore
        self.partialOcclusionDetected = partialOcclusionDetected
        self.candidateFeatureId = candidateFeatureId
        self.candidateFeatureType = candidateFeatureType
        self.candidateConfidenceScore = candidateConfidenceScore
        self.candidateSelectionBasis = candidateSelectionBasis
        self.alternativeCandidatesRejected = alternativeCandidatesRejected
        self.targetConfirmationSource = targetConfirmationSource
        self.unsupportedVisibleRestrictionFlag = unsupportedVisibleRestrictionFlag
        self.overlapDetected = overlapDetected
    }
}

// MARK: - Engine

/// The main evaluation engine.
/// One instance is initialized per app session.
/// One evaluation call = one ParkingEvaluationResult.
/// Per SDK_API_CONTRACT.md.
public final class ParkingEvaluationEngine {

    private let policy: PolicyRegistry
    private let measurementSession: ARMeasurementSession
    private let versionRefs: VersionRefs
    private var isInitialized = false

    public init(policy: PolicyRegistry, versionRefs: VersionRefs) {
        self.policy = policy
        self.versionRefs = versionRefs
        self.measurementSession = ARMeasurementSession(policy: policy)
    }

    // MARK: - Initialization

    /// Initializes the SDK. Must be called before evaluate().
    /// Per SDK_API_CONTRACT.md section 2.
    public func initialize() -> SDKInitResult {
        isInitialized = true
        return .ready
    }

    /// Returns the ARSession to attach to the AR view.
    public func startARSession() -> ARSession {
        return measurementSession.startSession()
    }

    // MARK: - Evaluation

    /// Performs a single legal parking evaluation.
    /// One call = one result. Per SDK_API_CONTRACT.md section 3.
    public func evaluate(input: EvaluationInput) -> ParkingEvaluationResult {
        guard isInitialized else {
            return refusalResult(reason: .insufficientEvidenceGeneral, input: input)
        }

        // 1. Pre-composition refusal gates
        let measurementInput = MeasurementInput(
            vehicleFootprintEdgePoint: input.vehicleFootprintEdgePoint,
            legalBoundaryLineStart: input.legalBoundaryLineStart,
            legalBoundaryLineEnd: input.legalBoundaryLineEnd,
            legalThresholdM: LegalThresholds.threshold(for: input.ruleFamily),
            ruleFamily: input.ruleFamily,
            boundaryProvenance: input.boundaryProvenance
        )

        guard let rawMeasurement = measurementSession.measure(input: measurementInput) else {
            return refusalResult(reason: .insufficientEvidenceGeneral, input: input)
        }

        if let preGateRefusal = LegalEvaluator.preCompositionRefusal(
            sessionQuality: input.sessionQuality,
            footprintQualityScore: input.footprintQualityScore,
            partialOcclusionDetected: input.partialOcclusionDetected,
            candidateFound: true,
            candidateAmbiguous: false,
            totalEstimatedErrorM: rawMeasurement.totalEstimatedErrorM,
            unsupportedVisibleRestriction: input.unsupportedVisibleRestrictionFlag,
            policy: policy
        ) {
            return refusalResult(reason: preGateRefusal, input: input)
        }

        // 2. Compose confidence score
        let evidenceScores = EvidenceScores(
            arPlaneStabilityScore: input.sessionQuality.planeStabilityScore,
            arMetricScaleScore: input.sessionQuality.metricScaleScore,
            footprintQualityScore: input.footprintQualityScore,
            candidateConfidenceScore: input.candidateConfidenceScore,
            boundaryProvenance: input.boundaryProvenance,
            totalEstimatedErrorM: rawMeasurement.totalEstimatedErrorM
        )
        let confidenceScore = ConfidenceComposer.compose(from: evidenceScores)

        // 3. Select decision state
        let inNearThresholdZone = abs(rawMeasurement.signedMarginM)
            < (rawMeasurement.totalEstimatedErrorM + policy.nearThresholdDowngradeMarginM)
        var state: DecisionState
        if input.ruleFamily.isDistanceBased {
            state = LegalEvaluator.stateForDistanceMeasurement(
                signedMarginM: rawMeasurement.signedMarginM,
                inNearThresholdZone: inNearThresholdZone,
                confidenceScore: confidenceScore,
                policy: policy
            )
        } else {
            state = LegalEvaluator.stateForOverlapEvaluation(
                overlapDetected: input.overlapDetected,
                confidenceScore: confidenceScore,
                policy: policy
            )
        }

        // 4. Post-composition escalation
        let (finalState, escalationReason) = LegalEvaluator.applyEscalation(
            state: state,
            confidenceScore: confidenceScore,
            boundaryProvenance: input.boundaryProvenance,
            unsupportedVisibleRestriction: input.unsupportedVisibleRestrictionFlag,
            policy: policy
        )

        if finalState == .unverifiable {
            return refusalResult(reason: escalationReason ?? .insufficientEvidenceGeneral, input: input)
        }

        // 5. Build full result
        let measurementBundle = MeasurementBundle(
            ruleFamily: input.ruleFamily.rawValue,
            legalThresholdM: measurementInput.legalThresholdM,
            measuredDistanceM: rawMeasurement.measuredDistanceM,
            signedMarginM: rawMeasurement.signedMarginM,
            totalEstimatedErrorM: rawMeasurement.totalEstimatedErrorM,
            confidenceScore: confidenceScore,
            measurementReferenceType: "vehicle_footprint_edge_to_boundary_line",
            boundaryProvenance: input.boundaryProvenance,
            nearThresholdDowngradeMarginM: policy.nearThresholdDowngradeMarginM
        )

        return ParkingEvaluationResult(
            decisionState: finalState,
            refusalReasons: [],
            ruleFamily: input.ruleFamily,
            measurement: measurementBundle,
            targetInfo: TargetInfo(
                targetConfirmationSource: input.targetConfirmationSource,
                footprintQualityScore: input.footprintQualityScore,
                partialOcclusionDetected: input.partialOcclusionDetected
            ),
            featureCandidate: FeatureCandidateInfo(
                candidateFeatureId: input.candidateFeatureId,
                candidateFeatureType: input.candidateFeatureType,
                candidateSelectionBasis: input.candidateSelectionBasis,
                alternativeCandidatesRejected: input.alternativeCandidatesRejected,
                candidateConfidenceScore: input.candidateConfidenceScore
            ),
            captureQuality: CaptureQualityBundle(
                arPlaneStabilityScore: input.sessionQuality.planeStabilityScore,
                arMetricScaleValid: input.sessionQuality.metricScaleValid,
                arMetricScaleScore: input.sessionQuality.metricScaleScore
            ),
            unsupportedVisibleRestrictionFlag: input.unsupportedVisibleRestrictionFlag,
            versionRefs: versionRefs
        )
    }

    // MARK: - Quality polling

    /// Returns the current AR session quality from the engine's internal measurement session.
    /// Call this on every AR frame to check whether the session is ready for evaluation.
    public func currentQuality(from frame: ARFrame) -> ARSessionQuality {
        return measurementSession.currentQuality(from: frame)
    }

    // MARK: - Teardown

    public func teardown() {
        measurementSession.pauseSession()
        isInitialized = false
    }

    // MARK: - Helpers

    private func refusalResult(reason: RefusalReasonCode, input: EvaluationInput) -> ParkingEvaluationResult {
        return ParkingEvaluationResult(
            decisionState: .unverifiable,
            refusalReasons: [reason],
            ruleFamily: input.ruleFamily,
            measurement: nil,
            targetInfo: nil,
            featureCandidate: nil,
            captureQuality: CaptureQualityBundle(
                arPlaneStabilityScore: input.sessionQuality.planeStabilityScore,
                arMetricScaleValid: input.sessionQuality.metricScaleValid,
                arMetricScaleScore: input.sessionQuality.metricScaleScore
            ),
            unsupportedVisibleRestrictionFlag: input.unsupportedVisibleRestrictionFlag,
            versionRefs: versionRefs
        )
    }
}
