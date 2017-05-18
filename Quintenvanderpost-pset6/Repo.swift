//
//  Repo.swift
//  Quintenvanderpost-pset6
//
//  Created by Quinten van der Post on 11/12/2016.
//  Copyright © 2016 Quinten van der Post. All rights reserved.
//

import Foundation
import Firebase

class Repo: NSObject, NSCoding{
    
    let key: String
    let name: String
    let owner: String
    var ref: FIRDatabaseReference?
    let url: String
    let updateDate: String
    let repoDescription: String
    let id: Int
    
    init(name: String, repoDescription: String, owner: String, url: String, updateDate: String, key: String = "", id: Int) {
        self.name = name
        self.owner = owner
        self.url = url
        self.updateDate = updateDate
        self.ref = nil
        self.key = key
        self.repoDescription = repoDescription
        self.id = id
    }
    
    init(snapshot: FIRDataSnapshot) {
        key = snapshot.key
        let snapshotValue = snapshot.value as! [String: AnyObject]
        name = snapshotValue["name"] as! String
        owner = snapshotValue["owner"] as! String
        updateDate = snapshotValue["updateDate"] as! String
        url = snapshotValue["url"] as! String
        repoDescription = snapshotValue["description"] as! String
        id = snapshotValue["id"] as! Int
        ref = snapshot.ref
    }
    
    func setRef(refURL: String) {
        
        self.ref = FIRDatabase.database().reference(fromURL: refURL)
    }
    
    func encode(with coder: NSCoder) {
        
        coder.encode(self.key, forKey:"repoKey")
        coder.encode(self.name, forKey:"repoName")
        coder.encode(self.owner, forKey:"repoOwner")
        coder.encode(self.ref?.url, forKey: "repoRef")
        coder.encode(self.url, forKey:"repoURL")
        coder.encode(self.updateDate, forKey:"repoUpdateDate")
        coder.encode(self.repoDescription, forKey: "repoDescription")
        coder.encode(String(describing: self.id), forKey: "repoID")
        
    }
    
    required convenience init?(coder: NSCoder) {
        
        guard let key = coder.decodeObject(forKey: "repoKey") as? String,
        let name = coder.decodeObject(forKey: "repoName") as? String,
        let owner = coder.decodeObject(forKey: "repoOwner") as? String,
        let url = coder.decodeObject(forKey: "repoURL") as? String,
        let updateDate = coder.decodeObject(forKey: "repoUpdateDate") as? String,
        let repoDescription = coder.decodeObject(forKey: "repoDescription") as? String,
        let id = coder.decodeObject(forKey: "repoID") as? String
            else { return nil }

        self.init(name: name, repoDescription: repoDescription, owner: owner, url: url, updateDate: updateDate, key: key, id: Int(id)!)
        if let saveRepoRefUrl = coder.decodeObject(forKey: "repoRef") as? String {
            self.setRef(refURL: saveRepoRefUrl)
        }
        
    }
    
    func toAnyObject() -> Any {
        
        return [
            "name" : name,
            "owner" : owner,
            "url" : url,
            "updateDate" : updateDate,
            "description" : repoDescription,
            "id" : id
        ]
    }
    
}
