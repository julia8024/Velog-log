//
//  CustomRefresher.swift
//  VelogLog
//
//  Created by 장세희 on 6/30/24.
//

import SwiftUI

struct CustomRefresher: View {
    @Environment(\.refresh) private var refresh
    
    var body: some View {
        Group {
            if let refresh = refresh {
                Button(
                    action: {
                        Task {
                            await refresh()
                        }
                    },
                    label: {
                        VStack {
                            Image(systemName: "arrow.clockwise")
                                .foregroundStyle(Color("DefaultTextColor"))
                                .font(.system(size: 20))
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
