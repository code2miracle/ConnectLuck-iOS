//
//  AuthService.swift
//  ConnectLuck
//
//  Created by 이종민 on 3/14/25.
//

import Foundation

class UserService {
    static let shared = UserService()
    
    /// 로그인 API 호출
    func login(email: String, password: String) async throws -> String {
        let requestBody: [String: Any] = [
            "email": email,
            "password": password
        ]

        let response: Token = try await NetworkManager.shared.request(
            endpoint: EndPoint.Auth.login,
            method: .POST,
            headers: [:],
            body: requestBody
        )

        return response.token
    }
    
    /// 회원가입 API 호출
    func signup(email: String, password: String, name: String, phoneNumber: String) async throws -> Token {
        let signupRequest = [
            "email": email,
            "password": password,
            "name": name,
            "phoneNumber": phoneNumber
        ]
        
        return try await NetworkManager.shared.request(
            endpoint: EndPoint.Auth.signup,
            method: .POST,
            // Auth API 호출 시 header를 비워둬야 함
            headers: [:],
            body: signupRequest
        )
    }
    
    /// 사용자 정보 가져오기
    func getUserInfo() async throws -> User {
        return try await NetworkManager.shared.request(
            endpoint: EndPoint.User.getUser,
            headers: getAuthHeader()
        )
    }
    
    /// 이메일 중복 확인
    func checkEmailAvailability(email: String) async throws -> Bool {
        let encodedEmail = email.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? email
        return try await NetworkManager.shared.request(
            endpoint: "\(EndPoint.Auth.emailCheck)?email=\(encodedEmail)",
            method: .POST,
            headers: [:]
        )
    }
    
    /// 권한 추가 (푸드트럭 사업자 또는 행사 관계자)
    func addRole(role: UserRole) async throws -> User {
        return try await NetworkManager.shared.request(
            endpoint: EndPoint.User.addRole,
            method: .POST,
            headers: getAuthHeader(),
            body: ["role": role.rawValue]
        )
    }
    
    // 인증 헤더 생성
    private func getAuthHeader() -> [String: String] {
        if let token = TokenManager.shared.getToken() {
            return ["Authorization": "Bearer \(token)"]
        }
        return [:]
    }
    
    // 서버 연결 테스트
    func testServerConnection() async -> Bool {
        do {
            let url = URL(string: EndPoint.baseURL)!
            let (_, response) = try await URLSession.shared.data(from: url)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("서버 연결 테스트: 상태 코드 \(httpResponse.statusCode)")
                return (200..<300).contains(httpResponse.statusCode)
            }
            return false
        } catch {
            print("서버 연결 테스트 실패: \(error.localizedDescription)")
            return false
        }
    }
}

// 토큰 관리 클래스
class TokenManager {
    static let shared = TokenManager()
    
    private let tokenKey = "auth_token"
    
    func saveToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: tokenKey)
    }
    
    func getToken() -> String? {
        return UserDefaults.standard.string(forKey: tokenKey)
    }
    
    func clearToken() {
        UserDefaults.standard.removeObject(forKey: tokenKey)
    }
    
    var isLoggedIn: Bool {
        return getToken() != nil
    }
}

// Data -> Dictionary 변환 확장
extension Data {
    func asDictionary() -> [String: Any]? {
        do {
            return try JSONSerialization.jsonObject(with: self, options: []) as? [String: Any]
        } catch {
            return nil
        }
    }
}
