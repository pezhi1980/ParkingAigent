// RuleFamily.kt
// DK Parking Engine SDK — Android Version 1 (Phase 9 Android)
// Locked statutory thresholds and rule families per LEGAL_THRESHOLDS.md
// Parity: iOS LegalThresholds.swift (PC-003, PC-004)

package com.dkparking.sdk.core

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

/**
 * The locked set of V1 rule families.
 * Source: SCOPE_AND_LIMITATIONS.md and launch_scope_register.md.
 */
@Serializable
enum class RuleFamily(val rawValue: String) {
    @SerialName("pedestrian_crossing_5m")
    PEDESTRIAN_CROSSING_5M("pedestrian_crossing_5m"),

    @SerialName("cycle_path_exit_5m")
    CYCLE_PATH_EXIT_5M("cycle_path_exit_5m"),

    @SerialName("intersection_10m")
    INTERSECTION_10M("intersection_10m"),

    @SerialName("bus_stop_12m_fallback")
    BUS_STOP_12M_FALLBACK("bus_stop_12m_fallback"),

    @SerialName("bus_stop_marked_segment")
    BUS_STOP_MARKED_SEGMENT("bus_stop_marked_segment"),

    @SerialName("direct_prohibited_surfaces")
    DIRECT_PROHIBITED_SURFACES("direct_prohibited_surfaces");

    /** Returns true if this family uses distance measurement (vs. overlap check). */
    val isDistanceBased: Boolean
        get() = when (this) {
            PEDESTRIAN_CROSSING_5M, CYCLE_PATH_EXIT_5M, INTERSECTION_10M,
            BUS_STOP_12M_FALLBACK, BUS_STOP_MARKED_SEGMENT -> true
            DIRECT_PROHIBITED_SURFACES -> false
        }
}

/**
 * Locked statutory distance thresholds.
 * Source: LEGAL_THRESHOLDS.md. These values may NOT be changed without a MAJOR SDK version bump
 * and a corresponding legal-source review per legal_governance_strategy.md.
 */
object LegalThresholds {

    /** § 28 stk. 1 pt. 3: 5m from a pedestrian crossing (nearside approach boundary). */
    const val PEDESTRIAN_CROSSING_5M: Double = 5.0

    /** § 28 stk. 1 pt. 3: 5m from a cycle-path exit onto a road. */
    const val CYCLE_PATH_EXIT_5M: Double = 5.0

    /** § 28 stk. 1 pt. 2: 10m from the transverse edge of an intersecting road (vejkryds). */
    const val INTERSECTION_10M: Double = 10.0

    /** § 28 stk. 1 pt. 4: 12m fallback from a bus-stop sign when marking extent is not resolved. */
    const val BUS_STOP_12M_FALLBACK: Double = 12.0

    /** Returns the legal threshold for a given rule family. */
    fun threshold(ruleFamily: RuleFamily): Double = when (ruleFamily) {
        RuleFamily.PEDESTRIAN_CROSSING_5M -> PEDESTRIAN_CROSSING_5M
        RuleFamily.CYCLE_PATH_EXIT_5M -> CYCLE_PATH_EXIT_5M
        RuleFamily.INTERSECTION_10M -> INTERSECTION_10M
        RuleFamily.BUS_STOP_12M_FALLBACK, RuleFamily.BUS_STOP_MARKED_SEGMENT -> BUS_STOP_12M_FALLBACK
        RuleFamily.DIRECT_PROHIBITED_SURFACES -> 0.0
    }
}
