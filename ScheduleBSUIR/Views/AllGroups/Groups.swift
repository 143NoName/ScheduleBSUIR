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
    
    var searchable: [ModelNumbersOfGroups] {
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
    
    var body: some View {
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
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.gray.opacity(0.5))
                                    .frame(width:100)
                            }
                        }
                        .scrollContentBackground(.hidden)
                    } else {
                        List {
                            if !viewModel.errorOfGroupsNum.isEmpty {
                                IfErrorGroups()
                            } else {
                                ForEach(searchable.enumerated(), id: \.offset) { index, each in
                                    NavigationLink(destination: EachGroup(groupName: each.name)) {
                                        HStack {
                                            Text(each.name)
                                                .font(.system(size: 18, weight: .medium))
                                        }
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
        }
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
