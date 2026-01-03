//
//  Extensions.swift
//  ScheduleBSUIR
//
//  Created by user on 28.10.25.
//

import SwiftUI

// расширение для String. Для преобразования строки в дату
extension String {
    func toDate() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        dateFormatter.locale = Locale(identifier: "ru_RU")
        return dateFormatter.date(from: self)
    }
}

// расширение для View. Для отображения .searchable по условию
extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}


struct CostomList<Content: View>: View {
    
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        List {
            content
        }
        .scrollContentBackground(.hidden)
    }
}
