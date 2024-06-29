//
//  ProfileView.swift
//  VelogLog
//
//  Created by 장세희 on 6/29/24.
//

import SwiftUI

struct ProfileView: View {
    
    @State var inputUserId: String = ""
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack {
            TextField("사용자 ID 입력", text: $inputUserId)
            Button(action: {
                UserDefaultsManager.setData(value: inputUserId, key: .userId)
                isPresented = false
            }, label: {
                Text("확인")
            })
        }
    }
}

//#Preview {
//    ProfileView()
//}
