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

    // [FIX-2] Track primary plane center history for variance-based stability scoring.
    // Per ar_measurement_strategy.md §3.2: "Consistency of the plane transform across
    // recent frames (low variance = high stability)".
    private var planeCenterHistory: [simd_float3] = []
    private let maxPlaneCenterHistoryCount = 10

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

    // [FIX-2] Revised plane stability scoring per ar_measurement_strategy.md §3.2.
    // Combines: tracking quality (metricScaleScore) + plane transform variance over
    // recent frames. Low variance across history → high stability score.
    private func planeStabilityScore(from frame: ARFrame) -> Double {
        guard !detectedPlanes.isEmpty else { return 0.0 }

        // Record the center of the largest detected plane (primary plane).
        if let primary = detectedPlanes.max(by: {
            $0.planeExtent.width * $0.planeExtent.height < $1.planeExtent.width * $1.planeExtent.height
        }) {
            let col = primary.transform.columns.3
            let center = simd_float3(col.x, col.y, col.z)
            planeCenterHistory.append(center)
            if planeCenterHistory.count > maxPlaneCenterHistoryCount {
                planeCenterHistory.removeFirst()
            }
        }

        let baseScore = metricScaleScore(from: frame)

        // Compute positional variance (XZ plane only — Y/height noise is expected).
        let varianceScore: Double
        if planeCenterHistory.count >= 3 {
            let xs = planeCenterHistory.map { Double($0.x) }
            let zs = planeCenterHistory.map { Double($0.z) }
            let varX = sampleVariance(xs)
            let varZ = sampleVariance(zs)
            let totalVariance = varX + varZ
            // Map to score: 0m variance → 1.0; ≥0.05m variance → 0.0 (5cm threshold).
            varianceScore = max(0.0, 1.0 - totalVariance / 0.05)
        } else {
            // Not enough history yet — give a conservative partial score.
            varianceScore = 0.4
        }

        // Weighted combination: 60% tracking quality, 40% plane stability.
        return min(1.0, baseScore * 0.6 + varianceScore * 0.4)
    }

    /// Sample variance of a sequence of Double values.
    private func sampleVariance(_ values: [Double]) -> Double {
        guard values.count > 1 else { return 0.0 }
        let mean = values.reduce(0, +) / Double(values.count)
        let squaredDiffs = values.map { ($0 - mean) * ($0 - mean) }
        return squaredDiffs.reduce(0, +) / Double(values.count - 1)
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
        let totalError = e