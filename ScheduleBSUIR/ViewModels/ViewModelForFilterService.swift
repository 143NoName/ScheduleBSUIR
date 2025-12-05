//
//  ViewModelForFilterService.swift
//  ScheduleBSUIR
//
//  Created by andrew on 5.12.25.
//

import Foundation
import Combine
import SwiftUI

class ViewModelForFilterService: ObservableObject {
    
    private let filterService: FilterServiceProtocol
    
    init(filterService: FilterServiceProtocol = FilterService()) {
        self.filterService = filterService
    }
    
    @Published var filteredLessons: [(dayName: String, lessons: [Lesson])] = []
    
    func filterSchedule(currentWeek: WeeksInPicker, subGroup: SubGroupInPicker, scheduleDays: [(dayName: String, lessons: [Lesson])]) {
        filteredLessons = filterService.filterSchedule(currentWeek: currentWeek, subGroup: subGroup, scheduleDays: scheduleDays)
        print("Получаем: \(scheduleDays)")
        print("Возвращаем: \(filteredLessons)")
    }
}
