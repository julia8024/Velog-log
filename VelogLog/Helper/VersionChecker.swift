//
//  VersionChecker.swift
//  VelogLog
//
//  Created by 장세희 on 10/31/24.
//
import SwiftUI

class VersionChecker: ObservableObject {
    static let shared = VersionChecker()
    
    @Published var showAlert = false
    private let appStoreURL = "https://apps.apple.com/app/id6578457334"
    
    func checkForVersionUpdate() {
        guard let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else { return }
        let savedVersion = (UserDefaults.standard.string(forKey: "currentVersion") ?? "1.0")
        
        if savedVersion != currentVersion {
            DispatchQueue.main.async {
                self.showAlert = true
            }
        }
        
        UserDefaults.standard.set(currentVersion, forKey: "currentVersion")
    }
    
    // 외부에서 접근할 수 있는 메서드
    func getAppStoreURL() -> URL? {
        return URL(string: appStoreURL)
    }
}
