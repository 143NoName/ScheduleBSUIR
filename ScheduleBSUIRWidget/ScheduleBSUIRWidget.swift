//
//  ScheduleBSUIRWidget.swift
//  ScheduleBSUIRWidget
//
//  Created by user on 30.10.25.
//

import WidgetKit
//import AppIntents
import SwiftUI

struct Provider: TimelineProvider {
    
    func placeholder(in context: Context) -> LessonsInWidget { // показывает заглушку при первом добавлении виджета
        LessonsInWidget(date: Date(), lessons: [], favoriteGroup: "261402")
    }

    func getSnapshot(in context: Context, completion: @escaping (LessonsInWidget) -> ()) { // показывает пример виджета при выборе
        let entry = LessonsInWidget(date: Date(), lessons: [], favoriteGroup: "261402")
        completion(entry)
    }
    
    
    let appStorageService = AppStorageService()
    
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) { // основная функция, создает расписание обновлений
        
        let date = Date()
        let calendar = Calendar.current
        let lessons = getDataFromUserDefaults()
        
        guard let nextDay = calendar.date(byAdding: .day, value: 1, to: date) else { return }
        let startOfNextDay = calendar.startOfDay(for: nextDay)
        
        let timeLine = [
            LessonsInWidget(date: date, lessons: findTodayLessons(lessons: lessons), favoriteGroup: getFavoriteGroupFromUserDefaults()),
            LessonsInWidget(date: startOfNextDay, lessons: findTodayLessons(lessons: lessons), favoriteGroup: getFavoriteGroupFromUserDefaults())
        ]
        
        completion(Timeline(entries: timeLine, policy: .after(Date())))
    }
    
    // получение номера группы
    private func getFavoriteGroupFromUserDefaults() -> String {
        let userDefaults = UserDefaults(suiteName: "group.foAppAndWidget.ScheduleBSUIR")!
        guard let favoriteGroup = userDefaults.string(forKey: "favoriteGroup") else {
            print("Ошибка при чтении данных из userDefaults")
            return ""
        }
        return favoriteGroup
    }

    // получение всего расписания
    private func getDataFromUserDefaults() -> /*[Lesson]*/ Schedules? {
//        let userDefaults = UserDefaults(suiteName: "group.foAppAndWidget.ScheduleBSUIR")!
//        guard let rawData = userDefaults.data(forKey: "widget") else {
//            print("Ошибка при чтении данных из userDefaults")
//            return []
//        }
//        do {
//            let data = try JSONDecoder().decode([Lesson].self, from: rawData)
//            return(data)
//        } catch {
//            print("Проблема с декодированием")
//        }
//        return []
        
        do {
            let data = try appStorageService.getDataFromAppStorage()
            print("Данные получаемые от AppStorage: \(String(describing: data))")
            return data
        } catch {
            print(error)
        }
        return nil
    }
    
    func findTodayLessons(lessons: Schedules?) -> [Lesson] {
        guard let lessons else { return [] }
        
        let calendar = Calendar.current
        let date = Date()
        let today = calendar.component(.weekday, from: date)
        return lessons.atDay(today) ?? []
    }
}

struct LessonsInWidget: TimelineEntry {
    let date: Date
    let lessons: [Lesson]
    let favoriteGroup: String
}


struct ScheduleBSUIRWidgetEntryView: View {
    var entry: Provider.Entry
        
    let calendar = Calendar.current
    
    @Environment(\.widgetFamily) var widgetFamily

    var body: some View {
//        switch widgetFamily {
//        case .systemSmall:
//            ViewForSmall(lesson: findCurrentLesson, favoriteGroup: entry.favoriteGroup ,isHaveData: isHaveData, date: date, color: color, startTime: startTime, endTime: endTime, typeOfLesson: typeOfLesson, lessomName: lessonName, auditories: auditories, nextLesson: nextLesson, numberOfLessons: numberOfLessons)
//        case .systemMedium:
//            ViewForMedium(isHaveData: isHaveData, date: date, lesson: findCurrentLesson, favoriteGroup: entry.favoriteGroup)
//        case .systemLarge:
//            ViewForLarge(isHaveData: isHaveData, date: date, lesson: findCurrentLesson, favoriteGroup: entry.favoriteGroup)
//        default:
//            EmptyView()
//        }
        
        switch widgetFamily {
//        case .systemSmall:
//            ViewForSmall(date: date, favoriteGroup: entry.favoriteGroup, lesson: entry.lessons)
        case .systemMedium:
            ViewForMedium(date: date, favoriteGroup: entry.favoriteGroup, lesson: entry.lessons)
        case .systemLarge:
            ViewForLarge(date: date, favoriteGroup: entry.favoriteGroup, lesson: entry.lessons)
        default:
            EmptyView()
        }
    }
}

extension ScheduleBSUIRWidgetEntryView {
    
    func getShortWeekdaySymbol() -> String { // получение текущего дня недели и число, например Чт и 5
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.calendar = Calendar.current
        let day = Calendar.current.component(.weekday, from: Date())
                
        let index: Int
        switch day {
        case 1: index = 0
        case 2: index = 1
        case 3: index = 2
        case 4: index = 3
        case 5: index = 4
        case 6: index = 5
        case 7: index = 6
        default: index = 1
        }
        
        return formatter.shortStandaloneWeekdaySymbols[index]
    }
    
//    var findCurrentLesson: [Lesson] { // определение текущего урока по времени
//        
//        let formatter = DateFormatter()
//        formatter.dateFormat = "HH:mm"
//        formatter.locale = Locale(identifier: "ru_RU")
//        
//        let currentDate = Date()
//        
//        let currentDateInString = formatter.string(from: currentDate)
//        
//        let currentLesson = entry.lessons.filter { lesson in
//            lesson.endLessonTime > currentDateInString || lesson.endLessonTime == currentDateInString
//        }
//        
//        return currentLesson
//    }
    
//    var isHaveData: Bool { // проверка наличия данных
//        if .isEmpty {
//            return false
//        } else {
//            return true
//        }
//    }
    
    var date: String { // создание самой даты, например (Чт, 5)
        "\(getShortWeekdaySymbol()), \(calendar.component(.day, from: Date()))"
    } // почему то выполняется 6 раз

    
    
    
    
    
    
//    var color: Color {
//        if findCurrentLesson.first?.lessonTypeAbbrev == "ЛК" {
//            return .green
//        } else if findCurrentLesson.first?.lessonTypeAbbrev == "ПЗ" {
//            return .yellow
//        } else if findCurrentLesson.first?.lessonTypeAbbrev == "ЛР" {
//            return .red
//        }
//        return .gray
//    }
//    
//    var startTime: String {
//        findCurrentLesson.first?.startLessonTime.description ?? ""
//    }
//    
//    var endTime: String {
//        findCurrentLesson.first?.endLessonTime.description ?? ""
//    }
//    
//    var typeOfLesson: String {
//        findCurrentLesson.first?.lessonTypeAbbrev.description ?? ""
//    }
//    
//    var lessonName: String {
//        findCurrentLesson.first?.subject.description ?? ""
//    }
//    
//    var auditories: [String] {
//        findCurrentLesson.first?.auditories ?? [""]
//    }
//    
//    var nextLesson: String {
//        if findCurrentLesson.count > 1 {
//            return findCurrentLesson[1].subject
//        } else {
//            return ""
//        }
//        
//    }
//    
//    var numberOfLessons: Int {
//        return findCurrentLesson.dropFirst(2).count
//    }
}

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

struct ViewForSmall: View {
    
    let lesson: [Lesson]
    
    let favoriteGroup: String
    let isHaveData: Bool
    let date: String
    let color: Color
    let startTime: String
    let endTime: String
    let typeOfLesson: String
    let lessomName: String
    let auditories: [String]
    let nextLesson: String
    let numberOfLessons: Int
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(date)
                Spacer()
                Text(favoriteGroup)
            }
            .font(.system(size: 16, weight: .medium))
            
            Spacer()
            
            if !isHaveData {
                VStack {
                    Text("Нет занятий")
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            else  {
                HStack {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(color)
                        .frame(width: 10, height: 55)
                    VStack(alignment: .leading) {
                        Text("\(startTime) - \(endTime)")
                            .opacity(0.9)
                        Text("\(typeOfLesson) по \(lessomName)")
                        Text(auditories.first ?? "Нет")
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
                        Text("\(nextLesson)")
                            .opacity(0.5)
                        Text(numberOfLessons > 0 ? "и еще \(numberOfLessons)" : "")
                            .opacity(0.5)
                    }
                    .font(.system(size: 14, weight: .medium))
                }
            }
        }
    }
}

struct ViewForMedium: View {
    
//    let isHaveData: Bool
//    let date: String
//    let lesson: [Lesson]
//    let favoriteGroup: String
    let date: String
    let favoriteGroup: String
    let lesson: [Lesson]
    
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
            
            if !lesson.isEmpty {
                Text("Нет занятий")
                    .frame(maxWidth: .infinity)
                Spacer()
            } else {
                ForEach(lesson.enumerated(), id: \.offset) { index, id in
                    if index < 3 {
                        HStack {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(color(lesson: lesson[index]))
                                .frame(width: 8, height: 20)
                            VStack(alignment: .leading) {
                                Text("C \(lesson[index].startLessonTime) по \(lesson[index].endLessonTime) \(lesson[index].lessonTypeAbbrev) по \(lesson[index].subject) в \(lesson[index].auditories.first!)")
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
                        Text("C 13:00 ПЗ по ОС и еще 2")
                            .font(.system(size: 14))
                            .opacity(0.5)
                    }
                }
            }
        }
        .onAppear {
            print(lesson)
        }
    }
}

struct ViewForLarge: View {
    
//    let isHaveData: Bool
//    let date: String
//    let lesson: [Lesson]
//    let favoriteGroup: String
    let date: String
    let favoriteGroup: String
    let lesson: [Lesson]
    
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
            
//            if !isHaveData {
//                Text("Нет занятий")
//                    .frame(maxWidth: .infinity)
//                    .font(.system(size: 20))
//            } else {
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
                                    Text("\(lesson[index].auditories.first!)")
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
//            }
            
            Spacer()
            
            HStack {
                Text("Неделя: 1")
                Spacer()
                Text("Подргуппа: 2")
            }
            .padding(EdgeInsets(top: 4, leading: 4, bottom: 0, trailing: 4))
            .font(.system(size: 14, weight: .semibold))
        }

    }
}


struct ScheduleBSUIRWidget: Widget {
    let kind: String = "ScheduleBSUIRWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: Provider()
        ) { entry in
            if #available(iOS 17.0, *) {
                ScheduleBSUIRWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                ScheduleBSUIRWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Расписание БГУИР")
        .description("Краткий просмотр расписания")
    }
}

#Preview(as: .systemSmall) {
    ScheduleBSUIRWidget()
} timeline: {
    LessonsInWidget(date: .now, lessons: [], favoriteGroup: "261402")
}

#Preview(as: .systemMedium) {
    ScheduleBSUIRWidget()
} timeline: {
    LessonsInWidget(date: .now, lessons: [], favoriteGroup: "261402")
}

#Preview(as: .systemLarge) {
    ScheduleBSUIRWidget()
} timeline: {
    LessonsInWidget(date: .now, lessons: [], favoriteGroup: "261402")
}
