// BackendConfig.kt
// DK Parking Engine SDK — Android Version 1
// Single place to configure the Render backend URL and API key.
// Set this once at app startup before calling TelemetryUploader or DatasetClient.

package com.dkparking.sdk.backend

/**
 * Backend configuration for the DK Parking Engine.
 * Set [BackendConfig.shared] at app startup before any SDK calls.
 */
data class BackendConfig(
    /** Base URL of the DK Parking backend on Render. e.g. https://dk-parking-backend.onrender.com */
    val baseUrl: String,
    /** API key sent in every request as X-API-Key header. Must match MOBILE_API_KEY on Render. */
    val apiKey: String
) {
    companion object {
        /** Shared instance — set once at app startup. */
        var shared: BackendConfig = BackendConfig(
            baseUrl = "https://dk-parking-backend.onrender.com",
            apiKey  = ""   // Set via BackendConfig.shared = BackendConfig(...) at startup
        )
    }
}
