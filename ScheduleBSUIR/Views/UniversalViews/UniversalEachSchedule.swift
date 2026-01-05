//
//  UniversalEachSchedule.swift
//  ScheduleBSUIR
//
//  Created by andrew on 5.01.26.
//

import SwiftUI

struct UniversalEachSchedule: View {
    
    #warning("Надо ограничить уроки по началу и концу сесиии")
    
    @EnvironmentObject var network: ViewModelForNetwork
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    let funcs = MoreFunctions() // так не правильно
    
    @AppStorage("weekDay") var weekDay: DaysInPicker = .monday
    @AppStorage("subGroupe") var subGroup: SubGroupInPicker = .all
    @AppStorage("weekNumber") var weekNumber: WeeksInPicker = .first
    
    @State var isShowMore: Bool = false
            
    let calendar = Calendar.current

    let url: String                 // ссылка для получения параметра для ссылки
    let isLoading: Bool             // значение загрузки    // не нужно
    let errorLoading: String        // значение ошибки      // не нужно
    let title: String               // название страницы (pageName)
    
    #warning("При просмотре расписания отдельного учителя или группы нет фильтрации по неделе")

    var pageName: String {
        if !isLoading {
            "Загрузка..."
        } else {
            if errorLoading.isEmpty {
                title
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
                if !isLoading {
                    Section(header:
                        Text("Загрузка...")
                            .foregroundStyle(colorScheme == .dark ? .white : .black)
                    ) {
                        ForEach(0..<5, id: \.self) { _ in
                            EachLessonLoading()
                        }
                    }
                } else {
                    if !errorLoading.isEmpty {
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
                                            EachLesson(lesson: lesson)
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
        
        .task {
            do {
                let data: [EachEmployeeResponse] = try await Network().getArray(.group)
            } catch {
                print("")
            }
        }
        
        .refreshable {
            network.scheduleForEachGroupInNull()
            await network.getScheduleGroup(group: url)
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
            await network.getScheduleGroup(group: url)
            
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

//#Preview {
//    NavigationStack {
//        UniversalEachSchedule(lessons: ViewModelForNetwork().arrayOfScheduleGroup, name: \.studentGroupDto.name, url: 261402, isLoading: <#T##Bool#>, errorLoading: <#T##String#>, title: <#T##String#>)
//            .environmentObject(ViewModelForNetwork())
//    }
//}
