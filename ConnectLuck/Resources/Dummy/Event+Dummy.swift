//
//  Event+Dummy.swift
//  ConnectLuck
//
//  Created by 이종민 on 3/15/25.
//

import Foundation

extension Event {
    /// 디버그용 더미 데이터
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
                managerName: "서울시청",
                status: .eventStart // BEFORE_APPLICATION, EVENT_START 등으로 교체 가능
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
                managerName: "부산시청",
                status: .beforeApplication
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
                managerName: "서울대학교 총학생회",
                status: .eventEnd
            )
        ]
    }
}
