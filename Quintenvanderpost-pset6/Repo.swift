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
    var ref: FIRDatabaseReference?
    let url: String
    let updateDate: String
    let description: String
    let id: Int
    
    init(name: String, description: String, owner: String, url: String, updateDate: String, key: String = "", id: Int) {
        self.name = name
        self.owner = owner
        self.url = url
        self.updateDate = updateDate
        self.ref = nil
        self.key = key
        self.description = description
        self.id = id
    }
    
    init(snapshot: FIRDataSnapshot) {
        key = snapshot.key
        let snapshotValue = snapshot.value as! [String: AnyObject]
        name = snapshotValue["name"] as! String
        owner = snapshotValue["owner"] as! String
        updateDate = snapshotValue["updateDate"] as! String
        url = snapshotValue["url"] as! String
        description = snapshotValue["description"] as! String
        id = snapshotValue["id"] as! Int
        ref = snapshot.ref
    }
    
    mutating func setRef(refURL: String) {
        
        self.ref = FIRDatabase.database().reference(fromURL: refURL)
    }
    
    func encodeRepo(coder: NSCoder) {
        
        coder.encode(self.key, forKey:"repoKey")
        coder.encode(self.name, forKey:"repoName")
        coder.encode(self.owner, forKey:"repoOwner")
        coder.encode(self.ref?.url, forKey: "repoRef")
        coder.encode(self.url, forKey:"repoURL")
        coder.encode(self.updateDate, forKey:"repoUpdateDate")
        coder.encode(self.description, forKey: "repoDescription")
        coder.encode(String(describing: self.id), forKey: "repoID")
        
    }
    
    init(coder: NSCoder) {
        
        key = coder.decodeObject(forKey: "repoKey") as! String
        name = coder.decodeObject(forKey: "repoName") as! String
        owner = coder.decodeObject(forKey: "repoOwner") as! String
        if let saveRepoRefUrl = coder.decodeObject(forKey: "repoRef") as? String {
            ref = FIRDatabase.database().reference(fromURL: saveRepoRefUrl)
        }
        url = coder.decodeObject(forKey: "repoURL") as! String
        updateDate = coder.decodeObject(forKey: "repoUpdateDate") as! String
        description = coder.decodeObject(forKey: "repoDescription") as! String
        id = Int(coder.decodeObject(forKey: "repoID") as! String)!
        
    }
    
    func toAnyObject() -> Any {
        
        return [
            "name" : name,
            "owner" : owner,
            "url" : url,
            "updateDate" : updateDate,
            "description" : description,
            "id" : id
        ]
    }
    
}
