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
    
    // MARK: - Для номера недели
    
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
    
    // MARK: - Для групп
    
    @Published var arrayOfGroupsNum: [StudentGroups] = []
    @Published var isLoadingArrayOfGroupsNum: Bool = false
    @Published var errorOfGroupsNum: String = ""
    
    // получение списка групп от API
    func getArrayOfGroupNum() async {
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
        studentGroupDto: StudentGroupDto(name: "", facultyAbbrev: "", facultyName: "", specialityName: "", specialityAbbrev: "", educationDegree: 0),
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
            convertGroupToScheduleDays() // сразу преобразовать в (День: [Занятия])
            withAnimation(.easeIn) {
                isLoadingArrayOfScheduleGroup = true
            }
        } catch {
            withAnimation(.easeIn) {
                errorOfScheduleGroup = error.localizedDescription
                isLoadingArrayOfScheduleGroup = true
            }
            print(error.localizedDescription)
        }
    }
    
    func scheduleForEachGroupInNull() {
        arrayOfScheduleGroup = ScheduleResponse(
            startDate: "",
            endDate: "",
            startExamsDate: nil,
            endExamsDate: nil,
            studentGroupDto: StudentGroupDto(name: "", facultyAbbrev: "", facultyName: "", specialityName: "", specialityAbbrev: "", educationDegree: 0),
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
    
    @Published var scheduleGroupByDays: [(dayName: String, lessons: [Lesson])] = []
    
    func convertGroupToScheduleDays() { // конвертация в (День: [Занятия])
        let days = [
            ("Понедельник", arrayOfScheduleGroup.schedules.monday),
            ("Вторник", arrayOfScheduleGroup.schedules.tuesday),
            ("Среда", arrayOfScheduleGroup.schedules.wednesday),
            ("Четверг", arrayOfScheduleGroup.schedules.thursday),
            ("Пятница", arrayOfScheduleGroup.schedules.friday),
            ("Суббота", arrayOfScheduleGroup.schedules.saturday),
            ("Воскресенье", arrayOfScheduleGroup.schedules.sunday)
        ]
        
        scheduleGroupByDays = days.compactMap { dayName, optionalLessons in
            guard let lessons = optionalLessons, !lessons.isEmpty else {
                return (dayName, [])
            }
            return (dayName, lessons)
        }
    }
    
    // используется в .onChange при изменении подгруппы и недели
    func filterGroupSchedule(currentWeek: WeeksInPicker, subGroup: SubGroupInPicker) {
        convertGroupToScheduleDays() // для того чтобы перед фильтрацией вернуть все пары, которые были отфильтрованы раньше
        let filteredArray = scheduleGroupByDays.map { (dayName, lessons) in
            let filteredLessons = lessons.filter { lesson in
                lesson.weekNumber.contains(currentWeek.rawValue) &&
                (subGroup.inNumber == 0 ? lesson.numSubgroup == 0 || lesson.numSubgroup == 1 || lesson.numSubgroup == 2 : lesson.numSubgroup == subGroup.inNumber || lesson.numSubgroup == 0) &&
                !["Консультация", "Экзамен"].contains(lesson.lessonTypeAbbrev)
            }
            return (dayName, filteredLessons)
        }
        scheduleGroupByDays = filteredArray
    }
    
    #warning("Разделить на 2 отдельные и сделать или универмальной или отдельно для преподавателей (только для недели)")
    
    
    
    // MARK: - Для преподавателей
    
    #warning("Мне не нравится, что рисписание загружается в один массив, и оттуда все получают данные")
    
    @Published var scheduleForEmployees: [EmployeeModel] = []
    @Published var isLoadingScheduleForEmployees: Bool = false
    @Published var errorOfEmployeesArray: String = ""
    
    // получение списка всех преподавателей
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
    
    // очистка списка преподавателей
    func employeesArrayInNull() {
        scheduleForEmployees = []
        isLoadingScheduleForEmployees = false
        errorOfEmployeesArray = ""
    }
    
    
    @Published var scheduleForEachEmployee: EachEmployeeResponse = EachEmployeeResponse(startDate: "", endDate: "", startExamsDate: "", endExamsDate: "", employeeDto: EmployeeDto(id: 0, firstName: "", middleName: "", lastName: "", photoLink: "", email: "", urlId: "", calendarId: "", chief: false), schedules: Schedules(monday: [], tuesday: [], wednesday: [], thursday: [], friday: [], saturday: [], sunday: []), currentPeriod: "")
    @Published var isLoadingScheduleForEachEmployee: Bool = false
    @Published var errorOfEachEmployee: String = ""
    
    // получение расписания отдельного преподавателя
    func getEachEmployeeSchedule(_ urlId: String) async {
        scheduleForEachEmployeeInNull()
        do {
            scheduleForEachEmployee = try await networkService.getEachEmployeeSchedule(urlId)
            convertToScheduleDaysEmployee()
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
    
    // очистка расписания преподавателей
    func scheduleForEachEmployeeInNull() {
        scheduleForEachEmployee = EachEmployeeResponse(startDate: "", endDate: "", startExamsDate: "", endExamsDate: "", employeeDto: EmployeeDto(id: 0, firstName: "", middleName: "", lastName: "", photoLink: "", email: "", urlId: "", calendarId: "", chief: false), schedules: Schedules(monday: [], tuesday: [], wednesday: [], thursday: [], friday: [], saturday: [], sunday: []), currentPeriod: "")
        isLoadingScheduleForEachEmployee = false
        errorOfEachEmployee = ""
    }
    
    @Published var scheduleEmployeeByDays: [(dayName: String, lessons: [Lesson])] = []
    
    // конвертация в (День: [Занятия])
    func convertToScheduleDaysEmployee() {
        let days = [
            ("Понедельник", scheduleForEachEmployee.schedules.monday),
            ("Вторник", scheduleForEachEmployee.schedules.tuesday),
            ("Среда", scheduleForEachEmployee.schedules.wednesday),
            ("Четверг", scheduleForEachEmployee.schedules.thursday),
            ("Пятница", scheduleForEachEmployee.schedules.friday),
            ("Суббота", scheduleForEachEmployee.schedules.saturday),
            ("Воскресенье", scheduleForEachEmployee.schedules.sunday)
        ]
        
        scheduleEmployeeByDays = days.compactMap { dayName, optionalLessons in
            guard let lessons = optionalLessons, !lessons.isEmpty else {
                return (dayName, [])
            }
            return (dayName, lessons)
        }
    }
    
    func filterByWeekGroupSchedule(currentWeek: WeeksInPicker) {
        convertToScheduleDaysEmployee() // вернуть все перед новой фильтрацией (надо как то выбирать для групп и для преподавателей)
        let filteredArray = scheduleEmployeeByDays.map { (dayName, lessons) in
            let filteredLessons = lessons.filter { lesson in
                lesson.weekNumber.contains(currentWeek.rawValue) &&
                !["Консультация", "Экзамен"].contains(lesson.lessonTypeAbbrev)
            }
            return (dayName, filteredLessons)
        }
        scheduleEmployeeByDays = filteredArray
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


