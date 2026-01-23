//
//  FilterInWidget.swift
//  ScheduleBSUIRWidgetExtension
//
//  Created by andrew on 23.01.26.
//

import Foundation

protocol FilterInWidgetProtocol {
    func findTodayLessons(lessons: [FormatedSchedules]?) -> [Lesson]
}

class FilterInWidget: FilterInWidgetProtocol {
    // фильтрация по дню недели
    #warning("Проверить бы как работает (unit тест)")
    func findTodayLessons(lessons: [FormatedSchedules]?) -> [Lesson] { //
        let calendar = Calendar.current
        let date = Date()
    
        let weekdays = ["Воскресенье", "Понедельник", "Вторник", "Среда", "Четверг", "Пятница", "Суббота"]  // массив строк дней недели
        let today = calendar.component(.weekday, from: date)                                                // получение номера дня недели (он же будет индексом в массиве weekdays)
        let todayWeekday = weekdays[today]                                                                  // получение строки дня недели по индексу из массивв weekdays
        
        return lessons?.first(where: { $0.day == todayWeekday })?.lesson ?? []
    }
}
