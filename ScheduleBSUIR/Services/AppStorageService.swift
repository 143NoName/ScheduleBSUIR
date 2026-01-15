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
    
    @AppStorage("groupSchedule", store: UserDefaults(suiteName: "group.foAppAndWidget.ScheduleBSUIR")) var groupSchedule: Data?
    @AppStorage("weekNumber", store: UserDefaults(suiteName: "group.foAppAndWidget.ScheduleBSUIR")) var weekNumber: Int = 0
    @AppStorage("subGroup", store: UserDefaults(suiteName: "group.foAppAndWidget.ScheduleBSUIR")) var subGroup: Int = 0
    
    let encoder = JSONEncoder()
    
    func filrerDataForWidget(_ data: [FormatedSchedules], weekNumber: Int, subgroup: Int) -> [FormatedSchedules] {
        let formatedData = data.map { schedule in
            let filteredLessons = schedule.lesson.filter { lesson in
                lesson.weekNumber.contains(weekNumber) &&
                (subgroup == 0 ? lesson.numSubgroup == 0 || lesson.numSubgroup == 1 || lesson.numSubgroup == 2 : lesson.numSubgroup == subgroup || lesson.numSubgroup == 0) &&
                !["Консультация", "Экзамен"].contains(lesson.lessonTypeAbbrev)
            }
            return FormatedSchedules(day: schedule.day, lesson: filteredLessons)
        }
        
        return formatedData
    }
    
    
    // загрузка расписания группы а AppStorage
    func saveDataForWidgetToAppStorage(_ data: Schedules) throws {
        do {
            let newFormat = data.getFormatedSchedules()
            let filteredData = filrerDataForWidget(newFormat, weekNumber: weekNumber, subgroup: subGroup)
            // тут все работает исправно
            
            let rawData = try encoder.encode(filteredData) // filteredData

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
