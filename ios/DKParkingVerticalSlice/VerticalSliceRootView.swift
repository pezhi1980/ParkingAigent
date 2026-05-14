// VerticalSliceRootView.swift
// Phase 9 Vertical Slice — pedestrian_crossing_5m
// Drives the SDK end-to-end: AR session → capture → evaluate → display result

import SwiftUI
import ARKit
import UIKit
import DKParkingSDK

// MARK: - View model

@MainActor
final class VerticalSliceViewModel: ObservableObject {

    @Published var sessionQualityLabel: String = "Initializing AR…"
    @Published var sessionIsValid: Bool = false
    @Published var result: ParkingEvaluationResult?
    @Published var isEvaluating: Bool = false
    // [UX] Front/rear measurement direction toggle
    @Published var isFrontMeasurement: Bool = true
    // [UX] Real-time distance estimate shown in overlay (nil = not yet measured)
    @Published var realtimeDistanceEstimateM: Double? = nil

    private let engine: ParkingEvaluationEngine
    private var lastQuality: ARSessionQuality = .invalid
    // [UX] Tracks previous session validity to trigger haptic only on transition
    private var wasSessionValid: Bool = false

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
        let nowValid = quality.isValid
        // [UX] Haptic: single pulse when session transitions from not-ready to ready
        if nowValid && !wasSessionValid {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
        wasSessionValid = nowValid
        sessionIsValid = nowValid
        if quality.isValid {
            sessionQualityLabel = String(format: "Ready — scale: %.2f  plane: %.2f",
                                         quality.metricScaleScore, quality.planeStabilityScore)
            // [FIX-1] Real-time distance estimate: distance from camera position to synthetic
            // boundary plane (z = -8.5 in AR world). In production this uses the real detected
            // vehicle footprint edge + localized legal boundary, not camera position.
            let camZ = Double(frame.camera.transform.columns.3.z)
            let syntheticBoundaryZ = -8.5
            realtimeDistanceEstimateM = max(0.0, camZ - syntheticBoundaryZ)
        } else {
            sessionQualityLabel = "Hold still — establishing measurement…"
            realtimeDistanceEstimateM = nil
        }
    }

    /// Performs an evaluation using synthetic geometry for the vertical slice demo.
    /// On a physical device this would use the real AR frame and detected feature geometry.
    /// Per ar_measurement_strategy.md and target_selection_policy.md.
    func evaluateWithSyntheticGeometry(frame: ARFrame) {
        guard !isEvaluating, sessionIsValid else { return }
        isEvaluating = true

        // [FIX-3] Use isFrontMeasurement to select the legally relevant vehicle edge.
        // Rule: intersection_10m (§ 28 stk. 1 pt. 2 — 10m from intersection transverse edge).
        // Synthetic geometry: intersection boundary at z = -8.5 in AR world.
        //   Front bumper at (0,0,0)   → 8.5m < 10m → expected PROBABLY_ILLEGAL
        //   Rear  bumper at (0,0,3.8) → 12.3m > 10m → expected LEGAL_WITH_BUFFER
        // This demonstrates why measuring from the correct end of the vehicle matters.
        let vehicleEdge: simd_float3 = isFrontMeasurement
            ? simd_float3(0, 0, 0)       // front bumper
            : simd_float3(0, 0, 3.8)     // rear bumper (assumes ~4m vehicle length)
        let boundaryStart = simd_float3(-3, 0, -8.5)
        let boundaryEnd   = simd_float3( 3, 0, -8.5)

        let input = EvaluationInput(
            arFrame: frame,
            sessionQuality: lastQuality,
            ruleFamily: .intersection10m,
            vehicleFootprintEdgePoint: vehicleEdge,
            legalBoundaryLineStart: boundaryStart,
            legalBoundaryLineEnd: boundaryEnd,
            boundaryProvenance: .mapPriorAssisted,
            footprintQualityScore: 0.82,
            partialOcclusionDetected: false,
            candidateFeatureId: "REG-DK-001-INT-00001",
            candidateFeatureType: "INTERSECTION",
            candidateConfidenceScore: 0.80,
            candidateSelectionBasis: "visual_confirmation_assisted",
            alternativeCandidatesRejected: 0,
            targetConfirmationSource: .autoSelectedUnambiguous,
            unsupportedVisibleRestrictionFlag: false
        )

        result = engine.evaluate(input: input)
        // [UX] Haptic: notify user when evaluation result is ready
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        isEvaluating = false
    }

    func reset() {
        result = nil
        sessionQualityLabel = sessionIsValid ? "Ready — tap Evaluate" : "Hold still — establishing measurement…"
    }

    // [UX] Toggle between measuring from front or rear of vehicle
    func toggleMeasurementDirection() {
        isFrontMeasurement.toggle()
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

            // [UX] Alignment guide overlay — hidden when result card is showing
            if vm.result == nil {
                alignmentOverlay
                    .ignoresSafeArea()
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
            // [FIX-3] Dynamic rule family label — reflects isFrontMeasurement selection
            Text(vm.isFrontMeasurement ? "intersection_10m · front" : "intersection_10m · rear")
                .font(.caption2)
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
    }

    // [UX] Alignment guide overlay: two framing zones + real-time distance label.
    // Top zone = legal boundary (street corner). Bottom zone = vehicle edge.
    // Zones turn green when AR session is ready. Hidden while result card is shown.
    private var alignmentOverlay: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                // Top zone: legal boundary / سر خیابان
                RoundedRectangle(cornerRadius: 8)
                    .stroke(vm.sessionIsValid ? Color.green : Color.white.opacity(0.5), lineWidth: 2)
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.06)))
                    .overlay(
                        Text("Street Corner / سر خیابان")
                            .font(.caption2)
                            .foregroundColor(.white)
                    )
                    .frame(height: geo.size.height * 0.22)
                    .padding(.horizontal, 40)

                Spacer()

                // Real-time distance estimate
                if let dist = vm.realtimeDistanceEstimateM {
                    Text(String(format: "≈ %.1f m", dist))
                        .font(.title2.bold())
                        .foregroundColor(.white)
                        .shadow(radius: 2)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.ultraThinMaterial)
                        .cornerRadius(8)
                }

                Spacer()

                // Bottom zone: vehicle front or rear / جلو یا عقب ماشین
                RoundedRectangle(cornerRadius: 8)
                    .stroke(vm.sessionIsValid ? Color.green : Color.white.opacity(0.5), lineWidth: 2)
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.06)))
                    .overlay(
                        Text(vm.isFrontMeasurement
                             ? "Front of Vehicle / جلوی ماشین"
                             : "Rear of Vehicle / عقب ماشین")
                            .font(.caption2)
                            .foregroundColor(.white)
                    )
                    .frame(height: geo.size.height * 0.22)
                    .padding(.horizontal, 40)
            }
            .padding(.top, 56)    // clear status banner
            .padding(.bottom, 72) // clear control bar
        }
        .allowsHitTesting(false)
    }

    private var controlBar: some View {
        HStack(spacing: 16) {
            Button("Reset") {
                vm.reset()
            }
            .buttonStyle(.bordered)
            .tint(.white)

            // [UX] Front/rear toggle — switches which vehicle edge is being measured
            Button(vm.isFrontMeasurement ? "⇄ Front" : "⇄ Rear") {
                vm.toggleMeasurementDirection()
            }
            .buttonStyle(.bordered)
            .tint(.yellow)

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

                // Per-family disclosure — dynamic per rule family
                // Source: user_disclosures_and_copy.md section 7
                Text(perFamilyDisclosure(for: result.measurement?.ruleFamily))
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

    // MARK: - Per-family disclosure per user_disclosures_and_copy.md section 7

    // [FIX-3] Dynamic disclosure text keyed to the evaluated rule family.
    private func perFamilyDisclosure(for ruleFamily: String?) -> String {
        switch ruleFamily {
        case "intersection_10m":
            return "This result evaluates only the 10-metre stopping/parking restriction near an intersection. Other restrictions at this location may also apply."
        case "pedestrian_crossing_5m":
            return "This result evaluates only the 5-metre stopping/parking restriction near a pedestrian crossing. Other restrictions at this location may also apply."
        case "cycle_path_exit_5m":
            return "This result evaluates only the 5-metre restriction near a cycle-path exit. Other restrictions at this location may also apply."
        case "bus_stop_12m_fallback", "bus_stop_marked_segment":
            return "This result evaluates only the bus-stop stopping/parking restriction. Other restrictions at this location may also apply."
        default:
            return "This result evaluates only the specific supported restriction checked. Other restrictions at this location may also apply."
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
  