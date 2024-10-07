//
//  DetailView.swift
//  VelogLog
//
//  Created by 장세희 on 9/23/24.
//

import SwiftUI

struct DetailView: View {
    
    @State private var showShareSheet = false
    var url: String
    
    var body: some View {
        CustomWKWebView(url: url)
            .navigationBarItems(trailing: HStack {
                Button(action: {
                    showShareSheet = true
                }) {
                    Image(systemName: "square.and.arrow.up")
                }
                .sheet(isPresented: $showShareSheet) {
                    // presentationDetents로 높이 설정
                    ShareSheet(activityItems: [URL(string: url)!])
                        .presentationDetents([.fraction(0.6), .medium, .large]) // 높이 설정
                        .presentationDragIndicator(.visible) // 드래그 인디케이터 추가
                }
            })
            .toolbar(.hidden, for: .tabBar)
    }
}
