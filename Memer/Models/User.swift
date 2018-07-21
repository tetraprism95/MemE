//
//  User.swift
//  Memer
//
//  Created by Nuri Chun on 6/16/18.
//  Copyright © 2018 tetra. All rights reserved.
//

import Foundation

struct User {
    
    let uid: String
    let username: String
    let fullName: String
    let profileImageURL: String
    
    
    init(uid: String, dictionary: [String : Any]) {
        self.uid = uid
        
        self.fullName = dictionary["fullName"] as? String ?? ""
        self.username = dictionary["username"] as? String ?? ""
        self.profileImageURL = dictionary["profileImageURL"] as? String ?? "" 
    }
}
