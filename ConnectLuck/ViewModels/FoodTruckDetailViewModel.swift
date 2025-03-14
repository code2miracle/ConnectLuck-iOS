//
//  FoodTruckDetailViewModel.swift
//  ConnectLuck
//
//  Created by 이종민 on 3/14/25.
//

import Foundation
import Observation

@Observable
class FoodTruckDetailViewModel {
    var foodTruckDetail: FoodTruckDetail?
    var isLoading = false
    var errorMessage: String?
    var showError = false
    
    /// 푸드트럭 상세 정보 가져오기
    func fetchFoodTruckDetail(id: Int) async {
        isLoading = true
        errorMessage = nil
        showError = false
        
        do {
            // 네트워크 서비스를 통해 상세 정보 요청
            foodTruckDetail = try await FoodTruckService.shared.fetchFoodTruckDetail(id: id)
            print("API 응답: 푸드트럭 상세 정보 로드됨 (ID: \(id))")
        } catch {
            // 네트워크 오류 처리
            errorMessage = "상세 정보를 불러오는 중 오류가 발생했습니다: \(error.localizedDescription)"
            showError = true
            print("API 오류: \(error.localizedDescription)")
            
            // 실패 시 더미 데이터 로드 (디버그 모드에서만)
            #if DEBUG
            print("디버그 모드: 더미 상세 데이터 로드")
            foodTruckDetail = FoodTruckDetail.dummyDetail(id: id)
            #endif
        }
        
        isLoading = false
    }
}
