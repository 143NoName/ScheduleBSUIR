//
//  SelectorView.swift
//  ScheduleBSUIR
//
//  Created by andrew on 20.12.25.
//

import SwiftUI

struct SelectorView: View {
    
    @EnvironmentObject var network: ViewModelForNetwork
    
    let calendar = Calendar.current
    let date = Date()
    
    @Binding var subGroup: SubGroupInPicker
    @Binding var weekNumber: WeeksInPicker
    @Binding var weekDay: DaysInPicker
    
    var body: some View {
        VStack(spacing: 0) {
            Button {
                if let updateWeekNum = WeeksInPicker(rawValue: network.currentWeek) {
                    weekNumber = updateWeekNum
                }
                    
                if let currentDay = DaysInPicker(rawValue: calendar.component(.weekday, from: date) - 1)  {
                    weekDay = currentDay
                }
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
                    network.filterSchedule(currentWeek: weekNumber, subGroup: subGroup)
                    // при изменении подгруппы фильтрация расписания
                }
                
                .onChange(of: weekNumber) {
                    network.filterSchedule(currentWeek: weekNumber, subGroup: subGroup)
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
    @Previewable @State var subGroup: SubGroupInPicker = .all
    @Previewable @State var weekNumber: WeeksInPicker = .first
    @Previewable @State var weekDay: DaysInPicker = .monday
    
    return SelectorView(subGroup: $subGroup, weekNumber: $weekNumber, weekDay: $weekDay)
        .environmentObject(ViewModelForNetwork())
}
