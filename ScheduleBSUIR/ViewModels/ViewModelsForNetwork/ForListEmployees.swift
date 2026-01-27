//
//  ForEmployeesList.swift
//  ScheduleBSUIR
//
//  Created by andrew on 27.01.26.
//

import SwiftUI
import OSLog

// MARK: - Список преподавателей
protocol NetworkViewModelForListEmployeesProtocol {
    var scheduleForEmployees: [EmployeeModel] { get }                                       // список всех преподавателей
    var isLoadingScheduleForEmployees: Bool { get }                                         // загурзка списка преподавателей
    var errorOfEmployeesArray: String { get }                                               // ошибка загрузки списка преподавателей
    func getArrayOfEmployees() async                                                        // получение списка преподавателей
    func employeesArrayInNull()                                                             // очистка списка преподавателей
}

@Observable class NetworkViewModelForListEmployees: NetworkViewModelForListEmployeesProtocol {
    
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }
    
    let logger = Logger()
    
    private(set) var scheduleForEmployees: [EmployeeModel] = []
    private(set) var isLoadingScheduleForEmployees: Bool = false
    private(set) var errorOfEmployeesArray: String = ""
    
    func getArrayOfEmployees() async {
        do {
            scheduleForEmployees = try await networkService.getArrayOfEmployees()
            withAnimation(.easeIn) {
                isLoadingScheduleForEmployees = true
            }
        } catch {
            withAnimation(.easeIn) {
                errorOfEmployeesArray = error.localizedDescription
                isLoadingScheduleForEmployees = true
            }
            logger.error("Ошибка получения списка преподавателей: \(error.localizedDescription)")
        }
    }
    
    // очистка списка преподавателей
    func employeesArrayInNull() {
        scheduleForEmployees = []
        isLoadingScheduleForEmployees = false
        errorOfEmployeesArray = ""
    }
}
