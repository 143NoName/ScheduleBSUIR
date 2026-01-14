//
//  EachEmployeeLesson.swift
//  ScheduleBSUIR
//
//  Created by andrew on 6.01.26.
//

import SwiftUI

struct EachEmployeeLessonLoading: View {
    
    var body: some View {
        HStack {
            VStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.5))
                    .frame(width: 60, height: 14)
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.5))
                    .frame(width: 60, height: 14)
            }
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(0.5))
                .frame(width: 7, height: 40)
            VStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.5))
                    .frame(width: 90, height: 14)
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.5))
                    .frame(width: 60, height: 14)
            }
            Spacer()
            Circle()
                .fill(Color.gray.opacity(0.5))
                .frame(width: 35)
        }
    }
}

#Preview {
    EachEmployeeLessonLoading()
}

struct EachEmployeeLesson: View {
        
    let funcs = MoreFunctions() // используется функций закончился ли урок по времени и по дате
    
    let lesson: Lesson
    
    var colorForRoundedRectangle: Color {
        if lesson.lessonTypeAbbrev == "ЛК" {
            return .green
        } else if lesson.lessonTypeAbbrev == "ПЗ" {
            return .yellow
        } else if lesson.lessonTypeAbbrev == "ЛР" {
            return .red
        }
        return .white
    }
    
    @ViewBuilder
    var calcImageGroup: some View {
        if lesson.numSubgroup == 0 {
            Image(systemName: "person.2")
        } else if lesson.numSubgroup == 1 || lesson.numSubgroup == 2 {
            HStack(spacing: 0) {
                Image(systemName: "person")
                Text("\(lesson.numSubgroup)")
            }
        } else {
            EmptyView()
        }
    }
    
    var body: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading) {
                Text("С \(lesson.startLessonTime)")
                Text("По \(lesson.endLessonTime)")
            }
            
            RoundedRectangle(cornerRadius: 10)
                .fill(colorForRoundedRectangle)
                .frame(width: 7)
            
            VStack(alignment: .leading) {
                Text("\(lesson.lessonTypeAbbrev) по \(lesson.subject)")
                
                if let auditories = lesson.auditories.first {
                    Text(auditories)
                }
                
                if !funcs.comparisonLessonOverDate(lesson: lesson).isEmpty {
                    Text("\(funcs.comparisonLessonOverDate(lesson: lesson))")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color.red)
                }
            }
            
            Spacer()
            
            HStack(spacing: -5) {
                ForEach(lesson.studentGroups.enumerated(), id: \.offset) { index, group in
                    if index < 2 {
                        CircleViewGroups(group: group.name)
                    } else {
                        Image(systemName: "plus")
                            .padding(2)
                            .font(.system(size: 12))
                            .glassEffect(.regular, in: Circle())
                    }
                }
            }
        }

        .font(.system(size: 14))
//        .opacity(funcs.comparisonLessonOverTime(lesson: lesson) || !funcs.comparisonLessonOverDate(lesson: lesson).isEmpty ? 0.5 : 1)
    }
}


struct CircleViewGroups: View {
    
    let group: String
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.clear)
                .frame(width: 35, height: 35)
            VStack {
                Text(group.prefix(3))
                Text(group.suffix(3))
            }
            .font(.caption)
            
        }
        .padding(1)
        .glassEffect(.regular, in: Circle())
    }
}
