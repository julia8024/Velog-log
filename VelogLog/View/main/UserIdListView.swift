//
//  UserIdListView.swift
//  VelogLog
//
//  Created by 장세희 on 10/16/24.
//

import SwiftUI

struct UserIdListView: View {
    @EnvironmentObject var lang: LanguageManager
    
    @Binding var isPresented: Bool
    @State var userId: String = UserDefaults.shared.string(forKey: "userId") ?? ""
    @State var allUserIds: [String] = UserDefaultsManager.getUserIdList()
    
    @State var shouldRefresh: Bool = false
    
    @State private var isConfirmingId: String? = nil

    
    var body: some View {
        
        VStack {
            AddUserIdView(shouldRefresh: $shouldRefresh)
                .padding(.top, 10)
            
            if (!allUserIds.isEmpty) {
                VStack (alignment: .leading, spacing: 10) {
                    Text(lang.localized("saved_user_id"))
                        .modifier(SmallTitle())
                    Divider()
                    
                    ScrollView {
                        LazyVStack {
                            ForEach(allUserIds, id: \.self) { ids in
                                
                                Button(action: {
                                    isConfirmingId = ids

                                }, label: {
                                    VStack {
                                        HStack {
                                            Text(ids)
                                                .modifier(BodyText(fontWeight: .regular))
                                                .foregroundColor(Color("DefaultTextColor"))
                                            
                                            Spacer()
                                            if (ids == userId) {
                                                Text("default")
                                                    .modifier(SmallText())
                                            }
                                        }
                                        .padding(.vertical, 6)
                                    }
                                })
                                .confirmationDialog(
                                    String(format: lang.localized("description_to_select_by_id"), ids)
                                    ,
                                    isPresented: Binding(
                                        get: { isConfirmingId == ids },
                                        set: { if !$0 { isConfirmingId = nil } }
                                    )
                                ) {
                                    Button(lang.localized("set_as_default")) {
                                        UserDefaults.shared.set(ids, forKey: "userId")
                                        refreshData()
                                        isPresented = false
                                        isConfirmingId = nil
                                    }
                                    Button(lang.localized("delete"), role: .destructive) {
                                        deleteItems(ids)
                                        refreshData()
                                        isPresented = false
                                        isConfirmingId = nil
                                    }
                                    Button(lang.localized("cancel"), role: .cancel) {}
                                } message: {
                                    Text(String(format: lang.localized("description_to_select_by_id"), ids)
                                         + "\n" + lang.localized("description_to_set_as_default"))
                                }
                                
                                Divider()
                                
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .padding(.top, 30)
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
