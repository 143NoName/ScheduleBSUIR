//
//  ForScheduleEmployees.swift
//  ScheduleBSUIR
//
//  Created by andrew on 27.01.26.
//

import SwiftUI
import OSLog

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
            logger.error("Ошибка получения расписания преподавателя: \(error.localizedDescription)")
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
