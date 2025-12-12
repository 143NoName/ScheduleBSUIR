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
        
//        startBackgroundDownload() // выполнение функции фоновой загрузки данных
//        
//        let value = loadData() // записать полученных данных в UserDefaults
//        
//        let nextDay = calendar.date(byAdding: .minute, value: 1, to: Date())! // определение завтрашнего дня (след минуты)
//        
//        let entrys = [ // создание одного entry
//            LessonsInWidget(date: date, lessons: [], favoriteGroup: value),
//            LessonsInWidget(date: nextDay, lessons: [], favoriteGroup: value)
//        ]
//        
//        let timeline = Timeline(entries: entrys, policy: .after(nextDay)) // записать нового TimeLine
//        
//        completion(timeline)
        
        do {
            guard let data = try funcsService.getDataFromUserDefaults() else { return }
            lessons = data
            print(data)
        } catch {
            print("Ошибка при получении расписания в виджет")
        }
        
        guard let nextDay = calendar.date(byAdding: .day, value: 1, to: date) else { return }
        let startOfNextDay = calendar.startOfDay(for: nextDay)
        
        let timeLine = [
            LessonsInWidget(date: date, lessons: funcsService.findTodayLessons(lessons: lessons), favoriteGroup: funcsService.favoriteGroup == "" ? "Неизвество" : funcsService.favoriteGroup, subGroup: funcsService.subGroup, weekNum: 1),
            LessonsInWidget(date: startOfNextDay, lessons: funcsService.findTodayLessons(lessons: lessons), favoriteGroup: funcsService.favoriteGroup == "" ? "Неизвество" : funcsService.favoriteGroup, subGroup: funcsService.subGroup, weekNum: 1)
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
//        case .systemSmall:
//            ViewForSmall(date: date, favoriteGroup: entry.favoriteGroup, lesson: findCurrentLesson, isWeekend: isWeekend, isHaveLessons: isHaveLessons)
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
    
    var findCurrentLesson: [Lesson] { // определение текущего урока по времени
        
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
    
    var isHaveLessons: Bool { // проверка наличия данных
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

//struct ViewForSmall: View {
//    
//    let date: String
//    let favoriteGroup: String
//    let lesson: [Lesson]
//    let isWeekend: Bool
//    let isHaveLessons: Bool
//    
//    func color(lesson: Lesson) -> Color {
//        if lesson.lessonTypeAbbrev == "ЛК" {
//            return .green
//        } else if lesson.lessonTypeAbbrev == "ПЗ" {
//            return .yellow
//        } else if lesson.lessonTypeAbbrev == "ЛР" {
//            return .red
//        }
//        return .gray
//    }
//    
//    var body: some View {
//        VStack(alignment: .leading) {
//            HStack {
//                Text(date)
//                Spacer()
//                Text(favoriteGroup)
//            }
//            .font(.system(size: 16, weight: .medium))
//            
//            Spacer()
//            
//            
//            if isWeekend {
//                VStack {
//                    Text("Выходной")
//                }
//                .frame(maxWidth: .infinity, maxHeight: .infinity)
//            } else if !isWeekend && !isHaveLessons {
//                VStack() {
//                    Text("Занятия закончились")
//                }
//                .frame(maxWidth: .infinity, maxHeight: .infinity)
//            } else {
//                HStack {
//                    RoundedRectangle(cornerRadius: 6)
//                        .fill(color(lesson: lesson.first))
//                        .frame(width: 10, height: 55)
//                    VStack(alignment: .leading) {
//                        Text("\(lesson.first!.startLessonTime) - \(lesson.first!.endLessonTime)")
//                            .opacity(0.9)
//                        Text("\(lesson.first!.lessonTypeAbbrev) по \(lesson.first!.subject)")
//                        Text(lesson.first!.auditories.first ?? "Нет")
//                            .opacity(0.7)
//                    }
//                }
//                .font(.system(size: 16))
//                
//                Spacer()
//                
//                if lesson.count > 1 {
//                    HStack {
//                        Circle()
//                            .fill(Color.gray)
//                            .frame(width: 12, height: 12)
//                        Text("\(lesson[1].subject)")
//                            .opacity(0.5)
//                        if lesson.count > 2 {
//                            Text("и еще \(lesson.count - 2)")
//                                .opacity(0.5)
//                        }
//                    }
//                    .font(.system(size: 14, weight: .medium))
//                }
//            }
//        }
//    }
//}

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
        .supportedFamilies([.systemMedium, .systemLarge])
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

//#Preview(as: .systemSmall) {
//    ScheduleBSUIRWidget()
//} timeline: {
//    LessonsInWidget(date: .now, lessons: [], favoriteGroup: "261402")
//}

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
