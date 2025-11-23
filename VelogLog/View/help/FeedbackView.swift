//
//  FeedbackView.swift
//  VelogLog
//
//  Created by 장세희 on 7/19/24.
//

import SwiftUI
import MessageUI

struct FeedbackView: View {
    @EnvironmentObject var lang: LanguageManager
    
    var maxRating: Int = 5
    
    var offImage = Image(systemName: "star")
    var onImage = Image(systemName: "star.fill")
    
    @State var ratingValue : Int = 5
    @State var messageBody: String = ""
    
    @State private var isShowingMailView: Bool = false
    @State private var result: Result<MFMailComposeResult, Error>? = nil
    
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    var body: some View {
        VStack {
            VStack(spacing: 20) {
                HStack(spacing: 0) {
                    // 별점 이미지
                    ForEach(1..<maxRating + 1, id:\.self) {number in
                        starImage(for: number)
                            .font(.system(size: 20))
                            .foregroundColor(.yellow)
                            .onTapGesture {
                                ratingValue = number
                            }
                    }
                    
                } // hstack
                
                Divider()
                
                VStack {
                    // TextEditor와 Placeholder Text를 overlay로 겹쳐서 표시
                    ZStack(alignment: .topLeading) {
                        // TextEditor 영역
                        TextEditor(text: $messageBody)
                            .font(.system(size: 16))
                            .fontWeight(.light)
                            .lineSpacing(5)
                            .scrollContentBackground(.hidden)
                            .frame(maxWidth: .infinity, minHeight: 200)
                        
                        // Placeholder Text
                        if messageBody.isEmpty {
                            Text(lang.localized("placeholder_feedback"))
                                .font(.system(size: 16))
                                .fontWeight(.light)
                                .foregroundColor(.gray)
                                .lineSpacing(5)
                                .alignmentGuide(.top) { d in
                                    d[.top] - 10 // TextEditor와 겹치도록 설정
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 8)
                        }
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 200)
                
                Button(action: {
                    self.isShowingMailView.toggle()
                }, label: {
                    Text(lang.localized("send_feedback"))
                        .font(.system(size: 16))
                })
            }
            .padding(20)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color("LightGrayColor"), lineWidth: 0.5)
            )
            
        }
        .padding(.vertical, 30)
        .sheet(isPresented: $isShowingMailView) {
            self.mailView
        }
        .onAppear (perform : UIApplication.shared.hideKeyboard)
        
        .alert(isPresented: $showAlert) {
            Alert(title: Text(lang.localized("feedback")), message: Text(alertMessage), dismissButton: .default(Text(lang.localized("confirm"))))
        }
    }
    
    func starImage(for number: Int) -> Image {
        if number > ratingValue {
            return offImage ?? onImage
        } else {
            return onImage
        }
    }
    
    private var mailView: some View {
        MailComposeViewControllerWrapper(
            recipient: .constant("julia8024@naver.com"),
            subject: .constant(lang.localized("mail_subject")),
            messageBody: .constant(
                String(format: lang.localized("mail_content"), ratingValue, messageBody)
            ),
            result: self.$result,
            showAlert: self.$showAlert,
            alertMessage: self.$alertMessage
        )
    }
}


struct MailComposeViewControllerWrapper: UIViewControllerRepresentable {
    @Binding var recipient: String
    @Binding var subject: String
    @Binding var messageBody: String
    @Binding var result: Result<MFMailComposeResult, Error>?
    @Binding var showAlert: Bool
    @Binding var alertMessage: String
    
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let mailComposer = MFMailComposeViewController()
        mailComposer.setToRecipients([recipient])
        mailComposer.setSubject(subject)
        mailComposer.setMessageBody(messageBody, isHTML: false)
        mailComposer.mailComposeDelegate = context.coordinator
        return mailComposer
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {
        // Update the view controller with the latest bindings
        uiViewController.setToRecipients([recipient])
        uiViewController.setSubject(subject)
        uiViewController.setMessageBody(messageBody, isHTML: false)
        
        // Handle result if it's set
        if let result = result {
            switch result {
            case .success(let result):
                handleMailResult(result)
            case .failure(let error):
                handleMailError(error)
            }
            self.result = nil // Reset result after handling
        }
    }
    
    func handleMailResult(_ result: MFMailComposeResult) {
        let lang = LanguageManager.shared
        
        switch result {
        case .cancelled:
            showAlertWithMessage(lang.localized("cancelled_sending_mail"))
        case .saved:
            showAlertWithMessage(lang.localized("saved_mail"))
        case .sent:
            showAlertWithMessage(lang.localized("sent_mail"))
        case .failed:
            showAlertWithMessage(lang.localized("failed_sending_mail"))
        @unknown default:
            showAlertWithMessage(lang.localized("alert_mail_default"))
        }
    }
    
    func handleMailError(_ error: Error) {
        showAlertWithMessage("Error: \(error.localizedDescription)")
    }
    
    func showAlertWithMessage(_ message: String) {
        alertMessage = message
        showAlert = true
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        var parent: MailComposeViewControllerWrapper
        
        init(parent: MailComposeViewControllerWrapper) {
            self.parent = parent
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            if let error = error {
                parent.handleMailError(error)
            } else {
                parent.handleMailResult(result)
            }
            controller.dismiss(animated: true)
        }
    }
}
