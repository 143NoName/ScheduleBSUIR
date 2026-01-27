//
//  ViewModel.swift
//  ScheduleBSUIR
//
//  Created by user on 26.10.25.
//

import SwiftUI
import Combine
import Alamofire
import OSLog


//// под это протокол пописаны AppStorageServiceForApp и NetworkService (это сервисы, которые используются в viewModel)
//// этим протоколом надо заменить сетевой сервис
//protocol SourceData {
//    func getScheduleGroup(_ group: String) async throws -> EachGroupResponse
//    func getEachEmployeeSchedule(_ urlId: String) async throws -> EachEmployeeResponse
//}




// MARK: - Для номера недели
protocol NetworkViewModelForWeekProtocol {
    var currentWeek: Int { get }
    var errorOfCurrentWeek: String { get }
    func getCurrentWeek() async
}


@Observable class NetworkViewModelForWeek: NetworkViewModelForWeekProtocol {
    
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }
    let logger = Logger()
    
    private(set) var currentWeek: Int = 0
    private(set) var errorOfCurrentWeek: String = ""
    
    // получение текущей недели от API
    func getCurrentWeek() async {
        do {
            currentWeek = try await networkService.getCurrentWeek()
        } catch {
            errorOfCurrentWeek = error.localizedDescription
            logger.error("Ошибка получения номера недели: \(error.localizedDescription)")
        }
    }
}



// MARK: - Списки групп
protocol NetworkViewModelForListGroupsProtocol {
    var arrayOfGroupsNum: [StudentGroups] { get }                                           // список всех групп
    var isLoadingArrayOfGroupsNum: Bool { get }                                             // загурзка списка групп
    var errorOfGroupsNum: String { get }                                                    // ошибка загрузки списка групп
    func getArrayOfGroupNum() async                                                         // получение списка всех групп
    func groupArrayInNull()                                                                 // очистка списка групп
}


@Observable class NetworkViewModelForListGroups: NetworkViewModelForListGroupsProtocol {
    
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }
    let logger = Logger()
    
    private(set) var arrayOfGroupsNum: [StudentGroups] = []
    private(set) var isLoadingArrayOfGroupsNum: Bool = false
    private(set) var errorOfGroupsNum: String = ""
    
    // получение списка групп от API
    func getArrayOfGroupNum() async {
        do {
            arrayOfGroupsNum = try await networkService.getArrayOfGroupNum()
            isLoadingArrayOfGroupsNum = true
        } catch {
            isLoadingArrayOfGroupsNum = true
            errorOfGroupsNum = error.localizedDescription
            logger.error("Ошибка получения списка групп: \(error.localizedDescription)")
        }
    }
    
    func groupArrayInNull() {
        arrayOfGroupsNum = []
        isLoadingArrayOfGroupsNum = false
        errorOfGroupsNum = ""
    }
}

// MARK: - Расписание группы
protocol NetworkViewModelForScheduleGroupsProtocol {
    var arrayOfScheduleGroup: EachGroupResponse { get }                                     // расписание отдельной группы
    var isLoadingArrayOfScheduleGroup: Bool { get }                                         // загрузка расписания группы
    var errorOfScheduleGroup: String { get }                                                // ошибка расписания группы
    func getScheduleGroup(group: String) async                                              // функция получения расписания группы
    func scheduleForEachGroupInNull()                                                       // функция очистки расписания группы
    var scheduleGroupByDays: [(dayName: String, lessons: [Lesson])] { get }                 // удобный вид для расписания
    func convertToScheduleDaysGroup()                                                       // преобразование в удобный вид
    func filterGroupSchedule(currentWeek: WeeksInPicker, subGroup: SubGroupInPicker)        // функция фильтрации расписания группы по неделе и подгруппы
}


@Observable class NetworkViewModelForScheduleGroups: NetworkViewModelForScheduleGroupsProtocol {
    
    let networkService: NetworkServiceProtocol
    let filterService: FilterServiceProtocol
    
    init(
        networkService: NetworkServiceProtocol = NetworkService(),
        filterService: FilterServiceProtocol = FilterService()
    ) {
        self.networkService = networkService
        self.filterService = filterService
    }
    
    let logger = Logger()
    
    private(set) var arrayOfScheduleGroup: EachGroupResponse = EachGroupResponse(               // весь ответ от сервера (можно поделить на мелкие данные (типо начало, окнец уроков и тд))
        startDate: "",
        endDate: "",
        startExamsDate: nil,
        endExamsDate: nil,
        studentGroupDto:
            StudentGroupDto(name: "",
                            facultyAbbrev: "",
                            facultyName: "",
                            specialityName: "",
                            specialityAbbrev: "",
                            educationDegree: 0
                           ),
        employeeDto: nil,
        schedules:
            Schedules(monday: [],
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
    private(set) var isLoadingArrayOfScheduleGroup: Bool = false                                // статус загрузки ответа от сервера
    private(set) var errorOfScheduleGroup: String = ""                                          // ошибка (если есть) ответа от сервера
    
    // получение расписания группы от API
    func getScheduleGroup(group: String) async {
        do {
            arrayOfScheduleGroup = try await networkService.getScheduleGroup(group)
            convertToScheduleDaysGroup() // сразу преобразовать в (День: [Занятия])
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
    
    #warning("Новая функция, которая просто получает и возвращает расписание группы")
    func getScheduleGroupForWidget(group: String) async -> [FormatedSchedules] {
        do {
            let data = try await networkService.getScheduleGroup(group)
            return data.schedules.getFormatedSchedules()
        } catch {
            print(error.localizedDescription)
            return []
        }
    }
    
    func scheduleForEachGroupInNull() {
        arrayOfScheduleGroup = EachGroupResponse(
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
    
    private(set) var scheduleGroupByDays: [(dayName: String, lessons: [Lesson])] = []
    
    func convertToScheduleDaysGroup() { // конвертация в (День: [Занятия])
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
    
    func filterGroupSchedule(currentWeek: WeeksInPicker, subGroup: SubGroupInPicker) {
        convertToScheduleDaysGroup() // для того чтобы перед фильтрацией вернуть все пары, которые были отфильтрованы раньше
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
}



// MARK: - Список преподавателей
protocol NetworkViewModelForListEmployeesProtocol {
    var scheduleForEmployees: [EmployeeModel] { get }                                       // список всех преподавателей
    var isLoadingScheduleForEmployees: Bool { get }                                         // загурзка списка преподавателей
    var errorOfEmployeesArray: String { get }                                               // ошибка загрузки списка преподавателей
    func getArrayOfEmployees() async                                                        // получение списка преподавателей
    func employeesArrayInNull()                                                             // очистка списка преподавателей
}

@Observable class NetworkViewModelForListEmployees: NetworkViewModelForListEmployeesProtocol {
    
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }
    
    let logger = Logger()
    
    private(set) var scheduleForEmployees: [EmployeeModel] = []
    private(set) var isLoadingScheduleForEmployees: Bool = false
    private(set) var errorOfEmployeesArray: String = ""
    
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
}

// MARK: - Расписание преподавателя
protocol NetworkViewModelForScheduleEmployeesProtocol {
    var scheduleForEachEmployee: EachEmployeeResponse { get }                               // расписание отдельного преподавателя
    var isLoadingScheduleForEachEmployee: Bool { get }                                      // загрузка расписания преподавателя
    var errorOfEachEmployee: String { get }                                                 // ошибка расписания преподавателя
    func getEachEmployeeSchedule(_ urlId: String) async                                     // функция получения расписания преподавателя
    func scheduleForEachEmployeeInNull()                                                    // функция очистки расписания преподавателя
    var scheduleEmployeeByDays: [(dayName: String, lessons: [Lesson])]  { get }             // удобный вид для расписания
    func convertToScheduleDaysEmployee()                                                    // преобразование в удобный вид
    func filterByWeekEmployeeSchedule(currentWeek: WeeksInPicker)                           // функция фильтрации расписания преподавателя по неделе
}


@Observable class NetworkViewModelForScheduleEmployees: NetworkViewModelForScheduleEmployeesProtocol {
    
    let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }
    
    let logger = Logger()
    
    private(set) var scheduleForEachEmployee: EachEmployeeResponse = EachEmployeeResponse(startDate: "", endDate: "", startExamsDate: "", endExamsDate: "", employeeDto: EmployeeDto(id: 0, firstName: "", middleName: "", lastName: "", photoLink: "", email: "", urlId: "", calendarId: "", chief: false), schedules: Schedules(monday: [], tuesday: [], wednesday: [], thursday: [], friday: [], saturday: [], sunday: []), currentPeriod: "")
    private(set) var scheduleOfEmployee: [FormatedSchedules] = []
    private(set) var isLoadingScheduleForEachEmployee: Bool = false
    private(set) var errorOfEachEmployee: String = ""
    
    // получение расписания отдельного преподавателя
    func getEachEmployeeSchedule(_ urlId: String) async {
        scheduleForEachEmployeeInNull()
        do {
            scheduleForEachEmployee = try await networkService.getEachEmployeeSchedule(urlId)
            
            convertToScheduleDaysEmployee() // сразу преобразовать в (День: [Занятия])
            
            scheduleOfEmployee = scheduleForEachEmployee.schedules.getFormatedSchedules() // записать в массив расписания
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
    
    // очистка расписания преподавателя
    func scheduleForEachEmployeeInNull() {
        scheduleForEachEmployee = EachEmployeeResponse(startDate: "", endDate: "", startExamsDate: "", endExamsDate: "", employeeDto: EmployeeDto(id: 0, firstName: "", middleName: "", lastName: "", photoLink: "", email: "", urlId: "", calendarId: "", chief: false), schedules: Schedules(monday: [], tuesday: [], wednesday: [], thursday: [], friday: [], saturday: [], sunday: []), currentPeriod: "")
        isLoadingScheduleForEachEmployee = false
        errorOfEachEmployee = ""
    }
    
    private(set) var scheduleEmployeeByDays: [(dayName: String, lessons: [Lesson])] = []
    
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
    
    // фильтрация по неделе (при выборе недели)
    func filterByWeekEmployeeSchedule(currentWeek: WeeksInPicker) {
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
