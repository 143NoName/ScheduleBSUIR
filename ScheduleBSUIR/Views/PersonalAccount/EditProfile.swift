//
//  EditProfile.swift
//  ScheduleBSUIR
//
//  Created by user on 12.11.25.
//

import SwiftUI

// нигде не используется
struct EditProfile: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @AppStorage("studentName") var studentName: String = ""
    @AppStorage("studentSurname") var studentSurname: String = ""
    @AppStorage("studentPatronymic") var studentPatronymic: String = ""
    @AppStorage("groupNumber") var groupNumber: String = ""
    @AppStorage("studentSubGroup") var studentSubGroup: String = ""
    
    private var fronStringToBinding: Binding<String> {
        switch parametr {
        case .name:
            return $studentName
        case .surname:
            return $studentSurname
        case .patronymic:
            return $studentPatronymic
        case .groupName:
            return $groupNumber
        case .subGroup:
            return $studentSubGroup
        }
    }
    
    let parametr: InEditProfile
    
    var body: some View {
        ZStack {
            if colorScheme == .light {
                Color.gray
                    .opacity(0.15)
                    .ignoresSafeArea(edges: .all)
            }
            
            List{
                Section(parametr.inSection) {
                    TextField(parametr.pageName != "" ? parametr.pageName : parametr.forAppStorage, text: fronStringToBinding)
                }
            }
            .scrollContentBackground(.hidden)
            .navigationTitle(parametr.pageName)
            .navigationBarTitleDisplayMode(.inline)

    }
    }
}

#Preview {
    return EditProfile(parametr: .name)
}
