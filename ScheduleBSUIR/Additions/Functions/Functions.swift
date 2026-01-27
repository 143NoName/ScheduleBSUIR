//
//  Functions.swift
//  ScheduleBSUIR
//
//  Created by user on 31.10.25.
//

import SwiftUI
import WidgetKit

protocol MoreFunctionsProtocol {
    
}

class MoreFunctions: MoreFunctionsProtocol {

    
    
    
    
    
    // фильтрация по дню недели используя enum DaysInPicker
    func comparisonDay(_ selectedDay: DaysInPicker, lessonDay: String) -> Bool {
        return selectedDay.filterByDay == lessonDay
    }
    
    // проверка закончился ли урок, если да, то добавляется прозачность
    func comparisonLessonOverTime(lesson: Lesson) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.locale = Locale(identifier: "ru_RU")
        
        let currentDate = Date()
        
        let currentDateInString = formatter.string(from: currentDate)
        
        if lesson.endLessonTime < currentDateInString {
            return true
        } else if lesson.endLessonTime > currentDateInString {
            return false
        }
        return false
    }
    
    // проверка будет ли урок или нет по сегодняшней дате, если нет, то будет написано когда начало или когда конец и добавляется прозрачность
    func comparisonLessonOverDate(lesson: Lesson) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        formatter.locale = Locale(identifier: "ru_RU")
        
        let calendar = Calendar.current
        let date = calendar.startOfDay(for: Date()) // получение сегоднящнего дня с временем 00:00
        
        guard let lessonStartLessonDate = lesson.startLessonDate else { return "" }
        guard let lessonEndLessonDate = lesson.endLessonDate else { return "" }
        
        let lessonStartLessonDateInDate = formatter.date(from: lessonStartLessonDate)!
        let lessonEndLessonDateInDate = formatter.date(from: lessonEndLessonDate)!
                
        if date > lessonEndLessonDateInDate {
            return "По \(lessonEndLessonDate)"
        } else if date < lessonStartLessonDateInDate {
            return "С \(lessonStartLessonDate)"
        }
        return ""
    }
    
    @AppStorage("weekNumber", store: UserDefaults(suiteName: "group.foAppAndWidget.ScheduleBSUIR")) var weekNumber: Int = 0
    
    // переход к сегодняшнему дню
    func findToday(selectedWeekNumber: inout WeeksInPicker, weekDay: inout DaysInPicker) {
        if let updateWeekNum = WeeksInPicker(rawValue: weekNumber) {
            selectedWeekNumber = updateWeekNum
        }
        if let currentDay = DaysInPicker(rawValue: getWeekDay())  {
            weekDay = currentDay
        }
    }
    
    // получение сегодняшнего дня недели
    func getWeekDay() -> Int {
        let calendar = Calendar.current
        
        let day = calendar.component(.weekday, from: Date())
                
        let index: Int
       
        switch day {
        case 1: index = 0
        case 2: index = 1
        case 3: index = 2
        case 4: index = 3
        case 5: index = 4
        case 6: index = 5
        case 7: index = 6
        default: index = 0
        }
        
        return index
    }
}
