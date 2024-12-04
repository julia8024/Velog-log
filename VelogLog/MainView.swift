//
//  MainView.swift
//  VelogLog
//
//  Created by 장세희 on 2024/06/17.
//

import SwiftUI
import Alamofire
import WebKit

struct MainView: View {
    
    @State private var posts: [Post] = []
    @State private var user: User?
    
    @State var isPresented: Bool = false
    
    @State var showWeb: Bool = false
    @State var inputUserId: String = ""
    //    @State var userIdTemp: String = UserDefaultsManager.getData(type: String.self, forKey: .userId) ?? ""
    @State var userIdTemp: String = UserDefaults.shared.string(forKey: "userId") ?? "" // set
    
    let pageSize = 10
    
    var body: some View {
        VStack {
            if (user != nil && !userIdTemp.isEmpty) {
                VStack {
                    HStack {
                        
                        AsyncImage(url: URL(string: (user?.profile.thumbnail)!)) { image in
                            image
                                .resizable()
                                .scaledToFit()
                        } placeholder: {
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .padding(14)
                                .foregroundColor(Color.gray)
                            
                        }
                        .background(Color("LightGrayColor"))
                        .clipShape(Circle())
                        .frame(width: 48)
                        
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text((user?.profile.display_name)!)
                                .font(.system(size: 20))
                                .fontWeight(.bold)
                            
                            Text((user?.profile.short_bio)!)
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                                .lineLimit(1)
                        }
                        
                        Spacer(minLength: 4)
                        
                        Button(action: {
                            self.isPresented.toggle()
                            refreshData()
                            
                        }, label: {
                            Image(systemName: "person.badge.plus")
                                .foregroundStyle(.blue)
                                .font(.system(size: 24))
                        })
                        
                    }
                    
                }
                .padding(.horizontal, 20)
                .padding(.top, 30)
                .padding(.bottom, 10)
            }
            VStack {
                if (user == nil || userIdTemp.isEmpty) {
                    VStack {
                        Spacer()
                        Text(userIdTemp.isEmpty ? "누구의 글을 불러올까요?" : "\"\(userIdTemp)\" 사용자를 찾을 수 없어요")
                            .font(.system(size: 16))
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 10)
                        StyledButton(text: "사용자 ID로 불러오기", action: {
                            self.isPresented.toggle()
                            refreshData()
                        })
                        Spacer()
                    }
                    .padding(20)
                }
                
                if (!posts.isEmpty) {
                    ScrollView {
                        LazyVStack {
                            ForEach(posts) { post in
                                VStack {
                                    NavigationLink(destination: DetailView(url: "https://velog.io/@\(userIdTemp)/\(post.url_slug)")) {
                                        HStack {
                                            VStack(alignment: .leading, spacing: 6) {
                                                Text(post.title)
                                                    .foregroundColor(Color("DefaultTextColor"))
                                                    .lineSpacing(2)
                                                    .font(.system(size: 16))
                                                    .multilineTextAlignment(.leading)
                                                Text(formatDate(date: post.released_at))
                                                    .foregroundColor(.gray)
                                                    .font(.system(size: 14))
                                                
                                            }
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            
                                            Spacer(minLength: 4)
                                            
                                            Image(systemName: "chevron.right")
                                                .font(.system(size: 14))
                                                .foregroundColor(.gray)
                                        }
                                        .padding(.horizontal, 20)
                                    }
                                    .padding(.vertical, 4)
                                    Divider()
                                }
                                .onAppear {
                                    guard let index = posts.firstIndex(where: {$0.id == post.id}) else { return }
                                    
                                    if index % pageSize == (pageSize - 1) {
                                        Task {
                                            do {
                                                try await loadMorePosts()
                                            } catch (let error) {
                                                print("Unable to get data : \(error)")
                                            }
                                        }
                                    }
                                }
                            }
                            //                                .trackScrollOffset()
                        }
                        //                            .trackScrollOffset()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                
            }
            .frame(maxWidth: .infinity)
            .overlay(
                VStack {
                    if (!posts.isEmpty) {
                        CustomRefresher()
                            .refreshable {
                                refreshData()
                            }
                            .padding(20)
                    }
                }
                
                //오른쪽 하단에 버튼 고정
                ,alignment: .bottomTrailing
            )
            
        }
        .sheet(isPresented: $isPresented, content: {
            UserIdListView(isPresented: $isPresented)
        })
        .onChange(of: isPresented) { old, new in
            refreshData()
        }
        .onAppear {
            refreshData()
        }
        .refreshable {
            refreshData()
        }
    }
    
    private func refreshData() {
        //        let userId = UserDefaultsManager.getData(type: String.self, forKey: .userId)
        let userId = UserDefaults.shared.string(forKey: "userId") ?? ""
        
        fetchUserId()
        
        guard userId != "" else {
            isPresented = true
            return
        }
        
        fetchUser() { fetchedUser in
            if let fetchedUser = fetchedUser {
                user = fetchedUser
            } else {
                user = nil
            }
        }
        
        fetchPosts(cursor: "") { fetchedPosts in
            if let fetchedPosts = fetchedPosts {
                posts = fetchedPosts
            }
        }
    }
    
    // Date 포맷을 설정하는 함수
    func formatDate(date: String) -> String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let isoDate = isoFormatter.date(from: date) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd, yyyy"
            return dateFormatter.string(from: isoDate)
        } else {
            return "Invalid Date Format"
        }
    }
    
    private func fetchUserId() {
        //        self.userIdTemp = UserDefaultsManager.getData(type: String.self, forKey: .userId) ?? ""
        self.userIdTemp = UserDefaults.shared.string(forKey: "userId") ?? ""
    }
    
    private func loadMorePosts() async {
        let lastPostId = posts.isEmpty ? "" : posts[posts.count - 1].id
        fetchPosts(cursor: lastPostId) { fetchedPosts in
            if let fetchedPosts = fetchedPosts {
                self.posts.append(contentsOf: fetchedPosts)
            }
        }
    }
    
    private func fetchUser(completion: @escaping (User?) -> Void) {
        if UserDefaults.shared.string(forKey: "userId")!.isEmpty {
            return completion(nil)
        }
        
        let url = "https://v2.velog.io/graphql"
        
        
        // URLRequest 객체 생성 (url 전달)
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        
        // 헤더 정보 설정
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        // json 인코더 생성
        let encoder = JSONEncoder()
        
        // json 출력 시 예쁘게 출력
        encoder.outputFormatting = .prettyPrinted
        let parameters: [String: Any] = [
            // 여기에 필요한 파라미터를 추가하세요
            "operationName":"User",
            "variables": [
                "username": UserDefaults.shared.string(forKey: "userId")!
            ],
            "query":"query User($username: String) {\n  user(username: $username) {\n    id\n    username\n    profile\n {\n      id\n      display_name\n      short_bio\n      thumbnail\n        __typename\n }\n   __typename\n }\n }\n"
        ]
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {
            print("Failed to serialize parameters")
            completion(nil)
            return
        }
        
        request.httpBody = httpBody
        
        AF.request(request).responseDecodable(of: UserResponse.self) { response in
            // responseDecodable은 결과를 PostListResponse 구조체로 디코딩한다.
            switch response.result {
            case .success(let userResponse):
                // postListResponse의 data.posts를 completion handler를 통해 외부로 전달한다.
                completion(userResponse.data.user)
            case .failure(let error):
                print("Error fetching posts: \(error)")
                completion(nil) // 에러 발생 시 nil을 반환하여 외부에서 에러 처리 가능하도록 한다.
            }
        }
    }
    
    private func fetchPosts(cursor: String?, completion: @escaping ([Post]?) -> Void) {
        
        if UserDefaults.shared.string(forKey: "userId") == "" {
            return completion([])
        }
        
        let url = "https://v2.velog.io/graphql"
        
        
        // URLRequest 객체 생성 (url 전달)
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        
        // 헤더 정보 설정
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        // json 인코더 생성
        let encoder = JSONEncoder()
        
        // json 출력 시 예쁘게 출력
        encoder.outputFormatting = .prettyPrinted
        let parameters: [String: Any] = [
            // 여기에 필요한 파라미터를 추가하세요
            "operationName":"Posts",
            "variables": [
                "username": UserDefaults.shared.string(forKey: "userId")!,
                "limit": pageSize,
                "cursor": cursor ?? nil
            ],
            "query":"query Posts($cursor: ID, $username: String, $temp_only: Boolean, $tag: String, $limit: Int) {\n  posts(cursor: $cursor, username: $username, temp_only: $temp_only, tag: $tag, limit: $limit) {\n    id\n    title\n    short_description\n        user {\n      id\n      username\n      profile {\n        id\n        display_name\n      short_bio\n        thumbnail\n        __typename\n      }\n      __typename\n    }\n    url_slug\n    released_at\n    updated_at\n    comments_count\n    tags\n    is_private\n    likes\n    __typename\n  }\n}\n"
        ]
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {
            print("Failed to serialize parameters")
            completion([])
            return
        }
        
        request.httpBody = httpBody
        
        AF.request(request).responseDecodable(of: PostListResponse.self) { response in
            // responseDecodable은 결과를 PostListResponse 구조체로 디코딩한다.
            switch response.result {
            case .success(let postListResponse):
                // postListResponse의 data.posts를 completion handler를 통해 외부로 전달한다.
                completion(postListResponse.data.posts)
            case .failure(let error):
                print("Error fetching posts: \(error)")
                completion(nil) // 에러 발생 시 nil을 반환하여 외부에서 에러 처리 가능하도록 한다.
            }
        }
    }
    
}


//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}

extension UserDefaults {
    static var shared: UserDefaults {
        let appGroupId = "group.seheeJang.VelogLog"
        return UserDefaults(suiteName: appGroupId)!
    }
}
