//
//  ModelLesson.swift
//  ScheduleBSUIR
//
//  Created by andrew on 21.12.25.
//

import SwiftUI

struct Schedules: Codable, Sendable {
    let monday: [Lesson]?
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
    
    // получение более удобного формата расписания
    var lessonsByDay: [(day: String, lessons: [Lesson])] {
        [
            ("Понедельник", monday ?? []),
            ("Вторик", tuesday ?? []),
            ("Среда", wednesday ?? []),
            ("Четверг", thursday ?? []),
            ("Пятница", friday ?? []),
            ("Суббота", saturday ?? []),
            ("Воскресенье", sunday ?? [])
        ]
    }
    
    // преобразование из Schedules в FormatedSchedules
    func getFormatedSchedules() -> [FormatedSchedules] {
        lessonsByDay.map { day, lessons in
            FormatedSchedules(day: day, lesson: lessons)
        }
    }
}

// модель для виджета (загрузка в него данных и их фильтрация)
struct FormatedSchedules: Codable, Identifiable {
    var id: UUID = UUID()
    let day: String
    let lesson: [Lesson]
}

// расписание уроков по отдельности
struct Lesson: Codable, Equatable, Identifiable {
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
    let employees: [Employee]?
    let dateLesson: String?
    let startLessonDate: String?
    let endLessonDate: String?
    let announcement: Bool
    let split: Bool
    
    var id: Int { UUID().hashValue }
}

struct StudentGroupInfo: Codable, Equatable {
    let specialityName: String
    let specialityCode: String
    let numberOfStudents: Int
    let name: String
    let educationDegree: Int
}

struct Employee: Codable, Equatable {
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
