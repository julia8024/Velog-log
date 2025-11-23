//
//  AddUserIdView.swift
//  VelogLog
//
//  Created by 장세희 on 10/16/24.
//

import SwiftUI

struct AddUserIdView: View {
    @EnvironmentObject var lang: LanguageManager
    
    @Binding var shouldRefresh: Bool
    @State private var inputUserId: String = UserDefaults.shared.string(forKey: "userId") ?? ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(lang.localized("input_user_id"))
                .modifier(SmallTitle())
            
            TextField("placeholder_input_user_id", text: $inputUserId)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            StyledButton(text: lang.localized("confirm"), action: {
                if !inputUserId.isEmpty {
                    UserDefaults.standard.set(inputUserId, forKey: "userId")
                    UserDefaultsManager.addUserId(inputUserId)
                    shouldRefresh.toggle()  // UserIdListView 새로고침 트리거
                    // TO DO : 리스트 스크롤 맨 아래로 이동
                }
            })
            .disabled(inputUserId.isEmpty)
        }
        .padding(.vertical, 20)
    }
}
