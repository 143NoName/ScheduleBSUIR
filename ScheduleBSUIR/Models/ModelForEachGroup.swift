//
//  NetworkModels.swift
//  ScheduleBSUIR
//
//  Created by user on 26.10.25.
//

import Foundation

struct ScheduleResponse: Codable, Sendable {
    let startDate: String?
    let endDate: String?
    let startExamsDate: String?
    let endExamsDate: String?
    let employeeDto: Employee?
    let schedules: Schedules
    let currentTerm: String?
    let currentPeriod: String?
}

struct Schedules: Codable, Sendable {
    let monday: [Lesson]?
    let tuesday: [Lesson]?
    let wednesday: [Lesson]?
    let thursday: [Lesson]?
    let friday: [Lesson]?
    let saturday: [Lesson]?
    let sunday: [Lesson]?
    
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

extension Schedules {
    func atDay(_ weekday: Int) -> [Lesson]? {
        switch weekday {
        case 2: return monday      // Понедельник
        case 3: return tuesday     // Вторник
        case 4: return wednesday   // Среда
        case 5: return thursday    // Четверг
        case 6: return friday      // Пятница
        case 7: return saturday    // Суббота
        case 1: return sunday      // Воскресенье
        default: return nil
        }
    }
}

struct Lesson: Codable, Sendable {
    let auditories: [String]
    let endLessonTime: String
    let lessonTypeAbbrev: String
    let note: String?
    let numSubgroup: Int
    let startLessonTime: String
    let studentGroups: [StudentGroupInfo]
    let subject: String
    let subjectFullName: String
    let weekNumber: [Int]
    let employees: [Employee]
    let dateLesson: String?
    let startLessonDate: String?
    let endLessonDate: String?
    let announcement: Bool
    let split: Bool
}

struct StudentGroupInfo: Codable, Sendable {
    let specialityName: String
    let specialityCode: String
    let numberOfStudents: Int
    let name: String
    let educationDegree: Int
}

struct Employee: Codable, Sendable {
    let id: Int
    let firstName: String?
    let middleName: String?
    let lastName: String?
    let photoLink: String?
    let degree: String?
    let degreeAbbrev: String?
    let rank: String?
    let email: String?
    let urlId: String?
    let calendarId: String?
    let jobPositions: String?
    let chief: Bool?
}
