//
//  AppStorageSaveService.swift
//  ScheduleBSUIR
//
//  Created by andrew on 24.11.25.
//

import SwiftUI

protocol AppStorageServiceProtocol {
    func saveDataForWidgetToAppStorage(_ data: Schedules) throws
//    func getDataFromAppStorage() throws -> Schedules?
}

class AppStorageService: AppStorageServiceProtocol {
    
    // для загрузки
    @AppStorage("groupSchedule", store: UserDefaults(suiteName: "group.foAppAndWidget.ScheduleBSUIR")) var groupSchedule: Data?
    @AppStorage("favoriteGroup", store: UserDefaults(suiteName: "group.foAppAndWidget.ScheduleBSUIR")) var favoriteGroup: String = ""
    // для загрузки
    
    // для загрузки и фильтрации
    @AppStorage("weekNumber", store: UserDefaults(suiteName: "group.foAppAndWidget.ScheduleBSUIR")) var weekNumber: Int = 0
    @AppStorage("subGroup", store: UserDefaults(suiteName: "group.foAppAndWidget.ScheduleBSUIR")) var subGroup: Int = 0
    // для загрузки и фильтрации
    
    let encoder = JSONEncoder()
    
    func filrerDataForWidget(_ data: Schedules) {
        
    }
    
    // загрузка расписание группы а AppStorage
    func saveDataForWidgetToAppStorage(_ data: Schedules) throws {
        do {
            
            let rawData = try encoder.encode(data)
            groupSchedule = rawData
        } catch {
            throw error
        }
    }
    
    // загрузка номера недели
    func saveWeekNumberToAppStorage(_ weekNum: Int) {
        weekNumber = weekNum
    }
    
    // загрузка favoriteGroup и subGroup в AppStorage автоматическое при их изменении
    
}
