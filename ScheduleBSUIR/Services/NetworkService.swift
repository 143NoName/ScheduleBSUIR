//
//  NetworkService.swift
//  ScheduleBSUIR
//
//  Created by user on 26.10.25.
//

import SwiftUI
import Alamofire

import os.log

protocol NetworkServiceProtocol {
    func getCurrentWeek() async throws -> Int
    
    func getArrayOfGroupNum() async throws -> [StudentGroups]
    func getScheduleGroup(_ group: String) async throws -> ScheduleResponse
    
    func getArrayOfEmployees() async throws -> [EmployeeModel]
    func getEachEmployeeSchedule(_ id: String) async throws -> EachEmployeeResponse
}

class NetworkService: NetworkServiceProtocol {
    let decoder = JSONDecoder()
    
    // НЕДЕЛЯ
    
    
    
    // получение номера недели
    func getCurrentWeek() async throws -> Int {
        return try await AF.request("https://iis.bsuir.by/api/v1/schedule/current-week")
            .validate()
            .serializingDecodable(Int.self)
            .value
    }
    
    
    
    // УЧЕНИКИ
    
    
    
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
    
    #warning("Если запросявно отменен, то надо его востановить (Request explicitly cancelled.)")
    
    // ПРЕПОДАВАТЕЛИ
    
    var logger = Logger(subsystem: "AF", category: "AF")
    
    
    func getArrayOfEmployees() async throws -> [EmployeeModel] {
        let data = try await AF.request("https://iis.bsuir.by/api/v1/employees/all")
            .validate()
            .serializingData()
            .value
        do {
            let response = try decoder.decode([EmployeeModel].self, from: data)
            return response
        } catch {
            throw error
        }
    }
    
    func getEachEmployeeSchedule(_ urlId: String) async throws -> EachEmployeeResponse {
        let data = try await AF.request("https://iis.bsuir.by/api/v1/employees/schedule/\(urlId)")
            .validate()
            .serializingData()
            .value
        do {
            return try decoder.decode(EachEmployeeResponse.self, from: data)
        } catch {
            throw error
        }
    }
}
