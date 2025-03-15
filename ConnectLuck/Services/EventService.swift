//
//  EventService.swift
//  ConnectLuck
//
//  Created by 이종민 on 3/15/25.
//

import Foundation

class EventService {
    static let shared = EventService()
    
    /// 이벤트 목록 가져오기
    func fetchEvents(eventStatus: EventStatus? = nil) async throws -> [Event] {
        var queryItems: [URLQueryItem] = []
        
        if let eventStatus = eventStatus {
            queryItems.append(URLQueryItem(name: "eventStatus", value: eventStatus.rawValue))
        }
        
        var endpoint = EndPoint.Event.list
        if !queryItems.isEmpty {
            let queryString = queryItems.map { "\($0.name)=\($0.value!)" }.joined(separator: "&")
            endpoint += "?\(queryString)"
        }
        
        print("API 요청: \(EndPoint.baseURL)\(endpoint)")
        return try await NetworkManager.shared.request(endpoint: endpoint)
    }
    
    /// 이벤트 상세 정보 가져오기
    func fetchEventDetail(id: Int) async throws -> Event {
        let endpoint = EndPoint.Event.detail(id)
        print("API 요청: \(EndPoint.baseURL)\(endpoint)")
        return try await NetworkManager.shared.request(endpoint: endpoint)
    }
}
