//
//  FoodTruck.swift
//  ConnectLuck
//
//  Created by 이종민 on 3/14/25.
//

import Foundation

struct FoodTruck: Codable, Identifiable {
    let id: Int
    let name: String
    let description: String
    let imageUrl: String
    let managerName: String
    let foodType: String
    let reviewCount: Int
    let avgRating: Double
    
    /// 푸드타입 enum으로 변환
    var foodTypeEnum: FoodType? {
        return FoodType(rawValue: foodType)
    }
}

// 기존 구조체는 FoodTruckDetail로 이름 변경하여 사용 가능
struct FoodTruckDetail: Codable, Identifiable {
    let id: Int
    let name: String
    let description: String
    let imageUrl: String
    let managerName: String
    let foodType: FoodType
    let reviews: [Review]
    let menus: [MenuItem]
    let avgRating: Double
}
