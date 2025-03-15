//
//  FoodTruck+Dummy.swift
//  ConnectLuck
//
//  Created by 이종민 on 3/14/25.
//

import Foundation

extension FoodTruck {
    /// 디버그용 더미 데이터 생성
    static func dummyData() -> [FoodTruck] {
        return [
            FoodTruck(
                id: 1,
                name: "100% Truck",
                description: "맛있는 음료수 팔고있어요",
                imageUrl: "https://img1.yna.co.kr/photo/yna/YH/2015/10/29/PYH2015102905340005100_P4.jpg",
                managerName: "User3",
                foodType: "DRINK", // 만약 내부에서 foodTypeEnum computed property가 있다면 그대로 사용
                reviewCount: 1,
                avgRating: 3
            ),
            // 나머지 FoodTruck 데이터...
        ]
    }
}

extension FoodTruckDetail {
    /// 디버그용 상세 더미 데이터 생성
    static func dummyDetail(id: Int) -> FoodTruckDetail {
        let dummyReviews: [FoodTruckReview] = [
            FoodTruckReview(
                id: 1,
                content: "맛있어요!",
                imageUrl: "",
                rating: 5,
                authorName: "리뷰어1",
                reply: "",
                createdAt: "2025-03-10T12:00:00.000Z",
                updatedAt: "2025-03-10T12:00:00.000Z"
            )
        ]
        
        let dummyMenus: [FoodTruckMenu] = [
            FoodTruckMenu(
                id: 1,
                name: "메뉴 1",
                description: "대표 메뉴",
                imageUrl: "",
                price: 8000,
                createdAt: "2025-03-01T12:00:00.000Z",
                updatedAt: "2025-03-01T12:00:00.000Z"
            ),
            FoodTruckMenu(
                id: 2,
                name: "메뉴 2",
                description: "인기 메뉴",
                imageUrl: "",
                price: 9000,
                createdAt: "2025-03-01T12:00:00.000Z",
                updatedAt: "2025-03-01T12:00:00.000Z"
            )
        ]
        
        let dummyTrucks = FoodTruck.dummyData()
        if let matchingTruck = dummyTrucks.first(where: { $0.id == id }) {
            return FoodTruckDetail(
                id: matchingTruck.id,
                name: matchingTruck.name,
                description: matchingTruck.description,
                imageUrl: matchingTruck.imageUrl,
                managerName: matchingTruck.managerName,
                foodType: (matchingTruck.foodTypeEnum ?? FoodType.etc).rawValue,
                avgRating: matchingTruck.avgRating,
                reviews: dummyReviews,
                menus: dummyMenus
            )
        }
        
        return FoodTruckDetail(
            id: id,
            name: "더미 푸드트럭",
            description: "테스트용 더미 데이터입니다.",
            imageUrl: "https://picsum.photos/1600/900",
            managerName: "테스트 매니저",
            foodType: FoodType.etc.rawValue,
            avgRating: 4.0,
            reviews: dummyReviews,
            menus: dummyMenus
        )
    }
}
