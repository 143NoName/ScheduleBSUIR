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
    
    func filrerDataForWidget(_ data: [(day: String, lessons: [Lesson])], weekNumber: Int, subgroup: Int) -> [(day: String, lessons: [Lesson])] {
        let filteredData = data.map { (day, lessons) in
            let filteredLessons = lessons.filter { lesson in
                lesson.weekNumber.contains(weekNumber) &&
                (subgroup == 0 ? lesson.numSubgroup == 0 || lesson.numSubgroup == 1 || lesson.numSubgroup == 2 : lesson.numSubgroup == subgroup || lesson.numSubgroup == 0) &&
                !["Консультация", "Экзамен"].contains(lesson.lessonTypeAbbrev)
            }
            return (day, filteredLessons)
        }
        return filteredData
    }
    
    // загрузка расписание группы а AppStorage
    func saveDataForWidgetToAppStorage(_ data: Schedules) throws {
        do {
            let newFormat = data.lessonsByDay
            let filteredData = filrerDataForWidget(newFormat, weekNumber: 1, subgroup: 0)
            // тут можно реализовать фильтрацию
            
            let rawData = try encoder.encode(data) // filteredData
            #warning("Тут закончил, при декодировании нужно использовать Codable модель, но у меня используется [(day: String, lessons: [Lesson])]")
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
