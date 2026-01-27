//
//  ForWeek.swift
//  ScheduleBSUIR
//
//  Created by andrew on 27.01.26.
//

import Foundation
import OSLog

// MARK: - Для номера недели
protocol NetworkViewModelForWeekProtocol {
    var currentWeek: Int { get }
    var errorOfCurrentWeek: String { get }
    func getCurrentWeek() async
}


@Observable class NetworkViewModelForWeek: NetworkViewModelForWeekProtocol {
    
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }
    let logger = Logger()
    
    private(set) var currentWeek: Int = 0
    private(set) var errorOfCurrentWeek: String = ""
    
    // получение текущей недели от API
    func getCurrentWeek() async {
        do {
            currentWeek = try await networkService.getCurrentWeek()
        } catch {
            errorOfCurrentWeek = error.localizedDescription
            logger.error("Ошибка получения номера недели: \(error.localizedDescription)")
        }
    }
}
