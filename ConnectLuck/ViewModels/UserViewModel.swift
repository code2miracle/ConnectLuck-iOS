//
//  UserViewModel.swift
//  ConnectLuck
//
//  Created by 이종민 on 3/14/25.
//

import Foundation
import Observation

@Observable
class UserViewModel {
    var currentUser: User?
    var isLoading = false
    var errorMessage: String?
    var showError = false
    var isLoggedIn = false
    
    
    init() {
        // 저장된 토큰이 있으면 로그인 상태로 판단
        isLoggedIn = TokenManager.shared.isLoggedIn
        
        // 앱 시작 시 사용자 정보 로드
        if isLoggedIn {
            Task {
                await fetchUserInfo()
            }
        }
    }
    
    // 로그인 처리
    func login(email: String, password: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        showError = false

        do {
            print("로그인 API 호출 시작")
            let token = try await AuthService.shared.login(email: email, password: password)
            print("로그인 API 응답 성공: 토큰 받음")

            TokenManager.shared.saveToken(token)
            print("토큰 저장 완료: \(String(token.prefix(20)))...")

            isLoggedIn = true

            print("사용자 정보 로드 시작")
            await fetchUserInfo()
            print("사용자 정보 로드 완료")

            isLoading = false
            return true
        } catch let apiError as APIError {
            errorMessage = apiError.errorDescription
            showError = true
            print("로그인 API 오류: \(apiError.localizedDescription)")
        } catch {
            errorMessage = "로그인에 실패했습니다: \(error.localizedDescription)"
            showError = true
            print("로그인 기타 오류: \(error)")
        }

        isLoading = false
        return false
    }
    
    func signup(email: String, password: String, name: String, phoneNumber: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        showError = false
        
        do {
            print("회원가입 API 호출 시작")
            let tokenResponse = try await AuthService.shared.signup(email: email, password: password, name: name, phoneNumber: phoneNumber)
            print("회원가입 API 응답 성공: 토큰 받음")
            
            TokenManager.shared.saveToken(tokenResponse.token)
            print("토큰 저장 완료: \(String(tokenResponse.token.prefix(20)))...")
            
            isLoggedIn = true
            
            // 사용자 정보 가져오기
            print("사용자 정보 로드 시작")
            await fetchUserInfo()
            if currentUser != nil {
                print("사용자 정보 로드 완료")
            } else {
                print("사용자 정보 로드 실패")
            }
            
            return true
        } catch let apiError as APIError {
            errorMessage = apiError.errorDescription
            showError = true
            print("회원가입 API 오류: \(apiError.localizedDescription)")
            isLoading = false
            return false
        } catch {
            errorMessage = "회원가입에 실패했습니다: \(error.localizedDescription)"
            showError = true
            print("회원가입 기타 오류: \(error)")
            isLoading = false
            return false
        }
    }
    
    // 사용자 정보 가져오기
    func fetchUserInfo() async {
        guard isLoggedIn else { return }
        
        isLoading = true
        do {
            currentUser = try await AuthService.shared.getUserInfo()
            isLoading = false
        } catch {
            errorMessage = "사용자 정보를 불러오는데 실패했습니다: \(error.localizedDescription)"
            showError = true
            print("사용자 정보 로드 오류: \(error.localizedDescription)")
            isLoading = false
        }
    }
    
    // 로그아웃
    func logout() {
        TokenManager.shared.clearToken()
        currentUser = nil
        isLoggedIn = false
    }
    
    // 이메일 중복 체크
    func checkEmailAvailability(email: String) async throws -> Bool {
        let encodedEmail = email.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? email
        let response: Data = try await NetworkManager.shared.request(
            endpoint: "\(EndPoint.Auth.emailCheck)?email=\(encodedEmail)",
            method: .POST,
            headers: [:]
        )

        // Boolean 값을 직접 변환하여 반환
        if let result = String(data: response, encoding: .utf8), result == "true" {
            return true
        } else {
            return false
        }
    }
    
    // 권한 추가 (푸드트럭 사업자 또는 행사 관계자)
    func addRole(role: UserRole) async -> Bool {
        isLoading = true
        
        do {
            currentUser = try await AuthService.shared.addRole(role: role)
            isLoading = false
            return true
        } catch {
            errorMessage = "권한 추가에 실패했습니다: \(error.localizedDescription)"
            showError = true
            isLoading = false
            return false
        }
    }
}
