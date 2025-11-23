//
//  HelpView.swift
//  VelogLog
//
//  Created by 장세희 on 7/19/24.
//

import SwiftUI
import Alamofire

struct HelpView: View {
    @EnvironmentObject var lang: LanguageManager
    @AppStorage("appearanceMode") private var appearanceRaw = AppearanceMode.system.rawValue
    
    private var appearanceBinding: Binding<AppearanceMode> {
        Binding(
            get: { AppearanceMode(rawValue: appearanceRaw) ?? .system },
            set: { appearanceRaw = $0.rawValue }
        )
    }
    
    private var FAQs: [FAQModel] = [
        FAQModel(question: NSLocalizedString("faq_q_1", comment: ""),
                 answer: NSLocalizedString("faq_a_1", comment: "")),
        FAQModel(question: NSLocalizedString("faq_q_2", comment: ""),
                 answer: NSLocalizedString("faq_a_2", comment: "")),
    ]
    
    private let currentVersion: String = UserDefaultsManager.getCurrentVersion()
    
    let email: String = "julia8024@naver.com"
    @State var showCopyAlert: Bool = false
    
    @State var alertMessage: String = ""
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {
                
                VStack(alignment: .leading) {
                    Text(lang.localized("settings"))
                        .modifier(Title())
                    
                    Text(lang.localized("screen_mode"))
                        .modifier(BodyText(fontWeight: .bold))
                    
                    Picker(lang.localized("screen_mode"), selection: appearanceBinding) {
                        ForEach(AppearanceMode.allCases) { mode in
                            Text(mode.title).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Divider()
                
                VStack(alignment: .leading) {
                    Text("FAQ")
                        .modifier(Title())
                    
                    ForEach(FAQs) { faq in
                        FAQContainer(faq: .constant(faq))
                            .padding(.bottom, 10)
                    }
                }
                
                Divider()
                
                VStack(alignment: .leading) {
                    Text(lang.localized("developer"))
                        .modifier(Title())
                    HStack {
                        Image("developer_profile")
                            .resizable()
                            .aspectRatio(1.0, contentMode: .fit)
//                            .clipped()
                            .clipShape(Circle())
                            .frame(width: 48)
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(lang.localized("my_name"))
                                    .font(.system(size: 20))
                                    .fontWeight(.bold)
                                
                                Text(lang.localized("my_description"))
                                    .modifier(BodyText(fontWeight: .light))
                            }
                            NavigationLink(destination: DetailView(url: "https://velog.io/@julia8024/posts")) {
                                Text(lang.localized("link_to_velog"))
                                    .modifier(BodyText(fontWeight: .regular))
                            }
                        }
                    }
                    
                }
                
                Divider()
                
                VStack(alignment: .leading) {
                    Text(lang.localized("feedback"))
                        .modifier(Title())
                    
                    Text(lang.localized("feedback_description_1"))
                        .modifier(BodyText(fontWeight: .light))
                        .padding(.bottom, 6)
                    
                    Text(lang.localized("feedback_description_2"))
                        .modifier(BodyText(fontWeight: .light))
                    
                    HStack {
                        Image(systemName: "envelope")
                            .font(.system(size: 16))
                        
                        Text(email)
                            .modifier(BodyText(fontWeight: .regular))
                        
                        Spacer()
                        
                        Button(action: {
                            copyToClipboard(email)
                            
                        }, label: {
                            Image(systemName: "square.on.square")
                                .foregroundStyle(.gray)
                                .font(.system(size: 16))
                            
                        })
                        .alert(isPresented: $showCopyAlert) {
                            Alert(title: Text(lang.localized("alert")), message: Text(alertMessage), dismissButton: .default(Text(lang.localized("confirm"))))
                        }
                    }
                    .padding(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color("LightGrayColor"), lineWidth: 0.5)
                    )
                    .padding(.top, 10)
                    
                    FeedbackView()
                    
                }
                
                VStack {
                    Text("Version \(currentVersion)")
                        .modifier(SmallText())
                }
            }
            .padding(30)
        }
        
    }
    
    func copyToClipboard(_ text: String) {
        
        // 문자열이 비어있는 경우 예외처리
        guard !text.isEmpty else {
            alertMessage = ClipboardCopyStatus.emptyString.message
            showCopyAlert = true
            return
        }

        if UIPasteboard.general.hasStrings {
            // 복사 성공
            UIPasteboard.general.string = text
            alertMessage = ClipboardCopyStatus.success.message
        } else {
            // 접근 권한 없어 복사 실패
            alertMessage = ClipboardCopyStatus.success.message
        }
        showCopyAlert = true
    }

}

enum ClipboardCopyStatus {
    case success
    case emptyString
    case failAccess

    var message: String {
        switch self {
        case .success:
            return NSLocalizedString("copy_success", comment: "")
        case .emptyString:
            return NSLocalizedString("copy_failed", comment: "")
        case .failAccess:
            return NSLocalizedString("copy_faild_due_to_access_denied", comment: "")
        }
    }
}


//struct Title: ViewModifier {
//    
//    func body(content: Content) -> some View {
//        content
//            .font(.system(size: 24))
//            .fontWeight(.bold)
//            .padding(.bottom, 15)
//    }
//}
//
//struct BodyText: ViewModifier {
//    var fontWeight: Font.Weight  // fontWeight를 매개변수로 추가
//
//    func body(content: Content) -> some View {
//        content
//            .font(.system(size: 16))
//            .fontWeight(fontWeight)  // 매개변수로 받은 fontWeight 적용
//            .lineSpacing(2)
//    }
//}
//
//struct SmallText: ViewModifier {
//    func body(content: Content) -> some View {
//        content
//            .font(.system(size: 14))
//            .foregroundColor(.gray)
//    }
//}
//
//// BodyText 모디파이어를 사용하기 위한 extension 추가
//extension View {
//    func bodyText(fontWeight: Font.Weight = .light) -> some View {
//        self.modifier(BodyText(fontWeight: fontWeight))
//    }
//}


struct FAQContainer: View {
    
    @Binding var faq: FAQModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Q. \(faq.question)")
                .modifier(BodyText(fontWeight: .bold))
            
            Text("A. \(faq.answer)")
                .modifier(BodyText(fontWeight: .light))
            
        }
    }
}
