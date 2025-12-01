//
//  ContentView.swift
//  ScheduleBSUIR
//
//  Created by user on 26.10.25.
//

import SwiftUI

struct Groups: View {
    
    @EnvironmentObject var viewModel: ViewModel
    
    @Environment(\.colorScheme) var colorScheme
    
    @State var searchText: String = ""
    
    var searchable: [StudentGroups] {
        if searchText.isEmpty {
            return viewModel.arrayOfGroupsNum
        } else {
            return viewModel.arrayOfGroupsNum.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var loadedGroups: String {
        if !viewModel.isLoadingArrayOfGroupsNum {
            return "Загрузка..."
        } else {
            return "Все группы"
        }
    }
    
//    @State var path: [String] = []
    
    var body: some View {
//        NavigationStack(path: $path) {
        NavigationStack {
            ZStack {
                
                if colorScheme == .light {
                    Color.gray
                        .opacity(0.1)
                        .ignoresSafeArea(edges: .all)
                }
                
                VStack {
                    if !viewModel.isLoadingArrayOfGroupsNum {
                        List {
                            ForEach(0..<20) { _ in
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
                    } else {
                        List {
                            if !viewModel.errorOfGroupsNum.isEmpty {
                                IfErrorGroups()
                            } else {
                                ForEach(viewModel.arrayOfGroupsNum) { each in
                                    
                                    
//                                    NavigationLink(destination: EachGroup(groupName: each.name)) {
//                                        ViewEachGroup(group: each)
//                                    }
                                    
                                    
//                                    Button {
//                                        path.append(each.name)
//                                        print(path)
//                                    } label: {
//                                        ViewEachGroup(group: each)
//                                    }
//                                    .tint(.primary)
                                    
                                    
                                    NavigationLink(value: each.name) {
                                        ViewEachGroup(group: each)
                                    }
                                    
                                    
                                }
                            }
                        }
                        .scrollContentBackground(.hidden)
                    }
                }
                
                .navigationTitle(loadedGroups)
                
                .if(viewModel.isLoadingArrayOfGroupsNum) { view in
                    view.searchable(text: $searchText, prompt: "Поиск по группам")
                }
                
                .refreshable {
                    await viewModel.getArrayOfGroupNum()       // получение списка групп
                }
                
                .ignoresSafeArea(edges: .bottom)
            }
            .navigationDestination(for: String.self) { group in
                EachGroup(groupName: group)
//                Text(group)
            }
        }
    }
}

struct Rrr: View {
    
    let rr: String
    
    var body: some View {
        Text("rfrjq nj \(rr)")
    }
}

extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

#Preview {
    Groups()
        .environmentObject(ViewModel())
}

 
private struct ViewEachGroup: View {
    
    let group: StudentGroups
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(group.name)
                .font(.system(size: 18, weight: .medium))
            HStack {
                if let facultyAbbrev = group.facultyAbbrev {
                    Text(facultyAbbrev)
                } else {
                    Text("Не известно")
                }
                Spacer()
                if let specialityAbbrev = group.specialityAbbrev {
                    Text(specialityAbbrev)
                }
                Spacer()
                if let course = group.course {
                    Text(" \(course) курс")
                }
            }
            .frame(width: 200)
            .font(.system(size: 14, weight: .light))
        }
    }
}
