//
//  FoodTruckViewModel.swift
//  ConnectLuck
//
//  Created by 이종민 on 3/14/25.
//  Updated to use FoodTruck model

import Foundation
import Observation

@Observable
class FoodTruckViewModel {
    var foodTrucks: [FoodTruck] = []
    var isLoading = false
    var errorMessage: String?
    var showError = false
    
    /// 푸드트럭 목록 가져오기 (이름과 음식 종류로 검색 가능)
    func fetchFoodTrucks(name: String? = nil, foodType: FoodType? = nil) async {
        isLoading = true
        errorMessage = nil
        showError = false
        
        do {
            // 네트워크 매니저를 통해 실제 API 요청
            foodTrucks = try await FoodTruckService.shared.fetchFoodTrucks(name: name, foodType: foodType)
            
            // 데이터가 비어있는 경우 빈 결과임을 알림
            if foodTrucks.isEmpty {
                print("API 응답: 검색 결과 없음")
            } else {
                print("API 응답: \(foodTrucks.count)개의 푸드트럭 정보 로드됨")
            }
        } catch {
            // 네트워크 오류 처리
            errorMessage = "데이터를 불러오는 중 오류가 발생했습니다: \(error.localizedDescription)"
            showError = true
            print("API 오류: \(error.localizedDescription)")
            
            // 실패 시 이전 데이터를 유지하거나, 오류가 발생했음을 알림
            #if DEBUG
            if foodTrucks.isEmpty {
                print("디버그 모드: 더미 데이터 로드")
                foodTrucks = FoodTruck.dummyData()
            }
            #endif
        }
        
        isLoading = false
    }
}
