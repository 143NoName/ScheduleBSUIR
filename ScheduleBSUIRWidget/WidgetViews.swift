//
//  WidgetViews.swift
//  ScheduleBSUIRWidgetExtension
//
//  Created by andrew on 17.12.25.
//

import SwiftUI
import WidgetKit

// view для маленького виджета
struct ViewForSmall: View {

    let date: String
    let favoriteGroup: String
    let lesson: [Lesson]
    let isWeekend: Bool
    let isHaveLessons: Bool

    func color(lesson: Lesson) -> Color {
        if lesson.lessonTypeAbbrev == "ЛК" {
            return .green
        } else if lesson.lessonTypeAbbrev == "ПЗ" {
            return .yellow
        } else if lesson.lessonTypeAbbrev == "ЛР" {
            return .red
        }
        return .gray
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(date)
                Spacer()
                Text(favoriteGroup)
            }
            .font(.system(size: 14, weight: .medium))

            Spacer()

            if isWeekend {
                VStack {
                    Text("Выходной")
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if !isWeekend && !isHaveLessons {
                VStack(alignment: .center) {
                    Text("Занятия закончились")
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            } else {
                HStack {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(color(lesson: lesson.first!))
                        .frame(width: 10, height: 55)
                    VStack(alignment: .leading) {
                        Text("\(lesson.first!.startLessonTime) - \(lesson.first!.endLessonTime)")
                            .opacity(0.9)
                        Text("\(lesson.first!.lessonTypeAbbrev) по \(lesson.first!.subject)")
                        Text(lesson.first!.auditories.first ?? "Нет")
                            .opacity(0.7)
                    }
                }
                .font(.system(size: 16))

                Spacer()

                if lesson.count > 1 {
                    HStack {
                        Circle()
                            .fill(Color.gray)
                            .frame(width: 12, height: 12)
                        Text("\(lesson[1].subject)")
                            .opacity(0.5)
                        if lesson.count > 2 {
                            Text("и еще \(lesson.count - 2)")
                                .opacity(0.5)
                        }
                    }
                    .font(.system(size: 14, weight: .medium))
                }
            }
        }
    }
}
// view для маленького виджета



// view для среднего виджета
struct ViewForMedium: View {
    
    let date: String
    let favoriteGroup: String
    let lesson: [Lesson]
    let isWeekend: Bool
    let isHaveLessons: Bool
    
    func color(lesson: Lesson) -> Color {
        if lesson.lessonTypeAbbrev == "ЛК" {
            return .green
        } else if lesson.lessonTypeAbbrev == "ПЗ" {
            return .yellow
        } else if lesson.lessonTypeAbbrev == "ЛР" {
            return .red
        }
        return .gray
    }
        
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(date)
                Spacer()
                Text(favoriteGroup)
            }
            .font(.system(size: 14, weight: .medium))
            
            Spacer()
            
            if isWeekend {
                VStack {
                    Text("Выходной")
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if !isWeekend && !isHaveLessons {
                VStack() {
                    Text("Занятия закончились")
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ForEach(lesson.enumerated(), id: \.offset) { index, id in
                    if index < 3 {
                        HStack {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(color(lesson: lesson[index]))
                                .frame(width: 8, height: 20)
                            VStack(alignment: .leading) {
                                Text("C \(lesson[index].startLessonTime) по \(lesson[index].endLessonTime) \(lesson[index].lessonTypeAbbrev) по \(lesson[index].subject) в \(lesson[index].auditories.first ?? "")")
                            }
                        }
                        .font(.system(size: 14))
                    }
                }
                
                Spacer()
                
                if lesson.count > 3 {
                    HStack {
                        Circle()
                            .fill(Color.gray)
                            .frame(width: 8, height: 8)
                        HStack {
                            Text("C \(lesson[2].startLessonTime) \(lesson[2].lessonTypeAbbrev) по \(lesson[2].subject) ")
                            if lesson.count > 4 {
                                Text("и еще \(lesson.count - 4)")
                            }
                        }
                        .font(.system(size: 14))
                        .opacity(0.5)
                    }
                }
            }
        }
    }
}
// view для среднего виджета



// view для большого виджета
struct ViewForLarge: View {
    
    let date: String
    let favoriteGroup: String
    let weenNumber: Int
    let subGroup: Int
    let lesson: [Lesson]
    let isWeekend: Bool
    let isHaveLessons: Bool
    
    func color(lesson: Lesson) -> Color {
        if lesson.lessonTypeAbbrev == "ЛК" {
            return .green
        } else if lesson.lessonTypeAbbrev == "ПЗ" {
            return .yellow
        } else if lesson.lessonTypeAbbrev == "ЛР" {
            return .red
        }
        return .gray
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(date)
                Spacer()
                Text(favoriteGroup)
            }
            .font(.system(size: 16, weight: .medium))
            
            Spacer()
            
            if isWeekend {
                VStack {
                    Text("Выходной")
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if !isWeekend && !isHaveLessons {
                VStack() {
                    Text("Занятия закончились")
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            else {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(lesson.enumerated(), id: \.offset) { index, id in
                        if index < 6 {
                            HStack(spacing: 10) {
                                VStack(alignment: .trailing) {
                                    Text("С \(lesson[index].startLessonTime)")
                                    Text("По \(lesson[index].endLessonTime)")
                                }
        
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(color(lesson: lesson[index]))
                                    .frame(width: 7, height: 30)
        
                                VStack(alignment: .leading) {
                                    Text("\(lesson[index].lessonTypeAbbrev) по \(lesson[index].subject)")
                                    Text("\(lesson[index].auditories.first ?? "")")
                                }
        
                                Spacer()
        
                                Image(systemName: "person")
                            }
                        }
                    }
                }
                .font(.system(size: 14))
                .padding()
                .background(Color.gray.opacity(0.25))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            Spacer()
            
            HStack {
                Text("Неделя: \(weenNumber)")
                Spacer()
                if subGroup == 0 {
                    Text("Все подгруппы")
                } else {
                    Text("Подргуппа: \(subGroup)")
                }
            }
            .padding(EdgeInsets(top: 4, leading: 4, bottom: 0, trailing: 4))
            .font(.system(size: 14, weight: .semibold))
        }
    }
}
// view для большого виджета



#Preview(as: .systemSmall) {
    ScheduleBSUIRWidget()
} timeline: {
    LessonsInWidget(date: .now, lessons: [], favoriteGroup: "261402", subGroup: 1, weekNum: 1)
}

#Preview(as: .systemMedium) {
    ScheduleBSUIRWidget()
} timeline: {
    LessonsInWidget(date: .now, lessons: [], favoriteGroup: "261402", subGroup: 1, weekNum: 1)
}

#Preview(as: .systemLarge) {
    ScheduleBSUIRWidget()
} timeline: {
    LessonsInWidget(date: .now, lessons: [], favoriteGroup: "261402", subGroup: 1, weekNum: 1)
}
