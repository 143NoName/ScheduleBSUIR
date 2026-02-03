//
//  AdditionalViews.swift
//  ScheduleBSUIR
//
//  Created by andrew on 1.02.26.
//

import SwiftUI
import Marquee

struct MoreInfoAboutGroup: View {
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    @Environment(NetworkViewModelForWeek.self) var weekViewModel

    let group: EachGroupResponse
    let currentWeek: Int
    
    var specialityAbbrev: String {
        guard let specialityAbbrev = group.studentGroupDto.specialityAbbrev else { return "" }
        return specialityAbbrev
    }
    
    var body: some View {
        ZStack {
            if colorScheme == .light {
                Color.gray
                    .opacity(0.15)
                    .ignoresSafeArea(edges: .all)
            }
            
            NavigationStack {
                List {
                    Section(header: Text("Информация о группе")) {
                        Text("Номер группы: \(group.studentGroupDto.name)")
                        HStack {
                            Text("Специальность: ")
                            Marquee {
                                Text("\(specialityAbbrev) (\(group.studentGroupDto.specialityName))")
                            }
                            .marqueeWhenNotFit(true)
                            .marqueeDuration(8)
                            .frame(height: 20)
                            #warning("Может все таки можно как то начинать слева и крутить налево")
                        }
                        HStack {
                            Text("Факультет: ")
                            Marquee {
                                Text("\(group.studentGroupDto.facultyAbbrev) (\(group.studentGroupDto.facultyName))")
                            }
                            .marqueeWhenNotFit(true)
                            .marqueeDuration(8)
                            .frame(height: 20)
                            #warning("Может все таки можно как то начинать слева и крутить налево")
                        }
                        
                        Text("Степень образования: \(group.studentGroupDto.educationDegree)")
                    }
                    Section(header: Text("Занятия")) {
                        Text("Начало занятий: \(group.startDate ?? "Не известно")")
                        Text("Конец занятий: \(group.endDate ?? "Не известно")")
                    }
                    Section(header: Text("Сессия")) {
                        Text("Начало сесии: \(group.startExamsDate ?? "Не известно")")
                        Text("Конец занятий: \(group.endExamsDate ?? "Не известно")")
                    }
                    Section(header: Text("Период")) {
                        Text("Текущая неделя: \(currentWeek)")
                        Text("Текущий период: \(group.currentPeriod ?? "Не известно")")
                    }
                }
                .scrollContentBackground(.hidden)
                
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                        }
                    }
                }
                .navigationTitle("О группе \(group.studentGroupDto.name)")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}

struct ViewSelection: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    @AppStorage("demonstrate") var demonstrate: Demonstrate = .byDays
    
    var explanation: String {
        switch demonstrate {
        case .byDays:
            "Все расписание будет отображено по дням недели, которые можно будет переключать"
        case .list:
            "Все расписание будет отображено списком дней с расписание только на это день"
        case .weekly:
            "Все расписание будет отображено по дням в одной неделе. Будут отображены все уроки, которые есть в этот день недели"
        }
    }
    
    var body: some View {
        ZStack {
            if colorScheme == .light {
                Color.gray
                    .opacity(0.15)
                    .ignoresSafeArea(edges: .all)
            }
            
            NavigationStack {
                
                Picker("", selection: $demonstrate) {
                    Text("По дням").tag(Demonstrate.byDays)
                    Text("Списком").tag(Demonstrate.list)
                    Text("Неделей").tag(Demonstrate.weekly) // немного не так
                }
                .pickerStyle(.segmented)
                .padding()
                
                Text(explanation)
                    .padding(.horizontal)
                
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                        }
                    }
                }
                
                .navigationTitle("Вид представления расписания")
                .navigationBarTitleDisplayMode(.inline)
            }
            .onChange(of: demonstrate) {
                dismiss()
            }
        }
    }
}
