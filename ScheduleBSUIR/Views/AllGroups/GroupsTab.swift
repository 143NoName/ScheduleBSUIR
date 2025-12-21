//
//  ContentView.swift
//  ScheduleBSUIR
//
//  Created by user on 26.10.25.
//

import SwiftUI

struct Groups: View {
    
    @EnvironmentObject var network: ViewModelForNetwork
    @Environment(\.colorScheme) var colorScheme
    
    @State var searchText: String = ""
    
    var searchable: [StudentGroups] {
        if searchText.isEmpty {
            return network.arrayOfGroupsNum
        } else {
            return network.arrayOfGroupsNum.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var loadedGroup: String {
        if !network.isLoadingArrayOfGroupsNum {
            return "Загрузка..."
        } else {
            return "Все группы"
        }
    }
        
    var body: some View {
        NavigationStack {
            ZStack {
                if colorScheme == .light {
                    Color.gray
                        .opacity(0.1)
                        .ignoresSafeArea(edges: .all)
                }
                
                VStack {
                    if !network.isLoadingArrayOfGroupsNum {
                        ViewEachGroupIsLoading()
                    } else {
                        List {
                            if !network.errorOfGroupsNum.isEmpty {
                                IfErrorGroups()
                            } else {
                                ForEach(searchable.enumerated(), id: \.offset ) { index, each in
                                    NavigationLink(value: each.name) {
                                        ViewEachGroup(group: each)
                                    }
                                }
                            }
                        }
                        .scrollContentBackground(.hidden)
                    }
                }
                
                .navigationTitle(loadedGroup)
                
                .if(network.isLoadingArrayOfGroupsNum) { view in
                    view.searchable(text: $searchText, placement: .navigationBarDrawer, prompt: "Поиск группы")
                } // было бы хорошо сделать UITextField в UIKit или просто как то кастомизировать через UIViewRepresentable
                
                .refreshable {
                    Task {
                        network.groupArrayInNull()
                        await network.getArrayOfGroupNum()       // получение списка групп
                    }
                }
                
                .ignoresSafeArea(edges: .bottom)
            }
            .task {
                await network.getArrayOfGroupNum()       // получение списка групп
            }
            .navigationDestination(for: String.self) { group in
                EachGroup(groupName: group)
            }
        }
    }
}

#Preview {
    Groups()
        .environmentObject(ViewModelForNetwork())
}

 
private struct ViewEachGroup: View {
    
    let group: StudentGroups
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(group.name)
                .font(.system(size: 16, weight: .medium))
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
                    Text("\(course) курс")
                }
            }
            .frame(width: 200)
            .font(.system(size: 14, weight: .light))
        }
    }
}

private struct ViewEachGroupIsLoading: View {
    var body: some View {
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
    }
}
