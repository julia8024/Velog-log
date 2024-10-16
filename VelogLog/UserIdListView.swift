//
//  UserIdListView.swift
//  VelogLog
//
//  Created by 장세희 on 10/16/24.
//

import SwiftUI

struct UserIdListView: View {
    
    @Binding var isPresented: Bool
    @State var userId: String = UserDefaults.shared.string(forKey: "userId") ?? ""
    @State var allUserIds: [String] = UserDefaultsManager.getUserIdList()
    
    @State var shouldRefresh: Bool = false
    
    var body: some View {
        
        VStack {
            AddUserIdView(shouldRefresh: $shouldRefresh)
                .padding(.top, 10)
            
            if (!allUserIds.isEmpty) {
                ScrollView {
                    LazyVStack {
                        ForEach(allUserIds, id: \.self) { ids in
                            
                            Button(action: {
                                UserDefaults.shared.set(ids, forKey: "userId")
                                refreshData()
                                isPresented = false
                            }, label: {
                                VStack {
                                    HStack {
                                        Text(ids)
                                            .foregroundColor(Color("DefaultTextColor"))
                                        Spacer()
                                        if (ids == userId) {
                                            Text("default")
                                        }
                                    }
                                    .padding(.vertical, 10)
                                    
                                    
                                }
                            })
                            .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                Button {
                                    deleteItems(ids)
                                } label: {
                                    Label("Delete", systemImage: "trash.circle")
                                }
                                .tint(.red)
                            }
                            Divider()
                            
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(20)
        .onAppear(perform: refreshData)
        .onChange(of: shouldRefresh) { old, new in
            refreshData()
        }
    }
    
    private func deleteItems(_ userIdTemp: String) {
        UserDefaultsManager.removeUserId(userIdTemp)
        if userIdTemp == userId {
            UserDefaults.standard.removeObject(forKey: "userId")
            userId = ""
        }
        
        refreshData()
    }
    
    
    private func refreshData() {
        userId = UserDefaults.shared.string(forKey: "userId") ?? ""
        allUserIds = UserDefaultsManager.getUserIdList()
        
        shouldRefresh = false
        
        guard userId != "" else {
            isPresented = true
            return
        }
    }
}
