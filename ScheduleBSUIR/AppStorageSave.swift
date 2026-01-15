//
//  AppStorageSave.swift
//  ScheduleBSUIR
//
//  Created by andrew on 12.01.26.
//

import SwiftUI
import Combine

class AppStorageSave: ObservableObject {
    
    enum KeysAppStorage {
        static let groupSchedule = "groupSchedule"
        static let favoriteGroup = "favoriteGroup"
        static let employeeName = "employeeName"
        static let weekNumber = "weekNumber"
        static let weekNumberInEnum = "weekNumberInEnum"
        static let subGroup = "subGroup"
        static let whoUser = "whoUser"
    }
    
    // виджет
    @AppStorage(KeysAppStorage.groupSchedule, store: UserDefaults(suiteName: "group.foAppAndWidget.ScheduleBSUIR")) var groupSchedule: Data? {                       // данные для отображения в виджете
        didSet { objectWillChange.send() }
    }
    @AppStorage(KeysAppStorage.favoriteGroup, store: UserDefaults(suiteName: "group.foAppAndWidget.ScheduleBSUIR")) var favoriteGroup: String = "Не выбрано" {       // строка имя группы в виджете (проверка выбранного пользователя. Отображается если выбрана группа)
        didSet { objectWillChange.send() }
    }
    @AppStorage(KeysAppStorage.employeeName, store: UserDefaults(suiteName: "group.foAppAndWidget.ScheduleBSUIR")) var employeeName: String = "Не выбрано" {         // строка имя преподавателя в виджете (проверка выбранного пользователя. Отображается, если выбран преподаватель)
        didSet { objectWillChange.send() }
    }
    @AppStorage(KeysAppStorage.weekNumber, store: UserDefaults(suiteName: "group.foAppAndWidget.ScheduleBSUIR")) var weekNumber: Int = 0 {                           // число номера текущей недели (в маленьком и срднем только для фильтрации, в большой + будет отображаться)
        didSet { objectWillChange.send() }
    }
    
    @AppStorage(KeysAppStorage.weekNumber, store: UserDefaults(suiteName: "group.foAppAndWidget.ScheduleBSUIR")) var weekNumberInEnum: Int = 0 {                           // число номера текущей недели (в маленьком и срднем только для фильтрации, в большой + будет отображаться)
        didSet { objectWillChange.send() }
    }
    
    // только для виджета
    @AppStorage(KeysAppStorage.subGroup, store: UserDefaults(suiteName: "group.foAppAndWidget.ScheduleBSUIR")) var subGroup: SubGroupInPicker = .all {               // число номер выбранной подгруппы (в маленьком и срднем только для фильтрации, в большой + будет отображаться)
        didSet { objectWillChange.send() }
    }
    @AppStorage(KeysAppStorage.whoUser, store: UserDefaults(suiteName: "group.foAppAndWidget.ScheduleBSUIR")) var whoUser: WhoUser = .none {                         // значение "кто пользователь"
        didSet { objectWillChange.send() }
    }
    // виджет
    
    
    #warning("Добавить все AppStorage")

}
