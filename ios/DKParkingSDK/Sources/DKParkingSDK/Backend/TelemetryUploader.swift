// TelemetryUploader.swift
// DK Parking Engine SDK — iOS Version 1
// Async telemetry batch uploader — SS-10 per SYSTEM_ARCHITECTURE.md
// Per privacy_and_telemetry_spec.md: no images, no GPS, no user identifiers.
// Upload MUST NOT block or delay the legal evaluation path.

import Foundation

// MARK: - Telemetry event models

public struct TelemetryEvent: Codable {
    public let eventType: String
    public let evaluationId: String?
    public let sessionId: String?
    public let timestampUtc: String
    public let decisionState: String?
    public let refusalReasons: [String]?
    public let ruleFamily: String?
    public let confidenceScore: Double?
    public let measuredDistanceM: Double?
    public let signedMarginM: Double?
    public let totalEstimatedErrorM: Double?
    public let boundaryProvenance: String?
    public let arMetricScaleScore: Double?
    public let arPlaneStabilityScore: Double?
    public let inNearThresholdZone: Bool?
    public let sdkVersion: String?
    public let policyVersion: String?
    public let datasetVersion: String?
    public let datasetRegionId: String?
    public let modelVersion: String?
    public let platform: String
    public let osVersion: String?
    public let evaluationCount: Int?
    public let refusalCount: Int?

    enum CodingKeys: String, CodingKey {
        case eventType             = "event_type"
        case evaluationId          = "evaluation_id"
        case sessionId             = "session_id"
        case timestampUtc          = "timestamp_utc"
        case decisionState         = "decision_state"
        case refusalReasons        = "refusal_reasons"
        case ruleFamily            = "rule_family"
        case confidenceScore       = "confidence_score"
        case measuredDistanceM     = "measured_distance_m"
        case signedMarginM         = "signed_margin_m"
        case totalEstimatedErrorM  = "total_estimated_error_m"
        case boundaryProvenance    = "boundary_provenance"
        case arMetricScaleScore    = "ar_metric_scale_score"
        case arPlaneStabilityScore = "ar_plane_stability_score"
        case inNearThresholdZone   = "in_near_threshold_zone"
        case sdkVersion            = "sdk_version"
        case policyVersion         = "policy_version"
        case datasetVersion        = "dataset_version"
        case datasetRegionId       = "dataset_region_id"
        case modelVersion          = "model_version"
        case platform
        case osVersion             = "os_version"
        case evaluationCount       = "evaluation_count"
        case refusalCount          = "refusal_count"
    }
}

// MARK: - Uploader

public final class TelemetryUploader {

    private let backendBaseURL: URL
    private let apiKey: String
    private var queue: [TelemetryEvent] = []
    private let maxBatchSize = 20
    private let uploadQueue = DispatchQueue(label: "com.dkparking.telemetry", qos: .background)
    private var uploadTask: URLSessionDataTask?

    public init(backendBaseURL: URL, apiKey: String) {
        self.backendBaseURL = backendBaseURL
        self.apiKey = apiKey
    }

    // MARK: - Enqueue

    /// Enqueue an event. Non-blocking. Thread-safe.
    public func enqueue(_ event: TelemetryEvent) {
        uploadQueue.async { [weak self] in
            guard let self else { return }
            self.queue.append(event)
            if self.queue.count >= self.maxBatchSize {
                self.flushInternal()
            }
        }
    }

    /// Flush all queued events immediately. Call on session end.
    public func flush() {
        uploadQueue.async { [weak self] in
            self?.flushInternal()
        }
    }

    // MARK: - Flush (internal, runs on uploadQueue)

    private func flushInternal() {
        guard !queue.isEmpty else { return }
        let batch = Array(queue.prefix(maxBatchSize))
        queue.removeFirst(min(batch.count, queue.count))

        let payload = BatchPayload(platform: "ios", events: batch)
        guard let data = try? JSONEncoder().encode(payload) else { return }

        var request = URLRequest(url: backendBaseURL.appendingPathComponent("api/v1/telemetry/batch"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
        request.httpBody = data
        request.timeoutInterval = 15

        URLSession.shared.dataTask(with: request) { [weak self] _, response, error in
            if let error = error {
                // Telemetry failure must NOT propagate — log and discard
                print("[TelemetryUploader] upload failed (ignored): \(error.localizedDescription)")
                return
            }
            if let http = response as? HTTPURLResponse, http.statusCode != 200 {
                print("[TelemetryUploader] server rejected batch: \(http.statusCode)")
            }
        }.resume()
    }

    private struct BatchPayload: Codable {
        let platform: String
        let events: [TelemetryEvent]
    }
}

// MARK: - Convenience factory methods

extension TelemetryEvent {

    static func evaluationCompleted(
        result: ParkingEvaluationResult,
        osVersion: String
    ) -> TelemetryEvent {
        TelemetryEvent(
            eventType:             "evaluation_completed",
            evaluationId:          result.evaluationId,
            sessionId:             nil,
            timestampUtc:          ISO8601DateFormatter().string(from: Date()),
            decisionState:         result.decisionState.rawValue,
            refusalReasons:        result.refusalReasons.map { $0.rawValue },
            ruleFamily:            result.ruleFamily.rawValue,
            confidenceScore:       result.measurement?.confidenceScore,
            measuredDistanceM:     result.measurement?.measuredDistanceM,
            signedMarginM:         result.measurement?.signedMarginM,
            totalEstimatedErrorM:  result.measurement?.totalEstimatedErrorM,
            boundaryProvenance:    result.measurement?.boundaryProvenance.rawValue,
            arMetricScaleScore:    result.captureQuality.arMetricScaleScore,
            arPlaneStabilityScore: result.captureQuality.arPlaneStabilityScore,
            inNearThresholdZone:   result.measurement?.inNearThresholdZone,
            sdkVersion:            result.versionRefs.sdkVersion,
            policyVersion:         result.versionRefs.policyVersion,
            datasetVersion:        result.versionRefs.datasetVersion,
            datasetRegionId:       result.versionRefs.datasetRegionId,
            modelVersion:          result.versionRefs.modelVersion,
            platform:              "ios",
            osVersion:             osVersion,
            evaluationCount:       nil,
            refusalCount:          nil
        )
    }

    static func sessionStarted(sessionId: String, versionRefs: VersionRefs, osVersion: String) -> TelemetryEvent {
        TelemetryEvent(
            eventType: "session_started", evaluationId: nil, sessionId: sessionId,
            timestampUtc: ISO8601DateFormatter().string(from: Date()),
            decisionState: nil, refusalReasons: nil, ruleFamily: nil,
            confidenceScore: nil, measuredDistanceM: nil, signedMarginM: nil,
            totalEstimatedErrorM: nil, boundaryProvenance: nil,
            arMetricScaleScore: nil, arPlaneStabilityScore: nil, inNearThresholdZone: nil,
            sdkVersion: versionRefs.sdkVersion, policyVersion: versionRefs.policyVersion,
            datasetVersion: versionRefs.datasetVersion, datasetRegionId: versionRefs.datasetRegionId,
            modelVersion: versionRefs.modelVersion, platform: "ios", osVersion: osVersion,
            evaluationCount: nil, refusalCount: nil
        )
    }

    static func sessionEnded(sessionId: String, evaluationCount: Int, refusalCount: Int, versionRefs: VersionRefs) -> TelemetryEvent {
        TelemetryEvent(
            eventType: "session_ended", evaluationId: nil, sessionId: sessionId,
            timestampUtc: ISO8601DateFormatter().string(from: Date()),
            decisionState: nil, refusalReasons: nil, ruleFamily: nil,
            confidenceScore: nil, measuredDistanceM: nil, signedMarginM: nil,
            totalEstimatedErrorM: nil, boundaryProvenance: nil,
            arMetricScaleScore: nil, arPlaneStabilityScore: nil, inNearThresholdZone: nil,
            sdkVersion: versionRefs.sdkVersion, policyVersion: versionRefs.policyVersion,
            datasetVersion: versionRefs.datasetVersion, datasetRegionId: versionRefs.datasetRegionId,
            modelVersion: versionRefs.modelVersion, platform: "ios", osVersion: nil,
            evaluationCount: evaluationCount, refusalCount: refusalCount
        )
    }
}
