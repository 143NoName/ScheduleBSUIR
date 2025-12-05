//
//  ViewModel.swift
//  ScheduleBSUIR
//
//  Created by user on 26.10.25.
//

import Foundation
import Combine
import SwiftUI

class ViewModelForNetwork: ObservableObject {
    
    private let appStorageService: AppStorageServiceProtocol
    private let networkService: NetworkServiceProtocol
//    private let filterSchedule: FilterServiceProtocol
    
    init(
        networkService: NetworkServiceProtocol = NetworkService(),
        appStorageService: AppStorageServiceProtocol = AppStorageService(),
//        filterSchedule: FilterServiceProtocol = FilterService()
    ) {
        self.networkService = networkService
        self.appStorageService = appStorageService
//        self.filterSchedule = filterSchedule
    }
    
    private let funcs = MoreFunctions()
    
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
    
    @Published var arrayOfGroupsNum: [StudentGroups] = []
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
//            convertToScheduleDays()
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
    
    func allInNull() {
        arrayOfScheduleGroup = ScheduleResponse(
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
        isLoadingArrayOfScheduleGroup = false
        errorOfScheduleGroup = ""
    }
    
    @Published var scheduleByDays: [(dayName: String, lessons: [Lesson])] = []
    
    func convertToScheduleDays() { // конвертация в (День: [Занятия])
        let days = [
            ("Понедельник", arrayOfScheduleGroup.schedules.monday),
            ("Вторник", arrayOfScheduleGroup.schedules.tuesday),
            ("Среда", arrayOfScheduleGroup.schedules.wednesday),
            ("Четверг", arrayOfScheduleGroup.schedules.thursday),
            ("Пятница", arrayOfScheduleGroup.schedules.friday),
            ("Суббота", arrayOfScheduleGroup.schedules.saturday),
            ("Воскресенье", arrayOfScheduleGroup.schedules.sunday)
        ]
        
        scheduleByDays = days.compactMap { dayName, optionalLessons in
            guard let lessons = optionalLessons, !lessons.isEmpty else {
                return (dayName, [])
            }
            return (dayName, lessons)
        }
    }
    
    func filterSchedule(currentWeek: WeeksInPicker, subGroup: SubGroupInPicker) {
        convertToScheduleDays()
        let filteredArray = scheduleByDays.map { (dayName, lessons) in
            let filteredLessons = lessons.filter { lesson in
                lesson.weekNumber.contains(currentWeek.rawValue) &&
                (subGroup.subGroupInNumber == 0 ? lesson.numSubgroup == 0 || lesson.numSubgroup == 1 || lesson.numSubgroup == 2 : lesson.numSubgroup == subGroup.subGroupInNumber || lesson.numSubgroup == 0) &&
                !["Консультация", "Экзамен"].contains(lesson.lessonTypeAbbrev)
            }
            return (dayName, filteredLessons)
        }
        scheduleByDays = filteredArray
    }
    // она один раз отфильтровала и а потом не вернула отфильтрованнные уроки
}





//extension ViewModelForNetwork {
//    
//    var scheduleDays: [(dayName: String, lessons: [Lesson])] {
//        let days = [
//            ("Понедельник", arrayOfScheduleGroup.schedules.monday),
//            ("Вторник", arrayOfScheduleGroup.schedules.tuesday),
//            ("Среда", arrayOfScheduleGroup.schedules.wednesday),
//            ("Четверг", arrayOfScheduleGroup.schedules.thursday),
//            ("Пятница", arrayOfScheduleGroup.schedules.friday),
//            ("Суббота", arrayOfScheduleGroup.schedules.saturday),
//            ("Воскресенье", arrayOfScheduleGroup.schedules.sunday)
//        ]
//        
//        return days.compactMap { dayName, optionalLessons in
//            guard let lessons = optionalLessons, !lessons.isEmpty else {
//                return (dayName, [])
//            }
//            return (dayName, lessons)
//        }
//    }
//    
//    // фильтрация уроков по подгруппе и по неделе + фильтрация "Консультация", "Экзамен"
//    
//    func filterSchedule2(currentWeek: WeeksInPicker, subGroup: SubGroupInPicker) {
//        let filteredArray = scheduleDays.map { (groupName, lessons) in
//            let filteredLessons = lessons.filter { each in
//                each.weekNumber.contains(currentWeek.rawValue) &&
//                (subGroup.subGroupInNumber == 0 ? each.numSubgroup == 0 || each.numSubgroup == 1 || each.numSubgroup == 2 : each.numSubgroup == subGroup.subGroupInNumber || each.numSubgroup == 0) &&
//                !["Консультация", "Экзамен"].contains(each.lessonTypeAbbrev)
//            }
//            return (groupName, filteredLessons)
//        }
//        filteredLessons = filteredArray
//    }
//    
//}
