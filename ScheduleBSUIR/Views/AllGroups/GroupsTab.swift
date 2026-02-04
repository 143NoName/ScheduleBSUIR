//
//  ContentView.swift
//  ScheduleBSUIR
//
//  Created by user on 26.10.25.
//

import SwiftUI

struct GroupsTab: View {
    
    @Environment(NetworkViewModelForListGroups.self) var groupListViewModel             // viewModel для получения списка групп
    @Environment(\.colorScheme) var colorScheme
    
    @State var searchText: String = ""
    
    var searchable: [StudentGroups] {                                                   // вычисляемое свойство для получения искомой группы
        if searchText.isEmpty {
            return groupListViewModel.arrayOfGroupsNum
        } else {
            return groupListViewModel.arrayOfGroupsNum.filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var pageName: String {                                                              // вычисляемое свойство для названия страницы
        if !groupListViewModel.isLoadingArrayOfGroupsNum {
            return "Загрузка..."
        } else {
            return "Все группы"
        }
    }
    
    var body: some View {
        NavigationStack {
            CostomList(items: searchable,
                        isLoading: groupListViewModel.isLoadingArrayOfGroupsNum,
                        loadingView: ViewEachGroupIsLoading(),
                        errorStr: groupListViewModel.errorOfGroupsNum,
                        content: { each in
                NavigationLink(value: each.name) {
                    ViewEachGroup(group: each)
                }
            })
            .navigationTitle(pageName)
            .if(groupListViewModel.isLoadingArrayOfGroupsNum) { view in
                view.searchable(text: $searchText, placement: .navigationBarDrawer, prompt: "Поиск группы")
            }
            .refreshable {
                Task {
                    groupListViewModel.groupArrayInNull()                // очистка списка групп
                    await groupListViewModel.getArrayOfGroupNum()        // получение списка групп
                }
            }
            .navigationDestination(for: String.self) { groupName in
                EachGroup(groupName: groupName)
            }
        }
    }
}

#Preview {
    GroupsTab()
        .environment(NetworkViewModelForListGroups())
}

private struct ViewEachGroup: View {
    
    let group: StudentGroups
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(group.name)
                .fontWeight(.medium)
            HStack(spacing: 10) {
                if let facultyAbbrev = group.facultyAbbrev {
                    Text(facultyAbbrev)
                } else {
                    Text("Не известно")
                }
                if let specialityAbbrev = group.specialityAbbrev {
                    Text(specialityAbbrev)
                }
                if let course = group.course {
                    Text("\(course) курс")
                }
            }
            .font(.system(size: 14, weight: .light))
        }
    }
}

private struct ViewEachGroupIsLoading2: View {
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

struct ViewEachGroupIsLoading: View {
    var body: some View {
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
