//
//  FuncsServiceForWidget.swift
//  ScheduleBSUIRWidgetExtension
//
//  Created by andrew on 29.11.25.
//

import SwiftUI

protocol GetScheduleForWidgetProtocol {
    func getDataFromAppStorage() throws -> [FormatedSchedules]?
}

class GetScheduleForWidget: GetScheduleForWidgetProtocol {
    
    let decoder = JSONDecoder()
    
    let appStorageSave = AppStorageSave()
    
    @AppStorage("scheduleForWidget", store: UserDefaults(suiteName: "group.foAppAndWidget.ScheduleBSUIR")) var scheduleForWidget: Data?
    @AppStorage("employeeSchedule", store: UserDefaults(suiteName: "group.foAppAndWidget.ScheduleBSUIR")) var employeeSchedule: Data?
    @AppStorage("favoriteGroup", store: UserDefaults(suiteName: "group.foAppAndWidget.ScheduleBSUIR")) var favoriteGroup: String = "Не выбрано"
    @AppStorage("weekNumber", store: UserDefaults(suiteName: "group.foAppAndWidget.ScheduleBSUIR")) var weekNumber: Int = 0
    @AppStorage("subGroup", store: UserDefaults(suiteName: "group.foAppAndWidget.ScheduleBSUIR")) var subGroup: Int = 0
    
    func getDataFromAppStorage() throws -> [FormatedSchedules]? {
        do {
            guard let rawData = scheduleForWidget else { return nil }
            let data = try decoder.decode([FormatedSchedules].self, from: rawData)
            return data
        } catch {
            print("Ошибка при получения расписания: \(error)")
            return nil
        }
    }
}
