//
//  FoodTruckDetailViewModel.swift
//  ConnectLuck
//
//  Created by 이종민 on 3/14/25.
//

import Foundation

class FoodTruckDetailViewModel: ObservableObject {
    @Published var foodTruckDetail: FoodTruckDetail?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false
    
    func fetchFoodTruckDetail(id: Int) async {
        isLoading = true
        errorMessage = nil
        showError = false
        
        do {
            let detail = try await FoodTruckService.shared.fetchFoodTruckDetail(id: id)
            
            DispatchQueue.main.async {
                self.foodTruckDetail = detail
                self.isLoading = false
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "상세 정보를 불러오는데 실패했습니다: \(error.localizedDescription)"
                self.showError = true
                self.isLoading = false
            }
            
            print("상세 정보 로드 오류: \(error.localizedDescription)")
        }
    }
}
