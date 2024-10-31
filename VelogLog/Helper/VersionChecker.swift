//
//  VersionChecker.swift
//  VelogLog
//
//  Created by 장세희 on 10/31/24.
//
import SwiftUI
import UIKit

class VersionChecker {
    static let shared = VersionChecker()
    
//    private let currentVersion = "1.1"
    private let appStoreURL = "https://apps.apple.com/app/id6578457334"
    
    // 현재 버전 확인 및 업데이트 알림 처리
    func checkForVersionUpdate() {
        // 현재 앱 버전 가져오기
        guard let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else { return }
        
        // 이전에 저장된 버전 가져오기
        let savedVersion = UserDefaults.standard.string(forKey: currentVersion)
        
        // 저장된 버전과 현재 버전을 비교하여 업데이트 알림 띄우기
        if let savedVersion = savedVersion, savedVersion != currentVersion {
            DispatchQueue.main.async {
                self.showAlertForUpdate()
            }
        }
        
        // 현재 버전을 UserDefaults에 저장
        UserDefaultsManager.updateVersion(currentVersion)
    }
    
    // SwiftUI에서 사용할 수 있도록 업데이트 알림 표시
    private func showAlertForUpdate() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            return
        }
        
        let alert = UIAlertController(title: "앱 업데이트 안내",
                                      message: "새로운 버전으로 업데이트되었습니다. 새로운 기능을 확인해보세요!",
                                      preferredStyle: .alert)
        
        // 나중에 버튼 (취소)
        alert.addAction(UIAlertAction(title: "나중에", style: .cancel, handler: nil))
        
        // 업데이트 버튼 (앱스토어 이동)
        alert.addAction(UIAlertAction(title: "업데이트", style: .default, handler: { _ in
            // 앱스토어로 이동
            if let url = URL(string: self.appStoreURL) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }))
        
        rootViewController.present(alert, animated: true, completion: nil)
    }
}
