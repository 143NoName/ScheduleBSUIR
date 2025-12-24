//
//  EachGroup.swift
//  ScheduleBSUIR
//
//  Created by user on 27.10.25.
//

import SwiftUI
import WidgetKit

struct EachGroup: View {
    
    @EnvironmentObject var network: ViewModelForNetwork
    @Environment(\.colorScheme) var colorScheme
    
    let funcs = MoreFunctions() // так не правильно
    
    @AppStorage("weekDay") var weekDay: DaysInPicker = .monday
    @AppStorage("subGroupe") var subGroup: SubGroupInPicker = .all
    @AppStorage("weekNumber") var weekNumber: WeeksInPicker = .first
    
    @AppStorage("favoriteGroup", store: UserDefaults(suiteName: "group.foAppAndWidget.ScheduleBSUIR")) var favoriteGroup: String = ""
        
    let calendar = Calendar.current
    
    let groupName: String
        
    @State var isShowMore: Bool = false
    
    var pageName: String {
        if network.arrayOfScheduleGroup.studentGroupDto.name.isEmpty {
            "Загрузка..."
        } else {
            network.arrayOfScheduleGroup.studentGroupDto.name
        }
    }
    #warning("При отсутствии данных, напишется Загрузка...")

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
                            EachLessonLoading()
                        }
                    }
                } else {
                    if !network.errorOfScheduleGroup.isEmpty {
                        IfHaveErrorSchedule()
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
            
            SelectorViewForGroup(todayWeek: network.currentWeek, subGroup: $subGroup, weekNumber: $weekNumber, weekDay: $weekDay)
        }
        .navigationTitle(pageName)
        
//        .onDisappear {
//            network.scheduleForEachGroupInNull() // чистка расписания при деинициализации
//        }
        
        .refreshable {
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
    }
}

#Preview {
    NavigationStack {
        EachGroup(groupName: "261402")
            .environmentObject(ViewModelForNetwork())

    }
    
}

#warning("Попробовать вернуть обычный цвет списка")
