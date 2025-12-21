//
//  ModelForEachEmployee.swift
//  ScheduleBSUIR
//
//  Created by andrew on 19.12.25.
//

import Foundation


//protocol ScheduleResponseProtocol {
//    let schedule: AllLessons
//}

struct EachEmployeeResponse: Codable {
    let startDate: String?
    let endDate: String?
    let startExamsDate: String?
    let endExamsDate: String?
    let employeeDto: EmployeeDto
//    let studentGroupDto: [String]?
    let schedules: Schedules
//    let nextSchedules: String?
//    let currentTerm: String?
//    let nextTerm: String?
//    let exams: String?
    let currentPeriod: String?
//    let isZaochOrDist: String
}


struct EmployeeDto: Codable {
    let id: Int
    let firstName: String
    let middleName: String
    let lastName: String
    let photoLink: String?
//    let degree: Int?
//    let degreeAbbrev: String?
//    let rank: Int?
    let email: String?
    let urlId: String
    let calendarId: String?
    let chief: Bool?
    
    var fullName: String {
        guard let firstName = firstName.first, let middleName = middleName.first else { return "" }
        return "\(lastName) \(firstName). \(middleName)."
    }
}
