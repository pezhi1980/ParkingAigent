// DatasetClient.swift
// DK Parking Engine SDK — iOS Version 1
// Dataset delivery client — SS-04 per SYSTEM_ARCHITECTURE.md
// Downloads regional dataset bundles from backend (Render + Supabase Storage).
// After activation, the app works fully offline.

import Foundation

// MARK: - Response models

public struct DatasetRegionInfo: Codable {
    public let regionId: String
    public let displayName: String
    public let version: String
    public let validUntil: String
    public let bundleSizeBytes: Int?
    public let checksumSha256: String?
    public let policyVersion: String?
    public let legalSourceBaselineDate: String?
    public let downloadUrl: String?
    public let downloadUrlExpiresInSeconds: Int?

    enum CodingKeys: String, CodingKey {
        case regionId                  = "region_id"
        case displayName               = "display_name"
        case version
        case validUntil                = "valid_until"
        case bundleSizeBytes           = "bundle_size_bytes"
        case checksumSha256            = "checksum_sha256"
        case policyVersion             = "policy_version"
        case legalSourceBaselineDate   = "legal_source_baseline_date"
        case downloadUrl               = "download_url"
        case downloadUrlExpiresInSeconds = "download_url_expires_in_seconds"
    }
}

public struct DatasetVersionCheck: Codable {
    public let regionId: String
    public let serverVersion: String
    public let isActive: Bool
    public let validUntil: String
    public let clientVersionIsCurrent: Bool?

    enum CodingKeys: String, CodingKey {
        case regionId               = "region_id"
        case serverVersion          = "server_version"
        case isActive               = "is_active"
        case validUntil             = "valid_until"
        case clientVersionIsCurrent = "client_version_is_current"
    }
}

// MARK: - Client errors

public enum DatasetClientError: Error {
    case networkError(Error)
    case serverError(Int)
    case decodingError(Error)
    case regionNotFound
    case downloadFailed
    case checksumMismatch
}

// MARK: - DatasetClient

public final class DatasetClient {

    private let backendBaseURL: URL
    private let apiKey: String
    private let session: URLSession

    public init(backendBaseURL: URL, apiKey: String) {
        self.backendBaseURL = backendBaseURL
        self.apiKey = apiKey
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 300
        self.session = URLSession(configuration: config)
    }

    // MARK: - Version check (lightweight polling)

    /// Check if the server has a newer dataset version than the installed one.
    public func checkVersion(regionId: String, clientVersion: String?) async throws -> DatasetVersionCheck {
        var urlComponents = URLComponents(
            url: backendBaseURL.appendingPathComponent("api/v1/dataset/regions/\(regionId)/check"),
            resolvingAgainstBaseURL: false
        )!
        if let clientVersion {
            urlComponents.queryItems = [URLQueryItem(name: "client_version", value: clientVersion)]
        }
        let request = makeRequest(url: urlComponents.url!)
        return try await decode(DatasetVersionCheck.self, from: request)
    }

    // MARK: - Fetch region metadata + signed download URL

    public func fetchRegionInfo(regionId: String) async throws -> DatasetRegionInfo {
        let url = backendBaseURL.appendingPathComponent("api/v1/dataset/regions/\(regionId)")
        let request = makeRequest(url: url)
        return try await decode(DatasetRegionInfo.self, from: request)
    }

    // MARK: - Download bundle to local file

    /// Downloads the dataset bundle to a temporary file.
    /// Caller is responsible for verifying the SHA-256 checksum and moving to final location.
    public func downloadBundle(info: DatasetRegionInfo, to destinationURL: URL) async throws {
        guard let downloadUrlString = info.downloadUrl,
              let downloadUrl = URL(string: downloadUrlString) else {
            throw DatasetClientError.downloadFailed
        }

        let (tempURL, response) = try await session.download(from: downloadUrl)
        if let http = response as? HTTPURLResponse, http.statusCode != 200 {
            throw DatasetClientError.serverError(http.statusCode)
        }

        // Verify checksum if provided
        if let expectedChecksum = info.checksumSha256 {
            let data = try Data(contentsOf: tempURL)
            let actualChecksum = sha256Hex(data)
            guard actualChecksum == expectedChecksum else {
                try? FileManager.default.removeItem(at: tempURL)
                throw DatasetClientError.checksumMismatch
            }
        }

        // Move to destination
        try? FileManager.default.removeItem(at: destinationURL)
        try FileManager.default.moveItem(at: tempURL, to: destinationURL)
    }

    // MARK: - Helpers

    private func makeRequest(url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
        return request
    }

    private func decode<T: Decodable>(_ type: T.Type, from request: URLRequest) async throws -> T {
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw DatasetClientError.networkError(error)
        }
        if let http = response as? HTTPURLResponse {
            if http.statusCode == 404 { throw DatasetClientError.regionNotFound }
            if http.statusCode != 200 { throw DatasetClientError.serverError(http.statusCode) }
        }
        do {
            return try JSONDecoder().decode(type, from: data)
        } catch {
            throw DatasetClientError.decodingError(error)
        }
    }

    private func sha256Hex(_ data: Data) -> String {
        var digest = [UInt8](repeating: 0, count: 32)
        data.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &digest)
        }
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}
