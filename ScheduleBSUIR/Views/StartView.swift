//
//  StartView.swift
//  ScheduleBSUIR
//
//  Created by user on 5.11.25.
//

import SwiftUI

struct StartView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
//    @EnvironmentObject var viewModelForNetwork: ViewModelForNetwork
    
    @AppStorage("favoriteGroup") var favoriteGroup: String = ""
    
    @Binding var opacity: Double
    @Binding var scale: CGFloat
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(colorScheme == .dark ? .black : .gray.opacity(0.1))
                    .ignoresSafeArea(edges: .all)
                
                VStack {
                    Image(colorScheme == .dark ? "LogoWhite" : "LogoBlack")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                .padding(50)
            }
            
        }
        .opacity(opacity)
        .scaleEffect(scale)
    }
}
