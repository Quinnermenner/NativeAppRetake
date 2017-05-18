//
//  Commit.swift
//  Quintenvanderpost-pset6
//
//  Created by Quinten van der Post on 14/12/2016.
//  Copyright © 2016 Quinten van der Post. All rights reserved.
//

import Foundation
import Firebase

class Commit: NSObject, MessageCommitProtocol, NSCoding {
    let key: String
    let author: String
    let ref: FIRDatabaseReference?
    let date: String
    let message: String
    let sha: String
    
    override public var description: String {return self.message}
    
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
    
    required convenience init(coder: NSCoder) {
        
        let author = coder.decodeObject(forKey: "author") as? String ?? ""
        let message = coder.decodeObject(forKey: "message") as? String ?? ""
        let date = coder.decodeObject(forKey: "date") as? String ?? ""
        let sha = coder.decodeObject(forKey: "sha") as? String ?? ""
        let key = coder.decodeObject(forKey: "key") as? String ?? ""
        
        
        self.init(author: author, message: message, sha: sha, date: date, key: key)
    }
    
    func toAnyObject() -> Any {
        
        return [
            "author" : author,
            "message" : message,
            "sha" : sha,
            "date" : date
        ]
    }
    
    func encode(with aCoder: NSCoder) {
        
        aCoder.encode(author, forKey: "author")
        aCoder.encode(message, forKey: "message")
        aCoder.encode(sha, forKey: "sha")
        aCoder.encode(date, forKey: "date")
        aCoder.encode(key, forKey: "key")
    }
    
}
