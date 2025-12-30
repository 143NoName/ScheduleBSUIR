//
//  SelectorView.swift
//  ScheduleBSUIR
//
//  Created by andrew on 20.12.25.
//

import SwiftUI
import WidgetKit

struct SelectorViewForPersonalAccount: View {
    @Environment(\.appStorageKey) var appStorageKey
    @EnvironmentObject var network: ViewModelForNetwork
    
    @State var showAll: Bool = true
    @Binding var whoUser: WhoUser
    
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
                            MinViewGroupInSelector(showAll: $showAll)                       // уменьшенный вид для группы
                        } else if whoUser == .employee {
                            MimViewEmployeeInSelector(whoUser: whoUser, showAll: $showAll)  // уменьшенный вид для преподавателей
                        } else {
                            MimViewNoneInSelector(whoUser: whoUser, showAll: $showAll)
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


#Preview {
    @Previewable @State var whoUser: WhoUser = .student
    
    return SelectorViewForPersonalAccount(whoUser: $whoUser)
        .environmentObject(ViewModelForNetwork())
}

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
    
    @EnvironmentObject var network: ViewModelForNetwork
    
    @AppStorage("subGroup", store: UserDefaults(suiteName: "group.foAppAndWidget.ScheduleBSUIR")) var subGroup: SubGroupInPicker = .all
    @AppStorage("favoriteGroup", store: UserDefaults(suiteName: "group.foAppAndWidget.ScheduleBSUIR")) var favoriteGroup: String = "Не выбрано"
    
    var body: some View {
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
                        Text("\(favoriteGroup)")
                            .tint(Color.primary)
                            .padding(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                            .background(Color.gray.opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 22))
                    }
                }
            }
            .padding(.leading, 10)
            
            // обновление виджета
            
//            .onChange(of: favoriteGroup) {
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
//            }
            // тут при изменении номера группы надо изменять номер группы и ее расписание (номер группы изменяется реактивно, а для изменения группы надо вызывать функцию получения и сохранения расписания)
            
            .onChange(of: subGroup) {
                WidgetCenter.shared.reloadAllTimelines()
                // надо будет тут опять вызывать обновление данных в виджете так как надо отфильтровать по подгруппе
            }
        }
        .padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 10))
        
        .navigationDestination(for: String.self) { _ in
            UniversalPicker(selected: $favoriteGroup, title: "Преподаватели", items: network.arrayOfGroupsNum, value: \.name, secondValue: \.name)
        }
    }
}

struct PickerGroups: View {
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var network: ViewModelForNetwork
    @AppStorage("favoriteGroup", store: UserDefaults(suiteName: "group.foAppAndWidget.ScheduleBSUIR")) var favoriteGroup: String = "Не выбрано"
    
    var body: some View {
        ZStack {
            if colorScheme == .light {
                Color.gray
                    .opacity(0.15)
                    .ignoresSafeArea(edges: .all)
            }
            List {
                ForEach(network.arrayOfGroupsNum) { each in
                    Button {
                        favoriteGroup = each.name
                        dismiss()
                    } label: {
                        Text(each.name)
                            .tint(Color.primary)
                    }
                }
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("Группы")
    }
}
// ученик

// преподаватель
struct MaxViewEmployeeInSelector: View {
    
    @EnvironmentObject var network: ViewModelForNetwork
    
    @AppStorage("employeeName", store: UserDefaults(suiteName: "group.foAppAndWidget.ScheduleBSUIR")) var employeeName: String = "Не выбрано"
    
    var employeeNameToFio: String {
        let words = employeeName.split(separator: " ")
            .enumerated()
            .map { index, word in
                index < 1 ? word : "\(word.first!)."
            }
            .joined(separator: " ")
        return words
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Ваше ФИО")
                .font(.system(size: 16, weight: .semibold))
                .padding(.leading)
            HStack {
                NavigationLink(value: "choice") {
                    Text("Выбор")
                        .tint(Color.primary)
                        .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .background(Color.gray.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 22))
                }
                Spacer()
                Text("\(employeeNameToFio)")
                Spacer()
            }
        }
        .padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 10))
        
        .navigationDestination(for: String.self) { _ in
            UniversalPicker(selected: $employeeName, title: "Преподаватели", items: network.scheduleForEmployees, value: \.fio, secondValue: \.urlId)
        }
    }
}

struct PickerEmployees: View {
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var network: ViewModelForNetwork
    @AppStorage("employeeName", store: UserDefaults(suiteName: "group.foAppAndWidget.ScheduleBSUIR")) var employeeName: String = "Не выбрано"
    
    var body: some View {
        ZStack {
            if colorScheme == .light {
                Color.gray
                    .opacity(0.15)
                    .ignoresSafeArea(edges: .all)
            }
            List {
                ForEach(network.scheduleForEmployees) { each in
                    Button {
                        employeeName = each.fio
                        dismiss()
                    } label: {
                        Text(each.fio)
                            .tint(Color.primary)
                    }
                }
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("Преподаватели")
    }
}
// преподаватель
// полный вид


// MARK: минимальный вид
// ученик
struct MinViewGroupInSelector: View {
    #warning("subGroup это число или enum")
    @AppStorage("subGroup", store: UserDefaults(suiteName: "group.foAppAndWidget.ScheduleBSUIR")) var subGroup: SubGroupInPicker = .all
    @AppStorage("favoriteGroup", store: UserDefaults(suiteName: "group.foAppAndWidget.ScheduleBSUIR")) var favoriteGroup: String = "Не выбрано"
    #warning("Вместо appStorage лучше просто передавать это знаяения (из главного вида в мелкие)")
    @State var whoUser: WhoUser = .student
    
    @Binding var showAll: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Подгруппа:")
                    .font(.system(size: 16, weight: .semibold))
                Text("\(subGroup.inString)")
            }
            Spacer()
            VStack(alignment: .leading) {
                Text("Группа:")
                    .font(.system(size: 16, weight: .semibold))
                Text("\(favoriteGroup)")
            }
            Spacer()
            VStack(alignment: .leading) {
                Text("Пользователь:")
                    .font(.system(size: 16, weight: .semibold))
                Text("\(whoUser.rawValue)")
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
    
    let whoUser: WhoUser
    @Binding var showAll: Bool
    @AppStorage("employeeName", store: UserDefaults(suiteName: "group.foAppAndWidget.ScheduleBSUIR")) var employeeName: String = "Не выбрано"
    
    var employeeNameToFio: String {
        let words = employeeName.split(separator: " ")
            .enumerated()
            .map { index, word in
                index < 1 ? word : "\(word.first!)."
            }
            .joined(separator: " ")
        return words
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("ФИО:")
                    .font(.system(size: 16, weight: .semibold))
                Text("\(employeeNameToFio)")
            }
            Spacer()
            VStack(alignment: .leading) {
                Text("Пользователь:")
                    .font(.system(size: 16, weight: .semibold))
                Text("\(whoUser.rawValue)")
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
struct MimViewNoneInSelector: View {
    
    let whoUser: WhoUser
    @Binding var showAll: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Пользователь:")
                    .font(.system(size: 16, weight: .semibold))
                Text("\(whoUser.rawValue)")
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
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @Binding var selected: String           // название хранилища в AppStorage
    
    let title: String                       // pageName
    let items: [T]                          // массив элементов для отображения
    let value: KeyPath<T, String>           // название ключа для получения либо ФИО либо ГРУППА
    let secondValue: KeyPath<T, String>   // необязательный ключ для urlID преподавателя
    
    var body: some View {
        ZStack {
            if colorScheme == .light {
                Color.gray
                    .opacity(0.15)
                    .ignoresSafeArea(edges: .all)
            }
            List {
                ForEach(items) { each in
                    Button {
                        selected = each[keyPath: secondValue]
                        dismiss()
                    } label: {
                        Text(each[keyPath: value])
                            .tint(Color.primary)
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
