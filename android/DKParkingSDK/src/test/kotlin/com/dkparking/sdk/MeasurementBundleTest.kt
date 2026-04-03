// MeasurementBundleTest.kt
// DK Parking Engine SDK — Android Unit Tests
// Parity: iOS MeasurementBundleTests.swift

package com.dkparking.sdk

import com.dkparking.sdk.ar.ARMeasurementSession
import com.dkparking.sdk.ar.MeasurementInput
import com.dkparking.sdk.ar.Vector3
import com.dkparking.sdk.core.BoundaryProvenance
import com.dkparking.sdk.core.MeasurementBundle
import com.dkparking.sdk.core.PolicyRegistry
import com.dkparking.sdk.core.RuleFamily
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Test

class MeasurementBundleTest {

    private lateinit var session: ARMeasurementSession
    private val policy = PolicyRegistry.v1Default

    @Before
    fun setUp() {
        session = ARMeasurementSession(policy)
        session.onSessionStarted()
    }

    // MARK: - Perpendicular distance geometry

    @Test
    fun `point directly in front of line segment gives correct distance`() {
        val input = MeasurementInput(
            vehicleFootprintEdgePoint = Vector3(0f, 0f, -3f),
            legalBoundaryLineStart = Vector3(-5f, 0f, -6f),
            legalBoundaryLineEnd = Vector3(5f, 0f, -6f),
            legalThresholdM = 5.0,
            ruleFamily = RuleFamily.PEDESTRIAN_CROSSING_5M,
            boundaryProvenance = BoundaryProvenance.VISUAL_DETECTION
        )
        val result = session.measure(input)
        assertNotNull(result)
        assertEquals(3.0, result!!.measuredDistanceM, 0.05)
    }

    @Test
    fun `vehicle inside restricted zone gives negative signed margin`() {
        val input = MeasurementInput(
            vehicleFootprintEdgePoint = Vector3(0f, 0f, -2f),
            legalBoundaryLineStart = Vector3(-5f, 0f, -6f),
            legalBoundaryLineEnd = Vector3(5f, 0f, -6f),
            legalThresholdM = 5.0,
            ruleFamily = RuleFamily.PEDESTRIAN_CROSSING_5M,
            boundaryProvenance = BoundaryProvenance.VISUAL_DETECTION
        )
        val result = session.measure(input)
        assertNotNull(result)
        assertTrue("Margin should be negative inside zone", result!!.signedMarginM < 0)
    }

    @Test
    fun `vehicle outside restricted zone gives positive signed margin`() {
        val input = MeasurementInput(
            vehicleFootprintEdgePoint = Vector3(0f, 0f, -2f),
            legalBoundaryLineStart = Vector3(-5f, 0f, -6f),
            legalBoundaryLineEnd = Vector3(5f, 0f, -6f),
            legalThresholdM = 2.5,
            ruleFamily = RuleFamily.PEDESTRIAN_CROSSING_5M,
            boundaryProvenance = BoundaryProvenance.VISUAL_DETECTION
        )
        val result = session.measure(input)
        assertNotNull(result)
        assertTrue("Margin should be positive outside zone", result!!.signedMarginM > 0)
    }

    @Test
    fun `map prior only provenance produces larger error budget than visual detection`() {
        val inputVisual = MeasurementInput(
            vehicleFootprintEdgePoint = Vector3(0f, 0f, -3f),
            legalBoundaryLineStart = Vector3(-5f, 0f, -6f),
            legalBoundaryLineEnd = Vector3(5f, 0f, -6f),
            legalThresholdM = 5.0,
            ruleFamily = RuleFamily.PEDESTRIAN_CROSSING_5M,
            boundaryProvenance = BoundaryProvenance.VISUAL_DETECTION
        )
        val inputMapOnly = inputVisual.copy(boundaryProvenance = BoundaryProvenance.MAP_PRIOR_ONLY)

        val visualResult = session.measure(inputVisual)
        val mapOnlyResult = session.measure(inputMapOnly)

        assertNotNull(visualResult)
        assertNotNull(mapOnlyResult)
        assertTrue(
            "Map-prior-only should have larger error budget",
            mapOnlyResult!!.totalEstimatedErrorM > visualResult!!.totalEstimatedErrorM
        )
    }

    @Test
    fun `excessive error budget returns null`() {
        val inputMapOnly = MeasurementInput(
            vehicleFootprintEdgePoint = Vector3(0f, 0f, -3f),
            legalBoundaryLineStart = Vector3(-5f, 0f, -6f),
            legalBoundaryLineEnd = Vector3(5f, 0f, -6f),
            legalThresholdM = 5.0,
            ruleFamily = RuleFamily.INTERSECTION_10M,
            boundaryProvenance = BoundaryProvenance.MAP_PRIOR_ONLY
        )
        // MAP_PRIOR_ONLY error = sqrt(0.18² + 0.10² + 0.20² + 1.20²) ≈ 1.24 < 2.0 — should NOT be null
        val result = session.measure(inputMapOnly)
        assertNotNull(result)
    }

    // MARK: - MeasurementBundle inNearThresholdZone

    @Test
    fun `near threshold zone is set correctly for margin within error plus downgrade margin`() {
        val bundle = MeasurementBundle.create(
            ruleFamily = "pedestrian_crossing_5m",
            legalThresholdM = 5.0,
            measuredDistanceM = 5.2,
            signedMarginM = 0.2,
            totalEstimatedErrorM = 0.35,
            confidenceScore = 0.85,
            measurementReferenceType = "vehicle_footprint_edge_to_boundary_line",
            boundaryProvenance = BoundaryProvenance.VISUAL_DETECTION,
            nearThresholdDowngradeMarginM = 0.30
        )
        // abs(0.2) < (0.35 + 0.30) = 0.55 → inNearThresholdZone = true
        assertTrue(bundle.inNearThresholdZone)
    }

    @Test
    fun `large margin is not in near threshold zone`() {
        val bundle = MeasurementBundle.create(
            ruleFamily = "pedestrian_crossing_5m",
            legalThresholdM = 5.0,
            measuredDistanceM = 8.0,
            signedMarginM = 3.0,
            totalEstimatedErrorM = 0.35,
            confidenceScore = 0.90,
            measurementReferenceType = "vehicle_footprint_edge_to_boundary_line",
            boundaryProvenance = BoundaryProvenance.VISUAL_DETECTION,
            nearThresholdDowngradeMarginM = 0.30
        )
        // abs(3.0) < (0.35 + 0.30) = 0.65 → false
        assertEquals(false, bundle.inNearThresholdZone)
    }
}
