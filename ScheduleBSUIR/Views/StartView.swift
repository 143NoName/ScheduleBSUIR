//
//  StartView.swift
//  ScheduleBSUIR
//
//  Created by user on 5.11.25.
//

import SwiftUI

struct StartView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @EnvironmentObject var viewModel: ViewModel
    
    @AppStorage("favoriteGroup") var favoriteGroup: String = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(colorScheme == .dark ? .black : .gray.opacity(0.1))
                    .ignoresSafeArea(edges: .all)
                
                VStack {
                    Image(colorScheme == .dark ? "LogoWhite" : "LogoBlack")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(.bottom)
                    Text("ScheduleBSUIR")
                        .font(.system(size: 26, weight: .semibold))
                }
                .padding(50)
            }
        }
    }
}


#Preview {
    StartView()
        .environmentObject(ViewModel())
}
