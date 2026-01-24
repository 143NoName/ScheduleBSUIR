//
//  ScheduleBSUIRWidget.swift
//  ScheduleBSUIRWidget
//
//  Created by user on 30.10.25.
//

import WidgetKit
import SwiftUI

import os.log

struct Provider: TimelineProvider {
        
    let filterInWidget: FilterInWidgetProtocol
    let getScheduleInWidget: GetScheduleForWidgetProtocol
    
    init(
         filterInWidget: FilterInWidgetProtocol = FilterInWidget(),
         getScheduleInWidget: GetScheduleForWidgetProtocol = GetScheduleForWidget()
    ){
        self.filterInWidget = filterInWidget
        self.getScheduleInWidget = getScheduleInWidget
    }
    
    @AppStorage("whoUser", store: UserDefaults(suiteName: "group.foAppAndWidget.ScheduleBSUIR")) var whoUser: WhoUser = .none
    @AppStorage("favoriteGroup", store: UserDefaults(suiteName: "group.foAppAndWidget.ScheduleBSUIR")) var favoriteGroup: String = "Не выбрано"
    @AppStorage("subGroup", store: UserDefaults(suiteName: "group.foAppAndWidget.ScheduleBSUIR")) var subGroup: SubGroupInPicker = .all
    @AppStorage("weekNumber", store: UserDefaults(suiteName: "group.foAppAndWidget.ScheduleBSUIR")) var weekNumber: Int = 0
    
    
    func placeholder(in context: Context) -> LessonsInWidget { // показывает заглушку при первом добавлении виджета
        LessonsInWidget(date: Date(), lessons: [], favoriteGroup: "261402", subGroup: .all, weekNum: 1) // показывается в canvass
    }

    func getSnapshot(in context: Context, completion: @escaping (LessonsInWidget) -> ()) { // показывает пример виджета при выборе
        let entry = LessonsInWidget(date: Date(), lessons: [], favoriteGroup: "261402", subGroup: .all, weekNum: 1)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) { // основная функция, создает расписание обновлений
        
//        let logger = Logger(subsystem: "com.bsuir.schedule.widget", category: "ScheduleWidget") // для логирования
        
        let date = Date()
        let calendar = Calendar.current
        var lessons: [FormatedSchedules] = [] // массив для расписания в виджете
        
        do {
            guard let data = try getScheduleInWidget.getDataFromAppStorage() else { return } // получение данных из UserDefaults
            lessons = data
        } catch {
            print("Ошибка при получении расписания в виджет")
        }
        
        // определение завтрашнего дня
        guard let nextDay = calendar.date(byAdding: .day, value: 1, to: date) else { return }
        let startOfNextDay = calendar.startOfDay(for: nextDay)
        
        let timeLine = [
            LessonsInWidget(date: date, lessons: filterInWidget.findTodayLessons(lessons: lessons), favoriteGroup: favoriteGroup, subGroup: subGroup, weekNum: weekNumber),
            LessonsInWidget(date: startOfNextDay, lessons: filterInWidget.findTodayLessons(lessons: lessons), favoriteGroup: favoriteGroup, subGroup: subGroup, weekNum: weekNumber)
        ]
        
        completion(Timeline(entries: timeLine, policy: .after(Date())))
    }
}

struct LessonsInWidget: TimelineEntry {
    let date: Date
    let lessons: [Lesson]
    let favoriteGroup: String
    let subGroup: SubGroupInPicker
    let weekNum: Int
}

struct ScheduleBSUIRWidgetEntryView: View {
    var entry: Provider.Entry
        
    let calendar = Calendar.current
    
    @Environment(\.widgetFamily) var widgetFamily
//    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        
        switch widgetFamily {
        case .systemSmall:
            ViewForSmall(date: date, favoriteGroup: entry.favoriteGroup, lesson: findCurrentLesson, isWeekend: isWeekend, isHaveLessons: isHaveLessons)
        case .systemMedium:
            ViewForMedium(date: date, favoriteGroup: entry.favoriteGroup, lesson: findCurrentLesson, isWeekend: isWeekend, isHaveLessons: isHaveLessons)
        case .systemLarge:
            ViewForLarge(date: date, favoriteGroup: entry.favoriteGroup, weenNumber: entry.weekNum, subGroup: entry.subGroup, lesson: findCurrentLesson, isWeekend: isWeekend, isHaveLessons: isHaveLessons)
        default:
            EmptyView()
        }
    }
}

extension ScheduleBSUIRWidgetEntryView {
    
    // получение текущего дня недели и число, например Чт и 5
    func getShortWeekdaySymbol() -> String {
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
        default: index = 0
        }
        
        return formatter.shortStandaloneWeekdaySymbols[index]
    }
    
    // определение текущего и будущих уроков
    var findCurrentLesson: [Lesson] {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.locale = Locale(identifier: "ru_RU")
        
        let currentDate = Date()
        
        let currentDateInString = formatter.string(from: currentDate)
        
        let currentLesson = entry.lessons.filter { lesson in
            lesson.endLessonTime > currentDateInString || lesson.endLessonTime == currentDateInString
        }
        
        return currentLesson
    }
    
    // проверка есть ли сегодня уроки
    var isWeekend: Bool {
        if entry.lessons.isEmpty {
            return true
        } else {
            return false
        }
    }
    
    // проверка есть ли уроки
    var isHaveLessons: Bool {
        if findCurrentLesson.isEmpty {
            return false
        } else {
            return true
        }
    }
    
    // создание самой даты, например (Чт, 5)
    var date: String {
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
}

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

struct ScheduleBSUIRWidget: Widget {
    
    let kind: String = "ScheduleBSUIRWidget"
    
    let defaults = UserDefaults(suiteName: "widget.schedule.bsuir")

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
                    .background(Color.white)
            }
        }
        .configurationDisplayName("Расписание БГУИР")
        .description("Краткий просмотр расписания")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
