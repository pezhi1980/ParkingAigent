// LegalThresholds.swift
// DK Parking Engine SDK — Phase 9 Vertical Slice
// Locked statutory thresholds per LEGAL_THRESHOLDS.md
// These values are NON-CONFIGURABLE. They are not in PolicyRegistry.

import Foundation

/// Locked statutory distance thresholds.
/// Source: LEGAL_THRESHOLDS.md. These values may NOT be changed without a MAJOR SDK version bump
/// and a corresponding legal-source review per legal_governance_strategy.md.
public enum LegalThresholds {

    /// § 28 stk. 1 pt. 3: 5m from a pedestrian crossing (nearside approach boundary).
    public static let pedestrianCrossing5m: Double = 5.0

    /// § 28 stk. 1 pt. 3: 5m from a cycle-path exit onto a road.
    public static let cyclePathExit5m: Double = 5.0

    /// § 28 stk. 1 pt. 2: 10m from the transverse edge of an intersecting road (vejkryds).
    public static let intersection10m: Double = 10.0

    /// § 28 stk. 1 pt. 4: 12m fallback from a bus-stop sign when marking extent is not resolved.
    public static let busStop12mFallback: Double = 12.0

    /// Returns the legal threshold for a given rule family identifier.
    public static func threshold(for ruleFamily: RuleFamily) -> Double {
        switch ruleFamily {
        case .pedestrianCrossing5m:
            return pedestrianCrossing5m
        case .cyclePathExit5m:
            return cyclePathExit5m
        case .intersection10m:
            return intersection10m
        case .busStop12mFallback, .busStopMarkedSegment:
            return busStop12mFallback
        case .directProhibitedSurfaces:
            return 0.0
        }
    }
}

/// The locked set of V1 rule families.
/// Source: SCOPE_AND_LIMITATIONS.md and launch_scope_register.md.
public enum RuleFamily: String, Codable, CaseIterable {
    case pedestrianCrossing5m = "pedestrian_crossing_5m"
    case cyclePathExit5m = "cycle_path_exit_5m"
    case intersection10m = "intersection_10m"
    case busStop12mFallback = "bus_stop_12m_fallback"
    case busStopMarkedSegment = "bus_stop_marked_segment"
    case directProhibitedSurfaces = "direct_prohibited_surfaces"

    /// Returns true if this family uses distance measurement (vs. overlap check).
    public var isDistanceBased: Bool {
        switch self {
        case .pedestrianCrossing5m, .cyclePathExit5m, .intersection10m,
             .busStop12mFallback, .busStopMarkedSegment:
            return true
        case .directProhibitedSurfaces:
            return false
        }
    }
}
