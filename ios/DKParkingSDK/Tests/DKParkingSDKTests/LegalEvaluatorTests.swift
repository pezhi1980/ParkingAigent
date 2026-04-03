// LegalEvaluatorTests.swift
// DK Parking Engine SDK — Phase 9 Vertical Slice Tests

import XCTest
@testable import DKParkingSDK

final class LegalEvaluatorTests: XCTestCase {

    let policy = PolicyRegistry.v1Default

    // MARK: - Pre-composition gates

    func test_lowMetricScale_returnsArScaleUntrusted() {
        let quality = ARSessionQuality(
            isValid: false,
            planeStabilityScore: 0.90,
            metricScaleScore: 0.50,
            metricScaleValid: false
        )
        let reason = LegalEvaluator.preCompositionRefusal(
            sessionQuality: quality,
            footprintQualityScore: 0.85,
            partialOcclusionDetected: false,
            candidateFound: true,
            candidateAmbiguous: false,
            totalEstimatedErrorM: 0.40,
            unsupportedVisibleRestriction: false,
            policy: policy
        )
        XCTAssertEqual(reason, .arScaleUntrusted)
    }

    func test_lowPlaneStability_returnsPlaneUnstable() {
        let quality = ARSessionQuality(
            isValid: false,
            planeStabilityScore: 0.50,
            metricScaleScore: 0.90,
            metricScaleValid: true
        )
        let reason = LegalEvaluator.preCompositionRefusal(
            sessionQuality: quality,
            footprintQualityScore: 0.85,
            partialOcclusionDetected: false,
            candidateFound: true,
            candidateAmbiguous: false,
            totalEstimatedErrorM: 0.40,
            unsupportedVisibleRestriction: false,
            policy: policy
        )
        XCTAssertEqual(reason, .planeUnstable)
    }

    func test_noCandidate_returnsBoundaryUnresolved() {
        let quality = ARSessionQuality(isValid: true, planeStabilityScore: 0.90, metricScaleScore: 0.90, metricScaleValid: true)
        let reason = LegalEvaluator.preCompositionRefusal(
            sessionQuality: quality,
            footprintQualityScore: 0.85,
            partialOcclusionDetected: false,
            candidateFound: false,
            candidateAmbiguous: false,
            totalEstimatedErrorM: 0.40,
            unsupportedVisibleRestriction: false,
            policy: policy
        )
        XCTAssertEqual(reason, .boundaryUnresolved)
    }

    func test_excessiveError_returnsInsufficientEvidence() {
        let quality = ARSessionQuality(isValid: true, planeStabilityScore: 0.90, metricScaleScore: 0.90, metricScaleValid: true)
        let reason = LegalEvaluator.preCompositionRefusal(
            sessionQuality: quality,
            footprintQualityScore: 0.85,
            partialOcclusionDetected: false,
            candidateFound: true,
            candidateAmbiguous: false,
            totalEstimatedErrorM: 2.5,
            unsupportedVisibleRestriction: false,
            policy: policy
        )
        XCTAssertEqual(reason, .insufficientEvidenceGeneral)
    }

    func test_allGatesPass_returnsNil() {
        let quality = ARSessionQuality(isValid: true, planeStabilityScore: 0.90, metricScaleScore: 0.90, metricScaleValid: true)
        let reason = LegalEvaluator.preCompositionRefusal(
            sessionQuality: quality,
            footprintQualityScore: 0.85,
            partialOcclusionDetected: false,
            candidateFound: true,
            candidateAmbiguous: false,
            totalEstimatedErrorM: 0.40,
            unsupportedVisibleRestriction: false,
            policy: policy
        )
        XCTAssertNil(reason)
    }

    // MARK: - Distance-based state selection

    func test_stronglyPositiveMargin_highConfidence_producesLegalWithBuffer() {
        let state = LegalEvaluator.stateForDistanceMeasurement(
            signedMarginM: 1.8,
            inNearThresholdZone: false,
            confidenceScore: 0.86,
            policy: policy
        )
        XCTAssertEqual(state, .legalWithBuffer)
    }

    func test_positiveMargin_inNearThreshold_producesProbablyLegal() {
        let state = LegalEvaluator.stateForDistanceMeasurement(
            signedMarginM: 0.3,
            inNearThresholdZone: true,
            confidenceScore: 0.86,
            policy: policy
        )
        XCTAssertEqual(state, .probablyLegal)
    }

    func test_negativeMargin_outsideNearThreshold_highConfidence_producesIllegal() {
        let state = LegalEvaluator.stateForDistanceMeasurement(
            signedMarginM: -1.5,
            inNearThresholdZone: false,
            confidenceScore: 0.85,
            policy: policy
        )
        XCTAssertEqual(state, .illegal)
    }

    func test_negativeMargin_inNearThreshold_producesProbablyIllegal() {
        let state = LegalEvaluator.stateForDistanceMeasurement(
            signedMarginM: -0.2,
            inNearThresholdZone: true,
            confidenceScore: 0.85,
            policy: policy
        )
        XCTAssertEqual(state, .probablyIllegal)
    }

    // MARK: - Post-composition escalation

    func test_mapPriorOnly_legalWithBuffer_downgradesToProbablyLegal() {
        let (finalState, reason) = LegalEvaluator.applyEscalation(
            state: .legalWithBuffer,
            confidenceScore: 0.82,
            boundaryProvenance: .mapPriorOnly,
            unsupportedVisibleRestriction: false,
            policy: policy
        )
        XCTAssertEqual(finalState, .probablyLegal)
        XCTAssertNil(reason)
    }

    func test_mapPriorOnly_illegal_downgradesToProbablyIllegal() {
        let (finalState, reason) = LegalEvaluator.applyEscalation(
            state: .illegal,
            confidenceScore: 0.82,
            boundaryProvenance: .mapPriorOnly,
            unsupportedVisibleRestriction: false,
            policy: policy
        )
        XCTAssertEqual(finalState, .probablyIllegal)
        XCTAssertNil(reason)
    }

    func test_veryLowConfidence_escalatesToUnverifiable() {
        let (finalState, reason) = LegalEvaluator.applyEscalation(
            state: .legalWithBuffer,
            confidenceScore: 0.18,
            boundaryProvenance: .visualDetection,
            unsupportedVisibleRestriction: false,
            policy: policy
        )
        XCTAssertEqual(finalState, .unverifiable)
        XCTAssertEqual(reason, .insufficientEvidenceGeneral)
    }

    func test_unsupportedRestriction_positiveResult_escalatesToUnverifiable() {
        let (finalState, reason) = LegalEvaluator.applyEscalation(
            state: .legalWithBuffer,
            confidenceScore: 0.85,
            boundaryProvenance: .visualDetection,
            unsupportedVisibleRestriction: true,
            policy: policy
        )
        XCTAssertEqual(finalState, .unverifiable)
        XCTAssertEqual(reason, .visibleUnsupportedRestriction)
    }

    func test_unsupportedRestriction_negativeResult_doesNotEscalate() {
        let (finalState, reason) = LegalEvaluator.applyEscalation(
            state: .illegal,
            confidenceScore: 0.85,
            boundaryProvenance: .visualDetection,
            unsupportedVisibleRestriction: true,
            policy: policy
        )
        XCTAssertEqual(finalState, .illegal)
        XCTAssertNil(reason)
    }
}
