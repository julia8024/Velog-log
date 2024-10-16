//
//  UserDefaultManager.swift
//  VelogLog
//
//  Created by 장세희 on 6/29/24.
//

import Foundation

class UserDefaultsManager {
    enum UserDefaultsKeys: String, CaseIterable {
        case userId
        case userIdList
    }
    
    static func setData<T>(value: T, key: UserDefaultsKeys) {
        let defaults = UserDefaults.standard
        defaults.set(value, forKey: key.rawValue)
    }
    
    static func getData<T>(type: T.Type, forKey: UserDefaultsKeys) -> T? {
        let defaults = UserDefaults.standard
        let value = defaults.object(forKey: forKey.rawValue) as? T
        return value
    }
    
    static func removeData(key: UserDefaultsKeys) {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: key.rawValue)
    }
    
    // userIdList에 userId 추가
    static func addUserId(_ userId: String) {
        guard !userId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return  // 빈 문자열이면 저장하지 않고 반환
        }
        
        var userIdList = getUserIdList()
        if !userIdList.contains(userId) {
            userIdList.append(userId)
            setData(value: userIdList, key: .userIdList)
        }
    }
    
    // userIdList에서 userId 제거
    static func removeUserId(_ userId: String) {
        var userIdList = getUserIdList()
        userIdList.removeAll { $0 == userId }
        setData(value: userIdList, key: .userIdList)
    }
    
    // 전체 userIdList 가져오기
    static func getUserIdList() -> [String] {
        return getData(type: [String].self, forKey: .userIdList) ?? []
    }
}
