// VerticalSliceRootView.swift
// Phase 9 Vertical Slice — pedestrian_crossing_5m
// Drives the SDK end-to-end: AR session → capture → evaluate → display result

import SwiftUI
import ARKit
import DKParkingSDK

// MARK: - View model

@MainActor
final class VerticalSliceViewModel: ObservableObject {

    @Published var sessionQualityLabel: String = "Initializing AR…"
    @Published var sessionIsValid: Bool = false
    @Published var result: ParkingEvaluationResult?
    @Published var isEvaluating: Bool = false

    private let engine: ParkingEvaluationEngine
    private var lastQuality: ARSessionQuality = .invalid

    init() {
        let policy = PolicyRegistry.v1Default
        let versionRefs = VersionRefs(
            sdkVersion: "sdk-v1.0.0",
            policyVersion: "policy-v1.0.0",
            datasetVersion: "REG-DK-001-2026.06.01-001",
            datasetRegionId: "REG-DK-001",
            modelVersion: "model-v1.0.0",
            legalSourceBaselineDate: "2026-04-03"
        )
        engine = ParkingEvaluationEngine(policy: policy, versionRefs: versionRefs)
    }

    func initializeEngine() {
        let initResult = engine.initialize()
        switch initResult {
        case .ready:
            sessionQualityLabel = "AR session starting…"
        case .noActiveDatasetRegion:
            sessionQualityLabel = "No active dataset region."
        default:
            sessionQualityLabel = "SDK init failed."
        }
    }

    func startARSession() -> ARSession {
        return engine.startARSession()
    }

    func updateQuality(from frame: ARFrame) {
        let quality = engine.currentQuality(from: frame)
        lastQuality = quality
        sessionIsValid = quality.isValid
        if quality.isValid {
            sessionQualityLabel = String(format: "Ready — scale: %.2f  plane: %.2f",
                                         quality.metricScaleScore, quality.planeStabilityScore)
        } else {
            sessionQualityLabel = "Hold still — establishing measurement…"
        }
    }

    /// Performs an evaluation using synthetic geometry for the vertical slice demo.
    /// On a physical device this would use the real AR frame and detected feature geometry.
    /// Per ar_measurement_strategy.md and target_selection_policy.md.
    func evaluateWithSyntheticGeometry(frame: ARFrame) {
        guard !isEvaluating, sessionIsValid else { return }
        isEvaluating = true

        // Vertical slice: pedestrian_crossing_5m
        // Synthetic geometry: vehicle edge at 6.8m from boundary → expected LEGAL_WITH_BUFFER
        let vehicleEdge = simd_float3(0, 0, 0)
        let boundaryStart = simd_float3(-3, 0, -6.8)
        let boundaryEnd   = simd_float3( 3, 0, -6.8)

        let input = EvaluationInput(
            arFrame: frame,
            sessionQuality: lastQuality,
            ruleFamily: .pedestrianCrossing5m,
            vehicleFootprintEdgePoint: vehicleEdge,
            legalBoundaryLineStart: boundaryStart,
            legalBoundaryLineEnd: boundaryEnd,
            boundaryProvenance: .mapPriorAssisted,
            footprintQualityScore: 0.82,
            partialOcclusionDetected: false,
            candidateFeatureId: "REG-DK-001-PC-00001",
            candidateFeatureType: "PEDESTRIAN_CROSSING",
            candidateConfidenceScore: 0.80,
            candidateSelectionBasis: "visual_confirmation_assisted",
            alternativeCandidatesRejected: 0,
            targetConfirmationSource: .autoSelectedUnambiguous,
            unsupportedVisibleRestrictionFlag: false
        )

        result = engine.evaluate(input: input)
        isEvaluating = false
    }

    func reset() {
        result = nil
        sessionQualityLabel = sessionIsValid ? "Ready — tap Evaluate" : "Hold still — establishing measurement…"
    }
}

// MARK: - AR view representable

struct ARViewRepresentable: UIViewRepresentable {
    let session: ARSession

    func makeUIView(context: Context) -> ARSCNView {
        let view = ARSCNView()
        view.session = session
        view.autoenablesDefaultLighting = true
        return view
    }

    func updateUIView(_ uiView: ARSCNView, context: Context) {}
}

// MARK: - Root view

struct VerticalSliceRootView: View {
    @StateObject private var vm = VerticalSliceViewModel()
    @State private var arSession: ARSession?
    @State private var currentFrame: ARFrame?
    let frameTimer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack(alignment: .bottom) {
            if let session = arSession {
                ARViewRepresentable(session: session)
                    .ignoresSafeArea()
            } else {
                Color.black.ignoresSafeArea()
            }

            VStack(spacing: 0) {
                statusBanner
                if let result = vm.result {
                    resultCard(result: result)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                controlBar
            }
            .animation(.easeInOut(duration: 0.3), value: vm.result != nil)
        }
        .onAppear {
            vm.initializeEngine()
            arSession = vm.startARSession()
        }
        .onReceive(frameTimer) { _ in
            guard let session = arSession, let frame = session.currentFrame else { return }
            currentFrame = frame
            vm.updateQuality(from: frame)
        }
    }

    // MARK: - Sub-views

    private var statusBanner: some View {
        HStack {
            Circle()
                .fill(vm.sessionIsValid ? Color.green : Color.orange)
                .frame(width: 10, height: 10)
            Text(vm.sessionQualityLabel)
                .font(.caption)
                .foregroundColor(.white)
            Spacer()
            Text("pedestrian_crossing_5m")
                .font(.caption2)
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
    }

    private var controlBar: some View {
        HStack(spacing: 20) {
            Button("Reset") {
                vm.reset()
            }
            .buttonStyle(.bordered)
            .tint(.white)

            Button(vm.isEvaluating ? "Evaluating…" : "Evaluate") {
                guard let frame = currentFrame else { return }
                vm.evaluateWithSyntheticGeometry(frame: frame)
            }
            .buttonStyle(.borderedProminent)
            .tint(.blue)
            .disabled(!vm.sessionIsValid || vm.isEvaluating)
        }
        .padding()
        .background(.ultraThinMaterial)
    }

    @ViewBuilder
    private func resultCard(result: ParkingEvaluationResult) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {

                // Headline
                HStack {
                    stateLabel(for: result.decisionState)
                    Spacer()
                    Text(result.evaluationId.prefix(8))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }

                Divider()

                // Explanation body (per state)
                Text(explanationBody(for: result))
                    .font(.caption)
                    .foregroundColor(.primary)
                    .fixedSize(horizontal: false, vertical: true)

                // Refusal details (UNVERIFIABLE only)
                if result.decisionState == .unverifiable {
                    ForEach(result.refusalReasons, id: \.rawValue) { reason in
                        Text(refusalExplanation(for: reason))
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Text(retryGuidance(for: result.refusalReasons))
                        .font(.caption)
                        .italic()
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                // Measurement details (non-refusal states)
                if let m = result.measurement {
                    Divider()
                    Group {
                        Text(String(format: "Distance: %.2fm  (threshold: %.0fm)", m.measuredDistanceM, m.legalThresholdM))
                        Text(String(format: "Margin: %+.2fm  Error: \u00b1%.2fm", m.signedMarginM, m.totalEstimatedErrorM))
                        Text(String(format: "Confidence: %.2f  Near-threshold: %@",
                                    m.confidenceScore, m.inNearThresholdZone ? "yes" : "no"))
                        Text("Provenance: \(m.boundaryProvenance.rawValue)")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }

                Divider()

                // Per-family disclosure — pedestrian_crossing_5m
                // Source: user_disclosures_and_copy.md section 7
                Text("This result evaluates only the 5-metre stopping/parking restriction near a pedestrian crossing. Other restrictions at this location may also apply.")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                // Universal limitations notice (mandatory, short form)
                // Source: user_disclosures_and_copy.md section 6
                Text("This app evaluates only specific supported Danish stopping and parking rules. Other rules, signs, and restrictions may apply. This is not legal advice.")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding()
        }
        .frame(maxHeight: 320)
        .background(RoundedRectangle(cornerRadius: 12).fill(.regularMaterial))
        .padding(.horizontal)
    }

    // MARK: - Locked display labels per user_disclosures_and_copy.md section 2.1

    private func stateLabel(for state: DecisionState) -> some View {
        let (label, color): (String, Color) = {
            switch state {
            case .legalWithBuffer:   return ("Appears compliant", .green)
            case .probablyLegal:     return ("Likely compliant", .yellow)
            case .probablyIllegal:   return ("Likely violation", .orange)
            case .illegal:           return ("Violation detected", .red)
            case .unverifiable:      return ("Could not evaluate", .gray)
            }
        }()
        return Text(label)
            .font(.headline)
            .foregroundColor(color)
    }

    // MARK: - Explanation body per user_disclosures_and_copy.md section 3

    private func explanationBody(for result: ParkingEvaluationResult) -> String {
        let family = result.measurement?.ruleFamily ?? "pedestrian_crossing_5m"
        let margin = result.measurement.map { String(format: "%.2fm", $0.signedMarginM) } ?? "—"
        let threshold = result.measurement.map { String(format: "%.0fm", $0.legalThresholdM) } ?? "—"

        switch result.decisionState {
        case .legalWithBuffer:
            return "Based on the evaluated vehicle footprint and the measured distance, the vehicle appears to comply with the \(family) restriction. Measured margin: \(margin) beyond the \(threshold) threshold.\n\nThis result applies only to the \(family) rule. Other restrictions may still apply."
        case .probablyLegal:
            return "Evidence suggests the vehicle is likely outside the \(family) restricted zone, but measurement confidence was not high enough for a strong positive result.\n\nIf in doubt, consider moving the vehicle or retrying with better framing. This result applies only to the \(family) rule."
        case .probablyIllegal:
            return "Evidence suggests the vehicle may be violating the \(family) restriction. Confidence was not high enough for a definitive result, but you should consider moving the vehicle.\n\nThis result applies only to the \(family) rule."
        case .illegal:
            return "The evaluated vehicle footprint appears to violate the \(family) restriction. The vehicle should be moved.\n\nThis result is based on the evaluated evidence and applies only to the \(family) rule."
        case .unverifiable:
            return "The system could not safely evaluate this scene. This is normal behavior when evidence is insufficient — it is not an error."
        }
    }

    // MARK: - Human-readable refusal explanation per user_disclosures_and_copy.md section 4

    private func refusalExplanation(for code: RefusalReasonCode) -> String {
        switch code {
        case .arScaleUntrusted:
            return "The app could not establish reliable metric scale for this scene. Move to a flatter, better-lit surface and try again."
        case .planeUnstable:
            return "The ground plane could not be stabilized. Try holding the phone more steadily and ensuring the ground is clearly visible."
        case .targetAmbiguous:
            return "More than one vehicle was detected near the frame. Please frame only the vehicle you want to evaluate and confirm the target."
        case .targetEdgeOccluded:
            return "Part of the vehicle\u2019s edge relevant to this measurement is not visible. Try repositioning to see the full side of the vehicle."
        case .boundaryUnresolved:
            return "The relevant legal boundary could not be clearly identified in this scene. Try to include the crossing, cycle path, intersection edge, or bus-stop sign in the frame."
        case .featureCandidateAmbiguous:
            return "Multiple nearby features matched the scene. The system could not safely select which one to evaluate. Try repositioning to make the relevant feature clearer."
        case .visibleUnsupportedRestriction:
            return "A sign or marking visible in the scene is not supported by this app\u2019s evaluation scope. The system cannot confirm compliance with that restriction."
        case .noActiveDatasetRegion:
            return "No active map data is available for this location. You may need to download the region dataset."
        case .insufficientEvidenceGeneral:
            return "There was not enough evidence to evaluate safely. Try repositioning and retrying."
        }
    }

    // MARK: - Retry guidance per user_disclosures_and_copy.md section 5

    private func retryGuidance(for reasons: [RefusalReasonCode]) -> String {
        guard let first = reasons.first else {
            return "For a better result: try repositioning for a clearer view of the vehicle and the relevant boundary, then capture again."
        }
        switch first {
        case .arScaleUntrusted, .planeUnstable:
            return "For a better result: hold your phone at a slight downward angle so the ground is clearly visible. Move slowly and wait for the AR indicator to stabilize before capturing."
        case .targetEdgeOccluded:
            return "For a better result: move to a position where you can clearly see the full side of the vehicle closest to the relevant boundary."
        case .targetAmbiguous:
            return "For a better result: move closer to the specific vehicle you want to evaluate."
        case .boundaryUnresolved, .featureCandidateAmbiguous:
            return "For a better result: reposition so the relevant feature (crossing, cycle path, intersection, or bus-stop sign) is clearly visible in the frame alongside the vehicle."
        case .visibleUnsupportedRestriction:
            return "This app cannot evaluate the restriction visible in the scene. Check the app\u2019s supported scope for what it can and cannot evaluate."
        default:
            return "For a better result: try repositioning for a clearer view of the vehicle and the relevant boundary, then capture again."
        }
    }
}
