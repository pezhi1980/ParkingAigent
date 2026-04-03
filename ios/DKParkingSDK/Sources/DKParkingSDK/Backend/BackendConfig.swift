// BackendConfig.swift
// DK Parking Engine SDK — iOS Version 1
// Single place to configure the Render backend URL and API key.
// Set these before calling TelemetryUploader or DatasetClient.

import Foundation

public struct BackendConfig {
    /// Base URL of the DK Parking backend on Render.
    /// Example: https://dk-parking-backend.onrender.com
    public let baseURL: URL

    /// API key sent in every request as X-API-Key header.
    /// Must match MOBILE_API_KEY set on Render environment.
    public let apiKey: String

    public init(baseURL: URL, apiKey: String) {
        self.baseURL = baseURL
        self.apiKey = apiKey
    }

    /// Shared instance — set this once at app startup before any SDK calls.
    public static var shared: BackendConfig = BackendConfig(
        baseURL: URL(string: "https://dk-parking-agent.onrender.com")!,
        apiKey: ""   // Set via BackendConfig.shared = BackendConfig(baseURL:apiKey:) at startup
    )
}
