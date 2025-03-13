//
//  String+Extension.swift
//  ConnectLuck
//
//  Created by 이종민 on 3/14/25.
//

import Foundation

extension String {
    func toFormattedDate() -> String? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        formatter.locale = Locale(identifier: "ko_KR")

        guard let date = formatter.date(from: self) else { return nil }

        formatter.dateFormat = "yyyy.MM.dd"
        return formatter.string(from: date)
    }
}
