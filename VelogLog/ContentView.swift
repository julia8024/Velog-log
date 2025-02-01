//
//  ContentView.swift
//  VelogLog
//
//  Created by 장세희 on 7/21/24.
//

import SwiftUI

struct ContentView: View {
    @State var isLaunching: Bool = true
    @StateObject private var versionChecker = VersionChecker.shared
        
    var body: some View {
        if isLaunching {
            SplashView()
                .onAppear {
                    versionChecker.checkForVersionUpdate()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        isLaunching = false
                    }
                }
            
                .alert(isPresented: $versionChecker.showAlert) {
                    Alert(
                        title: Text("앱 업데이트 안내"),
                        message: Text("새로운 버전으로 업데이트되었습니다. 새로운 기능을 확인해보세요!"),
                        primaryButton: .default(Text("업데이트"), action: {
                            if let url = versionChecker.getAppStoreURL() {
                                UIApplication.shared.open(url)
                            }
                        }),
                        secondaryButton: .cancel(Text("나중에"))
                    )
                }
        } else {
            BottomTabView()
        }
    }
}

#Preview {
    ContentView()
}
