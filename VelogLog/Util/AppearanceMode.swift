//
//  AppearanceMode.swift
//  VelogLog
//
//  Created by 장세희 on 11/23/25.
//


import SwiftUI

enum AppearanceMode: String, CaseIterable, Identifiable, Codable {
    case system, light, dark

    var id: String { rawValue }

    var title: String {
        switch self {
        case .system: return "시스템"
        case .light:  return "라이트"
        case .dark:   return "다크"
        }
    }

    /// .preferredColorScheme 에 넣을 값 (system 은 nil)
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light:  return .light
        case .dark:   return .dark
        }
    }
}
