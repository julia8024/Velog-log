//
//  AppLanguage.swift
//  VelogLog
//
//  Created by 장세희 on 11/23/25.
//

enum AppLanguage: String, CaseIterable {
    case korean = "ko"
    case english = "en"
    
    var displayName: String {
        switch self {
        case .korean: return "한국어"
        case .english: return "English"
        }
    }
}
