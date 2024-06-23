//
//  ContentView.swift
//  VelogLog
//
//  Created by 장세희 on 2024/06/17.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
            Button("버튼", action: {
                prints()
            })
        }
        .padding()
    }
    
    func prints() { print("helel") }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
