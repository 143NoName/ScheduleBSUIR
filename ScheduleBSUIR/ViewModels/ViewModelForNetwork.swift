//
//  ViewModel.swift
//  ScheduleBSUIR
//
//  Created by user on 26.10.25.
//

import Combine
import Alamofire
import SwiftUI
import OSLog


// под это протокол пописаны AppStorageServiceForApp и NetworkService (это сервисы, которые используются в viewModel)
// этим протоколом надо заменить сетевой сервис
protocol SourceData {
    func getScheduleGroup(_ group: String) async throws -> EachGroupResponse
    func getEachEmployeeSchedule(_ urlId: String) async throws -> EachEmployeeResponse
}


// MARK: - Для номера недели
protocol NetworkViewModelForWeekProtocol {
    var currentWeek: Int { get }
    var errorOfCurrentWeek: String { get }
    func getCurrentWeek() async
}

//@MainActor // хз пока
class NetworkViewModelForWeek: ObservableObject, NetworkViewModelForWeekProtocol {
    
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }
    let logger = Logger()
    
    @Published private(set) var currentWeek: Int = 0
    @Published private(set) var errorOfCurrentWeek: String = ""
    
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

class NetworkViewModelForListGroups: ObservableObject, NetworkViewModelForListGroupsProtocol {
    
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }
    let logger = Logger()
    
    @Published private(set) var arrayOfGroupsNum: [StudentGroups] = []
    @Published private(set) var isLoadingArrayOfGroupsNum: Bool = false
    @Published private(set) var errorOfGroupsNum: String = ""
    
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

class NetworkViewModelForScheduleGroups: ObservableObject, NetworkViewModelForScheduleGroupsProtocol {
    
//    private let networkService: NetworkServiceProtocol
    
    private let sourceData: SourceData // сервис получения расписания (по умолчанию NetworkService, но может быть и AppStorageServiceForApp)
    
    init(
//        networkService: NetworkServiceProtocol = NetworkService(),
        sourceData: SourceData = NetworkService()) {
//        self.networkService = networkService
        self.sourceData = sourceData
    }
    let logger = Logger()
    
    @Published private(set) var arrayOfScheduleGroup: EachGroupResponse = EachGroupResponse(
        startDate: "",
        endDate: "",
        startExamsDate: nil,
        endExamsDate: nil,
        studentGroupDto: StudentGroupDto(name: "", facultyAbbrev: "", facultyName: "", specialityName: "", specialityAbbrev: "", educationDegree: 0),
        employeeDto: nil,
        nextSchedules: Schedules(
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
    @Published private(set) var isLoadingArrayOfScheduleGroup: Bool = false
    @Published private(set) var errorOfScheduleGroup: String = ""
    
    // получение расписания группы от API
    func getScheduleGroup(group: String) async {
        do {
            arrayOfScheduleGroup = try await sourceData.getScheduleGroup(group)
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
    
    func scheduleForEachGroupInNull() {
        arrayOfScheduleGroup = EachGroupResponse(
            startDate: "",
            endDate: "",
            startExamsDate: nil,
            endExamsDate: nil,
            studentGroupDto: StudentGroupDto(name: "", facultyAbbrev: "", facultyName: "", specialityName: "", specialityAbbrev: "", educationDegree: 0),
            employeeDto: nil,
            nextSchedules: Schedules(
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
    
    @Published private(set) var scheduleGroupByDays: [(dayName: String, lessons: [Lesson])] = []
    
    func convertToScheduleDaysGroup() { // конвертация в (День: [Занятия])
        let days = [
            ("Понедельник", arrayOfScheduleGroup.nextSchedules.monday),
            ("Вторник", arrayOfScheduleGroup.nextSchedules.tuesday),
            ("Среда", arrayOfScheduleGroup.nextSchedules.wednesday),
            ("Четверг", arrayOfScheduleGroup.nextSchedules.thursday),
            ("Пятница", arrayOfScheduleGroup.nextSchedules.friday),
            ("Суббота", arrayOfScheduleGroup.nextSchedules.saturday),
            ("Воскресенье", arrayOfScheduleGroup.nextSchedules.sunday)
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

//@MainActor // хз пока
class NetworkViewModelForListEmployees: ObservableObject, NetworkViewModelForListEmployeesProtocol {
    
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }
    let logger = Logger()
    
    @Published private(set) var scheduleForEmployees: [EmployeeModel] = []
    @Published private(set) var isLoadingScheduleForEmployees: Bool = false
    @Published private(set) var errorOfEmployeesArray: String = ""
    
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

class NetworkViewModelForScheduleEmployees: ObservableObject, NetworkViewModelForScheduleEmployeesProtocol {
    
//    private let networkService: NetworkServiceProtocol
    private let sourceData: SourceData
    
    init(
//        networkService: NetworkServiceProtocol = NetworkService()
        sourceData: SourceData = NetworkService()
    ) {
//        self.networkService = networkService
        self.sourceData = sourceData
    }
    let logger = Logger()
    
    @Published private(set) var scheduleForEachEmployee: EachEmployeeResponse = EachEmployeeResponse(startDate: "", endDate: "", startExamsDate: "", endExamsDate: "", employeeDto: EmployeeDto(id: 0, firstName: "", middleName: "", lastName: "", photoLink: "", email: "", urlId: "", calendarId: "", chief: false), schedules: Schedules(monday: [], tuesday: [], wednesday: [], thursday: [], friday: [], saturday: [], sunday: []), currentPeriod: "")
    @Published private(set) var isLoadingScheduleForEachEmployee: Bool = false
    @Published private(set) var errorOfEachEmployee: String = ""
    
    // получение расписания отдельного преподавателя
    func getEachEmployeeSchedule(_ urlId: String) async {
        scheduleForEachEmployeeInNull()
        do {
            scheduleForEachEmployee = try await sourceData.getEachEmployeeSchedule(urlId)
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
    
    // очистка расписания преподавателя
    func scheduleForEachEmployeeInNull() {
        scheduleForEachEmployee = EachEmployeeResponse(startDate: "", endDate: "", startExamsDate: "", endExamsDate: "", employeeDto: EmployeeDto(id: 0, firstName: "", middleName: "", lastName: "", photoLink: "", email: "", urlId: "", calendarId: "", chief: false), schedules: Schedules(monday: [], tuesday: [], wednesday: [], thursday: [], friday: [], saturday: [], sunday: []), currentPeriod: "")
        isLoadingScheduleForEachEmployee = false
        errorOfEachEmployee = ""
    }
    
    @Published private(set) var scheduleEmployeeByDays: [(dayName: String, lessons: [Lesson])] = []
    
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


// новые

#warning("Изменить названия функций")

//struct NetworkViewModelForGetScheduleGroup {
//    
//    private let networkService: NetworkServiceProtocol                  // тогда это не нужно
//    
//    private let sourceData: SourceData                                  // тут будет нужный сервис для получения расписания
//    
//    init(networkService: NetworkServiceProtocol = NetworkService(), sourceData: SourceData = NetworkService()) {
//        self.networkService = networkService
//        self.sourceData = sourceData
//    }
//    let logger = Logger()
//    
//    func getListGroups() async -> [StudentGroups]? {
//        do {
//            let data = try await networkService.getArrayOfGroupNum()
//            return data
//        } catch {
//            logger.error("\(error.localizedDescription)")
//            return nil
//        }
//    }
//    
//    func getSchedule(_ groupName: String) async -> EachGroupResponse? {
//        do {
//            let data = try await networkService.getScheduleGroup(groupName)
//            return data
//        } catch {
//            logger.error("\(error.localizedDescription)")
//            return nil
//        }
//    }
//}












//class ViewModelForNetwork: ObservableObject {
//    
//    private let saveForWidget: AppStorageServiceProtocol
//    private let networkService: NetworkServiceProtocol
//    
//    init(saveForWidget: AppStorageServiceProtocol = SaveForWidgetService(), networkService: NetworkServiceProtocol = NetworkService()) {
//        self.saveForWidget = saveForWidget
//        self.networkService = networkService
//    }
//        
//    // MARK: - Для номера недели
//    
//    @Published var currentWeek: Int = 0
//    @Published var errorOfCurrentWeek: String = ""
//    
//    // получение текущей недели от API
//    func getCurrentWeek() async {
//        do {
//            currentWeek = try await networkService.getCurrentWeek()
//        } catch {
//            withAnimation(.easeIn) {
//                errorOfCurrentWeek = error.localizedDescription
//            }
//            print(error.localizedDescription)
//        }
//    }
//    
//    // MARK: - Для групп
//    
//    @Published var arrayOfGroupsNum: [StudentGroups] = []
//    @Published var isLoadingArrayOfGroupsNum: Bool = false
//    @Published var errorOfGroupsNum: String = ""
//    
//    // получение списка групп от API
//    func getArrayOfGroupNum() async {
//        do {
//            arrayOfGroupsNum = try await networkService.getArrayOfGroupNum()
//            withAnimation(.easeIn) {
//                isLoadingArrayOfGroupsNum = true
//            }
//        } catch {
//            withAnimation(.easeIn) {
//                isLoadingArrayOfGroupsNum = true
//                errorOfGroupsNum = error.localizedDescription
//            }
//            print(error.localizedDescription)
//        }
//    }
//    
//    func groupArrayInNull() {
//        arrayOfGroupsNum = []
//        isLoadingArrayOfGroupsNum = false
//        errorOfGroupsNum = ""
//    }
//    
//    @Published var arrayOfScheduleGroup: EachGroupResponse = EachGroupResponse(
//        startDate: "",
//        endDate: "",
//        startExamsDate: nil,
//        endExamsDate: nil,
//        studentGroupDto: StudentGroupDto(name: "", facultyAbbrev: "", facultyName: "", specialityName: "", specialityAbbrev: "", educationDegree: 0),
//        employeeDto: nil,
//        nextSchedules: Schedules(
//            monday: [],
//            tuesday: [],
//            wednesday: [],
//            thursday: [],
//            friday: [],
//            saturday: [],
//            sunday: []
//        ),
//        currentTerm: "",
//        currentPeriod: ""
//    )
//    @Published var isLoadingArrayOfScheduleGroup: Bool = false
//    @Published var errorOfScheduleGroup: String = ""
//    
//    // получение расписания группы от API
//    func getScheduleGroup(group: String) async {
//        do {
//            arrayOfScheduleGroup = try await networkService.getScheduleGroup(group)
//            convertToScheduleDaysGroup() // сразу преобразовать в (День: [Занятия])
//            withAnimation(.easeIn) {
//                isLoadingArrayOfScheduleGroup = true
//            }
//        } catch {
//            withAnimation(.easeIn) {
//                errorOfScheduleGroup = error.localizedDescription
//                isLoadingArrayOfScheduleGroup = true
//            }
//            print(error.localizedDescription)
//        }
//    }
//    
//    func scheduleForEachGroupInNull() {
//        arrayOfScheduleGroup = EachGroupResponse(
//            startDate: "",
//            endDate: "",
//            startExamsDate: nil,
//            endExamsDate: nil,
//            studentGroupDto: StudentGroupDto(name: "", facultyAbbrev: "", facultyName: "", specialityName: "", specialityAbbrev: "", educationDegree: 0),
//            employeeDto: nil,
//            nextSchedules: Schedules(
//                monday: [],
//                tuesday: [],
//                wednesday: [],
//                thursday: [],
//                friday: [],
//                saturday: [],
//                sunday: []
//            ),
//            currentTerm: "",
//            currentPeriod: ""
//        )
//        isLoadingArrayOfScheduleGroup = false
//        errorOfScheduleGroup = ""
//    }
//    
//    @Published var scheduleGroupByDays: [(dayName: String, lessons: [Lesson])] = []
//    
//    func convertToScheduleDaysGroup() { // конвертация в (День: [Занятия])
//        let days = [
//            ("Понедельник", arrayOfScheduleGroup.nextSchedules.monday),
//            ("Вторник", arrayOfScheduleGroup.nextSchedules.tuesday),
//            ("Среда", arrayOfScheduleGroup.nextSchedules.wednesday),
//            ("Четверг", arrayOfScheduleGroup.nextSchedules.thursday),
//            ("Пятница", arrayOfScheduleGroup.nextSchedules.friday),
//            ("Суббота", arrayOfScheduleGroup.nextSchedules.saturday),
//            ("Воскресенье", arrayOfScheduleGroup.nextSchedules.sunday)
//        ]
//        
//        scheduleGroupByDays = days.compactMap { dayName, optionalLessons in
//            guard let lessons = optionalLessons, !lessons.isEmpty else {
//                return (dayName, [])
//            }
//            return (dayName, lessons)
//        }
//    }
//    
//    // используется в .onChange при изменении подгруппы и недели
//    func filterGroupSchedule(currentWeek: WeeksInPicker, subGroup: SubGroupInPicker) {
//        convertToScheduleDaysGroup() // для того чтобы перед фильтрацией вернуть все пары, которые были отфильтрованы раньше
//        let filteredArray = scheduleGroupByDays.map { (dayName, lessons) in
//            let filteredLessons = lessons.filter { lesson in
//                lesson.weekNumber.contains(currentWeek.rawValue) &&
//                (subGroup.inNumber == 0 ? lesson.numSubgroup == 0 || lesson.numSubgroup == 1 || lesson.numSubgroup == 2 : lesson.numSubgroup == subGroup.inNumber || lesson.numSubgroup == 0) &&
//                !["Консультация", "Экзамен"].contains(lesson.lessonTypeAbbrev)
//            }
//            return (dayName, filteredLessons)
//        }
//        scheduleGroupByDays = filteredArray
//    }
//    
//    
//    
//    // MARK: - Для преподавателей
//    
//    #warning("Мне не нравится, что рисписание загружается в один массив, и оттуда все получают данные")
//    
//    @Published var scheduleForEmployees: [EmployeeModel] = []
//    @Published var isLoadingScheduleForEmployees: Bool = false
//    @Published var errorOfEmployeesArray: String = ""
//    
//    // получение списка всех преподавателей
//    func getArrayOfEmployees() async {
//        do {
//            scheduleForEmployees = try await networkService.getArrayOfEmployees()
//            withAnimation(.easeIn) {
//                isLoadingScheduleForEmployees = true
//            }
//        } catch {
//            withAnimation(.easeIn) {
//                errorOfEmployeesArray = error.localizedDescription
//                isLoadingScheduleForEmployees = true
//            }
//            print("Проблема с получением списка преподавателей: \(error.localizedDescription)")
//        }
//    }
//    
//    // очистка списка преподавателей
//    func employeesArrayInNull() {
//        scheduleForEmployees = []
//        isLoadingScheduleForEmployees = false
//        errorOfEmployeesArray = ""
//    }
//    
//    @Published var scheduleForEachEmployee: EachEmployeeResponse = EachEmployeeResponse(startDate: "", endDate: "", startExamsDate: "", endExamsDate: "", employeeDto: EmployeeDto(id: 0, firstName: "", middleName: "", lastName: "", photoLink: "", email: "", urlId: "", calendarId: "", chief: false), schedules: Schedules(monday: [], tuesday: [], wednesday: [], thursday: [], friday: [], saturday: [], sunday: []), currentPeriod: "")
//    @Published var isLoadingScheduleForEachEmployee: Bool = false
//    @Published var errorOfEachEmployee: String = ""
//    
//    // получение расписания отдельного преподавателя
//    func getEachEmployeeSchedule(_ urlId: String) async {
//        scheduleForEachEmployeeInNull()
//        do {
//            scheduleForEachEmployee = try await networkService.getEachEmployeeSchedule(urlId)
//            convertToScheduleDaysEmployee()
//            withAnimation(.easeIn) {
//                isLoadingScheduleForEachEmployee = true
//            }
//        } catch {
//            withAnimation(.easeIn) {
//                errorOfEachEmployee = error.localizedDescription
//                isLoadingScheduleForEachEmployee = true
//            }
//            print("Проблема с получением расписания преподавателя: \(error.localizedDescription)")
//        }
//    }
//    
//    // очистка расписания преподавателя
//    func scheduleForEachEmployeeInNull() {
//        scheduleForEachEmployee = EachEmployeeResponse(startDate: "", endDate: "", startExamsDate: "", endExamsDate: "", employeeDto: EmployeeDto(id: 0, firstName: "", middleName: "", lastName: "", photoLink: "", email: "", urlId: "", calendarId: "", chief: false), schedules: Schedules(monday: [], tuesday: [], wednesday: [], thursday: [], friday: [], saturday: [], sunday: []), currentPeriod: "")
//        isLoadingScheduleForEachEmployee = false
//        errorOfEachEmployee = ""
//    }
//    
//    @Published var scheduleEmployeeByDays: [(dayName: String, lessons: [Lesson])] = []
//    
//    // конвертация в (День: [Занятия])
//    func convertToScheduleDaysEmployee() {
//        let days = [
//            ("Понедельник", scheduleForEachEmployee.schedules.monday),
//            ("Вторник", scheduleForEachEmployee.schedules.tuesday),
//            ("Среда", scheduleForEachEmployee.schedules.wednesday),
//            ("Четверг", scheduleForEachEmployee.schedules.thursday),
//            ("Пятница", scheduleForEachEmployee.schedules.friday),
//            ("Суббота", scheduleForEachEmployee.schedules.saturday),
//            ("Воскресенье", scheduleForEachEmployee.schedules.sunday)
//        ]
//        
//        scheduleEmployeeByDays = days.compactMap { dayName, optionalLessons in
//            guard let lessons = optionalLessons, !lessons.isEmpty else {
//                return (dayName, [])
//            }
//            return (dayName, lessons)
//        }
//    }
//    
//    // фильтрация по неделе (при выборе недели)
//    func filterByWeekEmployeeSchedule(currentWeek: WeeksInPicker) {
//        convertToScheduleDaysEmployee() // вернуть все перед новой фильтрацией (надо как то выбирать для групп и для преподавателей)
//        let filteredArray = scheduleEmployeeByDays.map { (dayName, lessons) in
//            let filteredLessons = lessons.filter { lesson in
//                lesson.weekNumber.contains(currentWeek.rawValue) &&
//                !["Консультация", "Экзамен"].contains(lesson.lessonTypeAbbrev)
//            }
//            return (dayName, filteredLessons)
//        }
//        scheduleEmployeeByDays = filteredArray
//    }
//}
