// DatasetClient.kt
// DK Parking Engine SDK — Android Version 1
// Dataset delivery client — SS-04 per SYSTEM_ARCHITECTURE.md
// Downloads regional dataset bundles from backend (Render + Supabase Storage).
// After activation, the app works fully offline.

package com.dkparking.sdk.backend

import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.Json
import java.io.File
import java.io.FileOutputStream
import java.net.HttpURLConnection
import java.net.URL
import java.security.MessageDigest

// MARK: - Response models

@Serializable
data class DatasetRegionInfo(
    @SerialName("region_id")                    val regionId: String,
    @SerialName("display_name")                 val displayName: String,
    @SerialName("version")                      val version: String,
    @SerialName("valid_until")                  val validUntil: String,
    @SerialName("bundle_size_bytes")            val bundleSizeBytes: Long? = null,
    @SerialName("checksum_sha256")              val checksumSha256: String? = null,
    @SerialName("policy_version")               val policyVersion: String? = null,
    @SerialName("legal_source_baseline_date")   val legalSourceBaselineDate: String? = null,
    @SerialName("download_url")                 val downloadUrl: String? = null,
    @SerialName("download_url_expires_in_seconds") val downloadUrlExpiresInSeconds: Int? = null
)

@Serializable
data class DatasetVersionCheck(
    @SerialName("region_id")                  val regionId: String,
    @SerialName("server_version")             val serverVersion: String,
    @SerialName("is_active")                  val isActive: Boolean,
    @SerialName("valid_until")                val validUntil: String,
    @SerialName("client_version_is_current")  val clientVersionIsCurrent: Boolean? = null
)

// MARK: - Errors

sealed class DatasetClientError : Exception() {
    data class NetworkError(val cause: Exception) : DatasetClientError()
    data class ServerError(val statusCode: Int) : DatasetClientError()
    data class DecodingError(val cause: Exception) : DatasetClientError()
    object RegionNotFound : DatasetClientError()
    object DownloadFailed : DatasetClientError()
    object ChecksumMismatch : DatasetClientError()
}

// MARK: - Client

/**
 * Downloads and verifies dataset bundles from the DK Parking backend.
 * All download operations are suspend functions — run on Dispatchers.IO.
 */
class DatasetClient(
    private val backendBaseUrl: String,
    private val apiKey: String
) {
    private val json = Json { ignoreUnknownKeys = true }

    // MARK: - Version check

    /** Lightweight poll to check if the server has a newer bundle than installed. */
    suspend fun checkVersion(regionId: String, clientVersion: String? = null): DatasetVersionCheck =
        withContext(Dispatchers.IO) {
            val urlStr = buildString {
                append("$backendBaseUrl/api/v1/dataset/regions/$regionId/check")
                if (clientVersion != null) append("?client_version=$clientVersion")
            }
            get(urlStr, DatasetVersionCheck.serializer())
        }

    // MARK: - Fetch region metadata + signed URL

    suspend fun fetchRegionInfo(regionId: String): DatasetRegionInfo =
        withContext(Dispatchers.IO) {
            get("$backendBaseUrl/api/v1/dataset/regions/$regionId", DatasetRegionInfo.serializer())
        }

    // MARK: - Download bundle

    /**
     * Downloads the dataset bundle to [destinationFile].
     * Verifies SHA-256 checksum if provided in [info].
     * Caller is responsible for activating the bundle via SS-04.
     */
    suspend fun downloadBundle(info: DatasetRegionInfo, destinationFile: File) =
        withContext(Dispatchers.IO) {
            val downloadUrl = info.downloadUrl
                ?: throw DatasetClientError.DownloadFailed

            val tempFile = File(destinationFile.parent, "${destinationFile.name}.tmp")
            try {
                val url = URL(downloadUrl)
                val conn = url.openConnection() as HttpURLConnection
                conn.connectTimeout = 15_000
                conn.readTimeout = 120_000
                conn.connect()

                if (conn.responseCode != 200) {
                    conn.disconnect()
                    throw DatasetClientError.ServerError(conn.responseCode)
                }

                conn.inputStream.use { input ->
                    FileOutputStream(tempFile).use { output ->
                        input.copyTo(output)
                    }
                }
                conn.disconnect()

                // Verify checksum
                if (info.checksumSha256 != null) {
                    val actual = sha256Hex(tempFile.readBytes())
                    if (actual != info.checksumSha256) {
                        tempFile.delete()
                        throw DatasetClientError.ChecksumMismatch
                    }
                }

                // Move to destination
                destinationFile.delete()
                tempFile.renameTo(destinationFile)

            } catch (e: DatasetClientError) {
                tempFile.delete()
                throw e
            } catch (e: Exception) {
                tempFile.delete()
                throw DatasetClientError.NetworkError(e)
            }
        }

    // MARK: - Helpers

    private fun <T> get(urlStr: String, deserializer: kotlinx.serialization.DeserializationStrategy<T>): T {
        val url = URL(urlStr)
        val conn = url.openConnection() as HttpURLConnection
        conn.requestMethod = "GET"
        conn.setRequestProperty("Accept", "application/json")
        conn.setRequestProperty("X-API-Key", apiKey)
        conn.connectTimeout = 10_000
        conn.readTimeout = 15_000

        try {
            conn.connect()
            val code = conn.responseCode
            if (code == 404) throw DatasetClientError.RegionNotFound
            if (code != 200) throw DatasetClientError.ServerError(code)

            val body = conn.inputStream.bufferedReader().readText()
            conn.disconnect()
            return try {
                json.decodeFromString(deserializer, body)
            } catch (e: Exception) {
                throw DatasetClientError.DecodingError(e)
            }
        } catch (e: DatasetClientError) {
            throw e
        } catch (e: Exception) {
            throw DatasetClientError.NetworkError(e)
        }
    }

    private fun sha256Hex(data: ByteArray): String {
        val digest = MessageDigest.getInstance("SHA-256").digest(data)
        return digest.joinToString("") { "%02x".format(it) }
    }
}
