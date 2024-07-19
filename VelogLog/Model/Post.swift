//
//  Post.swift
//  VelogLog
//
//  Created by 장세희 on 6/23/24.
//

import Foundation

struct Post: Decodable, Identifiable {
    var id: String
    var title: String
    var short_description: String
//    var thumbnail: String
    var user: User
    var url_slug: String
    var released_at: String
    var updated_at: String
    var comments_count: Int
    var tags: [String]
    var is_private: Bool
    var likes: Int
    var __typename: String
    

    init() {
        id = ""
        title = ""
        short_description = ""
//        thumbnail = ""
        user = User(id: "", username: "", profile: Profile(id: "", thumbnail: "", __typename: ""), __typename: "")
        url_slug = ""
        released_at = ""
        updated_at = ""
        comments_count = 0
        tags = [""]
        is_private = false
        likes = 0
        __typename = ""
        
        
        
    }
}

struct User: Decodable, Identifiable {
    var id: String
    var username: String
    var profile: Profile
    var __typename: String
    
    init(id: String, username: String, profile: Profile, __typename: String) {
        self.id = id
        self.username = username
        self.profile = profile
        self.__typename = __typename
    }
}

struct Profile: Decodable, Identifiable {
    var id: String
    var thumbnail: String
    var display_name: String
    var short_bio: String
    var __typename: String
    
    init(id: String, thumbnail: String, __typename: String) {
        self.id = id
        self.display_name = ""
        self.short_bio = ""
        self.thumbnail = thumbnail
        self.__typename = __typename
    }
    
    init(id: String, display_name: String, short_bio: String, thumbnail: String, __typename: String) {
        self.id = id
        self.display_name = display_name
        self.short_bio = short_bio
        self.thumbnail = thumbnail
        self.__typename = __typename
    }
}
