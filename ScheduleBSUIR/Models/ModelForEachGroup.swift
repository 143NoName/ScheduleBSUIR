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
    let studentGroupDto: StudentGroupDto
    let employeeDto: Employee?
    let schedules: Schedules
    let currentTerm: String?
    let currentPeriod: String?
}

struct StudentGroupDto: Codable {
    let name: String
//    let facultyId: Int
    let facultyAbbrev: String
    let facultyName: String
//    let specialityDepartmentEducationFormId: Int
    let specialityName: String
    let specialityAbbrev: String?
//    let cours: Int
//    let id: Int
//    let calendarId: String
    let educationDegree: Int
}
