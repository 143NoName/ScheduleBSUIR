//
//  EachGroup.swift
//  ScheduleBSUIR
//
//  Created by user on 27.10.25.
//

import SwiftUI
import WidgetKit
import Marquee

struct EachGroup: View {
    
    #warning("Надо ограничить уроки по началу и концу сесиии")
    
    @Environment(NetworkViewModelForWeek.self) var weekViewModel
    @Environment(NetworkViewModelForScheduleGroups.self) var groupScheduleViewModel
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
        
    let funcs = MoreFunctions() // так не правильно
    
    @State var weekDay: DaysInPicker = .monday
    @State var weekNumber: WeeksInPicker = .first
    @State var subGroup: SubGroupInPicker = .all
    @State var isShowMore: Bool = false
    
    let groupName: String
    
    var pageName: String {
        if !groupScheduleViewModel.isLoadingArrayOfScheduleGroup {
            "Загрузка..."
        } else {
            if groupScheduleViewModel.errorOfScheduleGroup.isEmpty {
                groupScheduleViewModel.arrayOfScheduleGroup.studentGroupDto.name
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
                if !groupScheduleViewModel.isLoadingArrayOfScheduleGroup {
                    Section(header:
                        Text("Загрузка...")
                            .foregroundStyle(colorScheme == .dark ? .white : .black)
                    ) {
                        ForEach(0..<5, id: \.self) { _ in
                            EachGroupLessonLoading()
                        }
                    }
                } else {
                    if !groupScheduleViewModel.errorOfScheduleGroup.isEmpty {
                        IfHaveErrorSchedule(error: groupScheduleViewModel.errorOfScheduleGroup)
                    } else {
                        Section(header:
                                    Text("Расписание")
                                        .foregroundStyle(colorScheme == .dark ? .white : .black),
                                footer:
                                    Color.clear
                                        .frame(height: 300)
                        ) {
                            ForEach(groupScheduleViewModel.scheduleGroupByDays.enumerated(), id: \.offset) { index, day in
                                if funcs.comparisonDay(weekDay, lessonDay: day.dayName) {
                                    if day.lessons.isEmpty {
                                        IfDayLessonIsEmpty()
                                    } else {
                                        ForEach(day.lessons.enumerated(), id: \.offset) { index, lesson in
                                            EachGroupLesson(lesson: lesson)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            
            SelectorViewForGroup(subGroup: $subGroup, weekNumber: $weekNumber, weekDay: $weekDay)
        }
        .navigationTitle(pageName)

        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    HStack {
                        Image(systemName: "chevron.left")
                    }
                }
            }
        }
        
        .refreshable {
            groupScheduleViewModel.scheduleForEachGroupInNull()                                         // очистка данных
            await groupScheduleViewModel.getScheduleGroup(group: groupName)                             // получение новых данных
            groupScheduleViewModel.filterGroupSchedule(currentWeek: weekNumber, subGroup: subGroup)     // фильтрация полученных данных
            funcs.findToday(selectedWeekNumber: &weekNumber, weekDay: &weekDay)                         // для отображения сегодняшей даты
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
            MoreInfoAboutGroup(group: groupScheduleViewModel.arrayOfScheduleGroup, currentWeek: weekViewModel.currentWeek)
        }
        
        .task {
            await groupScheduleViewModel.getScheduleGroup(group: groupName)                             // получение расписания группы
            groupScheduleViewModel.filterGroupSchedule(currentWeek: weekNumber, subGroup: subGroup)     // фильтрация по неделе и по подгруппе
            funcs.findToday(selectedWeekNumber: &weekNumber, weekDay: &weekDay)                         // нахождение сегодняшнего дня (недели и дня недели)
        }
        
        .onDisappear {
            dismiss()                                                                                   // при переходе в другой tab чтобы выходило к списку
            groupScheduleViewModel.scheduleForEachGroupInNull()                                         // очистить при выходе (ошибки убрать и т.д.)
        }
    }
}

#Preview {
    NavigationStack {
        EachGroup(groupName: "310101")
            .environment(NetworkViewModelForWeek())
            .environment(NetworkViewModelForScheduleGroups())
    }
}

struct MoreInfoAboutGroup: View {
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    @Environment(NetworkViewModelForWeek.self) var weekViewModel

    let group: EachGroupResponse
    let currentWeek: Int
    
    var specialityAbbrev: String {
        guard let specialityAbbrev = group.studentGroupDto.specialityAbbrev else { return "" }
        return specialityAbbrev
    }
    
    var body: some View {
        ZStack {
            if colorScheme == .light {
                Color.gray
                    .opacity(0.15)
                    .ignoresSafeArea(edges: .all)
            }
            
            NavigationStack {
                List {
                    Section(header: Text("Информация о группе")) {
                        Text("Номер группы: \(group.studentGroupDto.name)")
                        HStack {
                            Text("Специальность: ")
                            Marquee {
                                Text("\(specialityAbbrev) (\(group.studentGroupDto.specialityName))")
                            }
                            .marqueeWhenNotFit(true)
                            .marqueeDuration(8)
                            .frame(height: 20)
                            #warning("Может все таки можно как то начинать слева и крутить налево")
                        }
                        HStack {
                            Text("Факультет: ")
                            Marquee {
                                Text("\(group.studentGroupDto.facultyAbbrev) (\(group.studentGroupDto.facultyName))")
                            }
                            .marqueeWhenNotFit(true)
                            .marqueeDuration(8)
                            .frame(height: 20)
                            #warning("Может все таки можно как то начинать слева и крутить налево")
                        }
                        
                        Text("Степень образования: \(group.studentGroupDto.educationDegree)")
                    }
                    Section(header: Text("Занятия")) {
                        Text("Начало занятий: \(group.startDate ?? "Не известно")")
                        Text("Конец занятий: \(group.endDate ?? "Не известно")")
                    }
                    Section(header: Text("Сессия")) {
                        Text("Начало сесии: \(group.startExamsDate ?? "Не известно")")
                        Text("Конец занятий: \(group.endExamsDate ?? "Не известно")")
                    }
                    Section(header: Text("Период")) {
                        Text("Текущая неделя: \(currentWeek)")
                        Text("Текущий период: \(group.currentPeriod ?? "Не известно")")
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
                .navigationTitle("О группе \(group.studentGroupDto.name)")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}
