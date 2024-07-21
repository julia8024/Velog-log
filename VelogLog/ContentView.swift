//
//  ContentView.swift
//  VelogLog
//
//  Created by 장세희 on 7/21/24.
//

import SwiftUI

struct ContentView: View {
    @State var isLaunching: Bool = true
        
    var body: some View {
        if isLaunching {
            SplashView()
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        isLaunching = false
                    }
                }
        } else {
            MainView()
        }
    }
}

#Preview {
    ContentView()
}
