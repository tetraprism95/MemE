//
//  Comment.swift
//  Memer
//
//  Created by Nuri Chun on 7/19/18.
//  Copyright © 2018 tetra. All rights reserved.
//

import Foundation

struct Comment { 
    
    let user: User
    let uid: String
    let text: String
    
    init(user: User, dictionary: [String : Any]) {
        self.user = user
        self.text = dictionary["text"] as? String ?? ""
        self.uid = dictionary["uid"] as? String ?? ""
    }
}
