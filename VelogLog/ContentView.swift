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
//    @State var userIdTemp: String = UserDefaultsManager.getData(type: String.self, forKey: .userId) ?? ""
    @State var userIdTemp: String = UserDefaults.shared.string(forKey: "userId") ?? "" // set
    
//    @State private var currentPage = 1
    private let pageSize = 100
//    private let thresholdDistance: CGFloat = 100 // 스크롤 도달 임계값
    
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
                            refreshData()
                            
                        }, label: {
                            Image(systemName: "square.and.pencil")
                                .foregroundStyle(.blue)
                                .font(.system(size: 24))
                        })
                        Spacer()
                    }
                }
                .padding(.horizontal, 20)
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
                        ScrollView {
                            LazyVStack {
                                ForEach(posts) { post in
                                    NavigationLink(destination: CustomWKWebView(url: "https://velog.io/@\(userIdTemp)/\(post.url_slug)")) {
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
                            }
                        }
//                        .frame(maxWidth: .infinity, maxHeight: .infinity)
//                        .background(.yellow)
//                        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
//                            // 스크롤 위치를 확인하여 추가적으로 데이터를 불러옴
//                            print("벨류!!", value)
//                            if shouldLoadMoreData(offset: value) {
//                                print("더 불러와!")
//                                fetchPosts() { fetchedPosts in
//                                    if let fetchedPosts = fetchedPosts {
//                                        posts = fetchedPosts
//                                    }
//                                }
//                            }
//                        }
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
//                UserDefaultsManager.setData(value: inputUserId, key: .userId)
                UserDefaults.shared.set(inputUserId, forKey: "userId")
                fetchUserId()
//                currentPage = 1
                
            }
            .onChange(of: self.userIdTemp, {
                fetchPosts() { fetchedPosts in
                    if let fetchedPosts = fetchedPosts {
                        posts = fetchedPosts
                    }
                }
            })
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
//        let userId = UserDefaultsManager.getData(type: String.self, forKey: .userId)
        let userId = UserDefaults.shared.string(forKey: "userId")
        
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
    
    private func fetchPosts(completion: @escaping ([Post]?) -> Void) {
        
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
                "limit": pageSize
//                "offset": (currentPage - 1) * pageSize
            ],
            "query":"query Posts($cursor: ID, $username: String, $temp_only: Boolean, $tag: String, $limit: Int) {\n  posts(cursor: $cursor, username: $username, temp_only: $temp_only, tag: $tag, limit: $limit) {\n    id\n    title\n    short_description\n        user {\n      id\n      username\n      profile {\n        id\n        thumbnail\n        __typename\n      }\n      __typename\n    }\n    url_slug\n    released_at\n    updated_at\n    comments_count\n    tags\n    is_private\n    likes\n    __typename\n  }\n}\n"
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
    
//    private func shouldLoadMoreData(offset: CGFloat) -> Bool {
//        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//              let window = windowScene.windows.first else {
//            return false
//        }
//        
//        // window의 frame 속성이 nil이 아닌 경우에만 스크롤 높이를 확인
//        
//        let scrollViewHeight = window.frame.height
//        
//        // 스크롤이 일정 거리(thresholdDistance) 위로 올라갈 때 데이터 추가 요청
//        return offset > scrollViewHeight - thresholdDistance
//        
//    }


}

// 스크롤 위치를 감지하기 위한 PreferenceKey 정의
//struct ScrollOffsetPreferenceKey: PreferenceKey {
//    typealias Value = CGFloat
//    
//    static var defaultValue: CGFloat = 0
//    
//    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
//        value = nextValue()
//    }
//}
//
//extension View {
//    // 스크롤 위치를 감지하여 PreferenceKey에 전달
//    func trackScrollOffset() -> some View {
//        background(
//            GeometryReader { geometry in
//                Color.clear.preference(
//                    key: ScrollOffsetPreferenceKey.self,
//                    value: geometry.frame(in: .global).minY
//                )
//            }
//        )
//    }
//}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}

extension UserDefaults {
    static var shared: UserDefaults {
        let appGroupId = "group.undefined.VelogLog"
        return UserDefaults(suiteName: appGroupId)!
    }
}
