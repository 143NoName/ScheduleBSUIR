//
//  AppStorageSaveService.swift
//  ScheduleBSUIR
//
//  Created by andrew on 24.11.25.
//

import SwiftUI

protocol AppStorageServiceProtocol {
    func saveDataForWidgetToAppStorage(_ data: Schedules) throws
    func getDataFromAppStorage() throws -> Schedules?
}

class AppStorageService: AppStorageServiceProtocol {
    
    @AppStorage("groupSchedule", store: UserDefaults(suiteName: "group.foAppAndWidget.ScheduleBSUIR")) var groupSchedule: Data?
    @AppStorage("favoriteGroup", store: UserDefaults(suiteName: "group.foAppAndWidget.ScheduleBSUIR")) var favoriteGroup: String = ""
    
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    
    // загрузка расписание группы а AppStorage
    func saveDataForWidgetToAppStorage(_ data: Schedules) throws {
        do {
            let rawData = try encoder.encode(data)
            groupSchedule = rawData
        } catch {
            throw error
        }
    }
    
    // получение расписания группы из AppStorage
    func getDataFromAppStorage() throws -> Schedules? {
        do {
            guard let rawData = groupSchedule else { return nil }
            let data = try decoder.decode(Schedules.self, from: rawData)
            return data
        } catch {
            throw error
        }
    }
    
    // загрузка имени любимой группы в AppStorage
    func saveFavoriteGroupInAppStorage(_ favoriteGroup: String) {
//        print("Имя группы загружено: \(favoriteGroup)")
//        favoriteGroup = favoriteGroup
    }
    
    // получение имени любимой группы в AppStorage
    func getFavoriteGroupFromAppStorage() -> String {
        print("Имя группы получено \(favoriteGroup)")
        return favoriteGroup
    }
}
