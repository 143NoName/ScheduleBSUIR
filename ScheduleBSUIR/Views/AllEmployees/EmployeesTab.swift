//
//  EmployeesTab.swift
//  ScheduleBSUIR
//
//  Created by andrew on 19.12.25.
//

import SwiftUI
import Marquee

struct EmployeesTab: View {
    
    @Environment(NetworkViewModelForListEmployees.self) var employeeListViewModel
    @Environment(\.colorScheme) var colorScheme

    @State var searchText: String = ""
    
    var searchable: [EmployeeModel] {
        if searchText.isEmpty {
            return employeeListViewModel.scheduleForEmployees
        } else {
            return employeeListViewModel.scheduleForEmployees.filter { $0.fullName.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var loadedArrayOfEmployees: String {
        if !employeeListViewModel.isLoadingScheduleForEmployees {
            return "Загрузка..."
        } else {
            return "Преподаватели"
        }
    }
    
    var body: some View {
        NavigationStack {
//            ZStack {
//                Group {
//                    if colorScheme == .light {
//                        Color.gray.opacity(0.55)
//                    } else {
//                        Color.black // или другой цвет для темной темы
//                    }
//                }
//                .ignoresSafeArea()
//                
                CostomList(items: searchable,
                           isLoading: employeeListViewModel.isLoadingScheduleForEmployees,
                           loadingView: ViewEachGroupIsLoading(),
                           errorStr: employeeListViewModel.errorOfEmployeesArray,
                           content: { each in
                    NavigationLink(value: each.urlId) {
                        EmployeesEach(employee: each)
                    }
                })
                .navigationTitle(loadedArrayOfEmployees)
                .if(employeeListViewModel.isLoadingScheduleForEmployees) { view in
                    view.searchable(text: $searchText, placement: .navigationBarDrawer, prompt: "Поиск преподавателя")
                }
                .refreshable {
                    Task {
                        employeeListViewModel.employeesArrayInNull()
                        await employeeListViewModel.getArrayOfEmployees()
                    }
                }
            }
            .navigationDestination(for: String.self) { employeeName in
                EachEmployee(employeeName: employeeName)
            }
//        }
    }
}

#Preview {
    EmployeesTab()
        .environment(NetworkViewModelForListEmployees())
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
                Marquee {
                    Text("\(employee.fullName)")
                        .fontWeight(.medium)
                }
                .marqueeWhenNotFit(true)
                .marqueeDuration(5)
                .frame(height: 20)
                
                if let departments = employee.academicDepartment {
                    let departmentsSrting = departments
                        .map { $0 }
                        .joined(separator: ", ")
                   
                    Marquee {
                        Text(departmentsSrting)
                               .font(.system(size: 14))
                    }
                    .marqueeWhenNotFit(true)
                    .marqueeDuration(7)
                    .frame(height: 20)
                }
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
                Spacer()
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.gray.opacity(0.5))
                    .frame(width: 10, height: 10)
            }
        }
        .scrollContentBackground(.hidden)
    }
}
