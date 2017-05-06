//
//  Repo.swift
//  Quintenvanderpost-pset6
//
//  Created by Quinten van der Post on 11/12/2016.
//  Copyright © 2016 Quinten van der Post. All rights reserved.
//

import Foundation
import Firebase

struct Repo {
    
    let key: String
    let name: String
    let owner: String
    let ref: FIRDatabaseReference?
    let url: String
    let updateDate: String
    let description: String
    
    init(name: String, description: String, owner: String, url: String, updateDate: String, key: String = "") {
        self.name = name
        self.owner = owner
        self.url = url
        self.updateDate = updateDate
        self.ref = nil
        self.key = key
        self.description = description
    }
    
    init(snapshot: FIRDataSnapshot) {
        key = snapshot.key
        let snapshotValue = snapshot.value as! [String: AnyObject]
        name = snapshotValue["name"] as! String
        owner = snapshotValue["owner"] as! String
        updateDate = snapshotValue["updateDate"] as! String
        url = snapshotValue["url"] as! String
        description = snapshotValue["description"] as! String
        ref = snapshot.ref
    }
    
    func toAnyObject() -> Any {
        
        return [
            "name" : name,
            "owner" : owner,
            "url" : url,
            "updateDate" : updateDate,
            "description" : description
        ]
    }
    
}
