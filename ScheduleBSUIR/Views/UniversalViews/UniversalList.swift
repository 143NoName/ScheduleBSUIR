//
//  ContentView.swift
//  ScheduleBSUIR
//
//  Created by user on 26.10.25.
//

import SwiftUI

//struct UniversalList<T: Identifiable>: View {
//    
//    @EnvironmentObject var network: ViewModelForNetwork
//    @Environment(\.colorScheme) var colorScheme
//    
//    let array: [T]
//    let isLoadedArray: Bool
//    let isErrorLoadingArray: String
//    
//    let name: KeyPath<T, String>                 // "имя" то ли группы то ли преподавателя
//    
//    let faculty: KeyPath<T, String?>?            // факультет для группы
//    let specialization: KeyPath<T, String?>?     // специальность для группы
//    let course: KeyPath<T, Int?>?                // курс для группы
//    
//    let image: KeyPath<T, String?>?              // изображение для преподавателя
//    let depart: KeyPath<T, [String]?>?           // кафедры для преподавателя
//    let urlID: KeyPath<T, String>?              // ссылка  для получения расписания
//    
//    var whoToShow: WhoToShow {
//        if faculty != nil, specialization != nil, course != nil {
//            return .group
//        } else if image != nil, depart != nil {
//            return .employee
//        }
//        return .group
//    }
//    
//    @State var searchText: String = ""
//    
//    var searchable: [T] {
//        if searchText.isEmpty {
//            return array
//        } else {
//            return array.filter { each in
//                each[keyPath: name].contains(searchText)
//            }
//        }
//    }
//    
//    var loadedGroup: String {
//        if !isLoadedArray {
//            return "Загрузка..."
//        } else {
//            return whoToShow.pageName
//        }
//    }
//        
//    var body: some View {
//        NavigationStack {
//            ZStack {
//                if colorScheme == .light {
//                    Color.gray
//                        .opacity(0.15)
//                        .ignoresSafeArea(edges: .all)
//                }
//                
//                VStack {
//                    if !isLoadedArray {
//                        if whoToShow == .group {
//                            ViewGroupIsLoading()
//                        } else if whoToShow == .employee {
//                            EmployeesEachIsLoading()
//                        }
//                    } else {
//                        CostomList {
//                            if !isErrorLoadingArray.isEmpty {
//                                IfErrorGroups()
//                            } else {
//                                ForEach(searchable) { each in
//                                    //                                    NavigationLink(value: each.name) {
//                                    //                                        ViewEachGroup(group: each)
//                                    //                                    }
//                                    
//                                    if whoToShow == .group {
//                                        NavigationLink(value: name) {
//                                            ViewForGroup(name: each[keyPath: name], faculty: each[keyPath: faculty!] ?? "", specialization: each[keyPath: specialization!] ?? "", course: each[keyPath: course!] ?? 0)
//                                        }
//                                    }
//                                    else if whoToShow == .employee {
//                                        NavigationLink(value: each[keyPath: urlID!]) {
//                                            ViewForEmployee(image: each[keyPath: image!] ?? "", name: each[keyPath: name], academicDepartment: each[keyPath: depart!] ?? [])
//                                        }
//                                    }
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//            .navigationTitle(loadedGroup)
//                
//            .if(network.isLoadingArrayOfGroupsNum) { view in
//                view.searchable(text: $searchText, placement: .navigationBarDrawer, prompt: "Поиск \(whoToShow.forSearch)")
//            } // было бы хорошо сделать UITextField в UIKit или просто как то кастомизировать через UIViewRepresentable
//                
//            .refreshable {
//                Task {
//                    network.groupArrayInNull()
//                    await network.getArrayOfGroupNum()       // получение списка групп
//                }
//            }
//            
//            .navigationDestination(for: String.self) { groupName in
//                EachGroup(groupName: groupName)
//            }
//        }
//    }
//}

//#Preview {
//    UniversalList(array: ViewModelForNetwork().arrayOfGroupsNum, isLoadedArray: true, isErrorLoadingArray: "", name: \.name, faculty: \.facultyAbbrev, specialization: \.specialityAbbrev, course: \.course, image: nil, depart: nil, urlID: nil)
//        .environmentObject(ViewModelForNetwork())
//}

 
//private struct ViewForGroup2: View {
//    
//    let name: String
//    let faculty: String
//    let specialization: String
//    let course: Int
//    
//    var body: some View {
//        VStack(alignment: .leading) {
//            Text(name)
//                .font(.system(size: 16, weight: .medium))
//            HStack {
//                Text(faculty)
//                Spacer()
//                Text(specialization)
//                Spacer()
//                Text("\(course) курс")
//            }
//            .frame(width: 200)
//            .font(.system(size: 14, weight: .light))
//        }
//    }
//}

//private struct ViewForEmployee2: View {
//    
//    let image: String
//    let name: String
//    let academicDepartment: [String]
//    
//    var body: some View {
//        HStack {
//            AsyncImage(url: URL(string: image)) { phase in
//                switch phase {
//                case .empty:
//                    ProgressView()
//                        .frame(width: 40, height: 40)
//                case .success(let image):
//                    image
//                        .resizable()
//                        .frame(width: 40, height: 40)
//                        .clipShape(RoundedRectangle(cornerRadius: 15))
//                case .failure:
//                    Image("PlainPhoto")
//                        .resizable()
//                        .frame(width: 40, height: 40)
//                        .clipShape(RoundedRectangle(cornerRadius: 15))
//                @unknown default:
//                    EmptyView()
//                }
//            }
//            VStack(alignment: .leading) {
//                Text(name)
//                    .font(.system(size: 16, weight: .medium))
//                HStack {
//                    ForEach(academicDepartment.enumerated(), id: \.offset) { index, academicDepartment in
//                        if index < 3 { // так не очень хорошо, надо бы отрисовать все, но с переносом
//                        Text("\(academicDepartment)")
//                        }
//                    }
//                }
//                .font(.system(size: 14, weight: .light))
//            }
//        }
//    }
//}


// дополнительный вид для списка групп (отдельно каждая группа)
struct ViewForGroup: View {
    
    let group: StudentGroups
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(group.name)
                .font(.system(size: 16, weight: .medium))
            HStack {
                Text(group.facultyAbbrev ?? "")
                Spacer()
                Text(group.specialityAbbrev ?? "")
                Spacer()
                Text("\(group.course ?? 0) курс")
            }
            .frame(width: 200)
            .font(.system(size: 14, weight: .light))
        }
    }
}

// дополнительный вид для списка (отдельно каждый преподаватель)
struct ViewForEmployee: View {
    
    let employee: EmployeeModel
    
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: employee.photoLink ?? "")) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(width: 40, height: 40)
                case .success(let image):
                    image
                        .resizable()
                        .frame(width: 40, height: 40)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                case .failure:
                    Image("PlainPhoto")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                @unknown default:
                    EmptyView()
                }
            }
            VStack(alignment: .leading) {
                Text(employee.fio)
                    .font(.system(size: 16, weight: .medium))
                HStack {
                    ForEach(employee.academicDepartment!.enumerated(), id: \.offset) { index, academicDepartment in
                        if index < 3 { // так не очень хорошо, надо бы отрисовать все, но с переносом
                        Text("\(academicDepartment)")
                        }
                    }
                }
                .font(.system(size: 14, weight: .light))
            }
        }
    }
}


// унивесальный вид для списков
struct UniversalListView<T: EachListsProtocol & Identifiable & Hashable>: View {
    
    let items: [T]                              // массив групп или преподавателей
    let name: KeyPath<T, String>                // значение для поиска
    let naviagtionValue: KeyPath<T, String>     // значение для навигации // пока не используется
    let isLoading: Bool                         // значение загрузки
    let errorLoading: String                    // значение ошибки
    let title: String                           // название страницы (pageName)
    
    @State private var searchText: String = ""
    
    var searcable: [T] {
        if searchText.isEmpty {
            return items
        } else {
            return items.filter { each in
                each[keyPath: name].contains(searchText)
            }
        }
    }
    
    var pageName: String {
        if !isLoading {
            "Загрузка..."
        } else {
            if errorLoading == "" {
                title
            } else {
                "Ошибка"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            List(searcable) { item in // понимает какой тип данных был передан и в зависимости от этого берет view каждого элемента (либо StudentGroups либо EmployeeModel)
                NavigationLink(value: item.url) {
                    item.makeCell()
                }
            }
            .navigationTitle(pageName)
            
            .if(isLoading) { view in
                view.searchable(text: $searchText, placement: .navigationBarDrawer, prompt: "Поиск преподавателя")
            } // было бы хорошо сделать UITextField в UIKit или просто как то кастомизировать через UIViewRepresentable
            
            .navigationDestination(for: String.self) { url in
                UniversalEachSchedule(url: url, isLoading: true, errorLoading: "", title: "щцтщм")                
            }
        }
    }
}

// вид загрузка всего списка
// для групп
private struct ViewGroupIsLoading: View {
    var body: some View {
        List {
            ForEach(0..<10) { _ in
                VStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.gray.opacity(0.5))
                        .frame(width: 100, height: 17)
                    HStack {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.gray.opacity(0.5))
                            .frame(height: 15)
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.gray.opacity(0.5))
                            .frame(height: 15)
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.gray.opacity(0.5))
                            .frame(height: 15)
                    }
                    .frame(width: 200)
                }
            }
        }
        .scrollContentBackground(.hidden)
    }
}

// для преподавателей
private struct ViewEmployeesEachIsLoading: View {
    var body: some View {
        List {
            ForEach(0..<10) { _ in
                HStack {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.gray.opacity(0.5))
                        .frame(width: 40, height: 40)
                    VStack(alignment: .leading) {
                        HStack {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.gray.opacity(0.5))
                                .frame(width: 70, height: 17)
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.gray.opacity(0.5))
                                .frame(width: 60, height: 17)
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.gray.opacity(0.5))
                                .frame(width: 60, height: 17)
                        }
                        HStack {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.gray.opacity(0.5))
                                .frame(width: 40, height: 15)
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.gray.opacity(0.5))
                                .frame(width: 40, height: 15)
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.gray.opacity(0.5))
                                .frame(width: 40, height: 15)
                        }
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
    }
}

