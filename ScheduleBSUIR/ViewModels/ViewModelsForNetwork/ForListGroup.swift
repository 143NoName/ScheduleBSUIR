//
//  ForListGroup.swift
//  ScheduleBSUIR
//
//  Created by andrew on 27.01.26.
//

import Foundation
import OSLog

// MARK: - Списки групп
protocol NetworkViewModelForListGroupsProtocol {
    var arrayOfGroupsNum: [StudentGroups] { get }                                           // список всех групп
    var isLoadingArrayOfGroupsNum: Bool { get }                                             // загурзка списка групп
    var errorOfGroupsNum: String { get }                                                    // ошибка загрузки списка групп
    func getArrayOfGroupNum() async                                                         // получение списка всех групп
    func groupArrayInNull()                                                                 // очистка списка групп
}


@Observable class NetworkViewModelForListGroups: NetworkViewModelForListGroupsProtocol {
    
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }
    let logger = Logger()
    
    private(set) var arrayOfGroupsNum: [StudentGroups] = []
    private(set) var isLoadingArrayOfGroupsNum: Bool = false
    private(set) var errorOfGroupsNum: String = ""
    
    func getArrayOfGroupNum() async {
        do {
            arrayOfGroupsNum = try await networkService.getArrayOfGroupNum()
            isLoadingArrayOfGroupsNum = true
        } catch {
            isLoadingArrayOfGroupsNum = true
            errorOfGroupsNum = error.localizedDescription
            logger.error("Ошибка получения списка групп: \(error.localizedDescription)")
        }
    }
    
    func groupArrayInNull() {
        arrayOfGroupsNum = []
        isLoadingArrayOfGroupsNum = false
        errorOfGroupsNum = ""
    }
}
