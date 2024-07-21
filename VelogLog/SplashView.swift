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
                Image("AppIconForSplash")
                    .resizable()
                    .aspectRatio(1.0, contentMode: .fit)
                    .clipped()
                    .padding(.horizontal, 120)
                    .padding(.bottom, 80)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    SplashView()
}
