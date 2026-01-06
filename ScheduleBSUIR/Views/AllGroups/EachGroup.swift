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
    
    @EnvironmentObject var network: ViewModelForNetwork
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    let funcs = MoreFunctions() // так не правильно
    
    @AppStorage("weekDay") var weekDay: DaysInPicker = .monday
    @AppStorage("subGroupe") var subGroup: SubGroupInPicker = .all
    @AppStorage("weekNumber") var weekNumber: WeeksInPicker = .first
            
    let calendar = Calendar.current
    let groupName: String
        
    @State var isShowMore: Bool = false
    #warning("При просмотре расписания отдельного учителя или группы нет фильтрации по неделе")

    var pageName: String {
        if !network.isLoadingArrayOfScheduleGroup {
            "Загрузка..."
        } else {
            if network.errorOfScheduleGroup.isEmpty {
                network.arrayOfScheduleGroup.studentGroupDto.name
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
                if !network.isLoadingArrayOfScheduleGroup {
                    Section(header:
                        Text("Загрузка...")
                            .foregroundStyle(colorScheme == .dark ? .white : .black)
                    ) {
                        ForEach(0..<5, id: \.self) { _ in
                            EachGroupLessonLoading()
                        }
                    }
                } else {
                    if !network.errorOfScheduleGroup.isEmpty {
                        IfHaveErrorSchedule()
                        #warning("Сделать ошибку такой же стеклянной")
                    } else {
                        Section(header:
                                    Text("Расписание")
                                        .foregroundStyle(colorScheme == .dark ? .white : .black),
                                footer:
                                    Color.clear
                                        .frame(height: 300)
                        ) {
                            ForEach(network.scheduleGroupByDays.enumerated(), id: \.offset) { index, day in
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
            
            SelectorViewForGroup(todayWeek: network.currentWeek, subGroup: $subGroup, weekNumber: $weekNumber, weekDay: $weekDay)
        }
        .navigationTitle(pageName)
//        .navigationBarTitleDisplayMode(.inline)
        
        .refreshable {
            network.scheduleForEachGroupInNull()
            await network.getScheduleGroup(group: groupName)
            network.filterGroupSchedule(currentWeek: weekNumber, subGroup: subGroup)
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
            // получение расписания группы
            await network.getScheduleGroup(group: groupName)
            
            // фильтрация по неделе и по подгруппе
            network.filterGroupSchedule(currentWeek: weekNumber, subGroup: subGroup)
            
            // нахождение сегодняшнего дня (недели и дня недели)
            funcs.findToday(todayWeek: network.currentWeek, weekNumber: &weekNumber, weekDay: &weekDay)
        }
        
        .onDisappear {
            dismiss() // при переходе в другой tab чтобы выходило к списку
            network.scheduleForEachGroupInNull() // очистить при выходе (ошибки убрать и т.д.)
            
        }
    }
}

#Preview {
    NavigationStack {
        EachGroup(groupName: "261402")
            .environmentObject(ViewModelForNetwork())

    }
    
}
