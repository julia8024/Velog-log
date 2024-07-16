//
//  LogWidget.swift
//  LogWidget
//
//  Created by 장세희 on 2024/06/17.
//

import WidgetKit
import SwiftUI
import Intents

struct Provider: IntentTimelineProvider {
    
    func placeholder(in context: Context) -> SimpleEntry {
        print("hello")
        return SimpleEntry(date: Date(), entries: [])
        //                            [PostItem(title: "Loading...", released_at: Date())])
    }
    
    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        // 데이터 가져오기
        getTexts { posts in
            guard !posts.isEmpty else {
                completion(SimpleEntry(date: Date(), entries: []))
                //                                        [PostItem(title: "No data!!", released_at: Date())]))
                return
            }
            let entry = SimpleEntry(date: Date(), entries: posts)
            completion(entry)
        }
    }
    
    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        // 데이터 가져오기
        getTexts { posts in
            let currentDate = Date()
            let entry = SimpleEntry(date: currentDate, entries: posts)
            
            // Define when to refresh the widget next
            let nextRefresh = Calendar.current.date(byAdding: .minute, value: 10, to: currentDate)!
            let timeline = Timeline(entries: [entry], policy: .after(nextRefresh))
            completion(timeline)
        }
    }
    
    private func getTexts(completion: @escaping ([PostItem]) -> ()) {
        guard let url = URL(string: "https://v2.velog.io/graphql") else {
            print("Invalid URL")
            completion([])
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let parameters: [String: Any] = [
            // 여기에 필요한 파라미터를 추가하세요
            "operationName":"Posts",
            "variables": [
                "username": UserDefaults.shared.string(forKey: "userId") ?? "",
                "limit": 6
            ],
            "query":"query Posts($cursor: ID, $username: String, $temp_only: Boolean, $tag: String, $limit: Int) {\n  posts(cursor: $cursor, username: $username, temp_only: $temp_only, tag: $tag, limit: $limit) {\n    id\n    title\n    short_description\n    thumbnail\n    user {\n      id\n      username\n      profile {\n        id\n        thumbnail\n        __typename\n      }\n      __typename\n    }\n    url_slug\n    released_at\n    updated_at\n    comments_count\n    tags\n    is_private\n    likes\n    __typename\n  }\n}\n"
            
        ]
        
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {
            print("Failed to serialize parameters")
            completion([])
            return
        }
        
        request.httpBody = httpBody
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                completion([])
                return
            }
            
            guard let data = data else {
                print("No data received")
                completion([])
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                
                
                let textModel = try decoder.decode(TextModel.self, from: data)
                //                completion([PostItem(title: "d2dfv", released_at: Date())])
                
                let posts = textModel.data.posts.map { PostItem(title: $0.title, released_at: $0.released_at) }
                completion(posts)
                
            } catch {
                print("Failed to decode JSON: \(error.localizedDescription)")
                //                completion([PostItem(title: "dkdkdk", released_at: Date())])
            }
        }.resume()
    }
}

struct TextModel: Decodable {
    struct Post: Decodable {
        let title: String
        let released_at: String
    }
    let data: DataContainer
    
    struct DataContainer: Decodable {
        let posts: [Post]
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let entries: [PostItem]
}

struct PostItem: Identifiable {
    var id = UUID()
    var title: String
    var released_at: String
}




struct LogWidgetEntryView : View {
    @Environment(\.widgetFamily) private var widgetFamily
    
    var entry: Provider.Entry
    
    var body: some View {
        VStack {
            switch widgetFamily {
            case .systemSmall:
                if !entry.entries.isEmpty {
                    VStack(alignment: .leading) {
                        Text("최신 글")
                            .font(.system(size: 14))
                            .fontWeight(.bold)
                        Divider()
                        
                        VStack {
                            if let title = entry.entries.first?.title { // testNumber에 값이 있을 경우
                                Text(title.splitChar())
                                    .foregroundColor(Color.black)
                                    .font(.system(size: 14))
                                    .lineSpacing(7)
                                    .lineLimit(3)
                            } else { // testNumber 가 nil일 경우
                                Text("")
                                    .foregroundColor(Color.black)
                                    .font(.system(size: 14))
                                    .lineLimit(3)
                            }
                        }
                        .padding(.vertical, 3)
                        Spacer()
                        
                        
                        HStack() {
                            Spacer()
                            Text("\(daysSinceRelease(releasedAtDateString: entry.entries.first?.released_at))")
                                .foregroundColor(Color.black)
                                .fontWeight(.bold)
                                .font(.system(size: 16))
                                .lineLimit(1)
                        }
                        
                    }
                } else {
                    VStack(alignment: .center) {
                        Text("Nothing...")
                    }
                    
                }
                
            case .systemMedium:
                VStack(alignment: .leading) {
                    HStack {
                        Text("최신 글")
                            .font(.system(size: 16))
                            .fontWeight(.bold)
                            .padding(.trailing, 4)
                        Text(UserDefaults.shared.string(forKey: "userId")!)
                            .font(.system(size: 14))
                            .foregroundColor(Color.gray)
                    }
                    
                    ForEach(entry.entries.prefix(3)) { post in
                        LazyVStack(alignment: .leading) {
                            Text("\(post.title)")
                                .foregroundColor(Color.black)
                                .font(.system(size: 14))
                                .lineLimit(1)
                            Divider()
                        }
                    }
                }
            case .systemLarge:
                Text("large")
            @unknown default:
                Text("unknown")
            }
        }
        .widgetBackground()
    }
}

// Date 포맷을 설정하는 함수
func formattedDate(dateString: String?) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ" // 입력된 문자열 형식에 맞게 설정
    
    guard let dateString = dateString, let date = formatter.date(from: dateString) else {
        return "Invalid Date"
    }
    
    // 원하는 형식으로 날짜를 문자열로 변환
    formatter.dateFormat = "MMMM dd, yyyy"
    return formatter.string(from: date)
}

func daysSinceRelease(releasedAtDateString: String?) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ" // 입력된 문자열 형식에 맞게 설정
    
    guard let releasedAtDateString = releasedAtDateString, let releasedDate = formatter.date(from: releasedAtDateString) else {
        return "-"
    }
    
    // 현재 날짜
    let currentDate = Date()
    
    // Calendar 객체 생성
    let calendar = Calendar.current
    
    // releasedDate와 currentDate의 자정 시각을 계산
    let startOfReleasedDate = calendar.startOfDay(for: releasedDate)
    let startOfCurrentDate = calendar.startOfDay(for: currentDate)
    
    // 날짜 차이 계산 (일 단위)
    let components = calendar.dateComponents([.day], from: startOfReleasedDate, to: startOfCurrentDate)
    
    // 날짜 차이 반환
    if let days = components.day {
        if days == 0 {
            return "Today" // 오늘 작성된 글
        } else if days == 1 {
            return "\(days) day ago" // 하루 전 작성된 글
        } else {
            return "\(days) days ago" // 며칠 전 작성된 글
        }
    }
    
    return "Unknown date" // 날짜 계산이 불가능한 경우
}



extension View {
    func widgetBackground() -> some View {
        if #available(iOSApplicationExtension 17.0, *) {
            return containerBackground(for: .widget) {
                // ...
            }
        } else {
            return background()
        }
    }
}

struct LogWidget: Widget {
    let kind: String = "LogWidget"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            LogWidgetEntryView(entry: entry)
        }
        
        .configurationDisplayName("Velog 로그")
        .description("Velog의 내 글의 로그를 볼 수 있어요")
    }
}

extension String {
    func splitChar() -> String {
        return self.split(separator: "").joined(separator: "\u{200B}")
    }
}

//struct LogWidget_Previews: PreviewProvider {
//    static var previews: some View {
//        LogWidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
//            .previewContext(WidgetPreviewContext(family: .systemSmall))
//    }
//}


extension UserDefaults {
    static var shared: UserDefaults {
        let appGroupId = "group.undefined.VelogLog"
        return UserDefaults(suiteName: appGroupId)!
    }
}
