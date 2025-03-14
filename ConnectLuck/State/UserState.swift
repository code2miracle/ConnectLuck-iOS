//
//  UserState.swift
//  ConnectLuck
//
//  Created by 이종민 on 3/15/25.
//

import Foundation
import Observation
import SwiftUI

@Observable
class UserState {
    var currentUser: User?
    var isLoggedIn = false
    
    init() {
        // 저장된 토큰으로 로그인 상태 체크
        isLoggedIn = TokenManager.shared.isLoggedIn
        
        // 로그인 상태면 사용자 정보 로드
        if isLoggedIn {
            loadUserInfo()
        }
    }
    
    // 사용자 정보 로드
    private func loadUserInfo() {
        Task {
            do {
                let user = try await UserService.shared.getUserInfo()
                await MainActor.run {
                    self.currentUser = user
                }
            } catch {
                print("사용자 정보 로드 실패: \(error)")
                // 토큰이 유효하지 않은 경우 로그아웃 처리
                await MainActor.run {
                    self.logout()
                }
            }
        }
    }
    
    // 로그아웃
    func logout() {
        TokenManager.shared.clearToken()
        currentUser = nil
        isLoggedIn = false
    }
    
    // 권한 체크 메서드
    var isAdmin: Bool { currentUser?.isAdmin() ?? false }
    var isEventManager: Bool { currentUser?.isEventManager() ?? false }
    var isFoodTruckManager: Bool { currentUser?.isFoodTruckManager() ?? false }
    
    // 사용자 정보 새로 가져오기
    func fetchUserInfo() async {
        do {
            let user = try await UserService.shared.getUserInfo()
            await MainActor.run {
                self.currentUser = user
            }
        } catch {
            print("사용자 정보 업데이트 실패: \(error)")
            // 토큰이 유효하지 않은 경우 로그아웃 처리
            if let apiError = error as? APIError {
                if case .unauthorized = apiError {
                    await MainActor.run {
                        self.logout()
                    }
                }
            }
        }
    }
}
