//
//  CommitController.swift
//  Quintenvanderpost-pset6
//
//  Created by Quinten van der Post on 13/12/2016.
//  Copyright © 2016 Quinten van der Post. All rights reserved.
//

import UIKit
import Firebase
import SwiftyJSON

class CommitController: UITableViewController {
    
    // MARK: Initializers
    var repo: Repo!
    var commitRef: FIRDatabaseReference!
    var commits: [Commit] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        commitRef = repo.ref?.child("commits")
        updateCommits()
        commitRef.observe(.value, with: { snapshot in
            var commitList: [Commit] = []
            for item in snapshot.children {
                let commit = Commit(snapshot: item as! FIRDataSnapshot)
                commitList.append(commit)
            }
            self.commits = commitList
            self.tableView.reloadData()
        })
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 60
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Functions
    func gitCommit(owner: String, repoName: String) -> JSON {
        
        let url = URL(string: "https://api.github.com/repos/\(owner)/\(repoName)/commits?q=\(title)")!
        let data = try? Data(contentsOf: url)
        let json = JSON(data: data!)
        
        return json
    }
    
    func updateCommits() {
        let commitJsons = gitCommit(owner: repo.owner, repoName: repo.name)
        for (index, subJson):(String, JSON) in commitJsons {
            let author = subJson["commit"]["committer"]["name"].stringValue
            let date = subJson["commit"]["committer"]["date"].stringValue
            let message = subJson["commit"]["message"].stringValue
            let sha = subJson["sha"].stringValue
            
            let commit = Commit(author: author, message: message, sha: sha, date: date)
            commitRef.child(sha).setValue(commit.toAnyObject())
        }
    }
    
    
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commits.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommitCell", for: indexPath) as! CommitCell

        let commit = commits[indexPath.row]
        
        cell.name.text = commit.author
        cell.comment.text = commit.message
        
        return cell
    }
 

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */


}
