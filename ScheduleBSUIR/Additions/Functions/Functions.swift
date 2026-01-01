//
//  Functions.swift
//  ScheduleBSUIR
//
//  Created by user on 31.10.25.
//

import SwiftUI
import WidgetKit

struct MoreFunctions {
    
    static let shared = MoreFunctions()

    // фильтрация по дню недели используя enum DaysInPicker
    func comparisonDay(_ selectedDay: DaysInPicker, lessonDay: String) -> Bool {
        return selectedDay.filterByDay == lessonDay
    }
    
    func saveInUserDefaults(_ data: Schedules, weekDay: DaysInPicker, weenNumber: Int, subGroupe: SubGroupInPicker, favoriteGroup: String) {
        let userDefaultSave = UserDefaults(suiteName: "group.foAppAndWidget.ScheduleBSUIR")!
        
        let today = Calendar.current.component(.weekday, from: Date())
    
        
        var todaySchedules: [Lesson] {
            switch today {
            case 2:
                return data.monday?.filter {$0.lessonTypeAbbrev != "Экзамен" && $0.lessonTypeAbbrev != "Консультация"}  ?? []
            case 3:
                return data.tuesday?.filter {$0.lessonTypeAbbrev != "Экзамен" && $0.lessonTypeAbbrev != "Консультация"}  ?? []
            case 4:
                return data.wednesday?.filter {$0.lessonTypeAbbrev != "Экзамен" && $0.lessonTypeAbbrev != "Консультация"}  ?? []
            case 5:
                return data.thursday?.filter {$0.lessonTypeAbbrev != "Экзамен" && $0.lessonTypeAbbrev != "Консультация"}  ?? []
            case 6:
                return data.friday?.filter {$0.lessonTypeAbbrev != "Экзамен" && $0.lessonTypeAbbrev != "Консультация"}  ?? []
            case 7:
                return data.saturday?.filter {$0.lessonTypeAbbrev != "Экзамен" && $0.lessonTypeAbbrev != "Консультация"}  ?? []
            case 1:
                return data.sunday?.filter {$0.lessonTypeAbbrev != "Экзамен" && $0.lessonTypeAbbrev != "Консультация"}  ?? []
            default:
                return data.monday?.filter {$0.lessonTypeAbbrev != "Экзамен" && $0.lessonTypeAbbrev != "Консультация"}  ?? []
            }
        }
        
        var todayWeek: [Lesson] {
            switch weenNumber {
            case 1:
                return todaySchedules.filter {$0.weekNumber.contains(1)}
            case 2:
                return todaySchedules.filter {$0.weekNumber.contains(2)}
            case 3:
                return todaySchedules.filter {$0.weekNumber.contains(3)}
            case 4:
                return todaySchedules.filter {$0.weekNumber.contains(4)}
            default:
                return todaySchedules.filter {$0.weekNumber.contains(0)}
            }
        } // можно укоротить
        
        var todayWeek2: [Lesson] {
            return todaySchedules.filter {$0.weekNumber.contains(weenNumber) }
        }
        
        var subGroupFiltered: [Lesson] {
            switch subGroupe {
            case .all:
                return todayWeek2
            case .first:
                return todayWeek2.filter {$0.numSubgroup == 1 || $0.numSubgroup == 0}
            case .second:
                return todayWeek2.filter {$0.numSubgroup == 2 || $0.numSubgroup == 0}
            }
        }
        
        
        do {
            userDefaultSave.set(favoriteGroup, forKey: "favoriteGroup")
            
            let jsonData = try JSONEncoder().encode(subGroupFiltered)
            userDefaultSave.set(jsonData, forKey: "widget")
            userDefaultSave.synchronize()
            
            WidgetCenter.shared.reloadAllTimelines()
        } catch {
            print("ошибка")
        }
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
    
    #warning("На день позже")
    // переход к сегодняшнему дню
    func findToday(todayWeek: Int, weekNumber: inout WeeksInPicker, weekDay: inout DaysInPicker) {
        if let updateWeekNum = WeeksInPicker(rawValue: todayWeek) {
            weekNumber = updateWeekNum
        }
        
        if let currentDay = DaysInPicker(rawValue: getWeekDay())  {
            weekDay = currentDay
        }
    }
    
    // получение сегодняшнего дня недели правильно
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
    
    
    
     // РАБОТА С APPSTORAGE
    
    
    
    @AppStorage("groupSchedule", store: UserDefaults(suiteName: "group.foAppAndWidget.ScheduleBSUIR")) var groupSchedule: Data?
    @AppStorage("groupName", store: UserDefaults(suiteName: "group.foAppAndWidget.ScheduleBSUIR")) var groupName: String = ""
    
    let encoder = JSONEncoder()
    
    // сохранение данных в AppStorage
    func saveDataForWidgetToAppStorage(_ data: Schedules) throws {
        do {
            let rawData = try encoder.encode(data)
            groupSchedule = rawData
        } catch {
            throw error
        }
    }
}
