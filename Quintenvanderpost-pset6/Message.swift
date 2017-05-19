//
//  Message.swift
//  Quintenvanderpost-pset6
//
//  Created by Quinten on 13/05/2017.
//  Copyright © 2017 Quinten van der Post. All rights reserved.
//

import Foundation
import Firebase

// A message class that contains information for the messages in the database and tableViews.
class Message: NSObject, MessageCommitProtocol, NSCoding {
    
    let text: String
    let date: String
    let author: String
    let key: String
    
    override public var description: String {return self.text}

    
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
    
    required convenience init(coder: NSCoder) {
        
        let author = coder.decodeObject(forKey: "author") as! String
        let text = coder.decodeObject(forKey: "text") as! String
        let date = coder.decodeObject(forKey: "date") as! String
        let key = coder.decodeObject(forKey: "key") as! String
        
        self.init(author: author, text: text, date: date, key: key)
    }
    
    func toAnyObject() -> Any {
        
        print(author, text, date)
        return [
            "author" : author,
            "text" : text,
            "date" : date
        ]
    }
    
    func encode(with aCoder: NSCoder) {
        
        aCoder.encode(author, forKey: "author")
        aCoder.encode(text, forKey: "text")
        aCoder.encode(date, forKey: "date")
        aCoder.encode(key, forKey: "key")
    }
}
