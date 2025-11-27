//
//  ScheduleBSUIRWidgetBundle.swift
//  ScheduleBSUIRWidget
//
//  Created by user on 30.10.25.
//

import WidgetKit
import SwiftUI

@main
struct ScheduleBSUIRWidgetBundle: WidgetBundle {
    var body: some Widget {
        ScheduleBSUIRWidget()
        ScheduleBSUIRWidgetControl()
        ScheduleBSUIRWidgetLiveActivity()
    }
}
