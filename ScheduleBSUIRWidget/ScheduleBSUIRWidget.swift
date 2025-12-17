//
//  ScheduleBSUIRWidget.swift
//  ScheduleBSUIRWidget
//
//  Created by user on 30.10.25.
//

import WidgetKit
import AppIntents
import SwiftUI

struct Provider: TimelineProvider {
    
    func placeholder(in context: Context) -> LessonsInWidget { // показывает заглушку при первом добавлении виджета
        LessonsInWidget(date: Date(), lessons: [], favoriteGroup: "261402", subGroup: 1, weekNum: 1)
    }

    func getSnapshot(in context: Context, completion: @escaping (LessonsInWidget) -> ()) { // показывает пример виджета при выборе
        let entry = LessonsInWidget(date: Date(), lessons: [], favoriteGroup: "261402", subGroup: 1, weekNum: 1)
        completion(entry)
    }

    let funcsService: FuncsServiceForWidget
    // для более простой тестуруемости (вместо FuncsServiceForWidget можно добавить другой класс)
    // а еще лучше зависеть не от объекта, а от абстракции (протокола)
    
    init(funcsService: FuncsServiceForWidget = FuncsServiceForWidget()) {
        self.funcsService = funcsService
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) { // основная функция, создает расписание обновлений
        
        let date = Date()
        let calendar = Calendar.current
        var lessons: Schedules? = nil
        
        do {
            guard let data = try funcsService.getDataFromUserDefaults() else { return }
            lessons = data
        } catch {
            print("Ошибка при получении расписания в виджет")
        }
        
        guard let nextDay = calendar.date(byAdding: .day, value: 1, to: date) else { return }
        let startOfNextDay = calendar.startOfDay(for: nextDay)
        
        let timeLine = [
            LessonsInWidget(date: date, lessons: funcsService.findTodayLessons(lessons: lessons), favoriteGroup: funcsService.favoriteGroup == "" ? "Неизвество" : funcsService.favoriteGroup, subGroup: funcsService.subGroup, weekNum: funcsService.weekNumber),
            LessonsInWidget(date: startOfNextDay, lessons: funcsService.findTodayLessons(lessons: lessons), favoriteGroup: funcsService.favoriteGroup == "" ? "Неизвество" : funcsService.favoriteGroup, subGroup: funcsService.subGroup, weekNum: funcsService.weekNumber)
        ]
        
        completion(Timeline(entries: timeLine, policy: .after(Date())))
    }
    
//    private func startBackgroundDownload() {
//        let sessionID = "widget.download.\(UUID().uuidString)" // создаем уникальный ID для этой загрузки
//    
//        let config = URLSessionConfiguration.background(withIdentifier: sessionID) // создаем фоновую сессию
//        config.isDiscretionary = true // Система выберет когда скачивать
//    
//        let session = URLSession(configuration: config) // создание самой сессии
//        
//        guard let url = URL(string: "https://iis.bsuir.by/api/v1/schedule/current-week") else {
//            return
//        }                // URL для данных
//            
//        // Создаем задачу загрузки
//        let task = session.downloadTask(with: url)
//        
//        // Планируем на ближайшее удобное время
//        task.earliestBeginDate = Date().addingTimeInterval(60) // Через 1 минуту
//        
//        // Запускаем
//        task.resume()
//        
//        print("📅 Загрузка запланирована: \(sessionID)")
//    }
//    
//    private func loadData() -> String {
//        // Просто читаем флаг
//        let defaults = UserDefaults(suiteName: "widget.schedule.bsuir")
////          if defaults?.string(forKey: "weekNumber") == "Задача выполненна и данные пришли" {
////               return "Данные получены!"
////            }
//        guard let data = defaults?.string(forKey: "weekNumber") else { return "Нет данных" }
//        return data
//    }
}

struct LessonsInWidget: TimelineEntry {
    let date: Date
    let lessons: [Lesson]
    let favoriteGroup: String
    let subGroup: Int
    let weekNum: Int
}


struct ScheduleBSUIRWidgetEntryView: View {
    var entry: Provider.Entry
        
    let calendar = Calendar.current
    
    @Environment(\.widgetFamily) var widgetFamily

    var body: some View {
        
        switch widgetFamily {
        case .systemSmall:
            ViewForSmall(date: date, favoriteGroup: entry.favoriteGroup, lesson: findCurrentLesson, isWeekend: isWeekend, isHaveLessons: isHaveLessons)
        case .systemMedium:
            ViewForMedium(date: date, favoriteGroup: entry.favoriteGroup, lesson: findCurrentLesson, isWeekend: isWeekend, isHaveLessons: isHaveLessons)
        case .systemLarge:
            ViewForLarge(date: date, favoriteGroup: entry.favoriteGroup, weenNumber: weenNumber, subGroup: subGroup, lesson: findCurrentLesson, isWeekend: isWeekend, isHaveLessons: isHaveLessons)
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
    
    var findCurrentLesson: [Lesson] { // определение текущего и будущих уроков
        
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
    
    var isWeekend: Bool { // проверка есть ли сегодня уроки
        if entry.lessons.isEmpty {
            return true
        } else {
            return false
        }
    }
    
    var isHaveLessons: Bool { // проверка есть ли уроки
        if findCurrentLesson.isEmpty {
            return false
        } else {
            return true
        }
    }
    
    var date: String { // создание самой даты, например (Чт, 5)
        "\(getShortWeekdaySymbol()), \(calendar.component(.day, from: Date()))"
    } // почему то выполняется 6 раз

    
    // только для большого виджета
    var subGroup: Int {
        return entry.subGroup
    }
    
    var weenNumber: Int {
        return entry.weekNum
    }
    // только для большого виджета
    
    
    
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
        // грубо говоря тут проверяем, что данные есть и если есть, то записываем в UserDefaults
//        .onBackgroundURLSessionEvents { identifier, completion in
//            let session = URLSession(configuration: .background(withIdentifier: identifier))
//            
//            session.getAllTasks { completedTasks in // проверка пришли ли данные, и если да, то показать их
//                for task in completedTasks {
//                    defaults?.set("Вот данные2", forKey: "weekNumber")
////                    print(task.response.debugDescription)
//                }
//                
//                WidgetCenter.shared.reloadAllTimelines() // обновление виджета
//                                
//                completion()
//            }
//        }
    }
}
