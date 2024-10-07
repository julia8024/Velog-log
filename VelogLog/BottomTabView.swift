//
//  BottomTabView.swift
//  VelogLog
//
//  Created by 장세희 on 10/8/24.
//

import SwiftUI

struct BottomTabView: View {
    private enum Tabs {
        case Home, Settings
    }
    
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()

        UITabBar.appearance().backgroundColor = UIColor(Color("DefaultColor"))
        UITabBar.appearance().standardAppearance = appearance
    }

    @State private var selectedTab: Tabs = .Home
    
    var body: some View {
        NavigationView {
            TabView(selection: $selectedTab) {
                MainView()
                    .tag(Tabs.Home)
                    .tabItem({
                        Image(systemName: "eyeglasses")
                            .environment(\.symbolVariants, .none)
                        Text("Explore")
                    })
                HelpView()
                    .tag(Tabs.Settings)
                    .tabItem({
                        Image(systemName: "gearshape")
                            .environment(\.symbolVariants, .none)
                        Text("Settings")
                    })
            }
            .accentColor(Color("DefaultTextColor"))
        }
    }
}
