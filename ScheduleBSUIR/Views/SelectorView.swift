//
//  SelectorView.swift
//  ScheduleBSUIR
//
//  Created by andrew on 20.12.25.
//

import SwiftUI

struct SelectorViewForGroup: View {
    @EnvironmentObject var network: ViewModelForNetwork
    
    let funcs = MoreFunctions()
    
    let calendar = Calendar.current
    let date = Date()
    
    let todayWeek: Int
    
    @Binding var subGroup: SubGroupInPicker
    @Binding var weekNumber: WeeksInPicker
    @Binding var weekDay: DaysInPicker
    
    var body: some View {
        VStack(spacing: 0) {
            Button {
                funcs.findToday(todayWeek: todayWeek, weekNumber: &weekNumber, weekDay: &weekDay)
            } label: {
                Text("К сегодняшнему дню")
                    .padding(EdgeInsets(top: 2, leading: 8, bottom: 2, trailing: 8))
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
                .onChange(of: subGroup) {
                    network.filterGroupSchedule(currentWeek: weekNumber, subGroup: subGroup)
                    // при изменении подгруппы фильтрация расписания
                    #warning("Тут функция меняет только массив для групп, а надо и для преподавателей")
                }
                
                .onChange(of: weekNumber) {
                    network.filterGroupSchedule(currentWeek: weekNumber, subGroup: subGroup)
                    // при изменении недели фильтрация расписания
                    #warning("Тут функция меняет только массив для групп, а надо и для преподавателей")
                }
                
            }
            .frame(height: 200)
            .glassEffect(.regular , in: .rect(cornerRadius: 20))
            .padding()
        }
    }
}

#Preview {
    @Previewable @State var subGroup: SubGroupInPicker = .all
    @Previewable @State var weekNumber: WeeksInPicker = .first
    @Previewable @State var weekDay: DaysInPicker = .monday
    
    SelectorViewForGroup(todayWeek: 1, subGroup: $subGroup, weekNumber: $weekNumber, weekDay: $weekDay)
        .environmentObject(ViewModelForNetwork())
}


struct SelectorViewForEmployee: View {
    @EnvironmentObject var network: ViewModelForNetwork
    
    let funcs = MoreFunctions()
    
    let calendar = Calendar.current
    let date = Date()
    #warning("Надо бы создать один экземпляр календаря и даты на все приложение и передавать его через Envaronment")
    
    let todayWeek: Int
    
    @Binding var weekNumber: WeeksInPicker
    @Binding var weekDay: DaysInPicker
    
    var  body: some View {
        VStack(spacing: 0) {
            Button {
                funcs.findToday(todayWeek: todayWeek, weekNumber: &weekNumber, weekDay: &weekDay)
            } label: {
                Text("К сегодняшнему дню")
                    .padding(EdgeInsets(top: 2, leading: 8, bottom: 2, trailing: 8))
            }
            .buttonStyle(GlassButtonStyle(.regular))
            
            VStack {
                VStack(alignment: .leading) {
                    Text("День недели")
                        .font(.system(size: 16, weight: .semibold))
//                        .padding(.leading)
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
                

                VStack(alignment: .leading) {
                    Text("Неделя")
                        .font(.system(size: 16, weight: .semibold))
                    Picker("", selection: $weekNumber) {
                        Text("1").tag(WeeksInPicker.first)
                        Text("2").tag(WeeksInPicker.second)
                        Text("3").tag(WeeksInPicker.third)
                        Text("4").tag(WeeksInPicker.fourth)
                    }
                    .pickerStyle(.segmented)
                }
                .padding(.horizontal, 16)
                
                .onChange(of: weekNumber) {
//                    network.filterGroupSchedule(currentWeek: weekNumber, subGroup: subGroup)
                    // при изменении недели фильтрация расписания
                }
                
            }
            .frame(height: 200)
            .glassEffect(.regular , in: .rect(cornerRadius: 20))
            .padding()
        }
    }
}

#Preview {
    @Previewable @State var weekNumber: WeeksInPicker = .first
    @Previewable @State var weekDay: DaysInPicker = .monday
    
    return SelectorViewForEmployee(todayWeek: 1, weekNumber: $weekNumber, weekDay: $weekDay)
        .environmentObject(ViewModelForNetwork())
}
