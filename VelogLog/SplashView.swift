//
//  SplashView.swift
//  VelogLog
//
//  Created by 장세희 on 7/21/24.
//

import SwiftUI

struct SplashView: View {
    
    var body: some View {
        VStack {
            VStack {
                Image("AppIcon")
                    .resizable()
                    .aspectRatio(1.0, contentMode: .fit)
                    .clipped()
                    .padding(.horizontal, 80)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    SplashView()
}
