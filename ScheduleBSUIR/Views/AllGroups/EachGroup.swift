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
    
    @AppStorage("demonstrate") var demonstrate: Demonstrate = .byDays
        
    let funcs = MoreFunctions() // так не правильно
    
    @State var weekDay: DaysInPicker = .monday
    @State var weekNumber: WeeksInPicker = .first
    @State var subGroup: SubGroupInPicker = .all
    
    @State var isShowMore: Bool = false
    @State var isShowViews: Bool = false
    
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
    
    var secondPageName: String {
        if !groupScheduleViewModel.isLoadingArrayOfScheduleGroup {
            "Загрузка..."
        } else {
            if groupScheduleViewModel.errorOfScheduleGroup.isEmpty {
                if demonstrate == .byDays {
                    "Расписание по дням"
                } else if demonstrate == .byDays {
                    "Все расписание в неделе"
                } else if demonstrate == .list {
                    "Расписание списком"
                } else {
                    ""
                }
            } else {
                ""
            }
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            
            if colorScheme == .light {
                Color.gray
                    .opacity(0.15)
                    .ignoresSafeArea(edges: .all)
            } else {
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
                        List {
                            IfHaveError(error: groupScheduleViewModel.errorOfScheduleGroup)
                        }
                        .scrollContentBackground(.hidden)
                    } else {                                                                                        // данные пришли
                        List {
                            if demonstrate == .byDays {                                                             // ВИД: "По дням"
                                Section(header: Text(weekDay.inString)) {
                                    ViewByDays()
                                }
                            } else if demonstrate == .list {                                                        // ВИД: "Список"
                                ViewList()
                            } else if demonstrate == .weekly {                                                // ВИД: "Все в одной неделе"
                                ViewAllInOneWeek()
                            }
                        }
                        .scrollContentBackground(.hidden)
                    }
                }
            }
            
            // показывать окно фильтрации или неь
            if demonstrate == .weekly {
                EmptyView()
            } else {
                SelectorViewForGroup(subGroup: $subGroup, weekNumber: $weekNumber, weekDay: $weekDay)
            }
        }
        
        .navigationTitle(pageName)
        .navigationSubtitle(secondPageName)

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
            Task {
                groupScheduleViewModel.scheduleForEachGroupInNull()                                                     // очистка данных
                await groupScheduleViewModel.getScheduleGroup(group: groupName)                                         // получение новых данных
                groupScheduleViewModel.filterGroupSchedule(currentWeek: weekNumber, subGroup: subGroup, day: weekDay)   // фильтрация расписания
                funcs.findToday(selectedWeekNumber: &weekNumber, weekDay: &weekDay)                                     // для отображения сегодняшей даты
            }
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
        
        // окно для дополнительной информации о группе
        .sheet(isPresented: $isShowMore) {
            MoreInfoAboutGroup(group: groupScheduleViewModel.arrayOfScheduleGroup, currentWeek: weekViewModel.currentWeek)
                .presentationDetents([.fraction(0.9)])
                .presentationDragIndicator(.visible)
        }
        
        // окно для выбоыр вида представления расписания
        .sheet(isPresented: $isShowViews) {
            ViewSelection()
                .presentationDetents([.fraction(0.3)])
                .presentationDragIndicator(.visible)
        }
        
        .task {
            await groupScheduleViewModel.getScheduleGroup(group: groupName)                                         // получение расписания группы
            groupScheduleViewModel.filterGroupSchedule(currentWeek: weekNumber, subGroup: subGroup, day: weekDay)   // фильтрация расписания
            funcs.findToday(selectedWeekNumber: &weekNumber, weekDay: &weekDay)                                     // нахождение сегодняшнего дня (недели и дня недели)
        }
        
        .onDisappear {
            dismiss()                                            // при переходе в другой tab чтобы выходило к списку
            groupScheduleViewModel.scheduleForEachGroupInNull()  // очистить при выходе (ошибки убрать и т.д.)
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
        if groupScheduleViewModel.filteredScheduleOfGroupOnDay.isEmpty {
            IfDayLessonIsEmpty()
        } else {
            ForEach(groupScheduleViewModel.filteredScheduleOfGroupOnDay) { lesson in
                EachGroupLesson(lesson: lesson)
            }
        }
    }
}

// ВИД: "Списком"
private struct ViewList: View {
    
    @Environment(NetworkViewModelForScheduleGroups.self) var groupScheduleViewModel
    
    var body: some View {
        ForEach(groupScheduleViewModel.filteredScheduleOfGroup) { day in
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
}


// ВИД: "Неделей"
private struct ViewAllInOneWeek: View {
    
    @Environment(NetworkViewModelForScheduleGroups.self) var groupScheduleViewModel
    
    var body: some View {
        ForEach(groupScheduleViewModel.scheduleOfGroup) { day in
            Section(header: Text(day.day)) {
                if day.lesson.isEmpty {
                    Text("Нет занятий")
                } else {
                    ForEach(day.lesson) { lesson in
                        EachGroupLesson(lesson: lesson)
                        #warning("Изменить UI для каждого урока")
                    }
                }
            }
        }
    }
}
