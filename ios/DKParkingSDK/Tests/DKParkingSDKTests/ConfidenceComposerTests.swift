// ConfidenceComposerTests.swift
// DK Parking Engine SDK — Phase 9 Vertical Slice Tests

import XCTest
@testable import DKParkingSDK

final class ConfidenceComposerTests: XCTestCase {

    // MARK: - Zero-in-any-dimension drives result to zero (anti-masking)

    func test_zeroFootprintScore_drivesConfidenceToZero() {
        let scores = EvidenceScores(
            arPlaneStabilityScore: 0.92,
            arMetricScaleScore: 0.88,
            footprintQualityScore: 0.0,
            candidateConfidenceScore: 0.80,
            boundaryProvenance: .visualDetection,
            totalEstimatedErrorM: 0.35
        )
        XCTAssertEqual(ConfidenceComposer.compose(from: scores), 0.0, "Zero in any score MUST drive confidence to 0")
    }

    func test_zeroCandidateScore_drivesConfidenceToZero() {
        let scores = EvidenceScores(
            arPlaneStabilityScore: 0.92,
            arMetricScaleScore: 0.88,
            footprintQualityScore: 0.85,
            candidateConfidenceScore: 0.0,
            boundaryProvenance: .visualDetection,
            totalEstimatedErrorM: 0.35
        )
        XCTAssertEqual(ConfidenceComposer.compose(from: scores), 0.0)
    }

    // MARK: - High quality inputs produce high confidence

    func test_allHighQuality_producesHighConfidence() {
        let scores = EvidenceScores(
            arPlaneStabilityScore: 0.92,
            arMetricScaleScore: 0.88,
            footprintQualityScore: 0.85,
            candidateConfidenceScore: 0.80,
            boundaryProvenance: .visualDetection,
            totalEstimatedErrorM: 0.35
        )
        let result = ConfidenceComposer.compose(from: scores)
        XCTAssertGreaterThan(result, 0.80, "High quality inputs should produce confidence > 0.80")
    }

    // MARK: - Map-prior-only boundary lowers confidence

    func test_mapPriorOnly_lowersBoundaryScore() {
        let visualScores = EvidenceScores(
            arPlaneStabilityScore: 0.90,
            arMetricScaleScore: 0.90,
            footprintQualityScore: 0.90,
            candidateConfidenceScore: 0.90,
            boundaryProvenance: .visualDetection,
            totalEstimatedErrorM: 0.20
        )
        let mapOnlyScores = EvidenceScores(
            arPlaneStabilityScore: 0.90,
            arMetricScaleScore: 0.90,
            footprintQualityScore: 0.90,
            candidateConfidenceScore: 0.90,
            boundaryProvenance: .mapPriorOnly,
            totalEstimatedErrorM: 0.20
        )
        let visualConfidence = ConfidenceComposer.compose(from: visualScores)
        let mapConfidence = ConfidenceComposer.compose(from: mapOnlyScores)
        XCTAssertGreaterThan(visualConfidence, mapConfidence, "Visual provenance should produce higher confidence than map-prior-only")
    }

    // MARK: - Large error budget reduces confidence

    func test_largeErrorBudget_reducesConfidence() {
        let lowError = EvidenceScores(
            arPlaneStabilityScore: 0.90,
            arMetricScaleScore: 0.90,
            footprintQualityScore: 0.90,
            candidateConfidenceScore: 0.90,
            boundaryProvenance: .visualDetection,
            totalEstimatedErrorM: 0.20
        )
        let highError = EvidenceScores(
            arPlaneStabilityScore: 0.90,
            arMetricScaleScore: 0.90,
            footprintQualityScore: 0.90,
            candidateConfidenceScore: 0.90,
            boundaryProvenance: .visualDetection,
            totalEstimatedErrorM: 1.80
        )
        XCTAssertGreaterThan(
            ConfidenceComposer.compose(from: lowError),
            ConfidenceComposer.compose(from: highError),
            "Lower error budget should produce higher confidence"
        )
    }
}
