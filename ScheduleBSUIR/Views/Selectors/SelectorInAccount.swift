//
//  SelectorView.swift
//  ScheduleBSUIR
//
//  Created by andrew on 20.12.25.
//

import SwiftUI
import WidgetKit

struct SelectorViewForPersonalAccount: View {
    @EnvironmentObject var appStorageSaveKey: AppStorageSave
    @State var showAll: Bool = true
        
    var body: some View {
        NavigationStack {
            VStack {
                ButtonShowMaxOrMin(showAll: $showAll)
                VStack {
                    if showAll {
                        if appStorageSaveKey.whoUser == .student {
                            MaxViewGroupInSelector()                 // полный вид для группы
                        } else if appStorageSaveKey.whoUser == .employee {
                            MaxViewEmployeeInSelector()             // полный вид для преподавателей
                        }
                        VStack {
                            VStack(alignment: .leading) {
                                Text("Пользователь")
                                    .font(.system(size: 16, weight: .semibold))
                                    .padding(.leading)
                                Picker("", selection: $appStorageSaveKey.whoUser) {
                                    Text("Ученик").tag(WhoUser.student)
                                    Text("Преподаватель").tag(WhoUser.employee)
                                    Text("Другое").tag(WhoUser.none)
                                }
                                .pickerStyle(.segmented)
                            }
                            .padding(10)
                        }
                    } else {
                        if appStorageSaveKey.whoUser == .student {
                            MinViewGroupInSelector(subGroup: appStorageSaveKey.subGroup.inString, favoriteGroup: appStorageSaveKey.favoriteGroup, whoUser: appStorageSaveKey.whoUser.rawValue, showAll: $showAll)                       // уменьшенный вид для группы
                        } else if appStorageSaveKey.whoUser == .employee {
                            MimViewEmployeeInSelector(employeeName: appStorageSaveKey.employeeName, whoUser: appStorageSaveKey.whoUser.rawValue, showAll: $showAll)  // уменьшенный вид для преподавателей
                        } else {
                            MinViewNoneInSelector(whoUser: appStorageSaveKey.whoUser.rawValue, showAll: $showAll)
                        }
                    }
                }
                .glassEffect(.regular , in: .rect(cornerRadius: 20))
                .animation(.easeOut, value: appStorageSaveKey.whoUser)
            }
            .padding()
        }
    }
}


#Preview {
    return SelectorViewForPersonalAccount()
        .environmentObject(ViewModelForNetwork())
        .environmentObject(AppStorageSave())

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
    
    @EnvironmentObject var appStorageSaveKey: AppStorageSave
    @EnvironmentObject var groupListViewModel: NetworkViewModelForListGroups
        
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Подгруппа")
                    .font(.system(size: 16, weight: .semibold))
                    .padding(.leading)
                Picker("", selection: $appStorageSaveKey.subGroup) {
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
                        Text(appStorageSaveKey.favoriteGroup)
                            .tint(Color.primary)
                            .padding(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                            .background(Color.gray.opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 22))
                    }
                }
            }
            .padding(.leading, 10)
            
            // обновление виджета
            .onChange(of: appStorageSaveKey.favoriteGroup) {
                print(appStorageSaveKey.favoriteGroup)
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
            
            .onChange(of: appStorageSaveKey.subGroup) {
                WidgetCenter.shared.reloadAllTimelines()
                // надо будет тут опять вызывать обновление данных в виджете так как надо отфильтровать по подгруппе
            }
        }
        .padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 10))
        
        .navigationDestination(for: String.self) { _ in
            UniversalPicker(selected: $appStorageSaveKey.favoriteGroup, title: "Преподаватели", items: groupListViewModel.arrayOfGroupsNum, value: \.name, secondValue: \.name)
        }
    }
}
// ученик

// преподаватель
struct MaxViewEmployeeInSelector: View {
    
    @EnvironmentObject var appStorageSaveKey: AppStorageSave
    @EnvironmentObject var employeeListViewModel: NetworkViewModelForListEmployees
        
    var employeeNameToFio: String {
        if appStorageSaveKey.employeeName != "Не выбрано" {
            let words = appStorageSaveKey.employeeName.split(separator: " ")
                .enumerated()
                .map { index, word in
                    index < 1 ? word : "\(word.first!)."
                }
                .joined(separator: " ")
            return words
        } else {
            return appStorageSaveKey.employeeName
        }
    }
    #warning("В AppStorage сохраняется urlId, а не фио")
    
    var body: some View {
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
        
        .navigationDestination(for: String.self) { _ in
            UniversalPicker(selected: $appStorageSaveKey.employeeName, title: "Преподаватели", items: employeeListViewModel.scheduleForEmployees, value: \.fio, secondValue: \.urlId)
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
