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
    @EnvironmentObject var filter: ViewModelForFilterService
    @Environment(\.viewModelForAppStorageKey) var appStorage
    
    
    @Environment(\.colorScheme) var colorScheme
    
    let funcs = MoreFunctions()
    
    @AppStorage("weekDay") var weekDay: DaysInPicker = .monday
    @AppStorage("subGroupe") var subGroup: SubGroupInPicker = .all
    @AppStorage("weekNumber") var weekNumber: WeeksInPicker = .first
    
    @AppStorage("favoriteGroup", store: UserDefaults(suiteName: "group.foAppAndWidget.ScheduleBSUIR")) var favoriteGroup: String = ""
        
    let calendar = Calendar.current // используется для нахождения сегодняшего дня (надо вынести в отдельную функцию)
    
    let groupName: String
    
    @State var isShowMore: Bool = false

    var body: some View {
        ZStack(alignment: .bottom) {
            
            if colorScheme == .light {
                Color.gray
                    .opacity(0.1)
                    .ignoresSafeArea(edges: .all)
            }
            
            VStack(alignment: .leading) {
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
                                ForEach(network.filteredLessons.enumerated(), id: \.offset) { index, day in
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
                                
//                                ForEach(filter.filteredLessons.enumerated(), id: \.offset) { index, day in
//                                    Text("jnihbu")
//                                }
                                
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            
            VStack(spacing: 0) {
                Button {
                    if let updateWeekNum = WeeksInPicker(rawValue: network.currentWeek) {
                        weekNumber = updateWeekNum
                    }
                        
                    if let currentDay = DaysInPicker(rawValue: calendar.component(.weekday, from: Date()) - 1)  {
                        weekDay = currentDay
                    }
                } label: {
                    Text("К сегодняшнему дню")
                        .padding(EdgeInsets(top: 4, leading: 12, bottom: 4, trailing: 12))
                }
                .buttonStyle(GlassButtonStyle(.regular))
                
                VStack {
                    VStack(alignment: .leading) {
                        Text("День недели")
                            .font(.system(size: 16, weight: .semibold))
                            .padding(.leading)
                        Picker("", selection: $weekDay) {
                            Text("пн").tag(DaysInPicker.monday)
                            Text("вт").tag(DaysInPicker.tuesday)
                            Text("ср").tag(DaysInPicker.wednesday)
                            Text("чт").tag(DaysInPicker.thursday)
                            Text("пт").tag(DaysInPicker.friday)
                            Text("сб").tag(DaysInPicker.saturday)
                            Text("вс").tag(DaysInPicker.sunday)
                        }
                        .pickerStyle(.segmented)
    
                    }
                    .frame(height: 30)
                    .padding(EdgeInsets(top: 0, leading: 16, bottom: 40, trailing: 16))
                    
                    HStack(spacing: 20) {
                        VStack(alignment: .leading) {
                            Text("Подгруппа")
                                .font(.system(size: 16, weight: .semibold))
                                .padding(.leading)
                            Picker("", selection: $subGroup) {
                                Text("Все").tag(SubGroupInPicker.all)
                                Text("1").tag(SubGroupInPicker.first)
                                Text("2").tag(SubGroupInPicker.second)
                            }
                            .pickerStyle(.segmented)
                        }
    
                        VStack(alignment: .leading) {
                            Text("Неделя")
                                .font(.system(size: 16, weight: .semibold))
                                .padding(.leading)
                            Picker("", selection: $weekNumber) {
                                Text("1").tag(WeeksInPicker.first)
                                Text("2").tag(WeeksInPicker.second)
                                Text("3").tag(WeeksInPicker.third)
                                Text("4").tag(WeeksInPicker.fourth)
                            }
                            .pickerStyle(.segmented)
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(height: 200)
                .glassEffect(.regular , in: .rect(cornerRadius: 20))
                .padding()
            }
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
        
        .onChange(of: subGroup) {
//            filter.filterSchedule(currentWeek: weekNumber, subGroup: subGroup, scheduleDays: network.scheduleDays)
            network.filterSchedule(currentWeek: weekNumber, subGroup: subGroup)
            // при изменении подгруппы фильтрация расписания
        }
        
        .onChange(of: weekNumber) {
//            filter.filterSchedule(currentWeek: weekNumber, subGroup: subGroup, scheduleDays: network.scheduleDays)
            network.filterSchedule(currentWeek: weekNumber, subGroup: subGroup)
            // при изменении недели фильтрация расписания
        }
        
        .sheet(isPresented: $isShowMore) {

        }
        
        .task {
            await network.getScheduleGroup(group: groupName) // получение расписания группы
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
