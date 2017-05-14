//
//  Message.swift
//  Quintenvanderpost-pset6
//
//  Created by Quinten on 13/05/2017.
//  Copyright © 2017 Quinten van der Post. All rights reserved.
//

import Foundation
import Firebase

struct Message: MessageCommitProtocol {
    
    let text: String
    let date: String
    let author: String
    let key: String
    
    init(author: String, text: String, date: String, key: String = "") {
        self.author = author
        self.text = text
        self.date = date
        self.key = key
    }
    
    init(snapshot: FIRDataSnapshot) {
        key = snapshot.key
        let snapshotValue = snapshot.value as! [String: AnyObject]
        author = snapshotValue["author"] as! String
        text = snapshotValue["text"] as! String
        date = snapshotValue["date"] as! String
    }
    
    func toAnyObject() -> Any {
        
        print(author, text, date)
        return [
            "author" : author,
            "text" : text,
            "date" : date
        ]
    }
}
