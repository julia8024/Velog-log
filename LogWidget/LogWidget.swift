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
                let nextRefresh = Calendar.current.date(byAdding: .minute, value: 1, to: currentDate)!
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
                "username":"julia8024",
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
                
                let posts = textModel.data.posts.map { PostItem(title: $0.title)}
//                                                                released_at: $0.released_at) }
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
//        let released_at: Date
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
//    var released_at: Date
}




struct LogWidgetEntryView : View {
    @Environment(\.widgetFamily) private var widgetFamily
    
    var entry: Provider.Entry
    
    var body: some View {
        VStack {
            switch widgetFamily {
            case .systemSmall:
                VStack(alignment: .center) {
                    Text("released_at")
//                    Text(entry.date, style: .date)
                }
            case .systemMedium:
                VStack(alignment: .leading) {
                    //            Text(entry.date, style: .time)
                    Text("최신 글")
                    ForEach(entry.entries.prefix(3)) { post in
                        LazyVStack(alignment: .leading) {
                            Text("\(post.title) -")
//                                 \(formattedDate(date: post.released_at))")
                                .foregroundColor(Color.black)
                                .font(.system(size: 14))
                                .lineLimit(1)
                            Divider()
                        }
                    }
//                    ForEach(entry.entries.prefix(3), id: \.hashValue) { post in
//                        LazyVStack(alignment: .leading) {
//                            Text("\(post)")
//                                .foregroundColor(Color.black)
//                                .font(.system(size: 14))
//                                .lineLimit(1)
//                            Divider()
//                        }
//                        
//                    }
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
func formattedDate(date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    return dateFormatter.string(from: date)
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

//struct LogWidget_Previews: PreviewProvider {
//    static var previews: some View {
//        LogWidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
//            .previewContext(WidgetPreviewContext(family: .systemSmall))
//    }
//}
