//
//  User.swift
//  ConnectLuck
//
//  Created by 이종민 on 3/13/25.
//

import Foundation

struct User: Codable, Identifiable, Equatable {
    let id: Int
    let email: String
    let name: String
    let phone: String
    let roles: [UserRole]
    let createdAt: String
    let updatedAt: String?
    var profileImage: String?
    var reviews: [Review]?
    
    enum CodingKeys: String, CodingKey {
        case id = "userId"
        case email, name, phone, roles, createdAt, updatedAt, profileImage, reviews
    }
    
    // Equatable 구현
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }
    
    // 사용자 역할 확인 메서드
    func isAdmin() -> Bool {
        return roles.contains(.admin)
    }
    
    func isEventManager() -> Bool {
        return roles.contains(.eventManager)
    }
    
    func isFoodTruckManager() -> Bool {
        return roles.contains(.foodTruckManager)
    }
}

enum UserRole: String, Codable {
    case user = "USER"
    case admin = "ADMIN"
    case eventManager = "EVENT_MANAGER"
    case foodTruckManager = "FOOD_TRUCK_MANAGER"
}


struct UserDetail: Codable {
    let id: Int
    let email: String
    let name: String
    let phone: String
    let profileImage: String?
    let roles: [String]
    let createdAt: String
}

// 로그인 요청
struct LoginRequest: Codable {
    let email: String
    let password: String
}

// 회원가입 요청
struct SignupRequest: Codable {
    let email: String
    let password: String
    let name: String
    let phoneNumber: String
}

// 토큰 응답
struct Token: Codable {
    let token: String
}

// 이메일 응답
struct EmailInfo: Codable {
    let email: String
}

// 아이디 중복 체크 응답
struct IdCheck: Codable {
    let isAvailable: Bool
}

// 사용자 정보 업데이트 요청
struct UserUpdateForm: Codable {
    let name: String?
    let phone: String?
}
