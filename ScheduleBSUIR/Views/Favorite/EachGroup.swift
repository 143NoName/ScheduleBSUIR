//
//  EachGroup.swift
//  ScheduleBSUIR
//
//  Created by user on 27.10.25.
//

import SwiftUI
import WidgetKit

struct EachGroup: View {
    
    @EnvironmentObject var viewModel: ViewModel
    
    @Environment(\.colorScheme) var colorScheme
    
    let funcs = MoreFunctions()
    
    @AppStorage("weekDay") var weekDay: DaysInPicker = .monday
    @AppStorage("subGroupe") var subGroup: SubGroupInPicker = .all
    @AppStorage("weekNumber") var weekNumber: WeeksInPicker = .first
    
    @AppStorage("favoriteGroup", store: UserDefaults(suiteName: "group.foAppAndWidget.ScheduleBSUIR")) var favoriteGroup: String = ""
    
    let userDefaultSave = UserDefaults(suiteName: "group.foAppAndWidget.ScheduleBSUIR")!
    
    let calendar = Calendar.current
    
    let groupName: String
    
    @State var isShowMore: Bool = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                
                if colorScheme == .light {
                    Color.gray
                        .opacity(0.1)
                        .ignoresSafeArea(edges: .all)
                }
                
                VStack(alignment: .leading) {
                    List {
                        if !viewModel.isLoadingArrayOfScheduleGroup {
                            Section(header:
                                Text("Загрузка...")
                                .foregroundStyle(colorScheme == .dark ? .white : .black)
                            ) {
                                ForEach(0..<6, id: \.self) { _ in
                                    EachLessonLoading()
                                }
                            }
                        } else {
                            if !viewModel.errorOfScheduleGroup.isEmpty {
                                IfHaveErrorSchedule()
                            } else {
                                Section(header:
                                            Text("Расписание")
                                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                                ) {
                                    ForEach(viewModel.filteredLessons.enumerated(), id: \.offset) { index, day in
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
                }
                
                VStack(spacing: 0) {
                    Button("К сегодняшнему дню") {
                        if let updateWeekNum = WeeksInPicker(rawValue: viewModel.currentWeek) {
                            weekNumber = updateWeekNum
                        }
                        
                        if let currentDay = DaysInPicker(rawValue: calendar.component(.weekday, from: Date()) - 1)  {
                            weekDay = currentDay
                        }
                    }
                    .padding(EdgeInsets(top: 8, leading: 18, bottom: 8, trailing: 18))
                    .glassEffect(.regular , in: .rect(cornerRadius: 12))
                    .foregroundStyle(.primary)
                    
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
                viewModel.allInNull()
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
                viewModel.filterSchedule(currentWeek: weekNumber, subGroup: subGroup)
            }
            
            .onChange(of: weekNumber) {
                viewModel.filterSchedule(currentWeek: weekNumber, subGroup: subGroup)
            }
            
            .sheet(isPresented: $isShowMore) {

            }
            
//            .onAppear {
//                funcs.saveInUserDefaults(viewModel.arrayOfScheduleGroup.schedules ,weekDay: weekDay, weenNumber: viewModel.currentWeek, subGroupe: subGroup, favoriteGroup: favoriteGroup) // сохранение в UserDefaults для виджета
//            }
            
            .task {
                await viewModel.getScheduleGroup(group: groupName) // получение расписания группы
                viewModel.filterSchedule(currentWeek: weekNumber, subGroup: subGroup) // фильтрация по неделе и по подгруппе
                
                
                if let updateWeekNum = WeeksInPicker(rawValue: viewModel.currentWeek) {
                    weekNumber = updateWeekNum
                }
                
                if let currentDay = DaysInPicker(rawValue: calendar.component(.weekday, from: Date()) - 1)  {
                    weekDay = currentDay
                }
                
                print("Расписание: \(viewModel.arrayOfScheduleGroup)")
                print("ОшибкаЖ: \(viewModel.errorOfScheduleGroup)")
            }
        }
    }
}

#Preview {
    EachGroup(groupName: "261402")
        .environmentObject(ViewModel())
}
