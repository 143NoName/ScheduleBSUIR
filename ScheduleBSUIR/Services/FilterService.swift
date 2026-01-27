//
//  FilterService.swift
//  ScheduleBSUIR
//
//  Created by andrew on 5.12.25.
//

import SwiftUI

protocol FilterServiceProtocol {
    func filterSchedule2(currentWeek: WeeksInPicker, subGroup: SubGroupInPicker, scheduleDays: [(dayName: String, lessons: [Lesson])]) -> [(dayName: String, lessons: [Lesson])]
    func filterSchedule(currentWeek: WeeksInPicker, subGroup: SubGroupInPicker, scheduleDays: inout [(dayName: String, lessons: [Lesson])])
    
    func filterSchedule(_ schedule: [FormatedSchedules], selectedDay: DaysInPicker, currentWeek: WeeksInPicker, subGroup: SubGroupInPicker) -> [Lesson]
//    func filterByDay(_ shedule: [FormatedSchedules], selectedDay: DaysInPicker, currentWeek: WeeksInPicker, subGroup: SubGroupInPicker) -> [Lesson]
}

struct FilterService: FilterServiceProtocol {
    
    func filterSchedule2(currentWeek: WeeksInPicker, subGroup: SubGroupInPicker, scheduleDays: [(dayName: String, lessons: [Lesson])]) -> [(dayName: String, lessons: [Lesson])] {
        return scheduleDays.map { (groupName, lessons) in
            let filteredLessons = lessons.filter { each in
                each.weekNumber.contains(currentWeek.rawValue) &&
                (subGroup.inNumber == 0 ? each.numSubgroup == 0 || each.numSubgroup == 1 || each.numSubgroup == 2 : each.numSubgroup == subGroup.inNumber || each.numSubgroup == 0) &&
                !["Консультация", "Экзамен"].contains(each.lessonTypeAbbrev)
            }
            return (groupName, filteredLessons)
        }
    }
    
    func filterSchedule(currentWeek: WeeksInPicker, subGroup: SubGroupInPicker, scheduleDays: inout [(dayName: String, lessons: [Lesson])]) {
        scheduleDays = scheduleDays.map { (groupName, lessons) in
            let filteredLessons = lessons.filter { each in
                each.weekNumber.contains(currentWeek.rawValue) &&
                (subGroup.inNumber == 0 ? each.numSubgroup == 0 || each.numSubgroup == 1 || each.numSubgroup == 2 : each.numSubgroup == subGroup.inNumber || each.numSubgroup == 0) &&
                !["Консультация", "Экзамен"].contains(each.lessonTypeAbbrev)
            }
            return (groupName, filteredLessons)
        }
    }
    
    
    
    
    
//    // новая для нового типа данных
//    func filterByDay(_ schedule: [FormatedSchedules], selectedDay: DaysInPicker, currentWeek: WeeksInPicker, subGroup: SubGroupInPicker) -> [Lesson] {
//        let day = selectedDay.inString
//        let scheduleDay = schedule.first { $0.day == day }?.lesson ?? []
//        return scheduleDay
//    }
//    
//    #warning("Идентична функции фильтрации в виджете (func filterLessons(lessons: [Lesson]) -> [Lesson])")
//    // фильтрация всего массива расписания по неделе и подгруппе
//    func filterByWeekAndSubGroup(_ schedule:  [Lesson], currentWeek: WeeksInPicker, subGroup: SubGroupInPicker) {
//        schedule.filter {
//            $0.weekNumber.contains(currentWeek.rawValue) &&
//            ($0.numSubgroup == 0 || $0.numSubgroup == subGroup.inNumber)
//        }
//    }
    
    func filterByDay(_ schedule: [FormatedSchedules], selectedDay: DaysInPicker) -> [Lesson] {
        let day = selectedDay.inString
        let scheduleDay = schedule.first { $0.day == day }?.lesson ?? []
        print("Расписание на день: \(scheduleDay)")
        return scheduleDay
    }
    
    func filterByWeekAndSubGroup(_ schedule: [Lesson], currentWeek: WeeksInPicker, subGroup: SubGroupInPicker) -> [Lesson] {
        let data = schedule.filter {
            $0.weekNumber.contains(currentWeek.rawValue) &&
            ($0.numSubgroup == 0 || $0.numSubgroup == subGroup.inNumber)
        }
        return data
    }
    
    func filterSchedule(_ schedule: [FormatedSchedules], selectedDay: DaysInPicker, currentWeek: WeeksInPicker, subGroup: SubGroupInPicker) -> [Lesson] {
        let scheduleDay = filterByDay(schedule, selectedDay: selectedDay)                                                           // фильтрация по дню
        let finalSchedule = filterByWeekAndSubGroup(scheduleDay, currentWeek: currentWeek, subGroup: subGroup)                      // фильтрацич по неделе и подгруппе
        return finalSchedule
    }
    
    
    
    // фильтрация всего массива расписания по неделе и подгруппе
//    func filterByWeekAndSubGroup(_ schedule: [FormatedSchedules], currentWeek: WeeksInPicker, subGroup: SubGroupInPicker) -> [FormatedSchedules] {
//        let data = schedule.map { each in
//            let lessons = each.lesson.filter {
//                $0.weekNumber.contains(currentWeek.rawValue) &&
//                ($0.numSubgroup == 0 || $0.numSubgroup == subGroup.inNumber)
//            }
//            return FormatedSchedules(day: each.day, lesson: lessons)
//        }
//        return data
//    }
}
