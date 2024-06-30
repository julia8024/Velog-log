//
//  ContentView.swift
//  VelogLog
//
//  Created by 장세희 on 2024/06/17.
//

import SwiftUI
import Alamofire
import WebKit

struct ContentView: View {
    
    @State private var posts: [Post] = []
    @State var isPresented: Bool = false
    @State var showWeb: Bool = false
    @State var inputUserId: String = ""
    @State var userIdTemp: String = UserDefaultsManager.getData(type: String.self, forKey: .userId) ?? ""
    
    var body: some View {
        NavigationView {
            VStack {
                VStack {
                    HStack {
                        Text(userIdTemp.isEmpty ? "누구의 글을 불러올까요?" : "\(userIdTemp)님의 Velog 글")
                            .font(.system(size: 24))
                            .fontWeight(.bold)
                            .padding(.trailing, 10)

                        Button(action: {
                            self.isPresented.toggle()
                        }, label: {
                            Image(systemName: "square.and.pencil")
                                .foregroundStyle(.blue)
                                .font(.system(size: 24))
                        })
                        Spacer()
                    }
                }
                .padding(.horizontal, 30)
                .padding(.top, 30)
                .padding(.bottom, 10)
                
                VStack {
                    if (posts.isEmpty) {
                        VStack {
                            Spacer()
                            Text("리스트가 비어있어요")
                            Spacer()
                        }
                        
                    }
                    else {
                        List(posts) { post in
                            NavigationLink(destination: CustomWKWebView(url: "https://velog.io/@\(userIdTemp)/\(post.url_slug)")) {
                                Text(post.title)
                                    .padding(.leading, 10)
                            }
                            .padding(.trailing, 10)
                        }
                        .listStyle(.plain)
                    }
                }
                .frame(maxWidth: .infinity)
                .overlay(
                    
                    CustomRefresher()
                        .refreshable {
                            refreshData()
                            fetchUserId()
                        }
                    .padding(20)
                    
                     //오른쪽 하단에 버튼 고정
                    ,alignment: .bottomTrailing
                )
                
            }
        }
        .alert("회원 ID", isPresented: $isPresented) {
            TextField("회원 ID를 입력하세요", text: $inputUserId)
            Button("확인") {
                UserDefaultsManager.setData(value: inputUserId, key: .userId)
                fetchUserId()
                
            }
        }
        .onAppear {
            refreshData()
        }
        .refreshable {
            refreshData()
            fetchUserId()
        }
    }
    
    private func refreshData() {
        let userId = UserDefaultsManager.getData(type: String.self, forKey: .userId)
        
        guard userId != nil else {
            isPresented = true
            return
        }
        
        fetchPosts() { fetchedPosts in
            if let fetchedPosts = fetchedPosts {
                posts = fetchedPosts
            }
        }
    }
    
    private func fetchUserId() {
        self.userIdTemp = UserDefaultsManager.getData(type: String.self, forKey: .userId) ?? ""
    }
    
    private func fetchPosts(completion: @escaping ([Post]?) -> Void) {
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
                "username": UserDefaultsManager.getData(type: String.self, forKey: .userId) ?? "",
                "limit": 100
            ],
            "query":"query Posts($cursor: ID, $username: String, $temp_only: Boolean, $tag: String, $limit: Int) {\n  posts(cursor: $cursor, username: $username, temp_only: $temp_only, tag: $tag, limit: $limit) {\n    id\n    title\n    short_description\n    thumbnail\n    user {\n      id\n      username\n      profile {\n        id\n        thumbnail\n        __typename\n      }\n      __typename\n    }\n    url_slug\n    released_at\n    updated_at\n    comments_count\n    tags\n    is_private\n    likes\n    __typename\n  }\n}\n"
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
    
    struct PostListResponse: Decodable {
        var data: DataWrapper
        
        struct DataWrapper: Decodable {
            var posts: [Post]
        }
    }
}


//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
