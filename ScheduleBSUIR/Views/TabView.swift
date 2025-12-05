//
//  TabView.swift
//  ScheduleBSUIR
//
//  Created by user on 28.10.25.
//

import SwiftUI

struct ViewModelForAppStorageKey: EnvironmentKey {
    static let defaultValue: ViewModelForAppStorage? = nil  // Может быть optional
}

extension EnvironmentValues {
    var viewModelForAppStorageKey: ViewModelForAppStorage? {
        get { self[ViewModelForAppStorageKey.self] }
        set { self[ViewModelForAppStorageKey.self] = newValue }
    }
}

struct TabBarView: View {
    
    @StateObject private var viewModelForNetwork = ViewModelForNetwork()
    @StateObject private var viewModelForFilter = ViewModelForFilterService()
                 private var viewModelForAppStorage = ViewModelForAppStorage()
    
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
                
                Tab("Личный кабинет", systemImage: "person.circle", value: 2) {
                    PersonalAccount()
                }
                
            }
            .task {
                await viewModelForNetwork.getCurrentWeek()           // получение текущей недели
                await viewModelForNetwork.getArrayOfGroupNum()       // получение списка групп
                
//                viewModelForNetwork.saveDataForWidgetToAppStorage(data: viewModelForNetwork.arrayOfScheduleGroup.schedules) // загрузка данных в AppStorage
                
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
        .environmentObject(viewModelForNetwork)
        .environmentObject(viewModelForFilter)
        .environment(\.viewModelForAppStorageKey, viewModelForAppStorage)
    }
}

#Preview {
    TabBarView()
}
