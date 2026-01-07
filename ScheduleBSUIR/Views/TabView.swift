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
    #warning("Сделать DI")
    @StateObject private var network = ViewModelForNetwork()
    @StateObject private var viewModelForFilter = ViewModelForFilterService()
                 private var appStorage = AppStorageService() // плохо, что view знает о сервисе, можно сдеать viewModel
    
    @State private var selectedTab: Int = 1
    @State private var splashScreen: Bool = true
    
    @State var whoUser: WhoUser = .none
    
    @State private var isPresentedSplashScreen: Bool = true
    @State var scale: CGFloat = 1
    @State var opacity: Double = 1
    
    @AppStorage("favoriteGroup", store: UserDefaults(suiteName: "group.foAppAndWidget.ScheduleBSUIR")) var favoriteGroup: String = "Не выбрано"
    @AppStorage("employeeName", store: UserDefaults(suiteName: "group.foAppAndWidget.ScheduleBSUIR")) var employeeName: String = "Не выбрано"

    
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                Tab("Все группы", systemImage: "person.3", value: 0) {
                    GroupsTab()
                }
                Tab("Преподаватели", systemImage: "calendar.and.person", value: 1) {
                    EmployeesTab()
                }
                
                // попытка сделать универсальный view
                
//                Tab("Группы", systemImage: "person.3", value: 0) {
//                    UniversalListView(items: network.arrayOfGroupsNum,
//                                      name: \.name,
//                                      naviagtionValue: \.name,
//                                      isLoading: network.isLoadingArrayOfGroupsNum,
//                                      errorLoading: network.errorOfScheduleGroup,
//                                      title: "Группы"
//                    ) { each in
//                        ViewForGroup(group: each)
//                    } navigation: { url in
//                        EachGroup(groupName: url)
//                    } loadigView: {
//                        ViewGroupIsLoading()
//                    }
//                }
//                
//                Tab("Преподаватели", systemImage: "calendar.and.person", value: 1) {
//                    UniversalListView(items: network.scheduleForEmployees,
//                                      name: \.fullName,
//                                      naviagtionValue: \.urlId,
//                                      isLoading: network.isLoadingScheduleForEmployees,
//                                      errorLoading: network.errorOfEmployeesArray,
//                                      title: "Преподаватели"
//                    ) { each in
//                        ViewForEmployee(employee: each)
//                    } navigation: { url in
//                        EachEmployee(employeeName: url)
//                    } loadigView: {
//                        ViewEmployeesEachIsLoading()
//                    }
//                }
                    
                if whoUser == .student && favoriteGroup != "Не выбрано" {
                    Tab("Моя группа", systemImage: "star", value: 2) {
                        NavigationStack {
                            EachGroup(groupName: favoriteGroup)
                        }
                    }
                } else if whoUser == .employee && employeeName != "Не выбрано" {
                    Tab("Мое расписание", systemImage: "star", value: 2) {
                        Text("obvoiebwrv")
                    }
                }
                
                Tab("Личный кабинет", systemImage: "person.circle", value: 3) {
                    PersonalAccount(whoUser: $whoUser)
                }
            }
            
            .task {
                await Task.detached {
                    await network.getCurrentWeek()           // получение текущей недели
                    await network.getArrayOfGroupNum()       // получение списка групп
                    await network.getArrayOfEmployees()      // получение списка преподавателей
                    
                    do {
                        try await appStorage.saveDataForWidgetToAppStorage(network.arrayOfScheduleGroup.schedules)
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
            
        }
        .environmentObject(network)
        .environmentObject(viewModelForFilter)
        .environment(\.appStorageKey, appStorage)
    }
}

#Preview {
    TabBarView()
}
