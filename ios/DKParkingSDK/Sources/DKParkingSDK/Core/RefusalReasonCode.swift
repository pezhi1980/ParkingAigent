// RefusalReasonCode.swift
// DK Parking Engine SDK — Phase 9 Vertical Slice
// Source: uncertainty_and_confidence_strategy.md, ar_measurement_strategy.md

import Foundation

/// Locked refusal reason codes produced when decision_state == UNVERIFIABLE.
/// These values are non-negotiable. Do not add or remove without a MINOR SDK version bump.
public enum RefusalReasonCode: String, Codable, Equatable {
    /// AR metric scale cannot be trusted (world-tracking confidence too low).
    case arScaleUntrusted = "AR_SCALE_UNTRUSTED"

    /// Ground plane is unstable or does not cover the measurement corridor.
    case planeUnstable = "PLANE_UNSTABLE"

    /// The legal boundary reference point or line cannot be localized.
    case boundaryUnresolved = "BOUNDARY_UNRESOLVED"

    /// Multiple feature candidates qualify and ambiguity cannot be resolved.
    case featureCandidateAmbiguous = "FEATURE_CANDIDATE_AMBIGUOUS"

    /// The legally relevant vehicle footprint edge is partially occluded beyond the acceptable threshold.
    case targetEdgeOccluded = "TARGET_EDGE_OCCLUDED"

    /// The confirmed target vehicle is ambiguous or lost between confirmation and evaluation.
    case targetAmbiguous = "TARGET_AMBIGUOUS"

    /// A visible restriction is present that the engine does not support evaluating.
    case visibleUnsupportedRestriction = "VISIBLE_UNSUPPORTED_RESTRICTION"

    /// No active dataset region covers the current location, or the active bundle has expired.
    case noActiveDatasetRegion = "NO_ACTIVE_DATASET_REGION"

    /// General insufficient evidence — used when no more specific code applies.
    case insufficientEvidenceGeneral = "INSUFFICIENT_EVIDENCE_GENERAL"
}
