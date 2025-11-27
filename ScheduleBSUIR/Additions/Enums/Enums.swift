//
//  Enums.swift
//  ScheduleBSUIR
//
//  Created by user on 31.10.25.
//

import SwiftUI

enum SubGroupInPicker: String, CaseIterable, Identifiable {
    case all = "Все"
    case first = "1"
    case second = "2"
    var id: Self { self }
    
    var subGroupInNumber: Int {
        switch self {
        case .all: return 0
        case .first: return 1
        case .second: return 2
        }
    }
    
    var allSubGroups: [Int] {
        switch self {
            case .all: return [0, 1, 2]
            case .first: return [0, 1]
            case .second: return [0, 2]
        }
    }
}

enum DaysInPicker: Int, CaseIterable, Identifiable {
    case monday = 1
    case tuesday = 2
    case wednesday = 3
    case thursday = 4
    case friday = 5
    case saturday = 6
    case sunday = 7
    var id: Self { self }
    
    var filterByDay: String {
        switch self {
        case .monday: return "Понедельник"
        case .tuesday: return "Вторник"
        case .wednesday: return "Среда"
        case .thursday: return "Четверг"
        case .friday: return "Пятница"
        case .saturday: return "Суббота"
        case .sunday: return "Воскресенье"
        }
    }
}

enum WeeksInPicker: Int, CaseIterable, Identifiable {
    case first = 1
    case second = 2
    case third = 3
    case fourth = 4
    var id: Self { self }
    
//    var filterByWeek: Int {
//        switch self {
//        case .first: return 1
//        case .second: return 2
//        case .third: return 3
//        case .fourth: return 4
//        }
//    }
}

enum InEditProfile {
    case name
    case surname
    case patronymic
    case groupName
    
    var pageName: String {
        switch self {
            case .name: return "Имя студента"
            case .surname: return "Фамилия студента"
            case .patronymic: return "Отчетсво студента"
            case .groupName: return "Номер группы"
        }
    }
    
    var inSection: String {
        switch self {
            case .name: return "Измени свое имя"
            case .surname: return "Измени свою фамилию"
            case .patronymic: return "Измени свое отчество"
            case .groupName: return "Выбери учебную группу"
        }
    }
    
    var forAppStorage: String {
        switch self {
            case .name: return "studentName"
            case .surname: return "studentSurname"
            case .patronymic: return "studentPatronymic"
            case .groupName: return "groupNumber"
        }
    }
}

enum Weekday: String {
    case monday = "Понедельник"
    case tuesday = "Вторник"
    case wednesday = "Среда"
    case thursday = "Четверг"
    case friday = "Пятница"
    case saturday = "Суббота"
    case sunday = "Воскресенье"
}
