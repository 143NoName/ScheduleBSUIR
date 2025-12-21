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
