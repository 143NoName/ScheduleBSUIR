//
//  EachGroup.swift
//  ScheduleBSUIR
//
//  Created by user on 27.10.25.
//

import SwiftUI
import WidgetKit

struct EachGroup: View {
    
    #warning("Надо ограничить уроки по началу и концу сесиии")
    
    @EnvironmentObject var weekViewModel: NetworkViewModelForWeek
    @EnvironmentObject var groupScheduleViewModel: NetworkViewModelForScheduleGroups
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    let funcs = MoreFunctions() // так не правильно
    
    @State var weekDay: DaysInPicker = .monday
    @State var weekNumber: WeeksInPicker = .first
    @State var subGroup: SubGroupInPicker = .all
            
    let calendar = Calendar.current
    let groupName: String
        
    @State var isShowMore: Bool = false
    
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
                        IfHaveErrorSchedule()
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
                    isShowMore.toggle()
                } label: {
                    Text("i")
                        .font(.system(size: 18, weight: .semibold))
                }
            }
        }
        
        .task {
            await groupScheduleViewModel.getScheduleGroup(group: groupName)                             // получение расписания группы
            groupScheduleViewModel.filterGroupSchedule(currentWeek: weekNumber, subGroup: subGroup)     // фильтрация по неделе и по подгруппе
            funcs.findToday(selectedWeekNumber: &weekNumber, weekDay: &weekDay)                         // нахождение сегодняшнего дня (недели и дня недели)
        }
        
        .onDisappear {
            dismiss() // при переходе в другой tab чтобы выходило к списку
            groupScheduleViewModel.scheduleForEachGroupInNull() // очистить при выходе (ошибки убрать и т.д.)
        }
    }
}

#Preview {
    NavigationStack {
        EachGroup(groupName: "310101")
            .environmentObject(NetworkViewModelForWeek())
            .environmentObject(NetworkViewModelForScheduleGroups())
    }
}
