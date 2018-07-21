//
//  Database.swift
//  Memer
//
//  Created by Nuri Chun on 6/22/18.
//  Copyright © 2018 tetra. All rights reserved.
//

import Firebase

extension Database {
    
    static func fetchUser(withUID uid: String, completion: @escaping (User) -> ()) {
        
        Database.database().reference().child("users").child(uid).observe(.value, with: { (snapshot) in
    
            guard let userDictionary = snapshot.value as? [String : Any] else { return }
            let user = User(uid: uid, dictionary: userDictionary)
            
            completion(user)
            
        }) { (error) in
            print("Could not Fetch User Data", error) 
        }
    }
    
    static func create(for post: Post, success: @escaping (Bool) -> Void) {
        
    }
}


