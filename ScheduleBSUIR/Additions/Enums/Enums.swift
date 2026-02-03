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
    
    var inNumber: Int {
        switch self {
        case .all: return 0
        case .first: return 1
        case .second: return 2
        }
    }
    
    var inString: String {
        switch self {
        case .all: return "Все"
        case .first: return "Первая"
        case .second: return "Вторая"
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
    
    var inString: String {
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
    
    var inString: String {
        switch self {
        case .first: return "Первая"
        case .second: return "Вторая"
        case .third: return "Третья"
        case .fourth: return "Четвёртая"
        }
    }
}

enum InEditProfile {
    case name
    case surname
    case patronymic
    case groupName
    case subGroup
    
    var pageName: String { // название страницы сверху
        switch self {
            case .name: return "Имя студента"
            case .surname: return "Фамилия студента"
            case .patronymic: return "Отчетсво студента"
            case .groupName: return "Номер группы"
            case .subGroup: return "Номер подгруппы"
        }
    }
    
    var inSection: String { // текст в секии списка
        switch self {
            case .name: return "Измени свое имя"
            case .surname: return "Измени свою фамилию"
            case .patronymic: return "Измени свое отчество"
            case .groupName: return "Выбери учебную группу"
            case .subGroup: return "Выбири свою подгруппу"
        }
    }
    
    var forAppStorage: String { // ссылка на хранилище в AppStorage
        switch self {
            case .name: return "studentName"
            case .surname: return "studentSurname"
            case .patronymic: return "studentPatronymic"
            case .groupName: return "groupNumber"
            case .subGroup: return "subGroupNumber"
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

// используется для выбора пользователя и для выбора его в панеле снизу
enum WhoUser: String {
    case student = "Ученик"
    case employee = "Преподаватель"
    case none = "Другое"
}

// используется для навигации в списках и расписании (для универсальных view)
enum GroupOrEmployee {
    case group
    case employee
    
//    var pageName: String {
//        switch self {
//        case .group: return "Группы"
//        case .employee: return "Преподаватели"
//        }
//    }
//    
//    var forSearch: String {
//        switch self {
//        case .group: return "группы"
//        case .employee: return "преподавателя"
//        }
//    }
//    
    var urlForArray: String {
        switch self {
        case .group: return "https://iis.bsuir.by/api/v1/student-groups"
        case .employee: return "https://iis.bsuir.by/api/v1/employees/all"
        }
    }
    
    var urlForSchedule: String {
        switch self {
        case .group: return "https://iis.bsuir.by/api/v1/schedule?studentGroup="
        case .employee: return "https://iis.bsuir.by/api/v1/employees/schedule/"
        }
    }
}


// перечисление видов отображения расписания
enum Demonstrate: String, CaseIterable, Codable {
    case list = "Листом"
    case weekly = "Неделей"
    case byDays = "По дням"
}
