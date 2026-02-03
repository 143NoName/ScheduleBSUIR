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

struct CostomList<Content: View, LoadingContent: View, Items: Identifiable>: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    let items: [Items]                  // элементы (данных)
    let isLoading: Bool
    let loadingView: LoadingContent
    let errorStr: String
    
    @ViewBuilder
    let content: (Items) -> Content     // вьюха для отображения
    
    var body: some View {
        ZStack {
            if colorScheme == .light {
                Color.gray
                    .opacity(0.15)
                    .ignoresSafeArea(edges: .all)
            }
            List {
                if isLoading {
                    if errorStr.isEmpty {
                        ForEach(items) { each in
                            content(each)
                        }
                    } else {
                        ErrorView(errorInfo: errorStr)
                    }
                } else {
                    ForEach(0...10, id: \.self) { _ in
                        loadingView
                    }
                }
            }
            .scrollContentBackground(.hidden)
        }
    }
}
