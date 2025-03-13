//
//  Menu.swift
//  ConnectLuck
//
//  Created by 이종민 on 3/14/25.
//

import Foundation

struct MenuItem: Codable, Identifiable {
    let id: Int
    let name: String
    let description: String
    let imageUrl: String
    let price: Int
    let createdAt: String
    let updatedAt: String
}
