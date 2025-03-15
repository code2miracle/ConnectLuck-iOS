//
//  StatusBadge.swift
//  ConnectLuck
//
//  Created on 3/15/25.
//

import SwiftUI

/// 공용 상태 배지 컴포넌트
struct StatusBadge: View {
    // 이벤트 상태 또는 푸드트럭 상태를 표시할 수 있도록 구현
    enum BadgeType {
        // 이벤트 상태
        case event(EventStatus)
        // 푸드트럭 상태
        case foodTruck(FoodTruckStatus)
        // 단순 텍스트 상태
        case custom(text: String, color: Color)
    }
    
    let type: BadgeType
    
    init(status: EventStatus) {
        self.type = .event(status)
    }
    
    init(status: FoodTruckStatus) {
        self.type = .foodTruck(status)
    }
    
    init(text: String, color: Color) {
        self.type = .custom(text: text, color: color)
    }
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(badgeColor)
                .frame(width: 8, height: 8)
            Text(badgeText)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(badgeColor)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(badgeColor.opacity(0.3))
        .cornerRadius(4)
    }
    
    // 배지 텍스트
    private var badgeText: String {
        switch type {
        case .event(let status):
            return status.displayText
        case .foodTruck(let status):
            return status.displayText
        case .custom(let text, _):
            return text
        }
    }
    
    // 배지 색상
    private var badgeColor: Color {
        switch type {
        case .event(let status):
            switch status {
            case .beforeApplication:
                return CLColor.SwiftUI.info
            case .openForApplication:
                return CLColor.SwiftUI.success
            case .applicationFinished:
                return CLColor.SwiftUI.warning
            case .eventStart:
                return CLColor.SwiftUI.primaryColor
            case .eventEnd:
                return CLColor.SwiftUI.textSecondary
            }
        case .foodTruck(let status):
            switch status {
            case .open:
                return CLColor.SwiftUI.success
            case .closed:
                return CLColor.SwiftUI.textSecondary
            case .recruiting:
                return CLColor.SwiftUI.primaryColor
            }
        case .custom(_, let color):
            return color
        }
    }
}

// 푸드트럭 상태 열거형
enum FoodTruckStatus {
    case open
    case closed
    case recruiting
    
    var displayText: String {
        switch self {
        case .open:
            return "영업 중"
        case .closed:
            return "영업 종료"
        case .recruiting:
            return "모집 중"
        }
    }
}

// 기존 코드와의 호환성을 위한 확장
extension StatusBadge {
    init(status: StatusBadge.BadgeType) {
        self.type = status
    }
}

#Preview {
    VStack(spacing: 20) {
        // 이벤트 상태 배지
        Group {
            StatusBadge(status: EventStatus.beforeApplication)
            StatusBadge(status: EventStatus.openForApplication)
            StatusBadge(status: EventStatus.applicationFinished)
            StatusBadge(status: EventStatus.eventStart)
            StatusBadge(status: EventStatus.eventEnd)
        }
        
        // 푸드트럭 상태 배지
        Group {
            StatusBadge(status: FoodTruckStatus.open)
            StatusBadge(status: FoodTruckStatus.closed)
            StatusBadge(status: FoodTruckStatus.recruiting)
        }
        
        // 커스텀 상태 배지
        StatusBadge(text: "커스텀 상태", color: .purple)
    }
    .padding()
}
