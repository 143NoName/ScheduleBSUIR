//
//  SelectorInGroup.swift
//  ScheduleBSUIR
//
//  Created by andrew on 25.12.25.
//

import SwiftUI

struct SelectorViewForGroup: View {
    let funcs = MoreFunctions()
    
    @State var showAll: Bool = true
    
    @Binding var subGroup: SubGroupInPicker
    @Binding var weekNumber: WeeksInPicker
    @Binding var weekDay: DaysInPicker
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button {
                    #warning("Сделать функция из другого класса")
                    funcs.findToday(selectedWeekNumber: &weekNumber, weekDay: &weekDay)
                } label: {
                    Text("К сегодняшнему дню")
                        .padding(EdgeInsets(top: 2, leading: 8, bottom: 2, trailing: 8))
                }
                .buttonStyle(GlassButtonStyle(.regular))
                Spacer()
                Button {
                    withAnimation(.easeOut) {
                        showAll.toggle()
                    }
                } label: {
                    Image(systemName: "chevron.down")
                        .padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                        .rotationEffect(showAll ? .degrees(0) : .degrees(180))
                }
                .buttonStyle(GlassButtonStyle(.regular))
            }
            .padding(.bottom)
            
            VStack {
                if showAll {
                    MaxViewSelector(subGroup: $subGroup, weekNumber: $weekNumber, weekDay: $weekDay)
                } else {
                    MinViewSelector(weekDay: weekDay.filterByDay, subGroup: subGroup.inString, weekNumber: weekNumber.inString)
                }
                
            }
            .glassEffect(.regular , in: .rect(cornerRadius: 20))

        }
        .padding()
    }
}

//#Preview {
//    @Previewable @State var subGroup: SubGroupInPicker = .all
//    @Previewable @State var weekNumber: WeeksInPicker = .first
//    @Previewable @State var weekDay: DaysInPicker = .monday
//    
//    SelectorViewForGroup(subGroup: $subGroup, weekNumber: $weekNumber, weekDay: $weekDay)
//}


private struct MaxViewSelector: View {
    
    @Environment(NetworkViewModelForScheduleGroups.self) var groupScheduleViewModel
    @Binding var subGroup: SubGroupInPicker
    @Binding var weekNumber: WeeksInPicker
    @Binding var weekDay: DaysInPicker
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                Text("День недели")
                    .font(.system(size: 14, weight: .semibold))
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
            .padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 10))
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Подгруппа")
                        .font(.system(size: 14, weight: .semibold))
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
                        .font(.system(size: 14, weight: .semibold))
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
            .padding(10)
            
//            // при изменении дня недели выбор расписания на день (берем один день из массива дней)
            .onChange(of: weekDay) { _, newValue in
                groupScheduleViewModel.chooseDay(day: newValue)
            }

                        
            // при изменении подгруппы фильтрация расписания
            .onChange(of: subGroup) {
                groupScheduleViewModel.filterGroupSchedule2(currentWeek: weekNumber, subGroup: subGroup, day: weekDay)
            }
            // при изменении недели фильтрация расписания
            .onChange(of: weekNumber) {
                groupScheduleViewModel.filterGroupSchedule2(currentWeek: weekNumber, subGroup: subGroup, day: weekDay)
            }
        }
    }
}

private struct MinViewSelector: View {
    
    let weekDay: String
    let subGroup: String
    let weekNumber: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("День недели:")
                    .font(.system(size: 16, weight: .semibold))
                Text(weekDay)
            }
            Spacer()
            VStack(alignment: .leading) {
                Text("Подгруппа:")
                    .font(.system(size: 16, weight: .semibold))
                Text(subGroup)
            }
            Spacer()
            VStack(alignment: .leading) {
                Text("Неделя:")
                    .font(.system(size: 16, weight: .semibold))
                Text(weekNumber)
            }
        }
        .padding(10)
    }
}
