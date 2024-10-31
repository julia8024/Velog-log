//
//  HelpView.swift
//  VelogLog
//
//  Created by 장세희 on 7/19/24.
//

import SwiftUI
import Alamofire

struct HelpView: View {
    
    private var FAQs: [FAQModel] = [
        FAQModel(question: "사용자 ID를 어떻게 확인하나요?", answer: "'https://velog.io/@userid/posts'처럼 velog.io의 url에서 @ 뒤에 있는 문자열이 사용자 ID입니다. (예시: 'https://velog.id/@julia8024/posts'인 경우, 사용자 ID는 julia8024)"),
        FAQModel(question: "Velog 로그인은 안 되나요?", answer: "해당 앱은 Velog 공식 앱이 아니어서 velog 로그인 및 글 작성은 불가합니다. velog 회원 ID를 통한 포스트 열람 및 위젯 기능 등이 가능하며, 앱 스토어에 등록된 앱 소개 이미지를 확인하시어 원활한 앱 사용이 되시길 바랍니다.")
    ]
    
    let email: String = "julia8024@naver.com"
    @State var showCopyAlert: Bool = false
    
    @State var alertMessage: String = ""
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {
                
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
                    Text("만든 이")
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
                                Text("장세희")
                                    .font(.system(size: 20))
                                    .fontWeight(.bold)
                                
                                Text(" | 디자인하는 개발자")
                                    .modifier(BodyText(fontWeight: .light))
                            }
                            NavigationLink(destination: DetailView(url: "https://velog.io/@julia8024/posts")) {
                                Text("velog 바로가기")
                                    .modifier(BodyText(fontWeight: .regular))
                            }
                        }
                    }
                    
                }
                
                Divider()
                
                VStack(alignment: .leading) {
                    Text("피드백")
                        .modifier(Title())
                    
                    Text("피드백을 남겨주세요!\n궁금한 점이나 개선 사항 모두 환영합니다 ☺️")
                        .modifier(BodyText(fontWeight: .light))
                        .padding(.bottom, 6)
                    
                    Text("이메일 주소로 직접 보내주셔도 좋습니다!")
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
                            Alert(title: Text("알림"), message: Text(alertMessage), dismissButton: .default(Text("확인")))
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
                    Text("Version \(UserDefaults.shared.string(forKey: "currentVersion") ?? "1.0")")
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
            return "클립보드에 복사되었습니다!"
        case .emptyString:
            return "클립보드 복사에 실패했습니다"
        case .failAccess:
            return "클립보드 복사에 실패했습니다\n설정에서 권한을 확인해주세요"
        }
    }
}


struct Title: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .font(.system(size: 24))
            .fontWeight(.bold)
            .padding(.bottom, 15)
    }
}

struct BodyText: ViewModifier {
    var fontWeight: Font.Weight  // fontWeight를 매개변수로 추가

    func body(content: Content) -> some View {
        content
            .font(.system(size: 16))
            .fontWeight(fontWeight)  // 매개변수로 받은 fontWeight 적용
            .lineSpacing(2)
    }
}

struct SmallText: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 14))
            .foregroundColor(.gray)
    }
}

// BodyText 모디파이어를 사용하기 위한 extension 추가
extension View {
    func bodyText(fontWeight: Font.Weight = .light) -> some View {
        self.modifier(BodyText(fontWeight: fontWeight))
    }
}


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
