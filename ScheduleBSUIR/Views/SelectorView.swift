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
    
    @State var showAll: Bool = true
    
    @Binding var subGroup: SubGroupInPicker
    @Binding var weekNumber: WeeksInPicker
    @Binding var weekDay: DaysInPicker
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button {
                    funcs.findToday(todayWeek: todayWeek, weekNumber: &weekNumber, weekDay: &weekDay)
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
                        .onChange(of: subGroup) {
                            network.filterGroupSchedule(currentWeek: weekNumber, subGroup: subGroup)
                            // при изменении подгруппы фильтрация расписания
                        }
                        
                        .onChange(of: weekNumber) {
                            network.filterGroupSchedule(currentWeek: weekNumber, subGroup: subGroup)
                            // при изменении недели фильтрация расписания
                        }
                    }
                } else {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("День недели:")
                                .font(.system(size: 16, weight: .semibold))
                            Text("\(weekDay.filterByDay)")
                        }
                        Spacer()
                        VStack(alignment: .leading) {
                            Text("Подгруппа:")
                                .font(.system(size: 16, weight: .semibold))
                            Text("\(subGroup.rawValue)")
                        }
                        Spacer()
                        VStack(alignment: .leading) {
                            Text("Неделя:")
                                .font(.system(size: 16, weight: .semibold))
                            Text("\(weekNumber.rawValue)")
                        }
                    }
                    .padding(10)
                }
                
            }
            .glassEffect(.regular , in: .rect(cornerRadius: 20))

        }
        .padding()
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
    
    @State var showAll: Bool = true
    
    @Binding var weekNumber: WeeksInPicker
    @Binding var weekDay: DaysInPicker
    
    var  body: some View {
        VStack(spacing: 0) {
            HStack {
                Button {
                    funcs.findToday(todayWeek: todayWeek, weekNumber: &weekNumber, weekDay: &weekDay)
                } label: {
                    Text("К сегодняшнему дню")
                        .padding(EdgeInsets(top: 2, leading: 8, bottom: 2, trailing: 8))
                }
                .buttonStyle(GlassButtonStyle(.regular))
                Spacer()
                Button {
                    withAnimation(.easeInOut) {
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
                VStack {
                    if showAll {
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
                        .padding(10)
                        
                        .onChange(of: weekNumber) {
                            network.filterByWeekGroupSchedule(currentWeek: weekNumber)
                            // при изменении недели фильтрация расписания
                        }
                    } else {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("День недели:")
                                    .font(.system(size: 16, weight: .semibold))
                                Text("\(weekDay.filterByDay)")
                            }
                            Spacer()
                            VStack(alignment: .leading) {
                                Text("Неделя:")
                                    .font(.system(size: 16, weight: .semibold))
                                Text("\(weekNumber.rawValue)")
                            }
                        }
                        .padding(10)
                    }
                }
            }
            .glassEffect(.regular , in: .rect(cornerRadius: 20))
        }
        .padding()
    }
}

#Preview {
    @Previewable @State var weekNumber: WeeksInPicker = .first
    @Previewable @State var weekDay: DaysInPicker = .monday
    
    return SelectorViewForEmployee(todayWeek: 1, weekNumber: $weekNumber, weekDay: $weekDay)
        .environmentObject(ViewModelForNetwork())
}


struct SelectorViewForPersonalAccount: View {
    @Environment(\.appStorageKey) var appStorageKey
    @EnvironmentObject var network: ViewModelForNetwork
    
    @State var showAll: Bool = true
    
    @State var angle: CGFloat = 0
    
//    @State var studentGroup: String = "Не выбрано"
    @State var whoUser: WhoUser = .none
    @AppStorage("favoriteGroup", store: UserDefaults(suiteName: "group.foAppAndWidget.ScheduleBSUIR")) var favoriteGroup: String = "Не выбрано"
    @AppStorage("subGroup", store: UserDefaults(suiteName: "group.foAppAndWidget.ScheduleBSUIR")) var subGroup: Int = 0
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
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
                
                VStack {
                    if showAll {
                        VStack {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Подгруппа")
                                        .font(.system(size: 16, weight: .semibold))
                                        .padding(.leading)
                                    Picker("Подгруппа", selection: $subGroup) {
                                        Text("Все").tag(0)
                                        Text("Первая").tag(1)
                                        Text("Вторая").tag(2)
                                    }
                                    .pickerStyle(.segmented)
                                }
                                
                                VStack(spacing: 8)  {
                                    Text("Группа")
                                        .font(.system(size: 16, weight: .semibold))
                                    
                                    Menu {
                                        Text("Не выбрано").tag("")
                                        ForEach(network.arrayOfGroupsNum.enumerated(), id: \.offset) { index, group in
                                            Button(group.name) {
                                                favoriteGroup = group.name
                                            }
                                        }
                                    } label: {
                                        Text(favoriteGroup)
                                            .foregroundStyle(Color(Color.primary))
                                            .padding(EdgeInsets(top: 4, leading: 10, bottom: 4, trailing: 10))
                                            .background(Color.gray.opacity(0.2))
                                            .clipShape(RoundedRectangle(cornerRadius: 14))
                                    }
                                    .onChange(of: favoriteGroup) { oldValue, newValue in
                                        print(favoriteGroup)
                                    }
                                }
                                .padding(.leading, 10)
                            }
                            .padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 10))
                            

                            VStack(alignment: .leading) {
                                Text("Пользователь")
                                    .font(.system(size: 16, weight: .semibold))
                                    .padding(.leading)
                                Picker("", selection: $whoUser) {
                                    Text("Ученик").tag(WhoUser.student)
                                    Text("Преподаватель").tag(WhoUser.employee)
                                    Text("Другое").tag(WhoUser.none)
                                }
                                .pickerStyle(.segmented)
                            }
                            .padding(10)
                            
                //            .onChange(of: weekNumber) {
                ////                    network.filterGroupSchedule(currentWeek: weekNumber, subGroup: subGroup)
                //                // при изменении недели фильтрация расписания
                //            }
                        }
                    } else {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Подгруппа:")
                                    .font(.system(size: 16, weight: .semibold))
                                Text("\(subGroup)")
                            }
                            Spacer()
                            VStack(alignment: .leading) {
                                Text("Группа:")
                                    .font(.system(size: 16, weight: .semibold))
                                Text("\(favoriteGroup)")
                            }
                            Spacer()
                            VStack(alignment: .leading) {
                                Text("Пользователь:")
                                    .font(.system(size: 16, weight: .semibold))
                                Text("\(whoUser.rawValue)")
                            }
                        }
                        .padding(10)
                    }
                }
                    .glassEffect(.regular , in: .rect(cornerRadius: 20))
            }
            .padding()
        }
    }
}


#Preview {
    SelectorViewForPersonalAccount()
        .environmentObject(ViewModelForNetwork())
}
