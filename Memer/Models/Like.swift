//
//  Like.swift
//  Memer
//
//  Created by Nuri Chun on 7/20/18.
//  Copyright © 2018 tetra. All rights reserved.
//

import Foundation

class Like {
    
    let user: User
    var hasLiked: Bool = false
    
    init(user: User, dictionary: [String : Any]) {
        self.user = user
    }
}
