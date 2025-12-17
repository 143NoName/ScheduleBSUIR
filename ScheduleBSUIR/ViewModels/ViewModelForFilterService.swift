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
    
    func filterScheduleForWidget(schedule: Schedules) { // так как schedule это просто набор свойств, можно просто пройтись по всем свойствам и каждое отфильтровать
        // для фильтрации для виджета
        if let monday = schedule.monday {

        }
        if let tuesday = schedule.tuesday {
            
        }
        if let wednesday = schedule.wednesday {
            
        }
        if let thursday = schedule.thursday {
            
        }
        if let friday = schedule.friday {
            
        }
        if let saturday = schedule.saturday {
            
        }
        if let sunday = schedule.sunday {
            
        }
    }
    
    
//    @Published var filteredLessons: [(dayName: String, lessons: [Lesson])] = []
    
//    func filterSchedule(currentWeek: WeeksInPicker, subGroup: SubGroupInPicker, scheduleDays: [(dayName: String, lessons: [Lesson])]) {
//        filteredLessons = filterService.filterSchedule(currentWeek: currentWeek, subGroup: subGroup, scheduleDays: scheduleDays)
//        print("Получаем: \(scheduleDays)")
//        print("Возвращаем: \(filteredLessons)")
//    }
//    
//    func rr () {
//        print("wjvijwe")
//    }
}
