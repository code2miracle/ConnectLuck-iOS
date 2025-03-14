//
//  Event.swift
//  ConnectLuck
//
//  Created by 이종민 on 3/14/25.
//

import Foundation
import SwiftUI

struct Event: Identifiable, Codable {
    let id: Int64
    let title: String
    let content: String
    let zipCode: String
    let streetAddress: String
    let detailAddress: String
    let startAt: String
    let endAt: String
    let imageUrl: String
    let manager: [String: Any]?
    let status: EventStatus
    let createdAt: String
    let updatedAt: String
    
    // 기본 주소 계산 프로퍼티
    var address: String {
        return "\(streetAddress) \(detailAddress)"
    }
    
    // 이벤트 기간 계산 프로퍼티
    var dateRange: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        if let startDate = formatter.date(from: startAt),
           let endDate = formatter.date(from: endAt) {
            formatter.dateFormat = "yyyy.MM.dd"
            let startDateString = formatter.string(from: startDate)
            let endDateString = formatter.string(from: endDate)
            return "\(startDateString) - \(endDateString)"
        }
        return "\(startAt) - \(endAt)"
    }
    
    // JSON 인코딩/디코딩을 위한 CodingKeys
    enum CodingKeys: String, CodingKey {
        case id, title, content, zipCode, streetAddress, detailAddress
        case startAt, endAt, imageUrl, manager, status, createdAt, updatedAt
    }
    
    // Decodable 구현
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int64.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        content = try container.decode(String.self, forKey: .content)
        zipCode = try container.decode(String.self, forKey: .zipCode)
        streetAddress = try container.decode(String.self, forKey: .streetAddress)
        detailAddress = try container.decode(String.self, forKey: .detailAddress)
        startAt = try container.decode(String.self, forKey: .startAt)
        endAt = try container.decode(String.self, forKey: .endAt)
        imageUrl = try container.decode(String.self, forKey: .imageUrl)
        status = try container.decode(EventStatus.self, forKey: .status)
        createdAt = try container.decode(String.self, forKey: .createdAt)
        updatedAt = try container.decode(String.self, forKey: .updatedAt)
        
        // manager 필드는 Any 타입이므로 특별 처리
        if let managerDict = try? container.decode([String: String].self, forKey: .manager) {
            manager = managerDict as [String: Any]
        } else if let managerData = try? container.decode(Data.self, forKey: .manager) {
            manager = try JSONSerialization.jsonObject(with: managerData) as? [String: Any]
        } else {
            manager = nil
        }
    }
    
    // Encodable 구현
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(content, forKey: .content)
        try container.encode(zipCode, forKey: .zipCode)
        try container.encode(streetAddress, forKey: .streetAddress)
        try container.encode(detailAddress, forKey: .detailAddress)
        try container.encode(startAt, forKey: .startAt)
        try container.encode(endAt, forKey: .endAt)
        try container.encode(imageUrl, forKey: .imageUrl)
        try container.encode(status, forKey: .status)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
        
        // manager 필드를 JSON 데이터로 변환해서 인코딩
        if let manager = manager {
            let managerData = try JSONSerialization.data(withJSONObject: manager)
            try container.encode(managerData, forKey: .manager)
        } else {
            try container.encodeNil(forKey: .manager)
        }
    }
    
    init(id: Int64, title: String, content: String, zipCode: String, streetAddress: String,
         detailAddress: String, startAt: String, endAt: String, imageUrl: String,
         manager: [String: Any]?, status: EventStatus, createdAt: String, updatedAt: String) {
        self.id = id
        self.title = title
        self.content = content
        self.zipCode = zipCode
        self.streetAddress = streetAddress
        self.detailAddress = detailAddress
        self.startAt = startAt
        self.endAt = endAt
        self.imageUrl = imageUrl
        self.manager = manager
        self.status = status
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// 이벤트 상태 열거형
enum EventStatus: String, Codable {
    case recruiting = "RECRUITING"     // 모집중
    case comingSoon = "COMING_SOON"    // 곧 마감
    case closed = "CLOSED"             // 마감
    case finished = "FINISHED"         // 종료
    
    var displayText: String {
        switch self {
        case .recruiting: return "모집중"
        case .comingSoon: return "곧 마감"
        case .closed: return "마감"
        case .finished: return "종료"
        }
    }
    
    var color: Color {
        switch self {
        case .recruiting: return CLColor.SwiftUI.success
        case .comingSoon: return CLColor.SwiftUI.warning
        case .closed, .finished: return CLColor.SwiftUI.textSecondary
        }
    }
}

// 테스트/미리보기용 더미 데이터
extension Event {
    static func dummyData() -> [Event] {
        return [
            Event(
                id: 1,
                title: "서울숲 푸드트럭 페스티벌",
                content: "서울숲에서 진행되는 푸드트럭 페스티벌입니다. 다양한 맛을 즐겨보세요!",
                zipCode: "04770",
                streetAddress: "서울시 성동구 서울숲길 100",
                detailAddress: "서울숲 중앙광장",
                startAt: "2025-04-15T10:00:00.000Z",
                endAt: "2025-04-20T20:00:00.000Z",
                imageUrl: "https://picsum.photos/id/292/800/600",
                manager: ["name": "서울시청", "phone": "02-1234-5678"],
                status: .recruiting,
                createdAt: "2025-03-01T09:00:00.000Z",
                updatedAt: "2025-03-01T09:00:00.000Z"
            ),
            Event(
                id: 2,
                title: "부산 해운대 푸드 페스티벌",
                content: "부산 최대 규모의 푸드 페스티벌이 해운대에서 개최됩니다.",
                zipCode: "48100",
                streetAddress: "부산 해운대구 해운대해변로 264",
                detailAddress: "해운대 해변",
                startAt: "2025-05-01T11:00:00.000Z",
                endAt: "2025-05-03T21:00:00.000Z",
                imageUrl: "https://picsum.photos/id/431/800/600",
                manager: ["name": "부산시청", "phone": "051-987-6543"],
                status: .comingSoon,
                createdAt: "2025-03-15T14:30:00.000Z",
                updatedAt: "2025-03-15T14:30:00.000Z"
            ),
            Event(
                id: 3,
                title: "대학 축제",
                content: "봄을 맞이하는 대학 축제입니다. 다양한 공연과 푸드트럭이 준비되어 있습니다.",
                zipCode: "08826",
                streetAddress: "서울시 관악구 관악로 1",
                detailAddress: "서울대학교 대운동장",
                startAt: "2025-05-10T12:00:00.000Z",
                endAt: "2025-05-12T22:00:00.000Z",
                imageUrl: "https://picsum.photos/id/1080/800/600",
                manager: ["name": "서울대학교 총학생회", "phone": "02-880-5555"],
                status: .closed,
                createdAt: "2025-04-01T10:00:00.000Z",
                updatedAt: "2025-04-10T15:45:00.000Z"
            )
        ]
    }
}
