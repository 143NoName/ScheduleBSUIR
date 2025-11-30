//
//  NetworkService.swift
//  ScheduleBSUIR
//
//  Created by user on 26.10.25.
//

import SwiftUI
import Alamofire

protocol NetworkServiceProtocol {
    func getCurrentWeek() async throws -> Int
    func getArrayOfGroupNum() async throws -> [StudentGroups]
    func getScheduleGroup(_ group: String) async throws -> ScheduleResponse
}

class NetworkService: NetworkServiceProtocol {
    let decoder = JSONDecoder()
    
    // получение номера недели
    func getCurrentWeek() async throws -> Int {
        return try await AF.request("https://iis.bsuir.by/api/v1/schedule/current-week")
            .validate()
            .serializingDecodable(Int.self)
            .value
    }
    
    // получение номеров групп
    func getArrayOfGroupNum() async throws -> [StudentGroups] {
        let data = try await AF.request("https://iis.bsuir.by/api/v1/student-groups")
            .validate()
            .serializingData()
            .value
        do {
            return try decoder.decode([StudentGroups].self, from: data)
        } catch {
            throw error
        }
    }
    
    // получение расписания группы
    func getScheduleGroup(_ group: String) async throws -> ScheduleResponse { // при частом выполнении, что то ломается
        let params: Parameters = ["studentGroup": "\(group)"]
        
        let data = try await AF.request("https://iis.bsuir.by/api/v1/schedule",
                                        parameters: params
        )
            .validate()
            .serializingData()
            .value
        do {
            return try decoder.decode(ScheduleResponse.self, from: data)
        } catch {
            throw error
        }
    }
}

//extension AFError {
//    var decriptionError: String {
//        switch self {
//        case .invalidURL(url: let url):
//            return "Невозжможно получить текущую неделю потому что неверный путь URL: \(url)"
//        }
//        case .responseSerializationFailed(reason: reason):
//          switch reason {
//          case .
//        }
//    }
//}
