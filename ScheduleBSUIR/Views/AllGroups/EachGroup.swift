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
    @State var isShowViews: Bool = false
    
    @State var demonstrate: Demonstrate = .byDays
    
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
            
//            List {
//                if !groupScheduleViewModel.isLoadingArrayOfScheduleGroup {
//                    Section(header:
//                        Text("Загрузка...")
//                            .foregroundStyle(colorScheme == .dark ? .white : .black)
//                    ) {
//                        ForEach(0..<5, id: \.self) { _ in
//                            EachGroupLessonLoading()
//                        }
//                    }
//                } else {
//                    if !groupScheduleViewModel.errorOfScheduleGroup.isEmpty {
//                        IfHaveErrorSchedule(error: groupScheduleViewModel.errorOfScheduleGroup)
//                    } else {
//                        Section(header:
//                                    Text("Расписание")
//                                        .foregroundStyle(colorScheme == .dark ? .white : .black),
//                                footer:
//                                    Color.clear
//                                        .frame(height: 300)
//                        ) {
////                            ForEach(groupScheduleViewModel.scheduleGroupByDays.enumerated(), id: \.offset) { index, day in
////                                if funcs.comparisonDay(weekDay, lessonDay: day.dayName) {
////                                    if day.lessons.isEmpty {
////                                        IfDayLessonIsEmpty()
////                                    } else {
////                                        ForEach(day.lessons.enumerated(), id: \.offset) { index, lesson in
////                                            EachGroupLesson(lesson: lesson)
////                                        }
////                                    }
////                                }
////                            }
//    
//                        }
//                    }
//                }
//            }
//            .scrollContentBackground(.hidden)
            
            
            if !groupScheduleViewModel.isLoadingArrayOfScheduleGroup {                                          // процесс загрузки
                List {
                    Section(header: Text("День недели")) {
                        ForEach(0...10, id: \.self) { _ in
                            EachGroupLessonLoading()
                        }
                    }
                }
            } else {                                                                                            // ответ
                if !groupScheduleViewModel.errorOfScheduleGroup.isEmpty {                                       // ошибка загрузки
                    IfHaveErrorSchedule(error: groupScheduleViewModel.errorOfScheduleGroup)
                } else {                                                                                        // данные пришли
                    if demonstrate == .byDays {                                                                 // ВИД: "По дням"
                        ViewByDays()
                    } else if demonstrate == .list {                                                            // ВИД: "Список"
                        ViewList()
                    } else if demonstrate == .allInOneWeek {                                                    // ВИД: "Все в одной неделе"
                        ViewAllInOneWeek()
                    }
                }
            }
            
            // подключать только когда нужна фильтрация по дню, неделе и дню недели
            SelectorViewForGroup(subGroup: $subGroup, weekNumber: $weekNumber, weekDay: $weekDay)
        }
        
        .navigationTitle(pageName)

//        .navigationBarBackButtonHidden(true)
//        .toolbar {
//            ToolbarItem(placement: .topBarLeading) {
//                Button {
//                    dismiss()
//                } label: {
//                    HStack {
//                        Image(systemName: "chevron.left")
//                    }
//                }
//            }
//        }
        
        .refreshable {
            groupScheduleViewModel.scheduleForEachGroupInNull()                                         // очистка данных
            await groupScheduleViewModel.getScheduleGroup(group: groupName)                             // получение новых данных
            groupScheduleViewModel.filterGroupSchedule(currentWeek: weekNumber, subGroup: subGroup)     // фильтрация полученных данных
            funcs.findToday(selectedWeekNumber: &weekNumber, weekDay: &weekDay)                         // для отображения сегодняшей даты
        }

        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isShowViews.toggle()
                } label: {
                    Image(systemName: "calendar")
                }
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
                .presentationDetents([.height(700)])
                .presentationDragIndicator(.visible)
        }
        
        .sheet(isPresented: $isShowViews) {
            ViewSelection(demonstrate: $demonstrate)
                .presentationDetents([.height(300)])
                .presentationDragIndicator(.visible)
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


// ВИД: "По дням"
private struct ViewByDays: View {
    @Environment(NetworkViewModelForScheduleGroups.self) var groupScheduleViewModel
    var body: some View {
        List {
            ForEach(groupScheduleViewModel.filteredScheduleOfGroupOnDay) { lesson in
                EachGroupLesson(lesson: lesson)
            }
        }
        .scrollContentBackground(.hidden)
    }
}

// ВИД: "Список"
private struct ViewList: View {
    @Environment(NetworkViewModelForScheduleGroups.self) var groupScheduleViewModel
    var body: some View {
        List {
            ForEach(groupScheduleViewModel.filteredScheduleOfGroup.enumerated(), id: \.offset) { _, day in
                Section(header: Text(day.day)) {
                    if day.lesson.isEmpty {
                        Text("Нет занятий")
                    } else {
                        ForEach(day.lesson) { lesson in
                            EachGroupLesson(lesson: lesson)
                        }
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
    }
}


// ВИД: "Все в одной неделе"
private struct ViewAllInOneWeek: View {
    @Environment(NetworkViewModelForScheduleGroups.self) var groupScheduleViewModel
    var body: some View {
        List {
            ForEach(groupScheduleViewModel.filteredScheduleOfGroup.enumerated(), id: \.offset) { _, day in

                Section(header: Text(day.day)) {
                    if day.lesson.isEmpty {
                        Text("Нет занятий")
                    } else {
                        ForEach(day.lesson) { lesson in
                            EachGroupLesson(lesson: lesson)
                        }
                    }
                    
                }
            }
        }
        .scrollContentBackground(.hidden)
    }
}
