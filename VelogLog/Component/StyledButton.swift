//
//  StyledButton.swift
//  VelogLog
//
//  Created by 장세희 on 10/16/24.
//

import SwiftUI

struct StyledButton: View {
    
    let text: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .foregroundColor(Color("DefaultColor"))
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color("DefaultTextColor"))
                .cornerRadius(8)
        }
    }
}
