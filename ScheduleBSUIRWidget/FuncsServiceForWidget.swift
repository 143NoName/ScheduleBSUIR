//
//  FuncsServiceForWidget.swift
//  ScheduleBSUIRWidgetExtension
//
//  Created by andrew on 29.11.25.
//

import SwiftUI

class FuncsServiceForWidget {
    
    let decoder = JSONDecoder()

    @AppStorage("groupSchedule", store: UserDefaults(suiteName: "group.foAppAndWidget.ScheduleBSUIR")) var groupSchedule: Data?
    @AppStorage("favoriteGroup", store: UserDefaults(suiteName: "group.foAppAndWidget.ScheduleBSUIR")) var favoriteGroup: String = ""
    @AppStorage("weekNumber", store: UserDefaults(suiteName: "group.foAppAndWidget.ScheduleBSUIR")) var weekNumber: Int = 0
    @AppStorage("subGroup", store: UserDefaults(suiteName: "group.foAppAndWidget.ScheduleBSUIR")) var subGroup: Int = 0
    
    
//    func convertToScheduleDays(_ schedules: Schedules) -> [(dayName: String, lessons: [Lesson])] { // конвертация в (День: [Занятия])
//        let days = [
//            ("Понедельник", schedules.monday),
//            ("Вторник", schedules.tuesday),
//            ("Среда", schedules.wednesday),
//            ("Четверг", schedules.thursday),
//            ("Пятница", schedules.friday),
//            ("Суббота", schedules.saturday),
//            ("Воскресенье", schedules.sunday)
//        ]
//        
//        return days.compactMap { dayName, optionalLessons in
//            guard let lessons = optionalLessons, !lessons.isEmpty else {
//                return (dayName, [])
//            }
//            return (dayName, lessons)
//        }
//    }
    
    // получение всего расписания
    func getDataFromUserDefaults() throws -> Schedules? {
        do {
            guard let rawData = groupSchedule else { return nil }
            let data = try decoder.decode(Schedules.self, from: rawData)
            return data
        } catch {
            print("Ошибка при получения расписания: \(error)")
            return nil
        }
    }
    
    // новая
    func getDataFromUserDefaults2() throws -> [(day: String, lessons: [Lesson])]? {
        do {
            guard let rawData = groupSchedule else { return nil }
            let data = try decoder.decode(Schedules.self, from: rawData)
            return data.lessonsByDay
        } catch {
            print("Ошибка при получения расписания: \(error)")
            return nil
        }
    }
    
    
    // определение текущего урока
    func findTodayLessons(lessons: Schedules?) -> [Lesson] {
        guard let lessons else { return [] }
        
        let calendar = Calendar.current
        let date = Date()
        let today = calendar.component(.weekday, from: date)
        return lessons.atDay(today) ?? [] // а можно проще lessons.lessonsByDay
    }
    
    // новая
    func findTodayLessons2(lessons: [(day: String, lessons: [Lesson])]?) -> [Lesson] {
        let calendar = Calendar.current
        let date = Date()
        let today = calendar.component(.weekday, from: date)
        switch today {
        case 1: return lessons?.first(where: { $0.day == "Воскресенье" })?.lessons ?? []
        case 2: return lessons?.first(where: { $0.day == "Понедельник" })?.lessons ?? []
        case 3: return lessons?.first(where: { $0.day == "Вторник" })?.lessons ?? []
        case 4: return lessons?.first(where: { $0.day == "Среда" })?.lessons ?? []
        case 5: return lessons?.first(where: { $0.day == "Четверг" })?.lessons ?? []
        case 6: return lessons?.first(where: { $0.day == "Пятница" })?.lessons ?? []
        case 7: return lessons?.first(where: { $0.day == "Суббота" })?.lessons ?? []
        default: return []
        }
    }
}
