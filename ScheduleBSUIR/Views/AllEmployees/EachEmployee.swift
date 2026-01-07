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
            "Загрузка..."
        } else {
            if network.errorOfEachEmployee.isEmpty {
                network.scheduleForEachEmployee.employeeDto.fio
            } else {
                "Ошибка"
            }
        }
    }
    
    #warning("При просмотре расписания отдельного учителя или группы нет фильтрации по неделе")
    var body: some View {
        ZStack(alignment: .bottom) {
            if colorScheme == .light {
                Color.gray
                    .opacity(0.15)
                    .ignoresSafeArea(edges: .all)
            }
            List {
                if !network.isLoadingScheduleForEachEmployee {
                    Section(header:
                        Text("Загрузка...")
                            .foregroundStyle(colorScheme == .dark ? .white : .black)
                    ) {
                        ForEach(0..<5, id: \.self) { _ in
                            EachGroupLessonLoading()
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
                                            EachGroupLesson(lesson: lesson)
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
            dismiss() // при переходе в другой tab чтобы выходило к списку
            network.scheduleForEachEmployeeInNull() // очистить при выходе (ошибки убрать и т.д.)
        }
    }
}

#Preview {
    NavigationStack {
        EachEmployee(employeeName: "e-andros")
            .environmentObject(ViewModelForNetwork())
    }
}
