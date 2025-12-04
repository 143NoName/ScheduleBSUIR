//
//  TabView.swift
//  ScheduleBSUIR
//
//  Created by user on 28.10.25.
//

import SwiftUI

struct TabBarView: View {
    
    @StateObject var viewModel = ViewModel()
    
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
                await viewModel.getCurrentWeek()           // получение текущей недели
                await viewModel.getArrayOfGroupNum()       // получение списка групп
                
//                viewModel.saveDataForWidgetToAppStorage(data: viewModel.arrayOfScheduleGroup.schedules) // загрузка данных в AppStorage
                
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
        .environmentObject(viewModel)
    }
}

#Preview {
    TabBarView()
}
