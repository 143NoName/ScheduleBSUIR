//
//  FuncsServiceForWidget.swift
//  ScheduleBSUIRWidgetExtension
//
//  Created by andrew on 29.11.25.
//

import SwiftUI

class FuncsServiceForWidget {
    
    let decoder = JSONDecoder()

    @AppStorage("scheduleForWidget", store: UserDefaults(suiteName: "group.foAppAndWidget.ScheduleBSUIR")) var scheduleForWidget: Data?
    @AppStorage("employeeSchedule", store: UserDefaults(suiteName: "group.foAppAndWidget.ScheduleBSUIR")) var employeeSchedule: Data?
    @AppStorage("favoriteGroup", store: UserDefaults(suiteName: "group.foAppAndWidget.ScheduleBSUIR")) var favoriteGroup: String = "Не выбрано"
    @AppStorage("weekNumber", store: UserDefaults(suiteName: "group.foAppAndWidget.ScheduleBSUIR")) var weekNumber: Int = 0
    @AppStorage("subGroup", store: UserDefaults(suiteName: "group.foAppAndWidget.ScheduleBSUIR")) var subGroup: Int = 0
    
    func getDataFromUserDefaults() throws -> [FormatedSchedules]? {
        do {
            guard let rawData = scheduleForWidget else { return nil }
            let data = try decoder.decode([FormatedSchedules].self, from: rawData)
            return data
        } catch {
            print("Ошибка при получения расписания: \(error)")
            return nil
        }
    }
    
    #warning("Как будто хуйня")
    func findTodayLessons(lessons: [FormatedSchedules]?) -> [Lesson] {
        let calendar = Calendar.current
        let date = Date()
        let today = calendar.component(.weekday, from: date)
                
        switch today {
        case 1: return lessons?.first(where: { $0.day == "Воскресенье" })?.lesson ?? []
        case 2: return lessons?.first(where: { $0.day == "Понедельник" })?.lesson ?? []
        case 3: return lessons?.first(where: { $0.day == "Вторник" })?.lesson ?? []
        case 4: return lessons?.first(where: { $0.day == "Среда" })?.lesson ?? []
        case 5: return lessons?.first(where: { $0.day == "Четверг" })?.lesson ?? []
        case 6: return lessons?.first(where: { $0.day == "Пятница" })?.lesson ?? []
        case 7: return lessons?.first(where: { $0.day == "Суббота" })?.lesson ?? []
        default: return []
        }    }
}
