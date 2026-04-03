// ARMeasurementSession.swift
// DK Parking Engine SDK — Phase 9 Vertical Slice
// Implements AR measurement backbone per ar_measurement_strategy.md

import ARKit
import simd

// MARK: - Session validity result

public struct ARSessionQuality {
    public let isValid: Bool
    public let planeStabilityScore: Double
    public let metricScaleScore: Double
    public let metricScaleValid: Bool

    public static let invalid = ARSessionQuality(
        isValid: false,
        planeStabilityScore: 0.0,
        metricScaleScore: 0.0,
        metricScaleValid: false
    )

    public init(isValid: Bool, planeStabilityScore: Double, metricScaleScore: Double, metricScaleValid: Bool) {
        self.isValid = isValid
        self.planeStabilityScore = planeStabilityScore
        self.metricScaleScore = metricScaleScore
        self.metricScaleValid = metricScaleValid
    }
}

// MARK: - Measurement input

/// Inputs required for a single distance measurement.
/// Per ar_measurement_strategy.md section 4.
public struct MeasurementInput {
    /// The legally relevant vehicle footprint edge point on the ground plane (metres, AR world).
    public let vehicleFootprintEdgePoint: simd_float3
    /// The legal boundary reference line projected onto the ground plane.
    public let legalBoundaryLineStart: simd_float3
    public let legalBoundaryLineEnd: simd_float3
    /// The legal threshold for this rule family.
    public let legalThresholdM: Double
    /// The rule family being evaluated.
    public let ruleFamily: RuleFamily
    /// The provenance of the boundary.
    public let boundaryProvenance: BoundaryProvenance

    public init(
        vehicleFootprintEdgePoint: simd_float3,
        legalBoundaryLineStart: simd_float3,
        legalBoundaryLineEnd: simd_float3,
        legalThresholdM: Double,
        ruleFamily: RuleFamily,
        boundaryProvenance: BoundaryProvenance
    ) {
        self.vehicleFootprintEdgePoint = vehicleFootprintEdgePoint
        self.legalBoundaryLineStart = legalBoundaryLineStart
        self.legalBoundaryLineEnd = legalBoundaryLineEnd
        self.legalThresholdM = legalThresholdM
        self.ruleFamily = ruleFamily
        self.boundaryProvenance = boundaryProvenance
    }
}

// MARK: - Measurement output

public struct MeasurementOutput {
    public let measuredDistanceM: Double
    public let signedMarginM: Double
    public let totalEstimatedErrorM: Double
    public let errorComponents: MeasurementErrorComponents
}

public struct MeasurementErrorComponents {
    public let arScaleErrorM: Double
    public let planeFitErrorM: Double
    public let vehicleEdgeLocalizationErrorM: Double
    public let boundaryLocalizationErrorM: Double

    /// RSS combination per ar_measurement_strategy.md section 5.2
    public var total: Double {
        sqrt(
            arScaleErrorM * arScaleErrorM +
            planeFitErrorM * planeFitErrorM +
            vehicleEdgeLocalizationErrorM * vehicleEdgeLocalizationErrorM +
            boundaryLocalizationErrorM * boundaryLocalizationErrorM
        )
    }
}

// MARK: - AR Measurement Session

/// Wraps ARSession and provides scored quality metrics and metric distance measurement.
/// Per ar_measurement_strategy.md.
public final class ARMeasurementSession: NSObject {

    private let policy: PolicyRegistry
    private var session: ARSession?
    private var detectedPlanes: [ARPlaneAnchor] = []
    private var sessionStartTime: Date?
    private var lastWorldOriginResetTime: Date?

    public init(policy: PolicyRegistry) {
        self.policy = policy
    }

    // MARK: - Session management

    public func startSession() -> ARSession {
        let arSession = ARSession()
        arSession.delegate = self
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = .horizontal
        arSession.run(config, options: [.resetTracking, .removeExistingAnchors])
        self.session = arSession
        self.sessionStartTime = Date()
        return arSession
    }

    public func pauseSession() {
        session?.pause()
    }

    // MARK: - Quality scoring

    /// Evaluates current session quality.
    /// Per ar_measurement_strategy.md sections 3 and 8.
    public func currentQuality(from frame: ARFrame) -> ARSessionQuality {
        guard let startTime = sessionStartTime,
              Date().timeIntervalSince(startTime) >= 2.0 else {
            return .invalid
        }

        if let resetTime = lastWorldOriginResetTime,
           Date().timeIntervalSince(resetTime) < 1.0 {
            return .invalid
        }

        let metricScaleScore = metricScaleScore(from: frame)
        let planeStabilityScore = planeStabilityScore(from: frame)
        let metricScaleValid = metricScaleScore >= policy.minArMetricScaleScore

        let isValid = metricScaleValid
            && planeStabilityScore >= policy.minArPlaneStabilityScore

        return ARSessionQuality(
            isValid: isValid,
            planeStabilityScore: planeStabilityScore,
            metricScaleScore: metricScaleScore,
            metricScaleValid: metricScaleValid
        )
    }

    private func metricScaleScore(from frame: ARFrame) -> Double {
        switch frame.camera.trackingState {
        case .normal:
            return 1.0
        case .limited(let reason):
            switch reason {
            case .initializing, .relocalizing:
                return 0.2
            case .excessiveMotion:
                return 0.4
            case .insufficientFeatures:
                return 0.3
            @unknown default:
                return 0.2
            }
        case .notAvailable:
            return 0.0
        @unknown default:
            return 0.0
        }
    }

    private func planeStabilityScore(from frame: ARFrame) -> Double {
        guard !detectedPlanes.isEmpty else { return 0.0 }
        let baseScore = metricScaleScore(from: frame)
        return min(1.0, baseScore * 0.9 + 0.1 * Double(min(detectedPlanes.count, 3)) / 3.0)
    }

    // MARK: - Metric distance measurement

    /// Computes the perpendicular distance from a vehicle footprint edge point to a
    /// legal boundary line, both projected on the AR ground plane.
    /// Returns nil if the measurement cannot be computed.
    public func measure(input: MeasurementInput) -> MeasurementOutput? {
        let edgePt = SIMD2<Float>(input.vehicleFootprintEdgePoint.x, input.vehicleFootprintEdgePoint.z)
        let lineStart = SIMD2<Float>(input.legalBoundaryLineStart.x, input.legalBoundaryLineStart.z)
        let lineEnd = SIMD2<Float>(input.legalBoundaryLineEnd.x, input.legalBoundaryLineEnd.z)

        let distanceM = Double(perpendicularDistance(point: edgePt, lineStart: lineStart, lineEnd: lineEnd))
        let signedMarginM = distanceM - input.legalThresholdM

        let errorComponents = errorBudget(for: input.boundaryProvenance)
        let totalError = errorComponents.total

        guard totalError <= 2.0 else { return nil }

        return MeasurementOutput(
            measuredDistanceM: distanceM,
            signedMarginM: signedMarginM,
            totalEstimatedErrorM: totalError,
            errorComponents: errorComponents
        )
    }

    private func perpendicularDistance(point: SIMD2<Float>, lineStart: SIMD2<Float>, lineEnd: SIMD2<Float>) -> Float {
        let lineVec = lineEnd - lineStart
        let lenSq = simd_dot(lineVec, lineVec)
        guard lenSq > 0 else {
            return simd_length(point - lineStart)
        }
        let t = max(0, min(1, simd_dot(point - lineStart, lineVec) / lenSq))
        let projection = lineStart + t * lineVec
        return simd_length(point - projection)
    }

    /// Error budget per ar_measurement_strategy.md section 5.1.
    private func errorBudget(for provenance: BoundaryProvenance) -> MeasurementErrorComponents {
        let boundaryLocalizationError: Double
        switch provenance {
        case .visualDetection:
            boundaryLocalizationError = 0.20
        case .mapPriorAssisted:
            boundaryLocalizationError = 0.50
        case .mapPriorOnly:
            boundaryLocalizationError = 1.20
        }

        return MeasurementErrorComponents(
            arScaleErrorM: 0.18,
            planeFitErrorM: 0.10,
            vehicleEdgeLocalizationErrorM: 0.20,
            boundaryLocalizationErrorM: boundaryLocalizationError
        )
    }
}

// MARK: - ARSessionDelegate

extension ARMeasurementSession: ARSessionDelegate {
    public func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        let planes = anchors.compactMap { $0 as? ARPlaneAnchor }
        detectedPlanes.append(contentsOf: planes)
    }

    public func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
        let removedIds = Set(anchors.compactMap { $0 as? ARPlaneAnchor }.map { $0.identifier })
        detectedPlanes.removeAll { removedIds.contains($0.identifier) }
    }

    public func sessionWasInterrupted(_ session: ARSession) {
        lastWorldOriginResetTime = Date()
    }

    public func sessionInterruptionEnded(_ session: ARSession) {
        lastWorldOriginResetTime = Date()
    }
}
