//
//  ModelForEachEmployee.swift
//  ScheduleBSUIR
//
//  Created by andrew on 19.12.25.
//

import Foundation

struct EachEmployeeResponse: Codable {
    let startDate: String
    let endDate: String
    let startExamsDate: String?
    let endExamsDate: String?
    let employeeDto: [EmployeeDto]
    let studentGroupDto: [String]?
    let schedules: [StudentGroupDto]
    let nextSchedules: String?
    let currentTerm: String?
    let nextTerm: String?
    let exams: String?
    let currentPeriod: String
    let isZaochOrDist: String
}


struct EmployeeDto: Codable {
    let id: Int
    let firstName: String
    let middleName: String
    let lastName: String
    let photoLink: String
    let degree: Int?
    let degreeAbbrev: Int?
    let rank: Int?
    let email: String?
    let urlId: String
    let calendarId: String?
    let chief: Bool?
}

struct StudentGroupDto: Codable {
    let monday: [Lesson]? // возможно Lesson будет другой
    let tuesday: [Lesson]?
    let wednesday: [Lesson]?
    let thursday: [Lesson]?
    let friday: [Lesson]?
    let saturday: [Lesson]?
    let sunday: [Lesson]?
    
    // Для получения данных из сети с русскими названиями, но потом перевод в анг как в модели
    private enum CodingKeys: String, CodingKey {
        case monday = "Понедельник"
        case tuesday = "Вторник"
        case wednesday = "Среда"
        case thursday = "Четверг"
        case friday = "Пятница"
        case saturday = "Суббота"
        case sunday = "Воскресенье"
    }
}

// более удобная форма
struct FormatedSchedulesEmployee: Codable {
    let day: String
    let lesson: [Lesson]
}
