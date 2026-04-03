// RefusalReasonCode.kt
// DK Parking Engine SDK — Android Version 1 (Phase 9 Android)
// Locked refusal reason codes per uncertainty_and_confidence_strategy.md
// Parity: iOS RefusalReasonCode.swift (PC-002)

package com.dkparking.sdk.core

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

/**
 * Locked refusal reason codes produced when decision_state == UNVERIFIABLE.
 * These values are non-negotiable. Do not add or remove without a MINOR SDK version bump.
 */
@Serializable
enum class RefusalReasonCode(val rawValue: String) {
    /** AR metric scale cannot be trusted (world-tracking confidence too low). */
    @SerialName("AR_SCALE_UNTRUSTED")
    AR_SCALE_UNTRUSTED("AR_SCALE_UNTRUSTED"),

    /** Ground plane is unstable or does not cover the measurement corridor. */
    @SerialName("PLANE_UNSTABLE")
    PLANE_UNSTABLE("PLANE_UNSTABLE"),

    /** The legal boundary reference point or line cannot be localized. */
    @SerialName("BOUNDARY_UNRESOLVED")
    BOUNDARY_UNRESOLVED("BOUNDARY_UNRESOLVED"),

    /** Multiple feature candidates qualify and ambiguity cannot be resolved. */
    @SerialName("FEATURE_CANDIDATE_AMBIGUOUS")
    FEATURE_CANDIDATE_AMBIGUOUS("FEATURE_CANDIDATE_AMBIGUOUS"),

    /** The legally relevant vehicle footprint edge is partially occluded beyond the acceptable threshold. */
    @SerialName("TARGET_EDGE_OCCLUDED")
    TARGET_EDGE_OCCLUDED("TARGET_EDGE_OCCLUDED"),

    /** The confirmed target vehicle is ambiguous or lost between confirmation and evaluation. */
    @SerialName("TARGET_AMBIGUOUS")
    TARGET_AMBIGUOUS("TARGET_AMBIGUOUS"),

    /** A visible restriction is present that the engine does not support evaluating. */
    @SerialName("VISIBLE_UNSUPPORTED_RESTRICTION")
    VISIBLE_UNSUPPORTED_RESTRICTION("VISIBLE_UNSUPPORTED_RESTRICTION"),

    /** No active dataset region covers the current location, or the active bundle has expired. */
    @SerialName("NO_ACTIVE_DATASET_REGION")
    NO_ACTIVE_DATASET_REGION("NO_ACTIVE_DATASET_REGION"),

    /** General insufficient evidence — used when no more specific code applies. */
    @SerialName("INSUFFICIENT_EVIDENCE_GENERAL")
    INSUFFICIENT_EVIDENCE_GENERAL("INSUFFICIENT_EVIDENCE_GENERAL")
}
