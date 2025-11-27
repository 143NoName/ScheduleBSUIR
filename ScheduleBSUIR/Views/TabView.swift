//
//  TabView.swift
//  ScheduleBSUIR
//
//  Created by user on 28.10.25.
//

import SwiftUI

struct TabBarView: View {
//    let appStorageService = AppStorageService()
//    let networkService = NetworkService()
//    let funcs = MoreFunctions()
    
    @StateObject var viewModel = ViewModel(
//        appStorageService: appStorageService,
//        networkService: networkService,
//        funcs: funcs
    )
    
    @State private var selectedTab: Int = 1
    @State private var splashScreen: Bool = true
    
    @AppStorage("favoriteGroup", store: UserDefaults(suiteName: "group.foAppAndWidget.ScheduleBSUIR")) var favoriteGroup: String = ""
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                Groups()
                    .tabItem {
                        Text("Все группы")
                        Image(systemName: "person.3")
                    }
                    .tag(0)
                if favoriteGroup != "" {
                    EachGroup(groupName: favoriteGroup)
                        .tabItem {
                            Text("Моя группа")
                            Image(systemName: "star")
                        }
                        .tag(1)
                }
                
                PersonalAccount()
                    .tabItem {
                        Text("Личный кабинет")
                        Image(systemName: "person")
                    }
                    .tag(2)
            }
            .task {
                await viewModel.getCurrentWeek()           // получение текущей недели
                await viewModel.getArrayOfGroupNum()       // получение списка групп

                viewModel.saveDataForWidgetToAppStorage(data: viewModel.arrayOfScheduleGroup.schedules)
            }
            
            if !viewModel.isLoadingArrayOfGroupsNum {
                StartView()
            }           // показывать начальное окно
        }
        .environmentObject(viewModel)
    }
}

#Preview {
    TabBarView()
}
