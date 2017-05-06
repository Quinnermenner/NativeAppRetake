//
//  Commit.swift
//  Quintenvanderpost-pset6
//
//  Created by Quinten van der Post on 14/12/2016.
//  Copyright © 2016 Quinten van der Post. All rights reserved.
//

import Foundation
import Firebase

struct Commit {
    let key: String
    let author: String
    let ref: FIRDatabaseReference?
    let date: String
    let message: String
    let sha: String
    
    init(author: String, message: String, sha: String, date: String, key: String = "") {
        self.author = author
        self.message = message
        self.sha = sha
        self.date = date
        self.ref = nil
        self.key = key
    }
    
    init(snapshot: FIRDataSnapshot) {
        key = snapshot.key
        let snapshotValue = snapshot.value as! [String: AnyObject]
        author = snapshotValue["author"] as! String
        message = snapshotValue["message"] as! String
        date = snapshotValue["date"] as! String
        sha = snapshotValue["sha"] as! String
        ref = snapshot.ref
    }
    
    func toAnyObject() -> Any {
        
        return [
            "author" : author,
            "message" : message,
            "sha" : sha,
            "date" : date
        ]
    }
    
}
