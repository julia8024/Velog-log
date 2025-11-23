//
//  VelogLogApp.swift
//  VelogLog
//
//  Created by 장세희 on 2024/06/17.
//

import SwiftUI
import SwiftData

@main
struct VelogLogApp: App {
    @AppStorage("appearanceMode") private var appearanceRaw = AppearanceMode.system.rawValue
    
    private var appearance: AppearanceMode {
        AppearanceMode(rawValue: appearanceRaw) ?? .system
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(appearance.colorScheme) // 전역 적용
        }
    }
}
