//
//  FoodType+Extension.swift
//  ConnectLuck
//
//  Created on 3/14/25.
//

import Foundation

/// FoodType에 displayName 속성 추가
extension FoodType {
    var displayName: String {
        switch self {
        case .burger: return "버거"
        case .chicken: return "치킨"
        case .dessert: return "디저트"
        case .drink: return "음료"
        case .hotdog: return "핫도그"
        case .noodle: return "면류"
        case .pizza: return "피자"
        case .rice: return "밥류"
        case .salad: return "샐러드"
        case .sandwich: return "샌드위치"
        case .snack: return "스낵"
        case .soup: return "수프"
        case .steak: return "스테이크"
        case .sushi: return "스시"
        case .chinese: return "중식"
        case .japanese: return "일식"
        case .korean: return "한식"
        case .italian: return "이탈리안"
        case .mexican: return "멕시칸"
        case .french: return "프렌치"
        case .thai: return "태국음식"
        case .vietnamese: return "베트남음식"
        case .indian: return "인도음식"
        case .turkish: return "터키음식"
        case .greek: return "그리스음식"
        case .spanish: return "스페인음식"
        case .brazilian: return "브라질음식"
        case .americanSpecial: return "미국 스페셜"
        case .brunch: return "브런치"
        case .bakery: return "베이커리"
        case .coffeeShop: return "커피샵"
        case .bar: return "바"
        case .vegetarian: return "채식"
        case .western: return "양식"
        case .tacos: return "타코"
        case .burritos: return "부리토"
        case .foodTruckSpecial: return "푸드트럭 스페셜"
        case .streetFood: return "길거리 음식"
        case .bbq: return "바베큐"
        case .grilledCheese: return "그릴드 치즈"
        case .fishTacos: return "피쉬 타코"
        case .friedChicken: return "프라이드 치킨"
        case .iceCream: return "아이스크림"
        case .etc: return "기타"
        }
    }
}
