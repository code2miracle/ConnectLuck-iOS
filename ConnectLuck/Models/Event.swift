//
//  Event.swift
//  ConnectLuck
//
//  Created by 이종민 on 3/14/25.
//

import Foundation
import SwiftUI

struct Event: Identifiable, Codable {
    let id: Int
    let title: String
    let content: String
    let zipCode: String
    let streetAddress: String
    let detailAddress: String
    let startAt: String
    let endAt: String
    let imageUrl: String
    let managerName: String
    let status: EventStatus
    
    /// 기본 주소 계산 프로퍼티
    var address: String {
        "\(streetAddress) \(detailAddress)"
    }
    
    /// 날짜 범위 문자열 (필요 시 DateFormatter로 포맷 변경)
    var dateRange: String {
        "\(startAt) - \(endAt)"
    }
}

// 이벤트 상태 열거형
enum EventStatus: String, Codable {
    case beforeApplication = "BEFORE_APPLICATION"
    case openForApplication = "OPEN_FOR_APPLICATION"
    case applicationFinished = "APPLICATION_FINISHED"
    case eventStart = "EVENT_START"
    case eventEnd = "EVENT_END"
    
    /// UI에 표시할 문자열
    var displayText: String {
        switch self {
        case .beforeApplication:
            return "접수 전"
        case .openForApplication:
            return "접수 중"
        case .applicationFinished:
            return "접수 마감"
        case .eventStart:
            return "진행 중"
        case .eventEnd:
            return "종료"
        }
    }
    
    /// UI에서 사용될 색상 (예시)
    var color: Color {
        switch self {
        case .beforeApplication:
            return CLColor.SwiftUI.warning
        case .openForApplication:
            return CLColor.SwiftUI.success
        case .applicationFinished:
            return CLColor.SwiftUI.accentColor
        case .eventStart:
            return CLColor.SwiftUI.primaryColor
        case .eventEnd:
            return CLColor.SwiftUI.textSecondary
        }
    }
}
