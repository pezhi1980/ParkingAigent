// ParkingEvaluationResult.swift
// DK Parking Engine SDK — Phase 9 Vertical Slice
// Implements the full output contract per OUTPUT_CONTRACT.md

import Foundation

// MARK: - Top-level result

/// The complete structured output from a single parking evaluation call.
/// All fields are normative per OUTPUT_CONTRACT.md.
public struct ParkingEvaluationResult: Codable {
    public let evaluationId: String
    public let timestamp: Date
    public let decisionState: DecisionState
    public let refusalReasons: [RefusalReasonCode]
    /// Top-level rule family being evaluated (REQUIRED per OUTPUT_CONTRACT.md §2).
    public let ruleFamily: RuleFamily
    public let measurement: MeasurementBundle?
    public let targetInfo: TargetInfo?
    public let featureCandidate: FeatureCandidateInfo?
    public let captureQuality: CaptureQualityBundle
    /// Advisory-first family outputs (empty list if none; REQUIRED per OUTPUT_CONTRACT.md §2).
    public let advisoryOutputs: [AdvisoryOutput]
    public let unsupportedVisibleRestrictionFlag: Bool
    /// Locked limitations notice text (REQUIRED per OUTPUT_CONTRACT.md §2, source: user_disclosures_and_copy.md §6).
    public let limitationsNotice: String
    public let versionRefs: VersionRefs

    public init(
        evaluationId: String = UUID().uuidString,
        timestamp: Date = Date(),
        decisionState: DecisionState,
        refusalReasons: [RefusalReasonCode] = [],
        ruleFamily: RuleFamily,
        measurement: MeasurementBundle? = nil,
        targetInfo: TargetInfo? = nil,
        featureCandidate: FeatureCandidateInfo? = nil,
        captureQuality: CaptureQualityBundle,
        advisoryOutputs: [AdvisoryOutput] = [],
        unsupportedVisibleRestrictionFlag: Bool = false,
        limitationsNotice: String = "This app evaluates only specific supported Danish stopping and parking rules. Other rules, signs, and restrictions may apply. This is not legal advice.",
        versionRefs: VersionRefs
    ) {
        self.evaluationId = evaluationId
        self.timestamp = timestamp
        self.decisionState = decisionState
        self.refusalReasons = refusalReasons
        self.ruleFamily = ruleFamily
        self.measurement = measurement
        self.targetInfo = targetInfo
        self.featureCandidate = featureCandidate
        self.captureQuality = captureQuality
        self.advisoryOutputs = advisoryOutputs
        self.unsupportedVisibleRestrictionFlag = unsupportedVisibleRestrictionFlag
        self.limitationsNotice = limitationsNotice
        self.versionRefs = versionRefs
    }
}

// MARK: - MeasurementBundle

/// Metric measurement details. Present only when a measurement was successfully computed.
/// Per OUTPUT_CONTRACT.md section 4.
public struct MeasurementBundle: Codable {
    public let ruleFamily: String
    public let legalThresholdM: Double
    public let measuredDistanceM: Double
    public let signedMarginM: Double
    public let totalEstimatedErrorM: Double
    public let confidenceScore: Double
    public let measurementReferenceType: String
    public let boundaryProvenance: BoundaryProvenance
    /// Which vehicle edge was used as the measurement reference (REQUIRED per OUTPUT_CONTRACT.md §4).
    public let vehicleEdgeUsed: String
    public let inNearThresholdZone: Bool

    public init(
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
    ) {
        self.ruleFamily = ruleFamily
        self.legalThresholdM = legalThresholdM
        self.measuredDistanceM = measuredDistanceM
        self.signedMarginM = signedMarginM
        self.totalEstimatedErrorM = totalEstimatedErrorM
        self.confidenceScore = confidenceScore
        self.measurementReferenceType = measurementReferenceType
        self.boundaryProvenance = boundaryProvenance
        self.vehicleEdgeUsed = vehicleEdgeUsed
        self.inNearThresholdZone = abs(signedMarginM) < (totalEstimatedErrorM + nearThresholdDowngradeMarginM)
    }
}

// MARK: - BoundaryProvenance

/// The provenance tier of the legal boundary used in measurement.
/// Locked values per legal_boundary_localization_strategy.md section 5.
public enum BoundaryProvenance: String, Codable {
    case visualDetection = "visual_detection"
    case mapPriorAssisted = "map_prior_assisted"
    case mapPriorOnly = "map_prior_only"
}

// MARK: - TargetInfo

/// Information about the confirmed target vehicle.
/// Per OUTPUT_CONTRACT.md section 5.
public struct TargetInfo: Codable {
    /// Identifier of the confirmed active target (REQUIRED per OUTPUT_CONTRACT.md §5).
    public let targetId: String
    public let targetConfirmationSource: TargetConfirmationSource
    public let footprintQualityScore: Double
    public let partialOcclusionDetected: Bool

    public init(
        targetId: String = UUID().uuidString,
        targetConfirmationSource: TargetConfirmationSource,
        footprintQualityScore: Double,
        partialOcclusionDetected: Bool
    ) {
        self.targetId = targetId
        self.targetConfirmationSource = targetConfirmationSource
        self.footprintQualityScore = footprintQualityScore
        self.partialOcclusionDetected = partialOcclusionDetected
    }
}

public enum TargetConfirmationSource: String, Codable {
    case autoSelectedUnambiguous = "auto_selected_unambiguous"
    case userConfirmed = "user_confirmed"
}

// MARK: - FeatureCandidateInfo

/// Information about the matched dataset feature candidate.
/// Per OUTPUT_CONTRACT.md section 6.
public struct FeatureCandidateInfo: Codable {
    public let candidateFeatureId: String
    public let candidateFeatureType: String
    public let candidateSelectionBasis: String
    public let alternativeCandidatesRejected: Int
    public let candidateConfidenceScore: Double

    public init(
        candidateFeatureId: String,
        candidateFeatureType: String,
        candidateSelectionBasis: String,
        alternativeCandidatesRejected: Int,
        candidateConfidenceScore: Double
    ) {
        self.candidateFeatureId = candidateFeatureId
        self.candidateFeatureType = candidateFeatureType
        self.candidateSelectionBasis = candidateSelectionBasis
        self.alternativeCandidatesRejected = alternativeCandidatesRejected
        self.candidateConfidenceScore = candidateConfidenceScore
    }
}

// MARK: - CaptureQualityBundle

/// AR session quality indicators at time of capture.
/// Per OUTPUT_CONTRACT.md section 8.
public struct CaptureQualityBundle: Codable {
    /// Camera focus quality score (REQUIRED per OUTPUT_CONTRACT.md §8).
    public let focusScore: Double
    /// Scene brightness quality score (REQUIRED per OUTPUT_CONTRACT.md §8).
    public let brightnessScore: Double
    public let arPlaneStabilityScore: Double
    public let arMetricScaleValid: Bool
    public let arMetricScaleScore: Double

    public init(
        focusScore: Double = 1.0,
        brightnessScore: Double = 1.0,
        arPlaneStabilityScore: Double,
        arMetricScaleValid: Bool,
        arMetricScaleScore: Double
    ) {
        self.focusScore = focusScore
        self.brightnessScore = brightnessScore
        self.arPlaneStabilityScore = arPlaneStabilityScore
        self.arMetricScaleValid = arMetricScaleValid
        self.arMetricScaleScore = arMetricScaleScore
    }
}

// MARK: - AdvisoryOutput

/// Advisory-first family output.
/// Per OUTPUT_CONTRACT.md section 9.
public struct AdvisoryOutput: Codable {
    /// The advisory family name (e.g., `driveway_obstruction`).
    public let advisoryFamily: String
    /// `ADVISORY_CONCERN` or `ADVISORY_NO_CONCERN_DETECTED`.
    public let advisoryState: String
    /// Display label — MUST include the word "advisory".
    public let advisoryLabel: String
    /// Optional additional context.
    public let advisoryNotes: String?

    public init(
        advisoryFamily: String,
        advisoryState: String,
        advisoryLabel: String,
        advisoryNotes: String? = nil
    ) {
        self.advisoryFamily = advisoryFamily
        self.advisoryState = advisoryState
        self.advisoryLabel = advisoryLabel
        self.advisoryNotes = advisoryNotes
    }
}

// MARK: - VersionRefs

/// Version references for full traceability per VERSIONING_POLICY.md.
/// All fields are mandatory in every result.
public struct VersionRefs: Codable {
    public let sdkVersion: String
    public let policyVersion: String
    public let datasetVersion: String
    public let datasetRegionId: String
    public let modelVersion: String
    public let legalSourceBaselineDate: String

    public init(
        sdkVersion: String,
        policyVersion: String,
        datasetVersion: String,
        datasetRegionId: String,
        modelVersion: String,
        legalSourceBaselineDate: String
    ) {
        self.sdkVersion = sdkVersion
        self.policyVersion = policyVersion
        self.datasetVersion = datasetVersion
        self.datasetRegionId = datasetRegionId
        self.modelVersion = modelVersion
        self.legalSourceBaselineDate = legalSourceBaselineDate
    }
}
