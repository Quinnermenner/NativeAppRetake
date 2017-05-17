//
//  User.swift
//  Quintenvanderpost-pset6
//
//  Created by Quinten van der Post on 12/12/2016.
//  Copyright © 2016 Quinten van der Post. All rights reserved.
//

import Foundation
import Firebase

struct User {
    
    let uid: String
    let email: String
    
    init(authData: FIRUser) {
        uid = authData.uid
        email = authData.email!
    }
    
    init(uid: String, email: String) {
        self.uid = uid
        self.email = email
    }
    
    init(coder: NSCoder) {
        
        email = coder.decodeObject(forKey: "userEmail") as! String
        uid = coder.decodeObject(forKey: "userUID") as! String
    }
    
    func encodeUser(coder: NSCoder) {
        
        coder.encode(uid, forKey: "userUID")
        coder.encode(email, forKey: "userEmail")
    }
    
}
