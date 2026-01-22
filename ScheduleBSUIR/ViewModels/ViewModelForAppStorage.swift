//
//  ViewModelAppStorage.swift
//  ScheduleBSUIR
//
//  Created by andrew on 4.12.25.
//

import SwiftUI
import Combine

class ViewModelForAppStorage: ObservableObject {
    
    private let saveForWidget: AppStorageServiceProtocol
    private let appStorageService: AppStorageServiceForAppProtocol
    
    init(
        appStorageService: AppStorageServiceForAppProtocol = AppStorageServiceForApp(),
        saveForWidget: AppStorageServiceProtocol = SaveForWidgetService()
    ) {
        self.appStorageService = appStorageService
        self.saveForWidget = saveForWidget
    }

    @Published var scheduleGroupFromAppStorage: EachGroupResponse = EachGroupResponse(startDate: nil, endDate: nil, startExamsDate: nil, endExamsDate: nil, studentGroupDto: StudentGroupDto(name: "", facultyAbbrev: "", facultyName: "", specialityName: "", specialityAbbrev: nil, educationDegree: 0), employeeDto: nil, nextSchedules: Schedules(monday: nil, tuesday: nil, wednesday: nil, thursday: nil, friday: nil, saturday: nil, sunday: nil), currentTerm: nil, currentPeriod: nil)
    @Published var scheduleEmployeeFromAppStorage: EachEmployeeResponse = EachEmployeeResponse(startDate: nil, endDate: nil, startExamsDate: nil, endExamsDate: nil, employeeDto: EmployeeDto(id: 0, firstName: "", middleName: "", lastName: "", photoLink: nil, email: nil, urlId: "", calendarId: nil, chief: nil) , schedules: Schedules(monday: nil, tuesday: nil, wednesday: nil, thursday: nil, friday: nil, saturday: nil, sunday: nil), currentPeriod: nil)
    
    func saveFavoriteGroupScheduleToAppStorage(_ data: EachGroupResponse) {
        do {
            try appStorageService.saveFavoriteGroupScheduleToAppStorage(data)
        } catch {
            print(error)
        }
    }
    
    func saveFavoriteEmployeeScheduleToAppStorage(_ data: EachEmployeeResponse) {
        do {
            try appStorageService.saveFavoriteEmployeeScheduleToAppStorage(data)
        } catch {
            print(error)
        }
    }
    
    //func getScheduleGroup(_ group: String) async throws -> EachGroupResponse
    //func getEachEmployeeSchedule(_ urlId: String) async throws -> EachEmployeeResponse

    
    
    func getFavoriteGroupScheduleFromAppStorage() async {
        do {
            scheduleGroupFromAppStorage = try await appStorageService.getScheduleGroup("")
        } catch {
            print("Ошибка получения данных: \(error)")
        }
    }
    
    func getFavoriteEmployeeScheduleFromAppStorage() async {
        do {
            scheduleEmployeeFromAppStorage = try await appStorageService.getEachEmployeeSchedule("")

        } catch {
            print("Ошибка получения данных: \(error)")
        }
    }
}



//func getScheduleGroup(_ group: String) async throws -> EachGroupResponse
//func getEachEmployeeSchedule(_ urlId: String) async throws -> EachEmployeeResponse
