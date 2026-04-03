// TelemetryUploader.kt
// DK Parking Engine SDK — Android Version 1
// Async telemetry batch uploader — SS-10 per SYSTEM_ARCHITECTURE.md
// Per privacy_and_telemetry_spec.md: no images, no GPS, no user identifiers.
// Upload MUST NOT block or delay the legal evaluation path.

package com.dkparking.sdk.backend

import com.dkparking.sdk.core.ParkingEvaluationResult
import com.dkparking.sdk.core.VersionRefs
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import java.net.HttpURLConnection
import java.net.URL
import java.time.Instant
import java.util.concurrent.CopyOnWriteArrayList

// MARK: - Telemetry event model

@Serializable
data class TelemetryEvent(
    @SerialName("event_type")              val eventType: String,
    @SerialName("evaluation_id")           val evaluationId: String? = null,
    @SerialName("session_id")              val sessionId: String? = null,
    @SerialName("timestamp_utc")           val timestampUtc: String,
    @SerialName("decision_state")          val decisionState: String? = null,
    @SerialName("refusal_reasons")         val refusalReasons: List<String>? = null,
    @SerialName("rule_family")             val ruleFamily: String? = null,
    @SerialName("confidence_score")        val confidenceScore: Double? = null,
    @SerialName("measured_distance_m")     val measuredDistanceM: Double? = null,
    @SerialName("signed_margin_m")         val signedMarginM: Double? = null,
    @SerialName("total_estimated_error_m") val totalEstimatedErrorM: Double? = null,
    @SerialName("boundary_provenance")     val boundaryProvenance: String? = null,
    @SerialName("ar_metric_scale_score")   val arMetricScaleScore: Double? = null,
    @SerialName("ar_plane_stability_score") val arPlaneStabilityScore: Double? = null,
    @SerialName("in_near_threshold_zone")  val inNearThresholdZone: Boolean? = null,
    @SerialName("sdk_version")             val sdkVersion: String? = null,
    @SerialName("policy_version")          val policyVersion: String? = null,
    @SerialName("dataset_version")         val datasetVersion: String? = null,
    @SerialName("dataset_region_id")       val datasetRegionId: String? = null,
    @SerialName("model_version")           val modelVersion: String? = null,
    @SerialName("platform")               val platform: String = "android",
    @SerialName("os_version")             val osVersion: String? = null,
    @SerialName("evaluation_count")       val evaluationCount: Int? = null,
    @SerialName("refusal_count")          val refusalCount: Int? = null
)

@Serializable
private data class BatchPayload(
    val platform: String,
    val events: List<TelemetryEvent>
)

// MARK: - Uploader

/**
 * Thread-safe async telemetry uploader.
 * Enqueue events with enqueue(). Call flush() on session end.
 * Upload failures are silently ignored — must not affect the legal evaluation path.
 */
class TelemetryUploader(
    private val backendBaseUrl: String,
    private val apiKey: String
) {
    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.IO)
    private val queue = CopyOnWriteArrayList<TelemetryEvent>()
    private val maxBatchSize = 20
    private val json = Json { ignoreUnknownKeys = true }

    /** Enqueue an event. Non-blocking. */
    fun enqueue(event: TelemetryEvent) {
        queue.add(event)
        if (queue.size >= maxBatchSize) {
            flush()
        }
    }

    /** Flush all queued events. Call on session end. */
    fun flush() {
        if (queue.isEmpty()) return
        val batch = ArrayList(queue.take(maxBatchSize))
        queue.removeAll(batch.toSet())
        scope.launch { uploadBatch(batch) }
    }

    private fun uploadBatch(events: List<TelemetryEvent>) {
        try {
            val payload = BatchPayload(platform = "android", events = events)
            val body = json.encodeToString(payload).toByteArray(Charsets.UTF_8)
            val url = URL("$backendBaseUrl/api/v1/telemetry/batch")
            val conn = url.openConnection() as HttpURLConnection
            conn.requestMethod = "POST"
            conn.setRequestProperty("Content-Type", "application/json")
            conn.setRequestProperty("X-API-Key", apiKey)
            conn.doOutput = true
            conn.connectTimeout = 10_000
            conn.readTimeout = 15_000
            conn.outputStream.use { it.write(body) }
            val code = conn.responseCode
            if (code != 200) {
                println("[TelemetryUploader] server rejected batch: $code")
            }
            conn.disconnect()
        } catch (e: Exception) {
            // Telemetry failure must NOT propagate
            println("[TelemetryUploader] upload failed (ignored): ${e.message}")
        }
    }

    private fun <E> List<E>.take(n: Int): List<E> = subList(0, minOf(n, size))
}

// MARK: - Convenience factory extensions

fun TelemetryEvent.Companion.evaluationCompleted(
    result: ParkingEvaluationResult,
    osVersion: String
) = TelemetryEvent(
    eventType             = "evaluation_completed",
    evaluationId          = result.evaluationId,
    timestampUtc          = Instant.now().toString(),
    decisionState         = result.decisionState.rawValue,
    refusalReasons        = result.refusalReasons.map { it.rawValue },
    ruleFamily            = result.ruleFamily.rawValue,
    confidenceScore       = result.measurement?.confidenceScore,
    measuredDistanceM     = result.measurement?.measuredDistanceM,
    signedMarginM         = result.measurement?.signedMarginM,
    totalEstimatedErrorM  = result.measurement?.totalEstimatedErrorM,
    boundaryProvenance    = result.measurement?.boundaryProvenance?.rawValue,
    arMetricScaleScore    = result.captureQuality.arMetricScaleScore,
    arPlaneStabilityScore = result.captureQuality.arPlaneStabilityScore,
    inNearThresholdZone   = result.measurement?.inNearThresholdZone,
    sdkVersion            = result.versionRefs.sdkVersion,
    policyVersion         = result.versionRefs.policyVersion,
    datasetVersion        = result.versionRefs.datasetVersion,
    datasetRegionId       = result.versionRefs.datasetRegionId,
    modelVersion          = result.versionRefs.modelVersion,
    platform              = "android",
    osVersion             = osVersion
)

fun TelemetryEvent.Companion.sessionStarted(
    sessionId: String,
    versionRefs: VersionRefs,
    osVersion: String
) = TelemetryEvent(
    eventType       = "session_started",
    sessionId       = sessionId,
    timestampUtc    = Instant.now().toString(),
    sdkVersion      = versionRefs.sdkVersion,
    policyVersion   = versionRefs.policyVersion,
    datasetVersion  = versionRefs.datasetVersion,
    datasetRegionId = versionRefs.datasetRegionId,
    modelVersion    = versionRefs.modelVersion,
    platform        = "android",
    osVersion       = osVersion
)

fun TelemetryEvent.Companion.sessionEnded(
    sessionId: String,
    evaluationCount: Int,
    refusalCount: Int,
    versionRefs: VersionRefs
) = TelemetryEvent(
    eventType       = "session_ended",
    sessionId       = sessionId,
    timestampUtc    = Instant.now().toString(),
    sdkVersion      = versionRefs.sdkVersion,
    policyVersion   = versionRefs.policyVersion,
    datasetVersion  = versionRefs.datasetVersion,
    datasetRegionId = versionRefs.datasetRegionId,
    modelVersion    = versionRefs.modelVersion,
    platform        = "android",
    evaluationCount = evaluationCount,
    refusalCount    = refusalCount
)
