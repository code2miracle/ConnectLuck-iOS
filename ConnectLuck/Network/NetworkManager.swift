//
//  NetworkManager.swift
//  ConnectLuck
//
//  Created by 이종민 on 3/14/25.
//

import Foundation
import Network

/// HTTP 메서드 타입
enum HTTPMethod: String {
    case GET, POST, PATCH, DELETE
}

/// 공통 네트워크 매니저 (네트워크 감지 + 기본 API 요청 포함)
class NetworkManager {
    static let shared = NetworkManager()
    
    private let baseURL = EndPoint.baseURL
    private let monitor = NWPathMonitor()
    private var isConnected = true

    private init() {
        startNetworkMonitoring()
    }

    // MARK: - 네트워크 상태 감지
    private func startNetworkMonitoring() {
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                self.isConnected = path.status == .satisfied
                print("네트워크 상태: \(self.isConnected ? "연결됨" : "연결 끊김")")
            }
        }
        monitor.start(queue: DispatchQueue.global(qos: .background))
    }

    /// 현재 인터넷 연결 상태 확인
    func isInternetAvailable() -> Bool {
        return isConnected
    }

    // MARK: - GET요청
    func request<T: Decodable>(
        endpoint: String,
        method: HTTPMethod = .GET,
        headers: [String: String]? = nil,
        body: [String: Any]? = nil
    ) async throws -> T {
        // 네트워크 연결 확인
        guard isConnected else { throw URLError(.notConnectedToInternet) }
        guard let url = URL(string: baseURL + endpoint) else { throw URLError(.badURL) }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        headers?.forEach { key, value in request.setValue(value, forHTTPHeaderField: key) }

        if let body = body {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode(T.self, from: data)
    }
}
