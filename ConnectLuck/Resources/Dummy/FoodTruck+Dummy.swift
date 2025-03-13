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
        [
            FoodTruck(
                id: 1,
                name: "100% truck",
                description: "맛있는 음료수 팔고있어요",
                imageUrl: "https://img1.yna.co.kr/photo/yna/YH/2015/10/29/PYH2015102905340005100_P4.jpg",
                managerName: "User3",
                foodType: "DRINK",
                reviewCount: 1,
                avgRating: 3
            ),
            FoodTruck(
                id: 2,
                name: "5달러닭강정",
                description: "닭강정이 5달러~",
                imageUrl: "https://mblogthumb-phinf.pstatic.net/MjAyMzAxMDRfMjI4/MDAxNjcyODAzNjM2MjEy.-Lp1Doax51gWIlYcnw_s3-2YDIdXAHP88g0exQ0ZmqYg.3c0heb7VGttuMK03uUhnCYcJYjfFbhhut_as23Lb_lIg.JPEG.bangsam23/1672745143719.jpg?type=w800",
                managerName: "User3",
                foodType: "CHICKEN",
                reviewCount: 1,
                avgRating: 5
            ),
            FoodTruck(
                id: 3,
                name: "CAFE&산토리니",
                description: "산토리니를 옮겨놓은듯한 카페",
                imageUrl: "https://thespike.co.kr/news/data/20230307/p1065607346201119_687_thum.jpeg",
                managerName: "User3",
                foodType: "COFFEE_SHOP",
                reviewCount: 1,
                avgRating: 2
            ),
            FoodTruck(
                id: 4,
                name: "HERO히어로",
                description: "히어로 부럽지않은 에너지드링크",
                imageUrl: "https://mblogthumb-phinf.pstatic.net/MjAxOTEyMjlfMTM2/MDAxNTc3NjE1MzI0NjAy.y2lWuporgreicP9luew1P0_VEM_Clp_hKQaO6gw7a2Ug.hlCCvID4b_CPCs6XPQe1B1I0Ur-PFBLIK2hqCpoY8Iog.JPEG.jayone0722/IMG_5723.JPG?type=w800",
                managerName: "User3",
                foodType: "COFFEE_SHOP",
                reviewCount: 1,
                avgRating: 4
            ),
            FoodTruck(
                id: 5,
                name: "간다GO",
                description: "시원한 아이스 아메리카노",
                imageUrl: "https://www.thinkfood.co.kr/news/photo/202310/98954_129587_443.jpg",
                managerName: "User3",
                foodType: "COFFEE_SHOP",
                reviewCount: 1,
                avgRating: 4
            ),
            FoodTruck(
                id: 6,
                name: "고니푸드",
                description: "시원한 사이다 (16oz)",
                imageUrl: "https://static.cdn.soomgo.com/upload/portfolio/456cd65b-161f-4d36-b75f-1a724316712f.jpg?h=630&w=1200&webp=1",
                managerName: "User3",
                foodType: "DRINK",
                reviewCount: 1,
                avgRating: 4
            ),
            FoodTruck(
                id: 7,
                name: "고성시니어클럽 정담맛차",
                description: "달달구리한 닭강정",
                imageUrl: "https://lh4.googleusercontent.com/proxy/GDjP2VtqkpvWZAYe_Crp1KCRh2jP39-_V4bhj6o2hxKlVVn6T1u1hYo4FYpVrvjuc2yxE6UY9_eupD8jOWUmKJyKK2FUWBhwHMpin1YVo7M",
                managerName: "User3",
                foodType: "CHICKEN",
                reviewCount: 1,
                avgRating: 5
            ),
            FoodTruck(
                id: 8,
                name: "골드스타(Gold Star)",
                description: "매니아층 확실한 에스프레소",
                imageUrl: "https://cdn.imweb.me/thumbnail/20220525/f374e4c38cae6.jpg",
                managerName: "User3",
                foodType: "COFFEE_SHOP",
                reviewCount: 1,
                avgRating: 5
            ),
            FoodTruck(
                id: 9,
                name: "그양반네",
                description: "톡 쏘는 콜라",
                imageUrl: "https://pds.joongang.co.kr/news/component/htmlphoto_mmdata/201608/29/htm_20160829154845783667.jpg/_ir_/resize/1280",
                managerName: "User3",
                foodType: "DRINK",
                reviewCount: 1,
                avgRating: 4
            ),
            FoodTruck(
                id: 10,
                name: "까멜리아푸드",
                description: "맵달맵달 떡볶이",
                imageUrl: "https://lh6.googleusercontent.com/proxy/Ky9DKPQI05Wl5ZvBbUAO9C59mBX2ntUFr-SzRQ0lF-900cBl_Ndac5hPfYglaZubeYfiUc27DWOE9M6giz8bmbfAxu8X",
                managerName: "User3",
                foodType: "SNACK",
                reviewCount: 1,
                avgRating: 2
            )
        ]
    }
}

extension FoodTruckDetail {
    /// 디버그용 상세 더미 데이터 생성
    static func dummyDetail(id: Int) -> FoodTruckDetail {
        let dummyReviews = [
            Review(id: 1,
                  content: "맛있어요!",
                  imageUrl: "",
                  rating: 5,
                  authorName: "리뷰어1",
                  reply: "",
                  createdAt: "2025-03-10T12:00:00.000Z",
                  updatedAt: "2025-03-10T12:00:00.000Z")
        ]
        
        let dummyMenus = [
            MenuItem(id: 1,
                    name: "메뉴 1",
                    description: "대표 메뉴",
                    imageUrl: "",
                    price: 8000,
                    createdAt: "2025-03-01T12:00:00.000Z",
                    updatedAt: "2025-03-01T12:00:00.000Z"),
            MenuItem(id: 2,
                    name: "메뉴 2",
                    description: "인기 메뉴",
                    imageUrl: "",
                    price: 9000,
                    createdAt: "2025-03-01T12:00:00.000Z",
                    updatedAt: "2025-03-01T12:00:00.000Z")
        ]
        
        // ID에 따라 푸드트럭 더미 데이터에서 찾기
        let dummyTrucks = FoodTruck.dummyData()
        if let matchingTruck = dummyTrucks.first(where: { $0.id == id }) {
            return FoodTruckDetail(
                id: matchingTruck.id,
                name: matchingTruck.name,
                description: matchingTruck.description,
                imageUrl: matchingTruck.imageUrl,
                managerName: matchingTruck.managerName,
                foodType: matchingTruck.foodTypeEnum ?? .etc,
                reviews: dummyReviews,
                menus: dummyMenus,
                avgRating: matchingTruck.avgRating
            )
        }
        
        // 기본 더미 데이터
        return FoodTruckDetail(
            id: id,
            name: "더미 푸드트럭",
            description: "테스트용 더미 데이터입니다.",
            imageUrl: "https://picsum.photos/1600/900",
            managerName: "테스트 매니저",
            foodType: .etc,
            reviews: dummyReviews,
            menus: dummyMenus,
            avgRating: 4.0
        )
    }
}
