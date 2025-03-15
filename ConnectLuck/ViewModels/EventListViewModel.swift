//
//  EventListViewModel.swift
//  ConnectLuck
//
//  Created by 이종민 on 3/15/25.
//

import Foundation
import Observation

@Observable
class EventViewModel {
    var events: [Event] = []
    var isLoading = false
    var errorMessage: String?
    var showError = false
    
    // 이벤트 목록 가져오기
    func fetchEvents(status: EventStatus? = nil) async {
        isLoading = true
        errorMessage = nil
        showError = false
        
        do {
            events = try await EventService.shared.fetchEvents(eventStatus: status)
            
            if events.isEmpty {
                print("API 응답: 검색 결과 없음")
            } else {
                print("API 응답: \(events.count)개의 이벤트 정보 로드됨")
            }
        } catch {
            errorMessage = "데이터를 불러오는 중 오류가 발생했습니다: \(error.localizedDescription)"
            showError = true
            print("API 오류: \(error.localizedDescription)")
            
            // 실패 시 디버그 모드에서는 더미 데이터 사용
            #if DEBUG
            if events.isEmpty {
                print("디버그 모드: 더미 데이터 로드")
                events = Event.dummyData()
            }
            #endif
        }
        
        isLoading = false
    }
}
