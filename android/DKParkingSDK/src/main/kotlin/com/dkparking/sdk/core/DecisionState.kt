// DecisionState.kt
// DK Parking Engine SDK — Android Version 1 (Phase 9 Android)
// Locked vocabulary per DECISION_STATES.md and user_disclosures_and_copy.md
// Parity: iOS DecisionState.swift (PC-001)

package com.dkparking.sdk.core

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

/**
 * The five locked decision states for the DK Parking Engine.
 * These values are non-negotiable. Do not add, remove, or rename cases.
 * Source: DECISION_STATES.md
 */
@Serializable
enum class DecisionState(val rawValue: String) {
    /** Measurement and evidence clearly indicate the vehicle is outside all applicable
     *  legal boundaries with a meaningful safety buffer. */
    @SerialName("LEGAL_WITH_BUFFER")
    LEGAL_WITH_BUFFER("LEGAL_WITH_BUFFER"),

    /** Evidence indicates likely compliance but proximity to a boundary or evidence
     *  quality prevents a high-confidence determination. */
    @SerialName("PROBABLY_LEGAL")
    PROBABLY_LEGAL("PROBABLY_LEGAL"),

    /** Evidence indicates likely non-compliance but proximity to a boundary or evidence
     *  quality prevents a high-confidence determination. */
    @SerialName("PROBABLY_ILLEGAL")
    PROBABLY_ILLEGAL("PROBABLY_ILLEGAL"),

    /** Measurement and evidence clearly indicate the vehicle is inside a prohibited zone
     *  or within a legally restricted distance. */
    @SerialName("ILLEGAL")
    ILLEGAL("ILLEGAL"),

    /** The engine cannot produce a reliable legal determination from available evidence. */
    @SerialName("UNVERIFIABLE")
    UNVERIFIABLE("UNVERIFIABLE")
}
