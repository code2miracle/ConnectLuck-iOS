//
//  FoodType.swift
//  ConnectLuck
//
//  Created by 이종민 on 3/14/25.
//

import Foundation

/// 푸드트럭 음식 종류 Enum
enum FoodType: String, Codable, CaseIterable {
    case burger = "BURGER"
    case chicken = "CHICKEN"
    case dessert = "DESSERT"
    case drink = "DRINK"
    case hotdog = "HOTDOG"
    case noodle = "NOODLE"
    case pizza = "PIZZA"
    case rice = "RICE"
    case salad = "SALAD"
    case sandwich = "SANDWICH"
    case snack = "SNACK"
    case soup = "SOUP"
    case steak = "STEAK"
    case sushi = "SUSHI"
    case chinese = "CHINESE"
    case japanese = "JAPANESE"
    case korean = "KOREAN"
    case italian = "ITALIAN"
    case mexican = "MEXICAN"
    case french = "FRENCH"
    case thai = "THAI"
    case vietnamese = "VIETNAMESE"
    case indian = "INDIAN"
    case turkish = "TURKISH"
    case greek = "GREEK"
    case spanish = "SPANISH"
    case brazilian = "BRAZILIAN"
    case americanSpecial = "AMERICAN_SPECIAL"
    case brunch = "BRUNCH"
    case bakery = "BAKERY"
    case coffeeShop = "COFFEE_SHOP"
    case bar = "BAR"
    case vegetarian = "VEGETARIAN"
    case western = "WESTERN"
    case tacos = "TACOS"
    case burritos = "BURRITOS"
    case foodTruckSpecial = "FOOD_TRUCK_SPECIAL"
    case streetFood = "STREET_FOOD"
    case bbq = "BBQ"
    case grilledCheese = "GRILLED_CHEESE"
    case fishTacos = "FISH_TACOS"
    case friedChicken = "FRIED_CHICKEN"
    case iceCream = "ICE_CREAM"
    case etc = "ETC"
    
    /// `FoodType`을 문자열 배열로 반환
    static var allCasesString: [String] {
        return Self.allCases.map { $0.rawValue }
    }

}

