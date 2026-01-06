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

struct StudentGroups: Decodable, Identifiable, Hashable {
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
    
    var url: String {
        return name
    }
    
//    func makeNav() -> AnyView { // скоро будет не нужно
//        AnyView(EachGroup(groupName: name))
//    }
}
