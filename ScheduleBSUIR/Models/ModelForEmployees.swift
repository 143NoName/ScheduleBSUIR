//
//  ModelForEmployees.swift
//  ScheduleBSUIR
//
//  Created by andrew on 18.12.25.
//

import Foundation
import SwiftUI

struct EmployeeResponse: Codable {
    let employees: [EmployeeModel]
    let page: Int
    let size: Int
    let total: Int
}

struct EmployeeModel: Codable, Identifiable, Hashable, EachListsProtocol {
    let id: Int
    let academicDepartment: [String]?
    let firstName: String?
    let lastName: String?
    let middleName: String?
    let rank: String?
    let photoLink: String?
    let degree: String?
    let urlId: String
    let calendarId: String?
    
    var url: String {
        return urlId
    }
    
    // создание view для отрисовки каждого элемента (гркппа или преподаватель)
    func makeCell() -> AnyView {
       AnyView(ViewForEmployee(employee: self))
    }
    
    // передача view для навигации (сразу )
    func makeNav() -> AnyView {
        AnyView(EachEmployee(employeeName: urlId))
    }
    
    var fullName: String {
        "\(lastName ?? "") \(firstName ?? "") \(middleName ?? "")"
    }
    var fio: String {
        guard let lastName, let firstName = firstName?.first, let middleName = middleName?.first else { return "" }
        return "\(lastName) \(firstName). \(middleName)."
    }

}
