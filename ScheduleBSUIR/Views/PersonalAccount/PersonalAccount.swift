//
//  PersonalAccount.swift
//  ScheduleBSUIR
//
//  Created by user on 5.11.25.
//

import SwiftUI
import WidgetKit

struct PersonalAccount: View {
    
    @EnvironmentObject var viewModel: ViewModel
    
    @Environment(\.colorScheme) var colorScheme
    
    let funcs = MoreFunctions()
    
    @State private var isShowSettings: Bool = false
    @State private var name: String = ""
    
    @AppStorage("studentName") var studentName: String = ""
    @AppStorage("studentSurname") var studentSurname: String = ""
    @AppStorage("studentPatronymic") var studentPatronymic: String = ""
        
    @AppStorage("favoriteGroup", store: UserDefaults(suiteName: "group.foAppAndWidget.ScheduleBSUIR")) var favoriteGroup: String = ""
    
    @AppStorage("studentSubGroup") var studentSubGroup: String = "0"
    
    var body: some View {
        NavigationStack {
            ZStack {
                if colorScheme == .light {
                    Color.gray
                        .opacity(0.1)
                        .ignoresSafeArea(edges: .all)
                }
                
                List {
                    Section {
                        Image("PlainPhoto")
                            .resizable()
                            .frame(width: 150, height: 150)
                            .clipShape(RoundedRectangle(cornerRadius: 75))
                            
                    }
                    .frame(maxWidth: .infinity)

                    Section {
                        
                        NavigationLink(value: InEditProfile.name) {
                            Text(studentName.isEmpty ? "Имя студента" : "Имя: \(studentName)")
                        }
                        NavigationLink(value: InEditProfile.surname) {
                            Text(studentSurname.isEmpty ? "Фамилия студента" : "Фамилия: \(studentSurname)")
                        }
                        NavigationLink(value: InEditProfile.patronymic) {
                            Text(studentPatronymic.isEmpty ? "Отвество студента" : "Ответство: \(studentPatronymic)")
                        }
                        
                    }
                    
                    Section(footer: Text("Твоя группа, которая будет отображаться по умолчанию в приложении и в виджетах")) {
                        Picker("Номер группы", selection: $favoriteGroup) {
                            Text("Не выбрано").tag("")
                            ForEach(viewModel.arrayOfGroupsNum, id: \.id) { group in
                                Text(group.name).tag(group.name)
                            }
                        }
                        .pickerStyle(.navigationLink)
                        
                        Picker("Подгруппа", selection: $studentSubGroup) {
                            Text("Все подгруппы").tag("0")
                            Text("Первая подгруппы").tag("1")
                            Text("Вторая подгруппы").tag("2")
                        }
                        .pickerStyle(.navigationLink)
                        
                    }
                    
                    .onChange(of: favoriteGroup) {
                        Task {
                            await viewModel.getScheduleGroup(group: favoriteGroup)
                            try funcs.saveDataForWidgetToAppStorage(viewModel.arrayOfScheduleGroup.schedules)
                            
                            WidgetCenter.shared.reloadAllTimelines()
                            
//                            await viewModel.getScheduleGroup(group: favoriteGroup)
                        }
                    } // вот тут при изменении номера группы надо изменять номер группы и ее расписание (номер группы изменяется реактивно, а для изменения группы надо вызывать функцию получения и сохранения расписания)
                }
                .scrollContentBackground(.hidden)
                .navigationBarTitle("Личный кабинет")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button{
                            isShowSettings.toggle()
                        } label: {
                            Image(systemName: "gearshape")
                        }
                    }
                }
            }
            .navigationDestination(for: InEditProfile.self) { parametr in
                EditProfile(parametr: parametr)
            }
        }
    }
}

#Preview() {
    let viewModel = ViewModel()
    viewModel.arrayOfGroupsNum = []
    
    return NavigationView {
        PersonalAccount()
            .environmentObject(viewModel)
    }
}
