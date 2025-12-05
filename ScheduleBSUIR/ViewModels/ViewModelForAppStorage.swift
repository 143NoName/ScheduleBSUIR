//
//  ViewModelAppStorage.swift
//  ScheduleBSUIR
//
//  Created by andrew on 4.12.25.
//

import SwiftUI

struct ViewModelForAppStorage {
    
    private let appStorageService: AppStorageServiceProtocol
    private let networkService: NetworkServiceProtocol
    
    init(
        networkService: NetworkServiceProtocol = NetworkService(),
        appStorageService: AppStorageServiceProtocol = AppStorageService()
    ) {
        self.networkService = networkService
        self.appStorageService = appStorageService
    }
        
    func saveDataForWidgetToAppStorage(data: Schedules) {
        do {
            try appStorageService.saveDataForWidgetToAppStorage(data)
        } catch {
            print("Проблема при загрузке данных")
        }
    }
    
}
