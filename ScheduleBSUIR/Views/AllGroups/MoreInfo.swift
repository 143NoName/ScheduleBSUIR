//
//  MoreInfo.swift
//  ScheduleBSUIR
//
//  Created by user on 31.10.25.
//

import SwiftUI

struct SheetMore: View {
    
    let lesson: String
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        Button {
            dismiss()
        } label: {
            Text("Назад")
        }
        Text(lesson)
    }
}
