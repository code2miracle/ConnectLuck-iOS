//
//  Review.swift
//  ConnectLuck
//
//  Created by 이종민 on 3/14/25.
//

import SwiftUI

// MARK: - 리뷰 모델
struct Review: Codable, Identifiable {
    let id: Int
    let content: String
    let imageUrl: String
    let rating: Int
    let authorName: String
    let reply: String
    let createdAt: String
    let updatedAt: String
}
