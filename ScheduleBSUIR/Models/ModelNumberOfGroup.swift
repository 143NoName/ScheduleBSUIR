//
//  NetworkModels.swift
//  ScheduleBSUIR
//
//  Created by user on 26.10.25.
//

import Foundation
import SwiftUI

protocol ModelsProtocol {
//    let id: String
//    var displayName: String { get }
    func makeCell() -> AnyView
    func makeNav() -> AnyView
}


struct ModelNumbersOfGroups: Decodable, Identifiable {
    let id: Int
    let name: String
    let faculty: String?
    let speciality: String?
    let course: Int?
    let educationForm: String?
    
    
}

struct StudentGroups: Decodable, Identifiable, Hashable, ModelsProtocol {
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
    
    func makeCell() -> AnyView {
       AnyView(ViewForGroup(group: self))
    }
    
    func makeNav() -> AnyView {
        AnyView(EachGroup(groupName: name))
    }
}
