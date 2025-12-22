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
    
    let funcs = MoreFunctions() // так не правильно
    
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
        ZStack(alignment: .bottom) {
            if colorScheme == .light {
                Color.gray
                    .opacity(0.1)
                    .ignoresSafeArea(edges: .all)
            }
            List {
                Section(header:
                            Text("Расписание")
                                .foregroundStyle(colorScheme == .dark ? .white : .black),
                        footer:
                            Color.clear
                                .frame(height: 300)
                ) {
                    ForEach(network.scheduleEmployeeByDays.enumerated(), id: \.offset) { index, day in
                        if funcs.comparisonDay(weekDay, lessonDay: day.dayName) {
                            if day.lessons.isEmpty {
                                IfDayLessonIsEmpty()
                            } else {
                                ForEach(day.lessons.enumerated(), id: \.offset) { index, lesson in
                                    EachLesson(lesson: lesson)
                                }
//                                                .backgroundStyle(.NewColor) // хочу сделать одинаковый цвет для листа и для окна выбора дня, недели и подгруппы
                            }
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            
            SelectorView(subGroup: $subGroup, weekNumber: $weekNumber, weekDay: $weekDay)
        }
            
            
        .navigationTitle(loadedEmployeeName)
    }
}

#Preview {
    NavigationStack {
        EachEmployee()
            .environmentObject(ViewModelForNetwork())
    }
}
