//
//  ProcessingViews.swift
//  ScheduleBSUIR
//
//  Created by andrew on 21.11.25.
//

import SwiftUI

// если сегодня нет уроков
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

// если есть ошибка
struct IfHaveError: View {
        
    let error: String
    
    var body: some View {
        HStack {
            Image(systemName: "multiply")
                .resizable()
                .foregroundStyle(.red)
                .frame(width: 100, height: 100)
            Spacer()
            Text(error)
                .font(.system(size: 16, weight: .medium))
        }
        .padding(EdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20))
    }
}

//struct IfErrorGroups: View {
//    
//    @Environment(NetworkViewModelForListGroups.self) var groupListViewModel
//    
//    var body: some View {
//        HStack() {
//            Image(systemName: "multiply")
//                .resizable()
//                .foregroundStyle(.red)
//                .frame(width: 100, height: 100)
//            Spacer()
//            Text(groupListViewModel.errorOfGroupsNum)
//                .font(.system(size: 16, weight: .medium))
//        }
//        .padding(EdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20))
//    }
//}


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
