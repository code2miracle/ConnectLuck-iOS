//
//  EndPoint.swift
//  ConnectLuck
//
//  Created by 이종민 on 3/14/25.
//

import Foundation

/// API 경로를 관리하는 Enum
enum EndPoint {
    static let baseURL = "https://connect-luck.cmsong111.site"

    enum Auth {
        static let signup = "/api/auth/signup"
        static let login = "/api/auth/login"
        static let findEmailByPhone = "/api/auth/findEmailByPhone"
        static let emailCheck = "/api/auth/email-check"
    }

    enum User {
        static let addRole = "/api/v1/user/add-role"
        static let getUser = "/api/v1/user"
        static let deleteUser = "/api/v1/user"
        static let updateUser = "/api/v1/user"
    }

    enum FoodTruck {
        static let list = "/api/food-truck"
        static func detail(_ id: Int) -> String { "/api/food-truck/\(id)" }
        static let myFoodTruck = "/api/food-truck/my"
    }

    enum FoodTruckMenu {
        static func list(_ foodTruckId: Int) -> String { "/api/food-truck/\(foodTruckId)/menu" }
        static func detail(_ foodTruckId: Int, _ menuId: Int) -> String { "/api/food-truck/\(foodTruckId)/menu/\(menuId)" }
    }

    enum FoodTruckReview {
        static func create(_ foodTruckId: Int) -> String { "/api/food-truck/\(foodTruckId)/review" }
        static func reply(_ foodTruckId: Int, _ reviewId: Int) -> String { "/api/food-truck/\(foodTruckId)/review/\(reviewId)/reply" }
        static func delete(_ foodTruckId: Int, _ reviewId: Int) -> String { "/api/food-truck/\(foodTruckId)/review/\(reviewId)" }
        static func update(_ foodTruckId: Int, _ reviewId: Int) -> String { "/api/food-truck/\(foodTruckId)/review/\(reviewId)" }
    }

    enum Event {
        static let list = "/api/event"
        static func detail(_ id: Int) -> String { "/api/event/\(id)" }
        static func update(_ id: Int) -> String { "/api/event/\(id)" }
        static let myEvents = "/api/event/my"
    }

    enum EventApplication {
        static func approve(_ eventId: Int, _ applicationId: Int) -> String { "/api/event/\(eventId)/applications/\(applicationId)" }
        static let apply = "/api/application"
        static let myApplications = "/api/application/truck-manager"
        static let eventApplications = "/api/application/event-manager"
    }

    enum Now {
        static func start(_ foodTruckId: Int) -> String { "/api/now/start/\(foodTruckId)" }
        static func end(_ foodTruckId: Int) -> String { "/api/now/end/\(foodTruckId)" }
        static let current = "/api/now"
    }

    enum Image {
        static let upload = "/api/v2/image"
    }

    enum Advertisement {
        static let list = "/api/ad"
    }
}
