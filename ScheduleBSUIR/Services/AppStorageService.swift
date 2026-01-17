//
//  AppStorageSaveService.swift
//  ScheduleBSUIR
//
//  Created by andrew on 24.11.25.
//

import SwiftUI

protocol AppStorageServiceProtocol {
    func filtredDataForWidget(_ data: [FormatedSchedules], weekNumber: Int, subgroup: Int) -> [FormatedSchedules]
    func saveDataForWidgetToAppStorage(_ data: Schedules) throws
}

class SaveForWidgetService: AppStorageServiceProtocol {
    
    @AppStorage("scheduleForWidget", store: UserDefaults(suiteName: "group.foAppAndWidget.ScheduleBSUIR")) var scheduleForWidget: Data?     // само расписание для отображения в виджете
    @AppStorage("weekNumber", store: UserDefaults(suiteName: "group.foAppAndWidget.ScheduleBSUIR")) var weekNumber: Int = 0
    @AppStorage("subGroup", store: UserDefaults(suiteName: "group.foAppAndWidget.ScheduleBSUIR")) var subGroup: Int = 0
    
    let encoder = JSONEncoder()
    
    func filtredDataForWidget(_ data: [FormatedSchedules], weekNumber: Int, subgroup: Int) -> [FormatedSchedules] {
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
    
    // загрузка расписания группы или преподавателя а AppStorage для виджета
    func saveDataForWidgetToAppStorage(_ data: Schedules) throws {
        do {
            let newFormat = data.getFormatedSchedules()
            let filteredData = filtredDataForWidget(newFormat, weekNumber: weekNumber, subgroup: subGroup)
            
            let rawData = try encoder.encode(filteredData)
            
            scheduleForWidget = rawData
        } catch {
            throw error
        }
    }
    
    #warning("Сомнительно")
    // загрузка номера недели
    func saveWeekNumberToAppStorage(_ weekNum: Int) {
        weekNumber = weekNum
    }
}

protocol AppStorageServiceForAppProtocol {
    func saveFavoriteGroupScheduleToAppStorage(_ data: EachGroupResponse) throws
    func saveFavoriteEmployeeScheduleToAppStorage(_ data: EachEmployeeResponse) throws
    func getScheduleGroup(_ group: String) async throws -> EachGroupResponse
    func getEachEmployeeSchedule(_ urlId: String) async throws -> EachEmployeeResponse
}


struct AppStorageServiceForApp: AppStorageServiceForAppProtocol, SourceData {
        
    @AppStorage("favoriteSchedule") var favoriteSchedule: Data?                                 // все данные расписания для отображения в "Мое расписание"
    
    let decoder = JSONDecoder()
    let encoder = JSONEncoder()
    
    // MARK: - Для приложения. Данные для отображения расписания выбранной группы или преподавателя
    
    // функция загрузки расписания в AppStorage
//    func saveFavoriteScheduleToAppStorage(_ data: T) throws { // или EachEmployeeResponse или EachGroupResponse
//        do {
//            let rawData = try encoder.encode(data)
//            favoriteSchedule = rawData
//        } catch {
//            print(error.localizedDescription)
//        }
//    }
    
    // функция получения расписания из AppStorage
//    func getFavoriteScheduleFromAppStorage() throws -> T {
//        guard let rawData = favoriteSchedule else {
//            throw NSError(domain: "AppStorageError",
//                          code: 1,
//                          userInfo: [NSLocalizedDescriptionKey: "No data found in AppStorage"]
//            )
//        }
//        
//        do {
//            let data = try decoder.decode(T.self, from: rawData)
//            return data
//        } catch {
//            print("Ошибка при попытке декодировать: \(error.localizedDescription)")
//            throw error
//        }
//    }
    
    func saveFavoriteGroupScheduleToAppStorage(_ data: EachGroupResponse) throws {                          // загрузка расписания группы
        do {
            let rawData = try encoder.encode(data)
            favoriteSchedule = rawData
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func saveFavoriteEmployeeScheduleToAppStorage(_ data: EachEmployeeResponse) throws {                    // загрузка расписания преподавателя
        do {
            let rawData = try encoder.encode(data)
            favoriteSchedule = rawData
        } catch {
            print(error.localizedDescription)
        }
    }
    
    
    func getScheduleGroup(_ group: String) async throws -> EachGroupResponse {                              // получение расписания группы
        guard let rawData = favoriteSchedule else {
            throw NSError(domain: "AppStorageError",
                          code: 1,
                          userInfo: [NSLocalizedDescriptionKey: "No data found in AppStorage"]
            )
        }
        
        do {
            let data = try decoder.decode(EachGroupResponse.self, from: rawData)
            return data
        } catch {
            print("Ошибка при попытке декодировать: \(error.localizedDescription)")
            throw error
        }
    }
    
    func getEachEmployeeSchedule(_ urlId: String) async throws -> EachEmployeeResponse {                    // получение расписания преподавателя
        guard let rawData = favoriteSchedule else {
            throw NSError(domain: "AppStorageError",
                          code: 1,
                          userInfo: [NSLocalizedDescriptionKey: "No data found in AppStorage"]
            )
        }
        
        do {
            let data = try decoder.decode(EachEmployeeResponse.self, from: rawData)
            return data
        } catch {
            print("Ошибка при попытке декодировать: \(error.localizedDescription)")
            throw error
        }
    }

}
