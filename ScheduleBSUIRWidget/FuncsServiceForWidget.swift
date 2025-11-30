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
    
    // получение всего расписания
    func getDataFromUserDefaults() throws -> Schedules? {
        do {
            guard let rawData = groupSchedule else { return nil }
            let data = try decoder.decode(Schedules.self, from: rawData)
            return data
        } catch {
            print("Ошибка при получения расписания: \(error)")
        }
        
        return nil
    }
    
    // определение текущего урока
    func findTodayLessons(lessons: Schedules?) -> [Lesson] {
        guard let lessons else { return [] }
        
        let calendar = Calendar.current
        let date = Date()
        let today = calendar.component(.weekday, from: date)
        return lessons.atDay(today) ?? []
    }
    
}
