//
//  EmployeesTab.swift
//  ScheduleBSUIR
//
//  Created by andrew on 19.12.25.
//

import SwiftUI

struct EmployeesTab: View {
    
    @EnvironmentObject var network: ViewModelForNetwork
    @Environment(\.colorScheme) var colorScheme

    @State var searchText: String = ""
    
    var searchble: [EmployeeModel] {
        if searchText.isEmpty {
            return network.scheduleForEmployees
        } else {
            return network.scheduleForEmployees.filter { $0.fullName.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var loadedArrayOfEmployees: String {
        if !network.isLoadingScheduleForEmployees {
            return "Загрузка..."
        } else {
            return "Преподаватели"
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
                    if !network.isLoadingScheduleForEmployees {
                        EmployeesEachIsLoading()
                    } else {
                        List {
                            ForEach(searchble.enumerated(), id: \.offset) { index, employee in
                                NavigationLink(value: employee.urlId) {
                                    EmployeesEach(employee: employee)
                                }
                            }
                        }
                        .scrollContentBackground(.hidden)
                    }
                }
                
                .navigationTitle(loadedArrayOfEmployees)
                
                .if(network.isLoadingScheduleForEmployees) { view in
                    view.searchable(text: $searchText, placement: .navigationBarDrawer, prompt: "Поиск преподавателя")
                } // было бы хорошо сделать UITextField в UIKit или просто как то кастомизировать через UIViewRepresentable

                .refreshable {
                    Task {
                        network.employeesArrayInNull()
                        await network.getArrayOfEmployees()
                    }
                }
            }
            
            .navigationDestination(for: String.self) { employeeName in
                EachEmployee(employeeName: employeeName)
            }
        }
    }
}

#Preview {
    EmployeesTab()
        .environmentObject(ViewModelForNetwork())
}

private struct EmployeesEach: View {
    
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
                Text("\(employee.fullName)")
                    .font(.system(size: 16, weight: .medium))
                HStack {
                    if let academicDepartment = employee.academicDepartment {
                        ForEach(academicDepartment.enumerated(), id: \.offset) { index, academicDepartment in
                            if index < 3 { // так не очень хорошо, надо бы отрисовать все, но с переносом
                            Text("\(academicDepartment)")
                            }
                        }
                        
                    }
                }
                .font(.system(size: 14, weight: .light))
            }
        }
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
