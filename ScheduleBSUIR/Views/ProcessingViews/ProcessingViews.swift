//
//  ProcessingViews.swift
//  ScheduleBSUIR
//
//  Created by andrew on 21.11.25.
//

import SwiftUI

struct IfDayLessonIsEmpty: View {
    var body: some View {
        HStack {
            Image(systemName: "graduationcap")
                .resizable()
                .foregroundStyle(.blue)
                .frame(width: 100, height: 100)
            Spacer()
            Text("Сегодня нет занятий")
                .font(.system(size: 16, weight: .medium))
        }
        .padding(EdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20))
    }
}

struct IfHaveErrorSchedule: View {
    
    @EnvironmentObject var groupScheduleViewModel: NetworkViewModelForScheduleGroups
    
    var body: some View {
        HStack {
            Image(systemName: "multiply")
                .resizable()
                .foregroundStyle(.red)
                .frame(width: 100, height: 100)
            Spacer()
            Text(groupScheduleViewModel.errorOfScheduleGroup)
                .font(.system(size: 16, weight: .medium))
            #warning("Пишется только ошибки для групп, можно сделать одну универсальную вместо 3 похожих")
        }
//        .glassEffect(.regular , in: .rect(cornerRadius: 20))
        .padding(EdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20))
    }
}

struct IfErrorGroups: View {
    
    @EnvironmentObject var groupListViewModel: NetworkViewModelForListGroups
    
    var body: some View {
        HStack() {
            Image(systemName: "multiply")
                .resizable()
                .foregroundStyle(.red)
                .frame(width: 100, height: 100)
            Spacer()
            Text(groupListViewModel.errorOfGroupsNum)
                .font(.system(size: 16, weight: .medium))
        }
        .padding(EdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20))
    }
}

#Preview {
    IfDayLessonIsEmpty()
}


struct ErrorView: View {
    
    let errorInfo: String
    
    var body: some View {
        HStack() {
            Image(systemName: "multiply")
                .resizable()
                .foregroundStyle(.red)
                .frame(width: 100, height: 100)
            Spacer()
            Text(errorInfo)
                .font(.system(size: 16, weight: .medium))
        }
        .padding(EdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20))
    }
}
