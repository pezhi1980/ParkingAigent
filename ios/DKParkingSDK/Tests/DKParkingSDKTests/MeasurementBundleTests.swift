// MeasurementBundleTests.swift
// DK Parking Engine SDK — Phase 9 Vertical Slice Tests

import XCTest
@testable import DKParkingSDK

final class MeasurementBundleTests: XCTestCase {

    // MARK: - LegalThresholds (locked values — must not regress)

    func test_pedestrianCrossing_threshold_is5m() {
        XCTAssertEqual(LegalThresholds.threshold(for: .pedestrianCrossing5m), 5.0)
    }

    func test_cyclePathExit_threshold_is5m() {
        XCTAssertEqual(LegalThresholds.threshold(for: .cyclePathExit5m), 5.0)
    }

    func test_intersection_threshold_is10m() {
        XCTAssertEqual(LegalThresholds.threshold(for: .intersection10m), 10.0)
    }

    func test_busStop12mFallback_threshold_is12m() {
        XCTAssertEqual(LegalThresholds.threshold(for: .busStop12mFallback), 12.0)
    }

    func test_busStopMarkedSegment_threshold_is12m() {
        XCTAssertEqual(LegalThresholds.threshold(for: .busStopMarkedSegment), 12.0)
    }

    func test_prohibitedSurfaces_threshold_is0m() {
        XCTAssertEqual(LegalThresholds.threshold(for: .directProhibitedSurfaces), 0.0)
    }

    // MARK: - RuleFamily.isDistanceBased

    func test_pedestrianCrossing_isDistanceBased() {
        XCTAssertTrue(RuleFamily.pedestrianCrossing5m.isDistanceBased)
    }

    func test_prohibitedSurfaces_isNotDistanceBased() {
        XCTAssertFalse(RuleFamily.directProhibitedSurfaces.isDistanceBased)
    }

    // MARK: - MeasurementBundle.inNearThresholdZone

    func test_signedMargin_1_8m_notInNearThresholdZone() {
        // error = 0.40m, nearThresholdMargin = 0.30m → zone limit = 0.70m
        // |1.8| = 1.8 > 0.70 → NOT in near-threshold zone
        let bundle = MeasurementBundle(
            ruleFamily: "pedestrian_crossing_5m",
            legalThresholdM: 5.0,
            measuredDistanceM: 6.8,
            signedMarginM: 1.8,
            totalEstimatedErrorM: 0.40,
            confidenceScore: 0.85,
            measurementReferenceType: "vehicle_footprint_edge_to_boundary_line",
            boundaryProvenance: .mapPriorAssisted,
            nearThresholdDowngradeMarginM: 0.30
        )
        XCTAssertFalse(bundle.inNearThresholdZone)
    }

    func test_signedMargin_0_3m_inNearThresholdZone() {
        // error = 0.40m, nearThresholdMargin = 0.30m → zone limit = 0.70m
        // |0.3| = 0.3 < 0.70 → IN near-threshold zone
        let bundle = MeasurementBundle(
            ruleFamily: "pedestrian_crossing_5m",
            legalThresholdM: 5.0,
            measuredDistanceM: 5.3,
            signedMarginM: 0.3,
            totalEstimatedErrorM: 0.40,
            confidenceScore: 0.85,
            measurementReferenceType: "vehicle_footprint_edge_to_boundary_line",
            boundaryProvenance: .mapPriorAssisted,
            nearThresholdDowngradeMarginM: 0.30
        )
        XCTAssertTrue(bundle.inNearThresholdZone)
    }

    func test_negativeMargin_0_2m_inNearThresholdZone() {
        // error = 0.40m, nearThresholdMargin = 0.30m → zone limit = 0.70m
        // |-0.2| = 0.2 < 0.70 → IN near-threshold zone
        let bundle = MeasurementBundle(
            ruleFamily: "pedestrian_crossing_5m",
            legalThresholdM: 5.0,
            measuredDistanceM: 4.8,
            signedMarginM: -0.2,
            totalEstimatedErrorM: 0.40,
            confidenceScore: 0.85,
            measurementReferenceType: "vehicle_footprint_edge_to_boundary_line",
            boundaryProvenance: .visualDetection,
            nearThresholdDowngradeMarginM: 0.30
        )
        XCTAssertTrue(bundle.inNearThresholdZone)
    }

    func test_negativeMargin_1_5m_notInNearThresholdZone() {
        // error = 0.40m → zone limit = 0.70m
        // |-1.5| = 1.5 > 0.70 → NOT in near-threshold zone
        let bundle = MeasurementBundle(
            ruleFamily: "pedestrian_crossing_5m",
            legalThresholdM: 5.0,
            measuredDistanceM: 3.5,
            signedMarginM: -1.5,
            totalEstimatedErrorM: 0.40,
            confidenceScore: 0.85,
            measurementReferenceType: "vehicle_footprint_edge_to_boundary_line",
            boundaryProvenance: .visualDetection,
            nearThresholdDowngradeMarginM: 0.30
        )
        XCTAssertFalse(bundle.inNearThresholdZone)
    }

    // MARK: - Vertical slice synthetic geometry verification

    func test_syntheticGeometry_verticalSlice_expectedLegalWithBuffer() {
        // vehicleEdge at 6.8m from boundary (threshold 5m) → signed_margin = +1.8m
        // error budget (mapPriorAssisted): √(0.18²+0.10²+0.20²+0.50²) ≈ 0.577m
        // zone limit = 0.577 + 0.30 = 0.877m → |1.8| = 1.8 > 0.877 → NOT in near-threshold zone
        let measuredDistanceM = 6.8
        let threshold = LegalThresholds.threshold(for: .pedestrianCrossing5m)
        let signedMargin = measuredDistanceM - threshold

        XCTAssertEqual(threshold, 5.0)
        XCTAssertEqual(signedMargin, 1.8, accuracy: 0.001)

        let totalError = sqrt(0.18 * 0.18 + 0.10 * 0.10 + 0.20 * 0.20 + 0.50 * 0.50)
        XCTAssertEqual(totalError, 0.577, accuracy: 0.001)

        let zoneLimit = totalError + 0.30
        XCTAssertFalse(abs(signedMargin) < zoneLimit,
                       "Synthetic geometry should NOT be in near-threshold zone for LEGAL_WITH_BUFFER")
    }

    // MARK: - PolicyRegistry v1Default locked values (regression guard)

    func test_policyV1Default_minConfidenceForLegalWithBuffer_is0_80() {
        XCTAssertEqual(PolicyRegistry.v1Default.minConfidenceForLegalWithBuffer, 0.80)
    }

    func test_policyV1Default_nearThresholdMargin_is0_30() {
        XCTAssertEqual(PolicyRegistry.v1Default.nearThresholdDowngradeMarginM, 0.30)
    }

    func test_policyV1Default_minArPlaneStability_is0_70() {
        XCTAssertEqual(PolicyRegistry.v1Default.minArPlaneStabilityScore, 0.70)
    }

    func test_policyV1Default_minArMetricScale_is0_75() {
        XCTAssertEqual(PolicyRegistry.v1Default.minArMetricScaleScore, 0.75)
    }
}
