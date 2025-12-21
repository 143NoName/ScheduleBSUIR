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
    
    let funcs = MoreFunctions()
    
    @AppStorage("weekDay") var weekDay: DaysInPicker = .monday
    @AppStorage("subGroupe") var subGroup: SubGroupInPicker = .all
    @AppStorage("weekNumber") var weekNumber: WeeksInPicker = .first
    
    @AppStorage("favoriteGroup", store: UserDefaults(suiteName: "group.foAppAndWidget.ScheduleBSUIR")) var favoriteGroup: String = ""
        
    let calendar = Calendar.current
    
    let groupName: String // получение номера группы для загрузки расписания и для navigationTitle
    
    @State var isShowMore: Bool = false

    var body: some View {
        ZStack(alignment: .bottom) {
            
            if colorScheme == .light {
                Color.gray
                    .opacity(0.1)
                    .ignoresSafeArea(edges: .all)
            }
            
//            VStack(alignment: .leading) {
                List {
                    if !network.isLoadingArrayOfScheduleGroup {
                        Section(header:
                            Text("Загрузка...")
                                .foregroundStyle(colorScheme == .dark ? .white : .black)
                        ) {
                            ForEach(0..<6, id: \.self) { _ in
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
                                ForEach(network.scheduleByDays.enumerated(), id: \.offset) { index, day in
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
//            }
            
            SelectorView(subGroup: $subGroup, weekNumber: $weekNumber, weekDay: $weekDay)
        }
        
        .onDisappear {
            network.allInNull() // чистка всего при деинициализации
        }

        .navigationTitle(groupName)
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
            await network.getScheduleGroup(group: groupName) // получение расписания группы
//            filter.filterSchedule(currentWeek: weekNumber, subGroup: subGroup, scheduleDays: network.scheduleDays)
                  network.filterSchedule(currentWeek: weekNumber, subGroup: subGroup) // фильтрация по неделе и по подгруппе
            
            // надо вынести в отдельную функцию
            if let updateWeekNum = WeeksInPicker(rawValue: network.currentWeek) {
                weekNumber = updateWeekNum
            }
            
            if let currentDay = DaysInPicker(rawValue: calendar.component(.weekday, from: Date()) - 1)  {
                weekDay = currentDay
            }
            // надо вынести в отдельную функцию
        }
    }
}

#Preview {
    NavigationStack {
        EachGroup(groupName: "261402")
            .environmentObject(ViewModelForNetwork())
    }
    
}
