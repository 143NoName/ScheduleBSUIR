//
//  EachEmployeeView.swift
//  ScheduleBSUIR
//
//  Created by andrew on 19.12.25.
//

import SwiftUI
import Marquee

struct EachEmployee: View {
    
    @Environment(NetworkViewModelForWeek.self) var weekViewModel
    @Environment(NetworkViewModelForScheduleEmployees.self) var employeeScheduleViewModel
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    let funcs = MoreFunctions() // так не правильно
    
    @State var weekDay: DaysInPicker = .monday
    @State var weekNumber: WeeksInPicker = .first
    @State var isShowMore: Bool = false

    let employeeName: String
    
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
                        IfHaveError(error: employeeScheduleViewModel.errorOfEachEmployee)
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
            
            SelectorViewForEmployee(weekNumber: $weekNumber, weekDay: $weekDay)
        }
        .navigationTitle(pageName)
        
        .refreshable {
            employeeScheduleViewModel.scheduleForEachEmployeeInNull()                           // очистка расписания
            await employeeScheduleViewModel.getEachEmployeeSchedule(employeeName)               // получение расписания преподавателя
            employeeScheduleViewModel.filterByWeekEmployeeSchedule(currentWeek: weekNumber)     // фильтрация по неделе и по подгруппе
            funcs.findToday(selectedWeekNumber: &weekNumber, weekDay: &weekDay)                 // для отображения сегодняшей даты
        }
        
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Text("Неделя: \(weekViewModel.currentWeek)")
                    .padding(.horizontal)
                    .font(.system(size: 14, weight: .semibold))
            }
            ToolbarSpacer(placement: .topBarTrailing)
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isShowMore.toggle()
                } label: {
                    Text("i")
                        .font(.system(size: 18, weight: .semibold))
                }
            }
        }
        
        .sheet(isPresented: $isShowMore) {
            MoreInfoAboutEmployee(employee: employeeScheduleViewModel.scheduleForEachEmployee, currentWeek: weekViewModel.currentWeek)
        }
        
        .task {
            await employeeScheduleViewModel.getEachEmployeeSchedule(employeeName)               // получение расписания преподавателя
            employeeScheduleViewModel.filterByWeekEmployeeSchedule(currentWeek: weekNumber)     // фильтрация по неделе и по подгруппе
            funcs.findToday(selectedWeekNumber: &weekNumber, weekDay: &weekDay)                 // для отображения сегодняшей даты
        }
        
        .onDisappear {
            dismiss()                                                                           // при переходе в другой tab чтобы выходило к списку
            employeeScheduleViewModel.scheduleForEachEmployeeInNull()                           // очистить при выходе (ошибки убрать и т.д.)
        }
    }
}

#Preview {
    NavigationStack {
        EachEmployee(employeeName: "i-abramov")
            .environment(NetworkViewModelForWeek())
            .environment(NetworkViewModelForScheduleEmployees())
    }
}

struct MoreInfoAboutEmployee: View {
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    let employee: EachEmployeeResponse
    let currentWeek: Int
    
    var body: some View {
        ZStack {
            if colorScheme == .light {
                Color.gray
                    .opacity(0.15)
                    .ignoresSafeArea(edges: .all)
            }

            NavigationStack {
                List {
                    Section(header: Text("Информация о преподавателе:")) {
                        VStack(alignment: .leading, spacing: 12) {
                            AsyncImage(url: URL(string: employee.employeeDto.photoLink ?? "")!) { image in
                                switch image {
                                case .empty:
                                    Image("PlainPhoto")
                                        .resizable()
                                        .frame(width: 120, height: 120)
                                        .clipShape(RoundedRectangle(cornerRadius: 15))
                                case .success(let image):
                                    image
                                        .resizable()
                                        .frame(width: 120, height: 120)
                                        .clipShape(RoundedRectangle(cornerRadius: 15))
                                case .failure:
                                    Image("PlainPhoto")
                                    .resizable()
                                    .frame(width: 120, height: 120)
                                    .clipShape(RoundedRectangle(cornerRadius: 15))
                                @unknown default:
                                    Image("PlainPhoto")
                                    .resizable()
                                    .frame(width: 120, height: 120)
                                    .clipShape(RoundedRectangle(cornerRadius: 15))
                                }
                            }
                            .frame(maxWidth: .infinity)
                            
                            HStack {
                                Text("Полное фио: ")
                                Marquee {
                                    Text("\(employee.employeeDto.fullName)")
                                }
                                .marqueeWhenNotFit(true)
                                .marqueeDuration(8)
                                .frame(height: 20)
                                #warning("Может все таки можно как то начинать слева и крутить налево")
                            }
                        }
                        Text("Email: \(employee.employeeDto.email ?? "Не известно")")
//                        Text("Специальность: \(specialityAbbrev) (\(group.studentGroupDto.specialityName))")
//                        Text("Факультет: \(group.studentGroupDto.facultyAbbrev) (\(group.studentGroupDto.facultyName))")
//                        Text("Степень образования: \(group.studentGroupDto.educationDegree)")
                        
                    }
                    Section(header: Text("Занятия")) {
                        Text("Начало занятий: \(employee.startDate ?? "Не известно")")
                        Text("Конец занятий: \(employee.endDate ?? "Не известно")")
                    }
                    Section(header: Text("Сессия")) {
                        Text("Начало сесии: \(employee.startExamsDate ?? "Не известно")")
                        Text("Конец занятий: \(employee.endExamsDate ?? "Не известно")")
                    }
                    Section(header: Text("Период")) {
                        Text("Текущая неделя: \(currentWeek)")
                        Text("Текущий период: \(employee.currentPeriod ?? "Не известно")")
                    }
                }
                .scrollContentBackground(.hidden)
                
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                        }
                    }
                }
                .navigationTitle("О \(employee.employeeDto.fio)")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}
