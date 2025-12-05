//
//  ScheduleBSUIRApp.swift
//  ScheduleBSUIR
//
//  Created by user on 26.10.25.
//

import SwiftUI
import BackgroundTasks

@main
struct ScheduleBSUIRApp: App {
    
//    @State var num: String = "Какай то текст"
        
//    func scheduleAppRefrash() {
//        let today = Calendar.current.startOfDay(for: .now)
//        guard let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today) else {
//            print("Проблема с получнием завтрашнего дня")
//            return
//        }
//        let midnight = DateComponents(hour: 11)
//        let min = DateComponents(minute: 1)
//        guard let dateForUdpdate = Calendar.current.date(byAdding: min, to: Date()) else {
//            print("Проблема с получением даты обновления")
//            return
//        }
//        
//        let request = BGAppRefreshTaskRequest(identifier: "updateScheduleForWidget")
//        request.earliestBeginDate = dateForUdpdate
//        
//        do {
//            try BGTaskScheduler.shared.submit(request)
//            print("Следующее обновление запланировано")
//        } catch {
//            print("Ошибка планирования: \(error.localizedDescription)")
//        }
//    }
        
    var body: some Scene {
        WindowGroup {
            TabBarView()
                .defaultAppStorage(UserDefaults(suiteName: "groupe.foAppAndWidget.ScheduleBSUIR")!)
        }
//        .backgroundTask(.appRefresh("updateScheduleForWidget")) {
//            await MainActor.run {
//                scheduleAppRefrash()
//            }
//        } // нихуя не пашет
    }
}
