//
//  CustomWKWebView.swift
//  VelogLog
//
//  Created by 장세희 on 6/30/24.
//

import SwiftUI
import WebKit

struct CustomWKWebView: UIViewRepresentable {
    var url: String
    
    func makeUIView(context: Context) -> WKWebView {
        guard let url = URL(string: url) else {
            return WKWebView()
        }
        let webView = WKWebView()

        webView.load(URLRequest(url: url))
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: UIViewRepresentableContext<CustomWKWebView>) {
        guard let url = URL(string: url) else { return }
        
        webView.load(URLRequest(url: url))
    }
}
