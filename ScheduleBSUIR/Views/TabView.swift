//
//  TabView.swift
//  ScheduleBSUIR
//
//  Created by user on 28.10.25.
//

import SwiftUI

struct SaveForWidgetServiceKey: EnvironmentKey {
    static let defaultValue: SaveForWidgetService? = nil  // Может быть optional
}

//struct IsPortraitOniPhone: EnvironmentKey {
//    static let defaultValue: Bool = false
//}

extension EnvironmentValues {
    var saveForWidgetService: SaveForWidgetService? {
        get { self[SaveForWidgetServiceKey.self] }
        set { self[SaveForWidgetServiceKey.self] = newValue }
    }
//    var isPortraitOniPhone: Bool {
//        get { self[IsPortraitOniPhone.self] }
//        set { self[IsPortraitOniPhone.self] = newValue }
//    }
}

struct TabBarView: View {
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    @StateObject private var weekViewModel = NetworkViewModelForWeek()                              // получение текущей недели
    @StateObject private var groupListViewModel = NetworkViewModelForListGroups()                   // получение списка групп
    @StateObject private var groupScheduleViewModel = NetworkViewModelForScheduleGroups()           // получение расписания группы (тут только один экземпляр с сетевым менеджером)
//    @StateObject private var
    @StateObject private var employeeListViewModel = NetworkViewModelForListEmployees()             // получение списка преподавателей
    @StateObject private var employeeScheduleViewModel = NetworkViewModelForScheduleEmployees()     // получение расписания преподавателя
    
    @StateObject private var viewModelForAppStorage = ViewModelForAppStorage()
    
    #warning("Сделать DI")
    @StateObject private var appStorageSave = AppStorageSave() // хранилище всех AppStorage
                 private var saveForWidgetService = SaveForWidgetService() // плохо, что view знает о сервисе, можно сдеать viewModel
    
    @State private var selectedTab: Int = 2
//    @State private var splashScreen: Bool = true
    
//    @State private var isPresentedSplashScreen: Bool = true
//    @State var scale: CGFloat = 1
//    @State var opacity: Double = 1
    
    
//    var isPortraitOniPhone: Bool { // проверка ориентации iPhone
//        if horizontalSizeClass == .compact && verticalSizeClass == .regular {
//            return true
//        } else if (horizontalSizeClass == .compact && verticalSizeClass == .compact) || (horizontalSizeClass == .regular && verticalSizeClass == .compact) {
//            return false
//        } else {
//            return true
//        }
//    }
    
    var body: some View {
//        ZStack { // для начального окна
            TabView(selection: $selectedTab) {
                Tab("Все группы", systemImage: "person.3", value: 0) {
                    GroupsTab()
                        .environmentObject(groupListViewModel)
                        .environmentObject(NetworkViewModelForScheduleGroups(sourceData: NetworkService()))
                }
                Tab("Преподаватели", systemImage: "calendar.and.person", value: 1) {
                    EmployeesTab()
                        .environmentObject(employeeListViewModel)
                        .environmentObject(employeeScheduleViewModel)
                }
                if appStorageSave.whoUser == .student && appStorageSave.favoriteGroup != "Не выбрано" {
                    Tab("Моя группа", systemImage: "star", value: 2) {
                        NavigationStack {
                            EachGroup(groupName: appStorageSave.favoriteGroup)
                                .environmentObject(NetworkViewModelForScheduleGroups(sourceData: AppStorageServiceForApp()))
                        }
                    }
                } else if appStorageSave.whoUser == .employee && appStorageSave.employeeName != "Не выбрано" {
                    Tab("Мое расписание", systemImage: "star", value: 2) {
                        NavigationStack {
                            EachEmployee(employeeName: appStorageSave.employeeName)
                                .environmentObject(groupListViewModel)
                                .environmentObject(employeeScheduleViewModel)
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
                        try await saveForWidgetService.saveDataForWidgetToAppStorage(groupScheduleViewModel.arrayOfScheduleGroup.nextSchedules)
                    } catch {
                        print("Неудачная попытка загрузить расписание в AppStorage: \(error)")
                    }
                }.value
                
                saveForWidgetService.saveWeekNumberToAppStorage(weekViewModel.currentWeek) // запись номера недели в appStorage
                
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
        
        .environmentObject(weekViewModel) // много ли где нужно?
        
        
        
        
        .environment(\.saveForWidgetService, saveForWidgetService)
        .environmentObject(appStorageSave)
    }
}

#Preview {
    TabBarView()
}
