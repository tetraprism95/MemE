//
//  Post.swift
//  Memer
//
//  Created by Nuri Chun on 6/16/18.
//  Copyright © 2018 tetra. All rights reserved.
//

import Foundation


struct Post {
    
    var id: String?
    var hasLiked: Bool = false
    var likeCount: Int
    
    let user: User
    let memeCaption: String?
    let memeDescription: String?
    let creationDate: Date
    let imageURL: String
    
    init(user: User, dictionary: [String : Any]) {
        
        self.user = user
        self.memeCaption = dictionary["memeCaption"] as? String ?? ""
        self.memeDescription = dictionary["memeDescription"] as? String ?? ""
        self.imageURL = dictionary["imagePostUrl"] as? String ?? ""
        
        let likeCount = dictionary["likeCount"] as? Int ?? 0
        self.likeCount = likeCount
        
        let secondsSince1970 = dictionary["creationDate"] as? Double ?? 0
        self.creationDate = Date(timeIntervalSince1970: secondsSince1970)
        
    }
}
