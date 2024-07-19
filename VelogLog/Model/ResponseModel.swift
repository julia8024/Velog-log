//
//  ResponseModel.swift
//  VelogLog
//
//  Created by 장세희 on 7/19/24.
//

import Foundation

struct UserResponse: Decodable {
    var data: DataWrapper
    
    struct DataWrapper: Decodable {
        var user: User
    }
}

struct PostListResponse: Decodable {
    var data: DataWrapper
    
    struct DataWrapper: Decodable {
        var posts: [Post]
    }
}
