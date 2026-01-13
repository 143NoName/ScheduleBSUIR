//
//  TabView.swift
//  ScheduleBSUIR
//
//  Created by user on 28.10.25.
//

import SwiftUI

struct AppStorageServiceKey: EnvironmentKey {
    static let defaultValue: AppStorageService? = nil  // Может быть optional
}


extension EnvironmentValues {
    var appStorageKey: AppStorageService? {
        get { self[AppStorageServiceKey.self] }
        set { self[AppStorageServiceKey.self] = newValue }
    }
}

struct TabBarView: View {
    
    @StateObject private var weekViewModel = NetworkViewModelForWeek()
    @StateObject private var groupListViewModel = NetworkViewModelForListGroups()
    @StateObject private var groupScheduleViewModel = NetworkViewModelForScheduleGroups()
    @StateObject private var employeeListViewModel = NetworkViewModelForListEmployees()
    @StateObject private var employeeScheduleViewModel = NetworkViewModelForScheduleEmployees()
    
    
    
    #warning("Сделать DI")
    @StateObject private var network = ViewModelForNetwork()
    @StateObject private var appStorageSave = AppStorageSave() // хранилище всех AppStorage
                 private var appStorage = AppStorageService() // плохо, что view знает о сервисе, можно сдеать viewModel
    
    @State private var selectedTab: Int = 2
//    @State private var splashScreen: Bool = true    
    
//    @State private var isPresentedSplashScreen: Bool = true
//    @State var scale: CGFloat = 1
//    @State var opacity: Double = 1
    
    var body: some View {
//        ZStack { // для начального окна
            TabView(selection: $selectedTab) {
                Tab("Все группы", systemImage: "person.3", value: 0) {
                    GroupsTab()
                }
                Tab("Преподаватели", systemImage: "calendar.and.person", value: 1) {
                    EmployeesTab()
                }
                
                if appStorageSave.whoUser == .student && appStorageSave.favoriteGroup != "Не выбрано" {
                    Tab("Моя группа", systemImage: "star", value: 2) {
                        NavigationStack {
                            EachGroup(groupName: appStorageSave.favoriteGroup)
                        }
                    }
                } else if appStorageSave.whoUser == .employee && appStorageSave.employeeName != "Не выбрано" {
                    Tab("Мое расписание", systemImage: "star", value: 2) {
                        NavigationStack {
                            EachEmployee(employeeName: appStorageSave.employeeName)
                        }
                    }
                }
                
                Tab("Личный кабинет", systemImage: "person.circle", value: 3) {
                    PersonalAccount()
                }
            }
            
            .task {
                await Task.detached {
                    await weekViewModel.getCurrentWeek()           // получение текущей недели
                    await groupListViewModel.getArrayOfGroupNum()       // получение списка групп
                    await employeeListViewModel.getArrayOfEmployees()      // получение списка преподавателей
                    
                    do {
                        try await appStorage.saveDataForWidgetToAppStorage(network.arrayOfScheduleGroup.nextSchedules)
                    } catch {
                        print("Неудачная попытка загрузить расписание в AppStorage: \(error)")
                    }
                    
                    
                }.value
                
                appStorage.saveWeekNumberToAppStorage(network.currentWeek)
            }
            
//            #warning("Создание большого количество потоков")
            // показывать начальное окно
//            if isPresentedSplashScreen {
//                StartView(opacity: $opacity, scale: $scale)
//                .onAppear {
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                        withAnimation(.easeOut(duration: 1)) {
//                            scale = 15
//                            opacity = 0
//                        }
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
//                            isPresentedSplashScreen = false
//                        }
//                    }
//                }
//            }
            
//        }
        
        .environmentObject(weekViewModel)
        .environmentObject(groupListViewModel)
        .environmentObject(groupScheduleViewModel)
        .environmentObject(employeeListViewModel)
        .environmentObject(employeeScheduleViewModel)
        
        
        .environmentObject(network)
        .environment(\.appStorageKey, appStorage)
        .environmentObject(appStorageSave)
    }
}

#Preview {
    TabBarView()
}
