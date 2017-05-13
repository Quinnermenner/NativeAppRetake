//
//  MCViewController.swift
//  Quintenvanderpost-pset6
//
//  Created by Quinten on 13/05/2017.
//  Copyright © 2017 Quinten van der Post. All rights reserved.
//

import UIKit
import Firebase
import SwiftyJSON

class MCViewController: UIViewController {
    
    // MARK: Initializers
    var repo: Repo!
    var commitRef: FIRDatabaseReference!
    var commits: [Commit] = []
    var sortedCommits: [Commit] = []
   
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
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
            self.sortedCommits = self.commits.sorted(by: {$0.date < $1.date})
        })
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 60
    }
    
    // MARK: Functions
    func gitCommit(owner: String, repoName: String) -> JSON {
        
        let url = URL(string: "https://api.github.com/repos/\(owner)/\(repoName)/commits")!
        let data = try? Data(contentsOf: url)
        let json = JSON(data: data!)
        
        return json
    }
    
    func updateCommits() {
        let commitJsons = gitCommit(owner: repo.owner, repoName: repo.name)
        for (_, subJson):(String, JSON) in commitJsons {
            let author = subJson["commit"]["committer"]["name"].stringValue
            let date = subJson["commit"]["committer"]["date"].stringValue
            let message = subJson["commit"]["message"].stringValue
            let sha = subJson["sha"].stringValue
            
            let commit = Commit(author: author, message: message, sha: sha, date: date)
            commitRef.child(sha).setValue(commit.toAnyObject())
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension MCViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commits.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommitCell", for: indexPath) as! CommitCell
        let commit = sortedCommits[indexPath.row]
        
        cell.name.text = commit.author
        cell.comment.text = commit.message
        
        return cell
    }
    
}
