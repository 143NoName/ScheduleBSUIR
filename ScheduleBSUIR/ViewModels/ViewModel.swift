//
//  ViewModel.swift
//  ScheduleBSUIR
//
//  Created by user on 26.10.25.
//

import Foundation
import Combine
import SwiftUI

@MainActor
class ViewModel: ObservableObject {
    
//    let appStorageService: AppStorageService
//    let networkService: NetworkService
//    let funcs: MoreFunctions
//    
//    init(appStorageService: AppStorageService, networkService: NetworkService, funcs: MoreFunctions) {
//        self.appStorageService = appStorageService
//        self.networkService = networkService
//        self.funcs = funcs
//    }
    
    let appStorageService = AppStorageService()
    let networkService = NetworkService()
    let funcs = MoreFunctions()
    
    @Published var currentWeek: Int = 0
    @Published var errorOfCurrentWeek: String = ""
    
    // получение текущей недели от API
    func getCurrentWeek() async {
        do {
            currentWeek = try await networkService.getCurrentWeek()
        } catch {
            withAnimation(.easeIn) {
                errorOfCurrentWeek = error.localizedDescription
            }
            print(error.localizedDescription)
        }
    }
    
    @Published var arrayOfGroupsNum: [ModelNumbersOfGroups] = []
    @Published var isLoadingArrayOfGroupsNum: Bool = false
    @Published var errorOfGroupsNum: String = ""
    
    // получение списка групп от API
    func getArrayOfGroupNum() async {
        arrayOfGroupsNum = []
        do {
            arrayOfGroupsNum = try await networkService.getArrayOfGroupNum()
            withAnimation(.easeIn) {
                isLoadingArrayOfGroupsNum = true
            }
        } catch {
            withAnimation(.easeIn) {
                isLoadingArrayOfGroupsNum = true
                errorOfGroupsNum = error.localizedDescription
            }
            print(error.localizedDescription)
        }
    }
    
    @Published var arrayOfScheduleGroup: ScheduleResponse = ScheduleResponse(
        startDate: "",
        endDate: "",
        startExamsDate: nil,
        endExamsDate: nil,
        employeeDto: nil,
        schedules: Schedules(
            monday: [],
            tuesday: [],
            wednesday: [],
            thursday: [],
            friday: [],
            saturday: [],
            sunday: []
        ),
        currentTerm: "",
        currentPeriod: ""
    )
    @Published var isLoadingArrayOfScheduleGroup: Bool = false
    @Published var errorOfScheduleGroup: String = ""
    
    // получение расписания группы от API
    func getScheduleGroup(group: String) async {
        do {
            arrayOfScheduleGroup = try await networkService.getScheduleGroup(group)
            withAnimation(.easeIn) {
                isLoadingArrayOfScheduleGroup = true
            }
        } catch {
            withAnimation(.easeIn) {
                isLoadingArrayOfScheduleGroup = true
                errorOfScheduleGroup = error.localizedDescription
            }
            print(error.localizedDescription)
        }
    }
    
    @Published var filteredLessons: [(dayName: String, lessons: [Lesson])] = []
    
    
    
    
    
    
    
    
    
// MARK: AppStorageService
    
    func saveDataForWidgetToAppStorage(data: Schedules) {
        do {
            try appStorageService.saveDataForWidgetToAppStorage(data)
        } catch {
            print("Проблема при загрузке данных")
        }
    }
}


extension ViewModel {
    
    var scheduleDays: [(dayName: String, lessons: [Lesson])] {
        
        var days: [(String, [Lesson])] = []
        
        if let monday = arrayOfScheduleGroup.schedules.monday, !monday.isEmpty {
            days.append(("Понедельник", monday))
        }
        if let tuesday = arrayOfScheduleGroup.schedules.tuesday, !tuesday.isEmpty {
            days.append(("Вторник", tuesday))
        }
        if let wednesday = arrayOfScheduleGroup.schedules.wednesday, !wednesday.isEmpty {
            days.append(("Среда", wednesday))
        }
        if let thursday = arrayOfScheduleGroup.schedules.thursday, !thursday.isEmpty {
            days.append(("Четверг", thursday))
        }
        if let friday = arrayOfScheduleGroup.schedules.friday, !friday.isEmpty {
            days.append(("Пятница", friday))
        }
        if let saturday = arrayOfScheduleGroup.schedules.saturday, !saturday.isEmpty {
            days.append(("Суббота", saturday))
        } else {
            days.append(("Суббота", []))
        }
        if let sunday = arrayOfScheduleGroup.schedules.sunday, !sunday.isEmpty {
            days.append(("Воскресенье", sunday))
        } else {
            days.append(("Воскресенье", []))
        }
        
        return days
    }
    
    // фильтрация уроков по подгруппе и по неделе + фильтрация "Консультация", "Экзамен"
    func filterSchedule(currentWeek: WeeksInPicker, subGroup: SubGroupInPicker) {
        let filteredArray = scheduleDays.map { (groupName, lessons) in
            let filteredLessons = lessons.filter { each in
                each.weekNumber.contains(currentWeek.rawValue) &&
                (subGroup.subGroupInNumber == 0 ? each.numSubgroup == 0 || each.numSubgroup == 1 || each.numSubgroup == 2 : each.numSubgroup == subGroup.subGroupInNumber || each.numSubgroup == 0) &&
                !["Консультация", "Экзамен"].contains(each.lessonTypeAbbrev)
            }
            return (groupName, filteredLessons)
        }
        filteredLessons = filteredArray
    }
    
}
