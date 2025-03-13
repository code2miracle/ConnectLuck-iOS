//
//  FoodTruckService.swift
//  ConnectLuck
//
//  Created by 이종민 on 3/14/25.
//  Updated to fix API response parsing

import Foundation

/// 푸드트럭 관련 API 서비스
class FoodTruckService {
    static let shared = FoodTruckService()
    
    /// 푸드트럭 검색 (쿼리 파라미터를 사용하여 검색)
    func fetchFoodTrucks(name: String? = nil, foodType: FoodType? = nil) async throws -> [FoodTruck] {
        var queryItems: [URLQueryItem] = []
        
        if let name = name {
            queryItems.append(URLQueryItem(name: "name", value: name))
        }
        if let foodType = foodType {
            queryItems.append(URLQueryItem(name: "foodType", value: foodType.rawValue))
        }

        var endpoint = EndPoint.FoodTruck.list
        if !queryItems.isEmpty {
            let queryString = queryItems.map { "\($0.name)=\($0.value!)" }.joined(separator: "&")
            endpoint += "?\(queryString)"
        }
        
        print("API 요청: \(EndPoint.baseURL)\(endpoint)")
        return try await NetworkManager.shared.request(endpoint: endpoint)
    }
    
    /// 푸드트럭 상세 정보 가져오기
    func fetchFoodTruckDetail(id: Int) async throws -> FoodTruckDetail {
        let endpoint = EndPoint.FoodTruck.detail(id)
        print("API 요청: \(EndPoint.baseURL)\(endpoint)")
        return try await NetworkManager.shared.request(endpoint: endpoint)
    }
}
