// DecisionState.swift
// DK Parking Engine SDK — Phase 9 Vertical Slice
// Locked vocabulary per DECISION_STATES.md and user_disclosures_and_copy.md

import Foundation

/// The five locked decision states for the DK Parking Engine.
/// These values are non-negotiable. Do not add, remove, or rename cases.
/// Source: DECISION_STATES.md
public enum DecisionState: String, Codable, Equatable {
    /// Measurement and evidence clearly indicate the vehicle is outside all applicable
    /// legal boundaries with a meaningful safety buffer.
    case legalWithBuffer = "LEGAL_WITH_BUFFER"

    /// Evidence indicates likely compliance but proximity to a boundary or evidence
    /// quality prevents a high-confidence determination.
    case probablyLegal = "PROBABLY_LEGAL"

    /// Evidence indicates likely non-compliance but proximity to a boundary or evidence
    /// quality prevents a high-confidence determination.
    case probablyIllegal = "PROBABLY_ILLEGAL"

    /// Measurement and evidence clearly indicate the vehicle is inside a prohibited zone
    /// or within a legally restricted distance.
    case illegal = "ILLEGAL"

    /// The engine cannot produce a reliable legal determination from available evidence.
    case unverifiable = "UNVERIFIABLE"
}
