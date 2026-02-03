//
//  EachLesson.swift
//  ScheduleBSUIR
//
//  Created by user on 31.10.25.
//

import SwiftUI


struct EachGroupLessonLoading: View {
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
            
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(0.5))
                .frame(width: 20, height: 20)
            
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.gray.opacity(0.5))
                .frame(width: 35, height: 35)
                .padding(.leading)
        }
    }
}

struct EachGroupLesson: View {
        
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
            VStack(alignment: .trailing) {
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
            
            calcImageGroup
            
            AsyncImage(url: {
                            if let employees = lesson.employees, !employees.isEmpty,
                               let photoLink = employees[0].photoLink,
                               let url = URL(string: photoLink) {
                                return url
                            }
                            return nil
                        }()
            ) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .frame(width: 35, height: 35)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                    #warning("Как бы отобразить загрузку")
                default:
                    Image("PlainPhoto")
                        .resizable()
                        .frame(width: 35, height: 35)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                }
            }
            .padding(.leading, 10)
        }
        .font(.system(size: 14))
//        .opacity(funcs.comparisonLessonOverTime(lesson: lesson) || !funcs.comparisonLessonOverDate(lesson: lesson).isEmpty ? 0.5 : 1)

        
            #warning("Тест")
//        HStack {
//            Text("\(lesson.numSubgroup)")
//            Text("\(lesson.weekNumber)")
//        }
        
    }
}
