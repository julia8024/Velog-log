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
}
