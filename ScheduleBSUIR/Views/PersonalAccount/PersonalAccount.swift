//
//  PersonalAccount.swift
//  ScheduleBSUIR
//
//  Created by user on 5.11.25.
//

import SwiftUI
import WidgetKit

enum WhoUser: String {
    case student = "Ученик"
    case employee = "Преподаватель"
    case none = "Другое"
}

struct PersonalAccount: View {
    
    @EnvironmentObject var network: ViewModelForNetwork
    
    @Environment(\.colorScheme) var colorScheme
    
    private var appStorage = AppStorageService()
    
    @State var whoUser: WhoUser = .none
    @State private var isShowSettings: Bool = false
    @State private var name: String = ""
    
    @AppStorage("studentName") var studentName: String = ""
    @AppStorage("studentSurname") var studentSurname: String = ""
    @AppStorage("studentPatronymic") var studentPatronymic: String = ""
        
    @AppStorage("favoriteGroup", store: UserDefaults(suiteName: "group.foAppAndWidget.ScheduleBSUIR")) var favoriteGroup: String = ""
    @AppStorage("subGroup", store: UserDefaults(suiteName: "group.foAppAndWidget.ScheduleBSUIR")) var subGroup: Int = 0
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                if colorScheme == .light {
                    Color.gray
                        .opacity(0.15)
                        .ignoresSafeArea(edges: .all)
                }
                #warning("Может быть вынести ZStack с условием if/else и цветом на заднем фоне")
                VStack {
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
                        
//                        Section(footer: Text("Твоя группа, которая будет отображаться по умолчанию в приложении и в виджетах")) {
//                            Picker("Номер группы", selection: $favoriteGroup) {
//                                Text("Не выбрано").tag("")
//                                ForEach(network.arrayOfGroupsNum, id: \.id) { group in
//                                    Text(group.name).tag(group.name)
//                                }
//                            }
//                            .pickerStyle(.navigationLink)
//                            
//                            Picker("Подгруппа", selection: $subGroup) {
//                                Text("Все подгруппы").tag(0)
//                                Text("Первая подгруппа").tag(1)
//                                Text("Вторая подгруппа").tag(2)
//                            }
//                            .pickerStyle(.navigationLink)
//                            
//                        }
                        
                        .onChange(of: favoriteGroup) {
                            Task {
                                do {
                                    await network.getScheduleGroup(group: favoriteGroup) // получение расписания
                                    try appStorage.saveDataForWidgetToAppStorage(network.arrayOfScheduleGroup.schedules) // загрузка расписания в виджет
                                } catch {
                                    print("Неудачная попытка загрузить расписание в AppStorage: \(error)")
                                }
                                
                                WidgetCenter.shared.reloadAllTimelines()
                            }
                        }
                        // тут при изменении номера группы надо изменять номер группы и ее расписание (номер группы изменяется реактивно, а для изменения группы надо вызывать функцию получения и сохранения расписания)
                        
                        .onChange(of: subGroup) {
                            WidgetCenter.shared.reloadAllTimelines()
                            // надо будет тут опять вызывать обновление данных в виджете так как надо отфильтровать по подгруппе
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
                
                SelectorViewForPersonalAccount()
                
                
                .navigationBarTitle("Личный кабинет")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button{
                            isShowSettings.toggle()
                        } label: {
                            Image(systemName: "gearshape")
//                                .symbolEffect()
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
    let viewModelForNetwork = ViewModelForNetwork()
    viewModelForNetwork.arrayOfGroupsNum = []
    
    return NavigationView {
        PersonalAccount()
            .environmentObject(viewModelForNetwork)
    }
}
