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

//struct AppStorageSaveKey: EnvironmentKey {
//    static let defaultValue: AppStorageSave = AppStorageSave()
//}

extension EnvironmentValues {
    var saveForWidgetService: SaveForWidgetService? {
        get { self[SaveForWidgetServiceKey.self] }
        set { self[SaveForWidgetServiceKey.self] = newValue }
    }
    
//    var appStorageSaveService: AppStorageSave {
//        get { self[AppStorageSaveKey.self] }
//        set { self[AppStorageSaveKey.self] = newValue }
//    }
//    var isPortraitOniPhone: Bool {
//        get { self[IsPortraitOniPhone.self] }
//        set { self[IsPortraitOniPhone.self] = newValue }
//    }
}

struct TabBarView: View {
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    #warning("Сделать DI")
    @State private var weekViewModel = NetworkViewModelForWeek()                              // получение текущей недели
    @State private var groupListViewModel = NetworkViewModelForListGroups()                   // получение списка групп
    @State private var groupScheduleViewModel = NetworkViewModelForScheduleGroups()           // получение расписания группы (тут только один экземпляр с сетевым менеджером)
    @State private var employeeListViewModel = NetworkViewModelForListEmployees()             // получение списка преподавателей
    @State private var employeeScheduleViewModel = NetworkViewModelForScheduleEmployees()     // получение расписания преподавателя
           private let saveForWidgetService = SaveForWidgetService()                                                // плохо, что view знает о сервисе, можно сдеать viewModel
    
    
    @State private var selectedTab: Int = 2
    
    @AppStorage("whoUser", store: UserDefaults(suiteName: "group.foAppAndWidget.ScheduleBSUIR")) var whoUser: WhoUser = .none
    @AppStorage("favoriteGroup", store: UserDefaults(suiteName: "group.foAppAndWidget.ScheduleBSUIR")) var favoriteGroup: String = "Не выбрано"
    @AppStorage("employeeName", store: UserDefaults(suiteName: "group.foAppAndWidget.ScheduleBSUIR")) var employeeName: String = "Не выбрано"
    
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
                }
                Tab("Преподаватели", systemImage: "calendar.and.person", value: 1) {
                    EmployeesTab()
                }
                if whoUser == .student && favoriteGroup != "Не выбрано" {
                    Tab("Моя группа", systemImage: "star", value: 2) {
                        NavigationStack {
                            EachGroup(groupName: favoriteGroup)
                        }
                    }
                } else if whoUser == .employee && employeeName != "Не выбрано" {
                    Tab("Мое расписание", systemImage: "star", value: 2) {
                        NavigationStack {
                            EachEmployee(employeeName: employeeName)
                        }
                    }
                }
                Tab("Личный кабинет", systemImage: "person.circle", value: 3) {
                    PersonalAccount()
                    // тут нужны 2 экзампляра (сетевой для получения списков (можно убрать) и хранилище)
                }
            }
            
            .task {
                await weekViewModel.getCurrentWeek()                            // получение текущей недели
                await groupListViewModel.getArrayOfGroupNum()                   // получение списка групп
                await employeeListViewModel.getArrayOfEmployees()               // получение списка преподавателей
            
                do {
                    try saveForWidgetService.saveDataForWidgetToAppStorage(groupScheduleViewModel.arrayOfScheduleGroup.schedules)
                } catch {
                    print("Неудачная попытка загрузить расписание в AppStorage: \(error)")
                }
                
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
        
        .environment(weekViewModel)
        .environment(groupListViewModel)                                      // список групп
        .environment(employeeListViewModel)                                   // список преподавателей
        .environment(groupScheduleViewModel)                                  // расписание группы
        .environment(employeeScheduleViewModel)                               // расписание преподавателя
        .environment(\.saveForWidgetService, saveForWidgetService)
//        .environment(appStorageSave)
        #warning("Сделать @Observable")
    }
}

#Preview {
    TabBarView()
}
