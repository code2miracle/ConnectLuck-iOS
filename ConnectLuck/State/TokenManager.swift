//
//  TokenManager.swift
//  ConnectLuck
//
//  Created by 이종민 on 3/15/25.
//

import Foundation

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
