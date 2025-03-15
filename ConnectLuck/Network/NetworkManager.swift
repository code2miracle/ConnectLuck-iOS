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
    
    // MARK: - API 요청
    func request<T: Decodable>(
        endpoint: String,
        method: HTTPMethod = .GET, //.GET 기본값
        headers: [String: String]? = nil,
        body: [String: Any]? = nil
    ) async throws -> T {
        // 네트워크 연결 확인
        guard isConnected else { throw URLError(.notConnectedToInternet) }
        guard let url = URL(string: baseURL + endpoint) else { throw URLError(.badURL) }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // 헤더 설정 (주의: Auth API는 헤더가 비어있어야 함)
        if let headers = headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        // 요청 바디 설정
        if let body = body {
            let jsonData = try JSONSerialization.data(withJSONObject: body)
            request.httpBody = jsonData
            
            // 디버깅용 - 요청 바디 출력
            if let bodyString = String(data: jsonData, encoding: .utf8) {
                print("Request Body: \(bodyString)")
            }
        }
        
        // 디버깅용 - 요청 정보 출력
        print("Request URL: \(url)")
        print("Request Method: \(method.rawValue)")
        print("Request Headers: \(request.allHTTPHeaderFields ?? [:])")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // 디버깅용 - 응답 출력
            if let responseString = String(data: data, encoding: .utf8) {
                print("Response: \(responseString)")
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw URLError(.badServerResponse)
            }
            
            print("HTTP 상태 코드: \(httpResponse.statusCode)")
            
            switch httpResponse.statusCode {
            case 200..<300:
                do {
                    return try JSONDecoder().decode(T.self, from: data)
                } catch {
                    print("JSON 디코딩 오류: \(error.localizedDescription)")
                    throw APIError.badRequest(message: "서버 응답을 처리할 수 없습니다.")
                }
            case 400:
                throw APIError.badRequest(message: "잘못된 요청입니다.")
            case 401:
                throw APIError.unauthorized
            case 404:
                throw APIError.notFound
            default:
                throw APIError.serverError(statusCode: httpResponse.statusCode)
            }
        } catch {
            print("네트워크 요청 오류: \(error.localizedDescription)")
            throw error
        }
    }
}

// API 오류 타입
enum APIError: Error, LocalizedError {
    case badRequest(message: String)
    case unauthorized
    case forbidden
    case notFound
    case serverError(statusCode: Int)
    
    var errorDescription: String? {
        switch self {
        case .badRequest(let message):
            return message
        case .unauthorized:
            return "인증에 실패했습니다"
        case .forbidden:
            return "접근 권한이 없습니다"
        case .notFound:
            return "요청한 리소스를 찾을 수 없습니다"
        case .serverError(let statusCode):
            return "서버 오류가 발생했습니다 (코드: \(statusCode))"
        }
    }
}

// 서버 에러 응답 구조
struct ErrorResponse: Codable {
    let status: String
    let errorType: String
    let message: String
}
