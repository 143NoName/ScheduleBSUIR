//
//  ScheduleBSUIRApp.swift
//  ScheduleBSUIR
//
//  Created by user on 26.10.25.
//

import SwiftUI

@main
struct ScheduleBSUIRApp: App {
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some Scene {
        WindowGroup {
            TabBarView()
                .defaultAppStorage(UserDefaults(suiteName: "groupe.foAppAndWidget.ScheduleBSUIR")!)
        }
    }
}
