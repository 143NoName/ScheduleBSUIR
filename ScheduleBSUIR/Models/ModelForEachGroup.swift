//
//  NetworkModels.swift
//  ScheduleBSUIR
//
//  Created by user on 26.10.25.
//

import Foundation

struct EachGroupResponse: Codable {
    let startDate: String?
    let endDate: String?
    let startExamsDate: String?
    let endExamsDate: String?
    let studentGroupDto: StudentGroupDto
    let employeeDto: Employee?
    let schedules: Schedules     // в течении семестра тут schedules а по окончанию nextSchedules
    let currentTerm: String?
    let currentPeriod: String?
}

struct StudentGroupDto: Codable {
    let name: String
    let facultyAbbrev: String
    let facultyName: String
    let specialityName: String
    let specialityAbbrev: String?
//    let cours: Int?
    let educationDegree: Int
}
