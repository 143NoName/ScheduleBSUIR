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
}

struct FilterService: FilterServiceProtocol {
    
    func filterSchedule2(currentWeek: WeeksInPicker, subGroup: SubGroupInPicker, scheduleDays: [(dayName: String, lessons: [Lesson])]) -> [(dayName: String, lessons: [Lesson])] {
        return scheduleDays.map { (groupName, lessons) in
            let filteredLessons = lessons.filter { each in
                each.weekNumber.contains(currentWeek.rawValue) &&
                (subGroup.subGroupInNumber == 0 ? each.numSubgroup == 0 || each.numSubgroup == 1 || each.numSubgroup == 2 : each.numSubgroup == subGroup.subGroupInNumber || each.numSubgroup == 0) &&
                !["Консультация", "Экзамен"].contains(each.lessonTypeAbbrev)
            }
            return (groupName, filteredLessons)
        }
    }
    
    func filterSchedule(currentWeek: WeeksInPicker, subGroup: SubGroupInPicker, scheduleDays: inout [(dayName: String, lessons: [Lesson])]) {
        scheduleDays = scheduleDays.map { (groupName, lessons) in
            let filteredLessons = lessons.filter { each in
                each.weekNumber.contains(currentWeek.rawValue) &&
                (subGroup.subGroupInNumber == 0 ? each.numSubgroup == 0 || each.numSubgroup == 1 || each.numSubgroup == 2 : each.numSubgroup == subGroup.subGroupInNumber || each.numSubgroup == 0) &&
                !["Консультация", "Экзамен"].contains(each.lessonTypeAbbrev)
            }
            print((groupName, filteredLessons))
            return (groupName, filteredLessons)
        }
    }
}
