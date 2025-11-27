//
//  Extensions.swift
//  ScheduleBSUIR
//
//  Created by user on 28.10.25.
//

import SwiftUI

extension String {
    func toDate() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        dateFormatter.locale = Locale(identifier: "ru_RU")
        return dateFormatter.date(from: self)
    }
}
