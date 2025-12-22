//
//  ModelForEmployees.swift
//  ScheduleBSUIR
//
//  Created by andrew on 18.12.25.
//

import Foundation

struct EmployeeResponse: Codable {
    let employees: [EmployeeModel]
    let page: Int
    let size: Int
    let total: Int
}

struct EmployeeModel: Codable, Identifiable {
    let id: Int
    let academicDepartment: [String]?
    let firstName: String?
    let lastName: String?
    let middleName: String?
    let rank: String?
    let photoLink: String?
    let degree: String?
    let urlId: String?
    let calendarId: String?
    let fio: String?
    
    var fullName: String {
        "\(lastName ?? "") \(firstName ?? "") \(middleName ?? "")"
    }
//    
//    // URL для фото (добавляем базовый URL если нужно)
//    var photoURL: URL? {
//        guard let link = photoLink, !link.isEmpty else { return nil }
//        // Если в API возвращается относительный путь
//        return URL(string: "https://iis.bsuir.by\(link)")
//    }
}
