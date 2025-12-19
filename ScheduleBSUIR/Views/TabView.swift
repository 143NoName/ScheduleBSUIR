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
    
    @StateObject private var network = ViewModelForNetwork()
    @StateObject private var viewModelForFilter = ViewModelForFilterService()
                 private var appStorage = AppStorageService() // плохо, что view знает о сервисе, можно сдеать viewModel
    
    @State private var selectedTab: Int = 1
    @State private var splashScreen: Bool = true
    
    @State private var isPresentedSplashScreen: Bool = true
    @State var scale: CGFloat = 1
    @State var opacity: Double = 1
    
    @AppStorage("favoriteGroup", store: UserDefaults(suiteName: "group.foAppAndWidget.ScheduleBSUIR")) var favoriteGroup: String = ""
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                Tab("Все группы", systemImage: "person.3", value: 0) {
                    Groups()
                }
                
                if favoriteGroup != "" {
                    Tab("Моя группа", systemImage: "star", value: 1) {
                        NavigationStack {
                            EachGroup(groupName: favoriteGroup)
                        }
                    }
                }
                
                Tab("Преподаватели", systemImage: "calendar.and.person", value: 2) {
                    Text("Преподаватели")
                }
                
                Tab("Личный кабинет", systemImage: "person.circle", value: 3) {
                    PersonalAccount()
                }
                
            }
            
            .task {
                await network.getCurrentWeek()           // получение текущей недели
                await network.getArrayOfGroupNum()       // получение списка групп
                
                do {
                    try appStorage.saveDataForWidgetToAppStorage(network.arrayOfScheduleGroup.schedules)
                } catch {
                    print("Неудачная попытка загрузить расписание в AppStorage: \(error)")
                }
                
                appStorage.saveWeekNumberToAppStorage(network.currentWeek)        
            }
            
            // показывать начальное окно
            if isPresentedSplashScreen {
                StartView(opacity: $opacity, scale: $scale)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        withAnimation(.easeOut(duration: 1)) {
                            scale = 15
                            opacity = 0
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
                            isPresentedSplashScreen = false
                        }
                    }
                }
            }
            
        }
        .environmentObject(network)
        .environmentObject(viewModelForFilter)
        .environment(\.appStorageKey, appStorage)
    }
}

#Preview {
    TabBarView()
}
