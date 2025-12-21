//
//  ViewModel.swift
//  ScheduleBSUIR
//
//  Created by user on 26.10.25.
//

import Foundation
import Combine
import Alamofire
import SwiftUI

class ViewModelForNetwork: ObservableObject {
    
    private let appStorageService: AppStorageServiceProtocol
    private let networkService: NetworkServiceProtocol
    
    init(appStorageService: AppStorageServiceProtocol = AppStorageService(), networkService: NetworkServiceProtocol = NetworkService()) {
        self.appStorageService = appStorageService
        self.networkService = networkService
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
//        groupArrayInNull()
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
    
    func groupArrayInNull() {
        arrayOfGroupsNum = []
        isLoadingArrayOfGroupsNum = false
        errorOfGroupsNum = ""
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
            convertToScheduleDays() // сразу преобразовать в (День: [Занятия])
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
    
    // используется в .onChange при изменении подгруппы и недели
    func filterSchedule(currentWeek: WeeksInPicker, subGroup: SubGroupInPicker) {
        convertToScheduleDays() // для того чтобы перед фильтрацией вернуть все пары, которые были отфильтрованы раньше
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
    
    
    
    // для преподавателей
    
    
    
    @Published var scheduleForEmployees: [EmployeeModel] = []
    @Published var isLoadingScheduleForEmployees: Bool = false
    @Published var errorOfEmployeesArray: String = ""
    
    func getArrayOfEmployees() async {
        do {
            scheduleForEmployees = try await networkService.getArrayOfEmployees()
            withAnimation(.easeIn) {
                isLoadingScheduleForEmployees = true
            }
        } catch {
            withAnimation(.easeIn) {
                errorOfEmployeesArray = error.localizedDescription
                isLoadingScheduleForEmployees = true
            }
            print("Проблема с получением списка преподавателей: \(error.localizedDescription)")
        }
    }
    
    func scheduleForEmployeesInNull() {
        scheduleForEmployees = []
        isLoadingScheduleForEmployees = false
        errorOfEmployeesArray = ""
    }
    
    
    @Published var scheduleForEachEmployee: EachEmployeeResponse = EachEmployeeResponse(startDate: "", endDate: "", startExamsDate: "", endExamsDate: "", employeeDto: EmployeeDto(id: 0, firstName: "", middleName: "", lastName: "", photoLink: "", email: "", urlId: "", calendarId: "", chief: false), schedules: Schedules(monday: [], tuesday: [], wednesday: [], thursday: [], friday: [], saturday: [], sunday: []), currentPeriod: "")
    @Published var isLoadingScheduleForEachEmployee: Bool = false
    @Published var errorOfEachEmployee: String = ""
    
    func getEachEmployeeSchedule(_ urlId: String) async {
        do {
            scheduleForEachEmployee = try await networkService.getEachEmployeeSchedule(urlId)
            withAnimation(.easeIn) {
                isLoadingScheduleForEachEmployee = true
            }
        } catch {
            withAnimation(.easeIn) {
                errorOfEachEmployee = error.localizedDescription
                isLoadingScheduleForEachEmployee = true
            }
            print("Проблема с получением расписания преподавателя: \(error.localizedDescription)")
        }
    }
    
    @Published var scheduleByDays2: [(dayName: String, lessons: [Lesson])] = []
    
    func convertToScheduleDays2(_ schedule: EachEmployeeResponse) { // конвертация в (День: [Занятия])
        let days = [
            ("Понедельник", schedule.schedules.monday),
            ("Вторник", schedule.schedules.tuesday),
            ("Среда", schedule.schedules.wednesday),
            ("Четверг", schedule.schedules.thursday),
            ("Пятница", schedule.schedules.friday),
            ("Суббота", schedule.schedules.saturday),
            ("Воскресенье", schedule.schedules.sunday)
        ]
        
        scheduleByDays2 = days.compactMap { dayName, optionalLessons in
            guard let lessons = optionalLessons, !lessons.isEmpty else {
                return (dayName, [])
            }
            return (dayName, lessons)
        }
    }
}



//    private func mapAFError(_ aferror: AFError?, urlerror: URLError?) -> String {
////        if let aferror {
////            switch aferror {
////
////            }
////        }
//
//        if let urlerror {
//            switch urlerror {
//            case .notConnectedToInternet:
//                return "Нет подключения к интернету"
//            case .badServerResponse:
//                return "Неверный ответ сервера"
//            case .cancelled:
//                return "Задача отменена"
//            case .badURL:
//                return "Неверно указана ссылка"
//            }
//        }
//    }



//extension URLError {
//    var userDescriptions: String {
//        switch self {
//        case .notConnectedToInternet:
//            return "Нет подключения к интернету"
//        }
//    }
//}

