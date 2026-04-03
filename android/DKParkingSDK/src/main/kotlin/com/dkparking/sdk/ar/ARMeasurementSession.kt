// ARMeasurementSession.kt
// DK Parking Engine SDK — Android Version 1 (Phase 9 Android)
// AR measurement backbone using ARCore — parity with iOS ARMeasurementSession.swift
// Per ar_measurement_strategy.md

package com.dkparking.sdk.ar

import com.dkparking.sdk.core.BoundaryProvenance
import com.dkparking.sdk.core.PolicyRegistry
import com.dkparking.sdk.core.RuleFamily
import com.google.ar.core.Frame
import com.google.ar.core.Plane
import com.google.ar.core.TrackingFailureReason
import com.google.ar.core.TrackingState
import kotlin.math.abs
import kotlin.math.min
import kotlin.math.sqrt

// MARK: - Session quality

data class ARSessionQuality(
    val isValid: Boolean,
    val planeStabilityScore: Double,
    val metricScaleScore: Double,
    val metricScaleValid: Boolean
) {
    companion object {
        val invalid = ARSessionQuality(
            isValid = false,
            planeStabilityScore = 0.0,
            metricScaleScore = 0.0,
            metricScaleValid = false
        )
    }
}

// MARK: - Measurement input / output

data class Vector3(val x: Float, val y: Float, val z: Float)

data class MeasurementInput(
    val vehicleFootprintEdgePoint: Vector3,
    val legalBoundaryLineStart: Vector3,
    val legalBoundaryLineEnd: Vector3,
    val legalThresholdM: Double,
    val ruleFamily: RuleFamily,
    val boundaryProvenance: BoundaryProvenance
)

data class MeasurementOutput(
    val measuredDistanceM: Double,
    val signedMarginM: Double,
    val totalEstimatedErrorM: Double,
    val errorComponents: MeasurementErrorComponents
)

data class MeasurementErrorComponents(
    val arScaleErrorM: Double,
    val planeFitErrorM: Double,
    val vehicleEdgeLocalizationErrorM: Double,
    val boundaryLocalizationErrorM: Double
) {
    /** RSS combination per ar_measurement_strategy.md section 5.2 */
    val total: Double
        get() = sqrt(
            arScaleErrorM * arScaleErrorM +
            planeFitErrorM * planeFitErrorM +
            vehicleEdgeLocalizationErrorM * vehicleEdgeLocalizationErrorM +
            boundaryLocalizationErrorM * boundaryLocalizationErrorM
        )
}

// MARK: - AR Measurement Session (ARCore)

/**
 * Wraps ARCore Session and provides scored quality metrics and metric distance measurement.
 * Per ar_measurement_strategy.md. ARCore equivalent of iOS ARMeasurementSession.
 */
class ARMeasurementSession(private val policy: PolicyRegistry) {

    private var detectedPlanes: MutableList<Plane> = mutableListOf()
    private var sessionStartTimeMs: Long? = null
    private var lastInterruptionTimeMs: Long? = null

    fun onSessionStarted() {
        sessionStartTimeMs = System.currentTimeMillis()
        detectedPlanes.clear()
    }

    fun onSessionPaused() {
        lastInterruptionTimeMs = System.currentTimeMillis()
    }

    fun onPlanesUpdated(updatedPlanes: Collection<Plane>) {
        for (plane in updatedPlanes) {
            if (plane.type == Plane.Type.HORIZONTAL_UPWARD_FACING &&
                plane.trackingState == TrackingState.TRACKING) {
                if (!detectedPlanes.contains(plane)) {
                    detectedPlanes.add(plane)
                }
            }
        }
        detectedPlanes.removeAll { it.trackingState == TrackingState.STOPPED }
    }

    // MARK: - Quality scoring

    /**
     * Evaluates current session quality from an ARCore Frame.
     * Per ar_measurement_strategy.md sections 3 and 8.
     */
    fun currentQuality(frame: Frame): ARSessionQuality {
        val startTime = sessionStartTimeMs ?: return ARSessionQuality.invalid
        if (System.currentTimeMillis() - startTime < 2000L) return ARSessionQuality.invalid

        val interruptTime = lastInterruptionTimeMs
        if (interruptTime != null && System.currentTimeMillis() - interruptTime < 1000L) {
            return ARSessionQuality.invalid
        }

        val metricScaleScore = metricScaleScore(frame)
        val planeStabilityScore = planeStabilityScore(frame)
        val metricScaleValid = metricScaleScore >= policy.minArMetricScaleScore

        val isValid = metricScaleValid && planeStabilityScore >= policy.minArPlaneStabilityScore

        return ARSessionQuality(
            isValid = isValid,
            planeStabilityScore = planeStabilityScore,
            metricScaleScore = metricScaleScore,
            metricScaleValid = metricScaleValid
        )
    }

    private fun metricScaleScore(frame: Frame): Double {
        return when (frame.camera.trackingState) {
            TrackingState.TRACKING -> 1.0
            TrackingState.PAUSED -> when (frame.camera.trackingFailureReason) {
                TrackingFailureReason.INITIALIZING -> 0.2
                TrackingFailureReason.RELOCALIZING -> 0.2
                TrackingFailureReason.EXCESSIVE_MOTION -> 0.4
                TrackingFailureReason.INSUFFICIENT_FEATURES -> 0.3
                TrackingFailureReason.INSUFFICIENT_LIGHT -> 0.2
                TrackingFailureReason.CAMERA_UNAVAILABLE -> 0.0
                else -> 0.2
            }
            TrackingState.STOPPED -> 0.0
            else -> 0.0
        }
    }

    private fun planeStabilityScore(frame: Frame): Double {
        if (detectedPlanes.isEmpty()) return 0.0
        val baseScore = metricScaleScore(frame)
        return min(1.0, baseScore * 0.9 + 0.1 * min(detectedPlanes.size, 3).toDouble() / 3.0)
    }

    // MARK: - Metric distance measurement

    /**
     * Computes the perpendicular distance from a vehicle footprint edge point to a
     * legal boundary line, both projected on the AR ground plane (XZ plane).
     * Returns null if the measurement cannot be computed.
     */
    fun measure(input: MeasurementInput): MeasurementOutput? {
        val edgePt = floatArrayOf(input.vehicleFootprintEdgePoint.x, input.vehicleFootprintEdgePoint.z)
        val lineStart = floatArrayOf(input.legalBoundaryLineStart.x, input.legalBoundaryLineStart.z)
        val lineEnd = floatArrayOf(input.legalBoundaryLineEnd.x, input.legalBoundaryLineEnd.z)

        val distanceM = perpendicularDistance(edgePt, lineStart, lineEnd).toDouble()
        val signedMarginM = distanceM - input.legalThresholdM

        val errorComponents = errorBudget(input.boundaryProvenance)
        val totalError = errorComponents.total

        if (totalError > 2.0) return null

        return MeasurementOutput(
            measuredDistanceM = distanceM,
            signedMarginM = signedMarginM,
            totalEstimatedErrorM = totalError,
            errorComponents = errorComponents
        )
    }

    private fun perpendicularDistance(
        point: FloatArray,
        lineStart: FloatArray,
        lineEnd: FloatArray
    ): Float {
        val lineVecX = lineEnd[0] - lineStart[0]
        val lineVecZ = lineEnd[1] - lineStart[1]
        val lenSq = lineVecX * lineVecX + lineVecZ * lineVecZ

        if (lenSq <= 0f) {
            val dx = point[0] - lineStart[0]
            val dz = point[1] - lineStart[1]
            return sqrt(dx * dx + dz * dz)
        }

        val dot = (point[0] - lineStart[0]) * lineVecX + (point[1] - lineStart[1]) * lineVecZ
        val t = (dot / lenSq).coerceIn(0f, 1f)
        val projX = lineStart[0] + t * lineVecX
        val projZ = lineStart[1] + t * lineVecZ
        val dx = point[0] - projX
        val dz = point[1] - projZ
        return sqrt(dx * dx + dz * dz)
    }

    /** Error budget per ar_measurement_strategy.md section 5.1. */
    private fun errorBudget(provenance: BoundaryProvenance): MeasurementErrorComponents {
        val boundaryLocalizationError = when (provenance) {
            BoundaryProvenance.VISUAL_DETECTION -> 0.20
            BoundaryProvenance.MAP_PRIOR_ASSISTED -> 0.50
            BoundaryProvenance.MAP_PRIOR_ONLY -> 1.20
        }
        return MeasurementErrorComponents(
            arScaleErrorM = 0.18,
            planeFitErrorM = 0.10,
            vehicleEdgeLocalizationErrorM = 0.20,
            boundaryLocalizationErrorM = boundaryLocalizationError
        )
    }
}
