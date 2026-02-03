//
//  SelectorView.swift
//  ScheduleBSUIR
//
//  Created by andrew on 20.12.25.
//

import SwiftUI
import WidgetKit

struct SelectorViewForPersonalAccount: View {
    
    @AppStorage("whoUser", store: UserDefaults(suiteName: "group.foAppAndWidget.ScheduleBSUIR")) var whoUser: WhoUser = .none
    @AppStorage("subGroup", store: UserDefaults(suiteName: "group.foAppAndWidget.ScheduleBSUIR")) var subGroup: SubGroupInPicker = .all
    @AppStorage("favoriteGroup", store: UserDefaults(suiteName: "group.foAppAndWidget.ScheduleBSUIR")) var favoriteGroup: String = "Не выбрано"
    @AppStorage("employeeName", store: UserDefaults(suiteName: "group.foAppAndWidget.ScheduleBSUIR")) var employeeName: String = "Не выбрано"
    
    @State var showAll: Bool = true
        
    var body: some View {
        NavigationStack {
            VStack {
                ButtonShowMaxOrMin(showAll: $showAll)
                VStack {
                    if showAll {
                        if whoUser == .student {
                            MaxViewGroupInSelector()                 // полный вид для группы
                        } else if whoUser == .employee {
                            MaxViewEmployeeInSelector()             // полный вид для преподавателей
                        }
                        VStack {
                            VStack(alignment: .leading) {
                                Text("Пользователь")
                                    .font(.system(size: 16, weight: .semibold))
                                    .padding(.leading)
                                Picker("", selection: $whoUser) {
                                    Text("Ученик").tag(WhoUser.student)
                                    Text("Преподаватель").tag(WhoUser.employee)
                                    Text("Другое").tag(WhoUser.none)
                                }
                                .pickerStyle(.segmented)
                            }
                            .padding(10)
                        }
                    } else {
                        if whoUser == .student {
                            MinViewGroupInSelector(subGroup: subGroup.inString, favoriteGroup: favoriteGroup, whoUser: whoUser.rawValue, showAll: $showAll)                       // уменьшенный вид для группы
                        } else if whoUser == .employee {
                            MimViewEmployeeInSelector(employeeName: employeeName, whoUser: whoUser.rawValue, showAll: $showAll)  // уменьшенный вид для преподавателей
                        } else {
                            MinViewNoneInSelector(whoUser: whoUser.rawValue, showAll: $showAll)
                        }
                    }
                }
                .glassEffect(.regular , in: .rect(cornerRadius: 20))
                .animation(.easeOut, value: whoUser)
            }
            .padding()
        }
    }
}

//#Preview {
//    return SelectorViewForPersonalAccount()
//        .environmentObject(AppStorageSave())
//}

// кнопка для переключения вида
struct ButtonShowMaxOrMin: View {
    
    @Binding var showAll: Bool
    
    var body: some View {
        HStack {
            Spacer()
            Button {
                withAnimation(.easeOut) {
                    showAll.toggle()
                }
            } label: {
                Image(systemName: "chevron.down")
                    .padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                    .rotationEffect(showAll ? .degrees(0) : .degrees(180))
            }
            .buttonStyle(GlassButtonStyle(.regular))
        }
    }
}
// кнопка для переключения вида


// MARK: полный вид

// ученик
struct MaxViewGroupInSelector: View {
    
    @AppStorage("scheduleForWidget", store: UserDefaults(suiteName: "group.foAppAndWidget.ScheduleBSUIR")) var scheduleForWidget: Data?                 // пусть это будет универсальные данные в виджете (массив дней и расписаний к ним)
    @AppStorage("subGroup", store: UserDefaults(suiteName: "group.foAppAndWidget.ScheduleBSUIR")) var subGroup: SubGroupInPicker = .all
    @AppStorage("favoriteGroup", store: UserDefaults(suiteName: "group.foAppAndWidget.ScheduleBSUIR")) var favoriteGroup: String = "Не выбрано"
    
//    @Environment(AppStorageSave.self) private var appStorageSave                                           // ключи AppStorage
    @Environment(NetworkViewModelForListGroups.self) var groupListViewModel                        // viewModel для получения массива преподавателей и загрузки его расписания для дальнейшей загрузки в AppStorage
    @Environment(NetworkViewModelForScheduleGroups.self) var scheduleGroup                         // расписание гурппы
        
    let encoder = JSONEncoder()
        
    var body: some View {
//        @Bindable var appStorageSave = appStorageSave
        HStack {
            VStack(alignment: .leading) {
                Text("Подгруппа")
                    .font(.system(size: 16, weight: .semibold))
                    .padding(.leading)
                Picker("", selection: $subGroup) {
                    Text("Все").tag(SubGroupInPicker.all)
                    Text("1").tag(SubGroupInPicker.first)
                    Text("2").tag(SubGroupInPicker.second)
                }
                .pickerStyle(.segmented)
            }
            VStack(spacing: 8)  {
                Text("Группа")
                    .font(.system(size: 16, weight: .semibold))
                HStack {
                    NavigationLink(value: "choice") {
                        Text(favoriteGroup)
                            .tint(Color.primary)
                            .padding(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                            .background(Color.gray.opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 22))
                    }
                }
            }
            .padding(.leading, 10)
            
            .onChange(of: favoriteGroup) {                                                                // при изменении выбранной группы:
                                
                // при изменении: надо получить расписание группы, отфильтровать, записать в appStorage и обновить виджет
                Task {
                    let data = await scheduleGroup.getScheduleGroupForWidget(group: favoriteGroup)        // получение расписания
    
                    // надо отфильтровать                                                                                   // фильтрация расписания
                    
                    do {                                                                                                    // кодирование и запись данных
                        scheduleForWidget = try encoder.encode(data)
                    } catch {
                        print("Проблема с декодированием")
                    }
                }
                
                // обновиться само
//                WidgetCenter.shared.reloadAllTimelines()                                                                    // обновленние
                
                
                // тут надо загружать расписание в AppStorage groupSchedule
                
//                Task {
//                    do {
//                        await network.getScheduleGroup(group: favoriteGroup) // получение расписания
//                        try appStorage.saveDataForWidgetToAppStorage(network.arrayOfScheduleGroup.schedules) // загрузка расписания в виджет
//                    } catch {
//                        print("Неудачная попытка загрузить расписание в AppStorage: \(error)")
//                    }
//                    
//                    WidgetCenter.shared.reloadAllTimelines()
//                }
            }
            // тут при изменении номера группы надо изменять номер группы и ее расписание (номер группы изменяется реактивно, а для изменения группы надо вызывать функцию получения и сохранения расписания)
            
        }
        .padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 10))
        
        .navigationDestination(for: String.self) { _ in
            UniversalPicker(selected: $favoriteGroup, title: "Группы", items: groupListViewModel.arrayOfGroupsNum, value: \.name, secondValue: \.name)
        }
    }
}
// ученик

// преподаватель
struct MaxViewEmployeeInSelector: View {
    
    #warning("Надо бы перенести в appStorageSaveKey")
    @AppStorage("employeeSchedule", store: UserDefaults(suiteName: "group.foAppAndWidget.ScheduleBSUIR")) var employeeSchedule: Data?
    @AppStorage("employeeName", store: UserDefaults(suiteName: "group.foAppAndWidget.ScheduleBSUIR")) var employeeName: String = "Не выбрано"
    
//    @Environment(AppStorageSave.self) private var appStorageSave                               // ключи AppStorage
    @Environment(NetworkViewModelForListEmployees.self) var employeeListViewModel          // viewModel для получения массива преподавателей и загрузки его расписания для дальнейшей загрузки в AppStorage
            
    @StateObject private var viewModelForAppStorage = ViewModelForAppStorage()
        
    var employeeNameToFio: String {
        if employeeName != "Не выбрано" {
            let words = employeeName.split(separator: " ")
                .enumerated()
                .map { index, word in
                    index < 1 ? word : "\(word.first!)."
                }
                .joined(separator: " ")
            return words
        } else {
            return employeeName
        }
    }
    #warning("В AppStorage сохраняется urlId, а не фио")
    
    var body: some View {
//        @Bindable var appStorageSave = appStorageSave
        VStack(alignment: .leading) {
            Text("Ваше ФИО")
                .font(.system(size: 16, weight: .semibold))
                .padding(.leading)
            HStack {
                Spacer()
                Text(employeeNameToFio)
                Spacer()
                NavigationLink(value: "choice") {
                    Text("Выбор")
                        .tint(Color.primary)
                        .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .background(Color.gray.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 22))
                }
            }
        }
        .padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 10))
        
        .onChange(of: employeeName) {                                     // при изменении выбранного преподавателя
            print(employeeName)
            
//            viewModelForAppStorage.saveFavoriteEmployeeScheduleToAppStorage(networkService.getSchedule(appStorageSaveKey.employeeName))

        }
        
        .navigationDestination(for: String.self) { _ in
            UniversalPicker(selected: $employeeName, title: "Преподаватели", items: employeeListViewModel.scheduleForEmployees, value: \.fio, secondValue: \.urlId)
        }
    }
}
// преподаватель
// полный вид


// MARK: минимальный вид

// ученик
struct MinViewGroupInSelector: View {
    
    let subGroup: String
    let favoriteGroup: String
    let whoUser: String
    
    @Binding var showAll: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Подгруппа:")
                    .font(.system(size: 16, weight: .semibold))
                Text(subGroup)
            }
            Spacer()
            VStack(alignment: .leading) {
                Text("Группа:")
                    .font(.system(size: 16, weight: .semibold))
                Text(favoriteGroup)
            }
            Spacer()
            VStack(alignment: .leading) {
                Text("Пользователь:")
                    .font(.system(size: 16, weight: .semibold))
                Text(whoUser)
            }
        }
        .padding(10)
        .onTapGesture {
            withAnimation(.easeOut) {
                showAll.toggle()
            }
        }
    }
}
// ученик

// преподаватель
struct MimViewEmployeeInSelector: View {
    
    let employeeName: String
    let whoUser: String
    @Binding var showAll: Bool
    
    var employeeNameToFio: String {
        if employeeName != "Не выбрано" {
            let words = employeeName.split(separator: " ")
                .enumerated()
                .map { index, word in
                    index < 1 ? word : "\(word.first!)."
                }
                .joined(separator: " ")
            return words
        } else {
            return employeeName
        }
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("ФИО:")
                    .font(.system(size: 16, weight: .semibold))
                Text(employeeNameToFio)
            }
            Spacer()
            VStack(alignment: .leading) {
                Text("Пользователь:")
                    .font(.system(size: 16, weight: .semibold))
                Text(whoUser)
            }
        }
        .padding(10)
        .onTapGesture {
            withAnimation(.easeOut) {
                showAll.toggle()
            }
        }
    }
}
// преподаватель

// никто
struct MinViewNoneInSelector: View {
    
    let whoUser: String
    @Binding var showAll: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Пользователь:")
                    .font(.system(size: 16, weight: .semibold))
                Text(whoUser)
            }
            Spacer()
        }
        .padding(10)
        .onTapGesture {
            withAnimation(.easeOut) {
                showAll.toggle()
            }
        }
    }
}
// никто
// минимальный вид

// MARK: универсальный

// универсальный пикер
struct UniversalPicker<T: Identifiable>: View {
    
    @Binding var selected: String
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
        
    let title: String                       // pageName
    let items: [T]                          // массив элементов для отображения
    let value: KeyPath<T, String>           // название ключа для получения либо ФИО либо ГРУППА
    let secondValue: KeyPath<T, String>     // необязательный ключ для urlID преподавателя
    
    var body: some View {
        ZStack {
            if colorScheme == .light {
                Color.gray
                    .opacity(0.15)
                    .ignoresSafeArea(edges: .all)
            }
            List {
                Button {
                    selected = "Не выбрано"
                    dismiss()
                } label: {
                    HStack {
                        Text("Не выбрано")
                            .tint(Color.primary)
                        Spacer()
                        selected == "Не выбрано" ? Image(systemName: "checkmark") : nil
                    }
                }
                
                ForEach(items) { each in
                    Button {
                        selected = each[keyPath: secondValue]
                        dismiss()
                    } label: {
                        HStack {
                            Text(each[keyPath: value])
                                .tint(Color.primary)
                            Spacer()
                            selected == each[keyPath: value] ? Image(systemName: "checkmark") : nil
                            #warning("Для преподавателей: при проверке смотрется fio и полное значение (вроде как)")
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
// универсальный пикер
