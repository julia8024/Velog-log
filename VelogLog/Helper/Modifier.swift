//
//  Modifier.swift
//  VelogLog
//
//  Created by 장세희 on 11/30/24.
//

import SwiftUI

struct Title: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .font(.system(size: 24))
            .fontWeight(.bold)
            .padding(.bottom, 15)
    }
}

struct SmallTitle: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .font(.system(size: 20))
            .fontWeight(.bold)
            .padding(.bottom, 10)
    }
}

struct BodyText: ViewModifier {
    var fontWeight: Font.Weight  // fontWeight를 매개변수로 추가

    func body(content: Content) -> some View {
        content
            .font(.system(size: 16))
            .fontWeight(fontWeight)  // 매개변수로 받은 fontWeight 적용
            .lineSpacing(2)
    }
}

struct SmallText: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 14))
            .foregroundColor(.gray)
    }
}

// BodyText 모디파이어를 사용하기 위한 extension 추가
extension View {
    func bodyText(fontWeight: Font.Weight = .light) -> some View {
        self.modifier(BodyText(fontWeight: fontWeight))
    }
}

