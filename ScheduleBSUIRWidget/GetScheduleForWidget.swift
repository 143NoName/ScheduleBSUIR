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
        
    @AppStorage("scheduleForWidget", store: UserDefaults(suiteName: "group.foAppAndWidget.ScheduleBSUIR")) var scheduleForWidget: Data?
    
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
