//
//  ContentView.swift
//  ScheduleBSUIR
//
//  Created by user on 26.10.25.
//

import SwiftUI

enum WhoToShow {
    case group
    case employee
    
    var pageName: String {
        switch self {
        case .group: return "Группы"
        case .employee: return "Преподаватели"
        }
    }
    
    var forSearch: String {
        switch self {
        case .group: return "группы"
        case .employee: return "преподавателя"
        }
    }
}

struct UniversalList<T: Identifiable>: View {
    
    @EnvironmentObject var network: ViewModelForNetwork
    @Environment(\.colorScheme) var colorScheme
    
    let array: [T]
    let isLoadedArray: Bool
    let isErrorLoadingArray: String
    
    let name: KeyPath<T, String>                 // "имя" то ли группы то ли преподавателя
    
    let faculty: KeyPath<T, String?>?            // факультет для группы
    let specialization: KeyPath<T, String?>?     // специальность для группы
    let course: KeyPath<T, Int?>?                // курс для группы
    
    let image: KeyPath<T, String?>?              // изображение для преподавателя
    let depart: KeyPath<T, [String]?>?           // кафедры для преподавателя
    let urlID: KeyPath<T, String>?              // ссылка  для получения расписания
    
    var whoToShow: WhoToShow {
        if faculty != nil, specialization != nil, course != nil {
            return .group
        } else if image != nil, depart != nil {
            return .employee
        }
        return .group
    }
    
    @State var searchText: String = ""
    
    var searchable: [T] {
        if searchText.isEmpty {
            return array
        } else {
            return array.filter { each in
                each[keyPath: name].contains(searchText)
            }
        }
    }
    
    var loadedGroup: String {
        if !isLoadedArray {
            return "Загрузка..."
        } else {
            return whoToShow.pageName
        }
    }
        
    var body: some View {
        NavigationStack {
            ZStack {
                if colorScheme == .light {
                    Color.gray
                        .opacity(0.15)
                        .ignoresSafeArea(edges: .all)
                }
                
                VStack {
                    if !isLoadedArray {
                        if whoToShow == .group {
                            ViewGroupIsLoading()
                        } else if whoToShow == .employee {
                            EmployeesEachIsLoading()
                        }
                    } else {
                        CostomList {
                            if !isErrorLoadingArray.isEmpty {
                                IfErrorGroups()
                            } else {
                                ForEach(searchable) { each in
                                    //                                    NavigationLink(value: each.name) {
                                    //                                        ViewEachGroup(group: each)
                                    //                                    }
                                    
                                    if whoToShow == .group {
                                        NavigationLink(value: name) {
                                            ViewForGroup(name: each[keyPath: name], faculty: each[keyPath: faculty!] ?? "", specialization: each[keyPath: specialization!] ?? "", course: each[keyPath: course!] ?? 0)
                                        }
                                    }
                                    else if whoToShow == .employee {
                                        NavigationLink(value: each[keyPath: urlID!]) {
                                            ViewForEmployee(image: each[keyPath: image!] ?? "", name: each[keyPath: name], academicDepartment: each[keyPath: depart!] ?? [])
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle(loadedGroup)
                
            .if(network.isLoadingArrayOfGroupsNum) { view in
                view.searchable(text: $searchText, placement: .navigationBarDrawer, prompt: "Поиск \(whoToShow.forSearch)")
            } // было бы хорошо сделать UITextField в UIKit или просто как то кастомизировать через UIViewRepresentable
                
            .refreshable {
                Task {
                    network.groupArrayInNull()
                    await network.getArrayOfGroupNum()       // получение списка групп
                }
            }
            
            .navigationDestination(for: String.self) { groupName in
                EachGroup(groupName: groupName)
            }
        }
    }
}

#Preview {
    UniversalList(array: ViewModelForNetwork().arrayOfGroupsNum, isLoadedArray: true, isErrorLoadingArray: "", name: \.name, faculty: \.facultyAbbrev, specialization: \.specialityAbbrev, course: \.course, image: nil, depart: nil, urlID: nil)
        .environmentObject(ViewModelForNetwork())
}

 
private struct ViewForGroup: View {
    
    let name: String
    let faculty: String
    let specialization: String
    let course: Int
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(name)
                .font(.system(size: 16, weight: .medium))
            HStack {
                Text(faculty)
                Spacer()
                Text(specialization)
                Spacer()
                Text("\(course) курс")
            }
            .frame(width: 200)
            .font(.system(size: 14, weight: .light))
        }
    }
}

private struct ViewForEmployee: View {
    
    let image: String
    let name: String
    let academicDepartment: [String]
    
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: image)) { phase in
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
                Text(name)
                    .font(.system(size: 16, weight: .medium))
                HStack {
                    ForEach(academicDepartment.enumerated(), id: \.offset) { index, academicDepartment in
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

private struct EmployeesEachIsLoading: View {
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
