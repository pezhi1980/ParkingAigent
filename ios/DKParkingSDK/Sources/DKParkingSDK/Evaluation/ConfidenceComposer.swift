// ConfidenceComposer.swift
// DK Parking Engine SDK — Phase 9 Vertical Slice
// Implements confidence composition per uncertainty_and_confidence_strategy.md

import Foundation

// MARK: - Individual evidence scores

/// All individual evidence quality scores used in confidence composition.
/// Per uncertainty_and_confidence_strategy.md section 3.
public struct EvidenceScores {
    public let arPlaneStabilityScore: Double
    public let arMetricScaleScore: Double
    public let footprintQualityScore: Double
    public let candidateConfidenceScore: Double
    public let boundaryLocalizationScore: Double
    public let measurementErrorBudgetScore: Double

    public init(
        arPlaneStabilityScore: Double,
        arMetricScaleScore: Double,
        footprintQualityScore: Double,
        candidateConfidenceScore: Double,
        boundaryProvenance: BoundaryProvenance,
        totalEstimatedErrorM: Double
    ) {
        self.arPlaneStabilityScore = arPlaneStabilityScore
        self.arMetricScaleScore = arMetricScaleScore
        self.footprintQualityScore = footprintQualityScore
        self.candidateConfidenceScore = candidateConfidenceScore

        // boundary_localization_score derived from provenance tier
        switch boundaryProvenance {
        case .visualDetection:
            self.boundaryLocalizationScore = 0.90
        case .mapPriorAssisted:
            self.boundaryLocalizationScore = 0.70
        case .mapPriorOnly:
            self.boundaryLocalizationScore = 0.50
        }

        // measurement_error_budget_score: 1.0 - (error / 2.0), clamped to [0, 1]
        self.measurementErrorBudgetScore = max(0.0, 1.0 - totalEstimatedErrorM / 2.0)
    }
}

// MARK: - Confidence composer

/// Computes the overall confidence_score from individual evidence scores.
/// Uses geometric-mean composition per uncertainty_and_confidence_strategy.md section 4.
///
/// Weights: plane=0.15, scale=0.20, footprint=0.20, candidate=0.20, boundary=0.15, error=0.10
/// A score of 0.0 in any dimension drives the overall score to 0.0 (no masking).
public enum ConfidenceComposer {

    public static func compose(from scores: EvidenceScores) -> Double {
        let terms: [(score: Double, weight: Double)] = [
            (scores.arPlaneStabilityScore,      0.15),
            (scores.arMetricScaleScore,          0.20),
            (scores.footprintQualityScore,       0.20),
            (scores.candidateConfidenceScore,    0.20),
            (scores.boundaryLocalizationScore,   0.15),
            (scores.measurementErrorBudgetScore, 0.10)
        ]

        var logSum = 0.0
        for term in terms {
            let clamped = max(0.0, min(1.0, term.score))
            if clamped == 0.0 { return 0.0 }
            logSum += term.weight * log(clamped)
        }

        return max(0.0, min(1.0, exp(logSum)))
    }
}
