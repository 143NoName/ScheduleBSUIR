//
//  EachEmployeeView.swift
//  ScheduleBSUIR
//
//  Created by andrew on 19.12.25.
//

import SwiftUI

struct EachEmployee: View {
    
    @EnvironmentObject var network: ViewModelForNetwork
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    let funcs = MoreFunctions() // так не правильно
    
    let employeeName: String
    
    @AppStorage("weekDay") var weekDay: DaysInPicker = .monday
    @AppStorage("subGroupe") var subGroup: SubGroupInPicker = .all
    @AppStorage("weekNumber") var weekNumber: WeeksInPicker = .first

    
    var pageName: String {
        if !network.isLoadingScheduleForEachEmployee {
            return "Загрузка..."
        } else {
            return network.scheduleForEachEmployee.employeeDto.fio
        }
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            
            if colorScheme == .light {
                Color.gray
                    .opacity(0.15)
                    .ignoresSafeArea(edges: .all)
            }
            
//            ScrollView {
//                LazyHStack(spacing: 0) {
//                    ForEach(network.scheduleEmployeeByDays.enumerated(), id: \.offset) { index, day in
//                        Text()
//                    }
//                }
//            }
            List {
                if !network.isLoadingScheduleForEachEmployee {
                    Section(header:
                        Text("Загрузка...")
                            .foregroundStyle(colorScheme == .dark ? .white : .black)
                    ) {
                        ForEach(0..<5, id: \.self) { _ in
                            EachLessonLoading()
                        }
                    }
                } else {
                    if !network.errorOfEachEmployee.isEmpty {
                        IfHaveErrorSchedule()
                    } else {
                        Section(header:
                                    Text("Расписание")
                                        .foregroundStyle(colorScheme == .dark ? .white : .black),
                                footer:
                                    Color.clear
                                        .frame(height: 300)
                        ) {
                            ForEach(network.scheduleEmployeeByDays.enumerated(), id: \.offset) { index, day in
                                if funcs.comparisonDay(weekDay, lessonDay: day.dayName) { // фильтрация по дню недели
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
                }
            }
            .scrollContentBackground(.hidden)
            
            SelectorViewForEmployee(todayWeek: network.currentWeek, weekNumber: $weekNumber, weekDay: $weekDay)
        }
        .navigationTitle(pageName)
//        .onDisappear {
//            network.scheduleForEachGroupInNull() // чистка расписания при деинициализации
//        }
        
        .refreshable {
            await network.getEachEmployeeSchedule(employeeName)
        }
        
        .task {
            // получение расписания преподавателя
            await network.getEachEmployeeSchedule(employeeName)
            
            // фильтрация по неделе и по подгруппе
            network.filterGroupSchedule(currentWeek: weekNumber, subGroup: subGroup)
            
            if let updateWeekNum = WeeksInPicker(rawValue: network.currentWeek) {
                weekNumber = updateWeekNum
            }
        }
        
        .onDisappear {
            dismiss()
        }
    }
}

#Preview {
    NavigationStack {
        EachEmployee(employeeName: "e-andros")
            .environmentObject(ViewModelForNetwork())
    }
}
