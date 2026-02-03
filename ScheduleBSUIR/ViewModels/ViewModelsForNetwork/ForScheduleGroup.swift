//
//  ForScheduleGroup.swift
//  ScheduleBSUIR
//
//  Created by andrew on 27.01.26.
//

import SwiftUI
import OSLog

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
    
    private(set) var arrayOfScheduleGroup: EachGroupResponse = EachGroupResponse(startDate: "", endDate: "", startExamsDate: nil, endExamsDate: nil, studentGroupDto: StudentGroupDto(name: "", facultyAbbrev: "", facultyName: "", specialityName: "", specialityAbbrev: "", educationDegree: 0 ), employeeDto: nil, schedules: Schedules(monday: [], tuesday: [], wednesday: [], thursday: [], friday: [], saturday: [], sunday: []), currentTerm: "", currentPeriod: "")
    private(set) var isLoadingArrayOfScheduleGroup: Bool = false                                // статус загрузки ответа от сервера
    private(set) var errorOfScheduleGroup: String = ""                                          // ошибка (если есть) ответа от сервера
    
    private(set) var scheduleOfGroup: [FormatedSchedules] = []                  // все расписание
    private(set) var filteredScheduleOfGroup: [FormatedSchedules] = []          // отфильтрованное расписание
    
    private(set) var scheduleOfGroupOnDay: [Lesson] = []
    private(set) var filteredScheduleOfGroupOnDay: [Lesson] = []
    
    // получение расписания группы от API
    func getScheduleGroup(group: String) async {
        do {
            let data = try await networkService.getScheduleGroup(group)
            arrayOfScheduleGroup = data
            convertToScheduleDaysGroup() // сразу преобразовать в (День: [Занятия])
            
            scheduleOfGroup = data.schedules.getFormatedSchedules()
            filteredScheduleOfGroup = data.schedules.getFormatedSchedules()
            
            withAnimation(.easeIn) {
                isLoadingArrayOfScheduleGroup = true
            }
        } catch {
            withAnimation(.easeIn) {
                errorOfScheduleGroup = error.localizedDescription
                isLoadingArrayOfScheduleGroup = true
            }
            logger.error("Ошибка получения расписания группы: \(error.localizedDescription)")
        }
    }
    
    #warning("Возможно можно использовать переменную scheduleOfGroup вместо этой функции")
    #warning("Новая функция, которая просто получает и возвращает расписание группы")
    func getScheduleGroupForWidget(group: String) async -> [FormatedSchedules] {
        do {
            let data = try await networkService.getScheduleGroup(group)
            return data.schedules.getFormatedSchedules()
        } catch {
            logger.error("Ошибка получения расписания группы для виджета: \(error.localizedDescription)")
            return []
        }
    }
    
    func scheduleForEachGroupInNull() {
        arrayOfScheduleGroup = EachGroupResponse(startDate: "", endDate: "", startExamsDate: nil, endExamsDate: nil, studentGroupDto: StudentGroupDto(name: "", facultyAbbrev: "", facultyName: "", specialityName: "", specialityAbbrev: "", educationDegree: 0), employeeDto: nil, schedules: Schedules(monday: [], tuesday: [], wednesday: [], thursday: [], friday: [], saturday: [], sunday: []), currentTerm: "", currentPeriod: "")
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
    
    
    
    // фильтрация по неделе и по подгруппе (фильтрует весь массив дней)
    func filterGroupSchedule2(currentWeek: WeeksInPicker, subGroup: SubGroupInPicker, day: DaysInPicker) {
        let schedule = scheduleOfGroup                  // берется копия нефильтрованного массива всего расписания
        
        filteredScheduleOfGroup = schedule.map { each in
            let data = each.lesson.filter { lesson in
                let weekMatches = lesson.weekNumber.contains(currentWeek.rawValue)
                
                let subgroupMatches =
                subGroup.inNumber == 0 ? true :                     // Все подгруппы
                subGroup.inNumber == 1 ? (lesson.numSubgroup == 0 || lesson.numSubgroup == 1) : // 1 подгруппа
                subGroup.inNumber == 2 ? (lesson.numSubgroup == 0 || lesson.numSubgroup == 2) : // 2 подгруппа
                false                                               // Запасной вариант
                
                return weekMatches && subgroupMatches
            }
            return FormatedSchedules(id: UUID(), day: each.day, lesson: data)
        }
        #warning("Очень не нравится такое решение, нужно найти другое (вычисляемое свойство или withObservationTracking)")
        chooseDay(day: day)
    }
    
    // выбирает день
    func chooseDay(day: DaysInPicker) {
        filteredScheduleOfGroupOnDay = filteredScheduleOfGroup
            .first(where: { $0.day == day.inString })?
            .lesson ?? []
    }
}
