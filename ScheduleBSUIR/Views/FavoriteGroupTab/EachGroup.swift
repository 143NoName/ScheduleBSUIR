//
//  EachGroup.swift
//  ScheduleBSUIR
//
//  Created by user on 27.10.25.
//

import SwiftUI
import WidgetKit

struct ScheduleView: View {
    
    @EnvironmentObject var network: ViewModelForNetwork
    @Environment(\.colorScheme) var colorScheme
    
    let funcs = MoreFunctions() // так не правильно
    
    @AppStorage("weekDay") var weekDay: DaysInPicker = .monday
    @AppStorage("subGroupe") var subGroup: SubGroupInPicker = .all
    @AppStorage("weekNumber") var weekNumber: WeeksInPicker = .first
    
    @AppStorage("favoriteGroup", store: UserDefaults(suiteName: "group.foAppAndWidget.ScheduleBSUIR")) var favoriteGroup: String = ""
        
    let calendar = Calendar.current
        
    @State var isShowMore: Bool = false
    
    var pageName: String {
        if network.arrayOfScheduleGroup.studentGroupDto.name.isEmpty {
            "Загрузка..."
        } else {
            network.arrayOfScheduleGroup.studentGroupDto.name
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            
            if colorScheme == .light {
                Color.gray
                    .opacity(0.1)
                    .ignoresSafeArea(edges: .all)
            }
            
            List {
                #warning("Все проверки ведутся с данными для групп, а могут тут использоваться и преподаватели")
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
            
            SelectorView(subGroup: $subGroup, weekNumber: $weekNumber, weekDay: $weekDay)
        }
        
        .onDisappear {
            network.allInNull() // чистка всего при деинициализации
        }

        .navigationTitle(pageName)
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
//            filter.filterSchedule(currentWeek: weekNumber, subGroup: subGroup, scheduleDays: network.scheduleDays)
                  network.filterSchedule(currentWeek: weekNumber, subGroup: subGroup) // фильтрация по неделе и по подгруппе
            
            if let updateWeekNum = WeeksInPicker(rawValue: network.currentWeek) {
                weekNumber = updateWeekNum
            }
            
            if let currentDay = DaysInPicker(rawValue: calendar.component(.weekday, from: Date()) - 1)  {
                weekDay = currentDay
            }
            #warning("Тут надо вынести в отдельную функцию")
            #warning("Также надо переделать филтрация по неделе и подгруппе при появлении")
        }
        .onDisappear {
            print("Деинициализация")
        }
    }
}

#Preview {
    NavigationStack {
        ScheduleView()
            .environmentObject(ViewModelForNetwork())
//            .task {
//                await network.getScheduleGroup(group: "261402") // получение расписания группы
//            }
    }
    
}
