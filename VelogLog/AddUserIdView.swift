//
//  AddUserIdView.swift
//  VelogLog
//
//  Created by 장세희 on 10/16/24.
//

import SwiftUI

struct AddUserIdView: View {
    
    @Binding var shouldRefresh: Bool
    @State private var inputUserId: String = UserDefaults.shared.string(forKey: "userId") ?? ""
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("사용자 ID 입력")
                .font(.system(size: 14))
            TextField("사용자 ID를 입력하세요", text: $inputUserId)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            StyledButton(text: "확인", action: {
                if !inputUserId.isEmpty {
                    UserDefaults.standard.set(inputUserId, forKey: "userId")
                    UserDefaultsManager.addUserId(inputUserId)
                    shouldRefresh.toggle()  // UserIdListView 새로고침 트리거
                    // TO DO : 리스트 스크롤 맨 아래로 이동
                }
            })
            .disabled(inputUserId.isEmpty)
        }
    }
}
