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
    
//    // Простой способ получить полное имя
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


//<firstName>Инна</firstName>
//<lastName>Андриалович</lastName>
//<middleName>Владимировна</middleName>
//<degree/>
//<rank/>
//<photoLink>https://iis.bsuir.by/api/v1/employees/photo/520632</photoLink>
//<calendarId>c95fum04qq8hju3a6ce8uiq31o@group.calendar.google.com</calendarId>
//<academicDepartment>
//<academicDepartment>Каф.ИПЭ</academicDepartment>
//<academicDepartment>Каф.ПИКС</academicDepartment>
//</academicDepartment>
//<id>520632</id>
//<urlId>i-andrialovich</urlId>
//<fio>Андриалович И. В.</fio>
