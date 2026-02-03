//
//  ForScheduleGroup.swift
//  ScheduleBSUIR
//
//  Created by andrew on 27.01.26.
//

import Foundation
import OSLog

// MARK: - Расписание группы
protocol NetworkViewModelForScheduleGroupsProtocol {
    var arrayOfScheduleGroup: EachGroupResponse { get }                                                 // расписание отдельной группы
    var isLoadingArrayOfScheduleGroup: Bool { get }                                                     // загрузка расписания группы
    var errorOfScheduleGroup: String { get }                                                            // ошибка расписания группы
    func getScheduleGroup(group: String) async                                                          // функция получения расписания группы
    func scheduleForEachGroupInNull()                                                                   // функция очистки расписания группы
    func filterGroupSchedule(currentWeek: WeeksInPicker, subGroup: SubGroupInPicker, day: DaysInPicker) // функция фильтрации расписания группы по неделе, подгрупп и дню
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
    
    private(set) var scheduleOfGroup: [FormatedSchedules] = []                                  // все расписание
    private(set) var filteredScheduleOfGroup: [FormatedSchedules] = []                          // отфильтрованное расписание
    
    private(set) var scheduleOfGroupOnDay: [Lesson] = []
    private(set) var filteredScheduleOfGroupOnDay: [Lesson] = []
    
    // получение расписания группы
    func getScheduleGroup(group: String) async {
        do {
            let data = try await networkService.getScheduleGroup(group)
            arrayOfScheduleGroup = data  // сырой ответ от сети
            
            scheduleOfGroup = data.schedules.getFormatedSchedules()
            filteredScheduleOfGroup = data.schedules.getFormatedSchedules()
            
            isLoadingArrayOfScheduleGroup = true
        } catch {
            errorOfScheduleGroup = error.localizedDescription
            isLoadingArrayOfScheduleGroup = true
                        
            logger.info("Ошибка получения расписания группы: \(error.localizedDescription)")
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
    
    // очистка массива расписания
    #warning("Надо дополнить новыми массивами (фильтрованный и тд)")
    func scheduleForEachGroupInNull() {
        arrayOfScheduleGroup = EachGroupResponse(startDate: "", endDate: "", startExamsDate: nil, endExamsDate: nil, studentGroupDto: StudentGroupDto(name: "", facultyAbbrev: "", facultyName: "", specialityName: "", specialityAbbrev: "", educationDegree: 0), employeeDto: nil, schedules: Schedules(monday: [], tuesday: [], wednesday: [], thursday: [], friday: [], saturday: [], sunday: []), currentTerm: "", currentPeriod: "")
        isLoadingArrayOfScheduleGroup = false
        errorOfScheduleGroup = ""
        filteredScheduleOfGroupOnDay = []
        filteredScheduleOfGroup = []
    }
    
    // фильтрация по неделе и по подгруппе (фильтрует весь массив дней)
    func filterGroupSchedule(currentWeek: WeeksInPicker, subGroup: SubGroupInPicker, day: DaysInPicker) {
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
