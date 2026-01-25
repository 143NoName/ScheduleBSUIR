//
//  FilterInWidget.swift
//  ScheduleBSUIRWidgetExtension
//
//  Created by andrew on 23.01.26.
//

import Foundation
import SwiftUI

protocol FilterInWidgetProtocol {
    func findTodayLessons(lessons: [FormatedSchedules]?) -> [Lesson]
    func filterLessons(lessons: [Lesson]) -> [Lesson]
}

class FilterInWidget: FilterInWidgetProtocol {
    
    @AppStorage("weekNumber", store: UserDefaults(suiteName: "group.foAppAndWidget.ScheduleBSUIR")) var weekNumber: Int = 0
    @AppStorage("subGroup", store: UserDefaults(suiteName: "group.foAppAndWidget.ScheduleBSUIR")) var subGroup: SubGroupInPicker = .all
    
    // фильтрация по дню недели
    #warning("Проверить бы как работает (unit тест)")
    func findTodayLessons(lessons: [FormatedSchedules]?) -> [Lesson] { //
        let calendar = Calendar.current
        let date = Date()
    
        let weekdays = ["Воскресенье", "Понедельник", "Вторник", "Среда", "Четверг", "Пятница", "Суббота"]  // массив строк дней недели
        let today = calendar.component(.weekday, from: date)                                                // получение номера дня недели (он же будет индексом в массиве weekdays)
        let todayWeekday = weekdays[today]                                                                  // получение строки дня недели по индексу из массивв weekdays
        
        guard let lessons else { return [] }                                                                // проверка наличия уроков в этот день
        let todayLessons = lessons.first(where: { $0.day == todayWeekday })?.lesson ?? []                   // фильтрация уроков по сегодняшнему дню
        let filteredLessons = filterLessons(lessons: todayLessons)                                          // фильтрация по неделе и подгруппе
                
        return filteredLessons
    }
    
    func filterLessons(lessons: [Lesson]) -> [Lesson] {
        return lessons.filter {
            $0.weekNumber.contains(weekNumber) &&
            ($0.numSubgroup == 0 || $0.numSubgroup == subGroup.inNumber)
            
        }
    }
}
