//
//  EachEmployeeView.swift
//  ScheduleBSUIR
//
//  Created by andrew on 19.12.25.
//

import SwiftUI

struct EachEmployee: View {
    
    @EnvironmentObject var weekViewModel: NetworkViewModelForWeek
    @EnvironmentObject var employeeScheduleViewModel: NetworkViewModelForScheduleEmployees
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    let funcs = MoreFunctions() // так не правильно
    
    let employeeName: String
    
    @AppStorage("weekDay") var weekDay: DaysInPicker = .monday
    @AppStorage("subGroupe") var subGroup: SubGroupInPicker = .all
    @AppStorage("weekNumber") var weekNumber: WeeksInPicker = .first

    
    var pageName: String {
        if !employeeScheduleViewModel.isLoadingScheduleForEachEmployee {
            "Загрузка..."
        } else {
            if employeeScheduleViewModel.errorOfEachEmployee.isEmpty {
                employeeScheduleViewModel.scheduleForEachEmployee.employeeDto.fio
            } else {
                "Ошибка"
            }
        }
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if colorScheme == .light {
                Color.gray
                    .opacity(0.15)
                    .ignoresSafeArea(edges: .all)
            }
            List {
                if !employeeScheduleViewModel.isLoadingScheduleForEachEmployee {
                    Section(header:
                        Text("Загрузка...")
                            .foregroundStyle(colorScheme == .dark ? .white : .black)
                    ) {
                        ForEach(0..<5, id: \.self) { _ in
                            EachEmployeeLessonLoading()
                        }
                    }
                } else {
                    if !employeeScheduleViewModel.errorOfEachEmployee.isEmpty {
                        IfHaveErrorSchedule()
                    } else {
                        Section(header:
                                    Text("Расписание")
                                        .foregroundStyle(colorScheme == .dark ? .white : .black),
                                footer:
                                    Color.clear
                                        .frame(height: 300)
                        ) {
                            ForEach(employeeScheduleViewModel.scheduleEmployeeByDays.enumerated(), id: \.offset) { index, day in
                                if funcs.comparisonDay(weekDay, lessonDay: day.dayName) { // фильтрация по дню недели
                                    if day.lessons.isEmpty {
                                        IfDayLessonIsEmpty()
                                    } else {
                                        ForEach(day.lessons.enumerated(), id: \.offset) { index, lesson in
                                            EachEmployeeLesson(lesson: lesson)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            
            SelectorViewForEmployee(todayWeek: weekViewModel.currentWeek, weekNumber: $weekNumber, weekDay: $weekDay)
        }
        .navigationTitle(pageName)
        
        .refreshable {
            await employeeScheduleViewModel.getEachEmployeeSchedule(employeeName)
        }
        
        .task {
            // получение расписания преподавателя
            await employeeScheduleViewModel.getEachEmployeeSchedule(employeeName)
            
            // фильтрация по неделе и по подгруппе
            employeeScheduleViewModel.filterByWeekEmployeeSchedule(currentWeek: weekNumber)
            
            if let updateWeekNum = WeeksInPicker(rawValue: weekViewModel.currentWeek) {
                weekNumber = updateWeekNum
            }
        }
        
        .onDisappear {
            dismiss() // при переходе в другой tab чтобы выходило к списку
            employeeScheduleViewModel.scheduleForEachEmployeeInNull() // очистить при выходе (ошибки убрать и т.д.)
        }
    }
}

#Preview {
    NavigationStack {
        EachEmployee(employeeName: "i-abramov")
            .environmentObject(ViewModelForNetwork())
    }
}
