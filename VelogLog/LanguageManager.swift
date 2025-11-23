//
//  LanguageManager.swift
//  VelogLog
//
//  Created by 장세희 on 11/23/25.
//

import Foundation

class LanguageManager: ObservableObject {
    @Published var current: AppLanguage = .korean {
        didSet { UserDefaults.standard.set(current.rawValue, forKey: "appLanguage") }
    }

    init() {
        if let saved = UserDefaults.standard.string(forKey: "appLanguage"),
           let lang = AppLanguage(rawValue: saved) {
            current = lang
        }
    }

    func localized(_ key: String) -> String {
        let path = Bundle.main.path(forResource: current.rawValue, ofType: "lproj")!
        let bundle = Bundle(path: path)!
        return NSLocalizedString(key, bundle: bundle, comment: "")
    }
}
