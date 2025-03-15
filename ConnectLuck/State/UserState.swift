//
//  UserState.swift
//  ConnectLuck
//
//  Created by 이종민 on 3/15/25.
//

import SwiftUI
import Observation

@MainActor
@Observable
class UserState {
    var currentUser: User?
    var isLoggedIn = false
    
    init() {
        // 앱 실행 시 저장된 토큰 확인
        isLoggedIn = TokenManager.shared.isLoggedIn
        if isLoggedIn {
            loadUserInfo()
        }
    }
    
    // 로그인
    func login(token: String, user: User) {
        TokenManager.shared.saveToken(token)
        self.currentUser = user
        self.isLoggedIn = true
    }
    
    // 로그아웃 (자동 로그아웃 포함)
    func logout() {
        TokenManager.shared.clearToken()
        self.currentUser = nil
        self.isLoggedIn = false
    }
    
    // 사용자 정보 불러오기
    func loadUserInfo() {
        Task {
            do {
                let user = try await UserService.shared.getUserInfo()
                self.currentUser = user
            } catch {
                print("사용자 정보 로드 실패: \(error)")
                // 인증 오류 발생 시 자동 로그아웃
                if let apiError = error as? APIError, case .unauthorized = apiError {
                    self.logout()
                }
            }
        }
    }
    
    // 사용자 역할 (권한) 확인
    var isAdmin: Bool { currentUser?.isAdmin() ?? false }
    var isEventManager: Bool { currentUser?.isEventManager() ?? false }
    var isFoodTruckManager: Bool { currentUser?.isFoodTruckManager() ?? false }
}
