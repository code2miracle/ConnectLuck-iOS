//
//  FoodTruckDetail.swift
//  ConnectLuck
//
//  Created by 이종민 on 3/15/25.
//

import Foundation

struct FoodTruckDetail: Codable {
    let id: Int
    let name: String
    let description: String
    let imageUrl: String
    let managerName: String
    let foodType: String
    let avgRating: Double?
    let reviews: [FoodTruckReview]
    let menus: [FoodTruckMenu]
}

struct FoodTruckReview: Codable, Identifiable {
    let id: Int
    let content: String
    let imageUrl: String?
    let rating: Int
    let authorName: String
    let reply: String?
    let createdAt: String
    let updatedAt: String
}

struct FoodTruckMenu: Codable, Identifiable {
    let id: Int
    let name: String
    let description: String
    let imageUrl: String
    let price: Int
    let createdAt: String
    let updatedAt: String
}
