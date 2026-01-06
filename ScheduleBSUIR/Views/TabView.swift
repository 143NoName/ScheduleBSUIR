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
                
                Tab("Группы", systemImage: "person.3", value: 1) {
//                    UniversalList(array: network.arrayOfGroupsNum,  isLoadedArray: network.isLoadingArrayOfGroupsNum, isErrorLoadingArray: network.errorOfScheduleGroup, name: \.name, faculty: \.facultyAbbrev, specialization: \.specialityAbbrev, course: \.course, image: nil, depart: nil, urlID: nil)
                    UniversalListView(items: network.arrayOfGroupsNum, name: \.name, naviagtionValue: \.name , isLoading: network.isLoadingArrayOfGroupsNum, errorLoading: network.errorOfScheduleGroup , title: "Группы")
                }
                
                Tab("Преподаватели", systemImage: "calendar.and.person", value: 2) {
//                    UniversalList(array: network.scheduleForEmployees, isLoadedArray: network.isLoadingScheduleForEmployees, isErrorLoadingArray: network.errorOfEmployeesArray, name: \.fullName, faculty: nil, specialization: nil, course: nil, image: \.photoLink, depart: \.academicDepartment, urlID: \.urlId)
                    UniversalListView(items: network.scheduleForEmployees, name: \.fullName, naviagtionValue: \.urlId, isLoading:  network.isLoadingScheduleForEmployees, errorLoading: network.errorOfEmployeesArray, title: "Преподаватели")
                }
                
//                Tab("Преподаватели", systemImage: "calendar.and.person", value: 1) {
//                    EmployeesTab()
//                }
//                
//                if whoUser == .student && favoriteGroup != "Не выбрано" {
//                    Tab("Моя группа", systemImage: "star", value: 2) {
//                        NavigationStack {
//                            EachGroup(groupName: favoriteGroup)
//                        }
//                    }
//                } else if whoUser == .employee && employeeName != "Не выбрано" {
//                    Tab("Мое расписание", systemImage: "star", value: 2) {
//                        Text("obvoiebwrv")
//                    }
//                }
//                
//                Tab("Личный кабинет", systemImage: "person.circle", value: 3) {
//                    PersonalAccount(whoUser: $whoUser)
//                }
            }
            
            .task {
                await Task.detached {
//                    print(Thread.isMainThread)
                    await network.getCurrentWeek()           // получение текущей недели
                    await network.getArrayOfGroupNum()       // получение списка групп
                    await network.getArrayOfEmployees()      // получение списка преподавателей
                    
                    do {
                        try appStorage.saveDataForWidgetToAppStorage(network.arrayOfScheduleGroup.schedules)
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
