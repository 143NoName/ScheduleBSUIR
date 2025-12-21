//
//  EachEmployeeView.swift
//  ScheduleBSUIR
//
//  Created by andrew on 19.12.25.
//

import SwiftUI

struct EachEmployee: View {
    
    @EnvironmentObject var network: ViewModelForNetwork
    @Environment(\.colorScheme) var colorScheme
    
    @State var urlId: String
    
    @AppStorage("weekDay") var weekDay: DaysInPicker = .monday
    @AppStorage("subGroupe") var subGroup: SubGroupInPicker = .all
    @AppStorage("weekNumber") var weekNumber: WeeksInPicker = .first

    var loadedEmployeeName: String {
        if !network.isLoadingScheduleForEachEmployee {
            return "Загрузка..."
        } else {
            return network.scheduleForEachEmployee.employeeDto.fullName
        }
    }
    
    var body: some View {
        ZStack {
            if colorScheme == .light {
                Color.gray
                    .opacity(0.1)
                    .ignoresSafeArea(edges: .all)
            }
        
            List {
//                ForEach() { _ in
//                    
//                }
            }
                
            SelectorView(subGroup: $subGroup, weekNumber: $weekNumber, weekDay: $weekDay)
                
        }
            
            
        .navigationTitle(loadedEmployeeName)
        
        .task {
            await network.getEachEmployeeSchedule(urlId)
        }
    }
}

#Preview {
    EachEmployee(urlId: "e-andros")
        .environmentObject(ViewModelForNetwork())
}
