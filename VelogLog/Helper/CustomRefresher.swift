//
//  CustomRefresher.swift
//  VelogLog
//
//  Created by 장세희 on 6/30/24.
//

import SwiftUI

struct CustomRefresher: View {
    @Environment(\.refresh) private var refresh
    
    @State private var rotationAngle: Double = 0
    
    var body: some View {
        Group {
            if let refresh = refresh {
                Button(
                    action: {
                        Task {
                            await refresh()
                            withAnimation {
                                // 현재 회전 각도에 360을 더하여 오른쪽 방향으로 회전
                                rotationAngle += 360
                            }
                            // 회전 후에 0으로 초기화 (값이 너무 커지지 않도록)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                rotationAngle = 0
                            }
                        }
                    },
                    label: {
                        VStack {
                            Image(systemName: "arrow.clockwise")
                                .foregroundStyle(Color("DefaultTextColor"))
                                .font(.system(size: 20))
                                .rotationEffect(.degrees(rotationAngle))
                        }
                        .padding(15)
                        .background(Color("DefaultColor"))
                        .clipShape(Circle())
                    }
                )
            }
        }
    }
}

