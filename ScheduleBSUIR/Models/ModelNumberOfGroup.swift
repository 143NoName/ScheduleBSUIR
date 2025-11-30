//
//  NetworkModels.swift
//  ScheduleBSUIR
//
//  Created by user on 26.10.25.
//

import Foundation

struct ModelNumbersOfGroups: Decodable, Identifiable {
    let id: Int
    let name: String
    let faculty: String?
    let speciality: String?
    let course: Int?
    let educationForm: String?
}

struct StudentGroups: Codable, Identifiable {
    let id: Int
    let name: String
    let facultyId: Int?
    let facultyAbbrev: String?
    let facultyName: String?
    let specialityDepartmentEducationFormId: Int?
    let specialityName: String?
    let specialityAbbrev: String?
    let course: Int?
    let educationDegree: Int?
    let calendarId: String?
}
