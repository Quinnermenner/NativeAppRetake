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
import SafariServices

class MCViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: Initializers
    var repo: Repo!
    var user: User!
    var userRef: FIRDatabaseReference!
    var commitRef: FIRDatabaseReference!
    var messageRef: FIRDatabaseReference!
    var commits = [Commit]()
    var messages = [Message]()
    var tableCellList = [MessageCommitProtocol]()
   
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        messageTextField.delegate = self
        
        self.title = repo.name
        
        commitRef = repo.ref?.child("commits")
        messageRef = repo.ref?.child("messages")
        
        updateCommits()
        
        commitRef.observe(.value, with: { snapshot in
            var commitList: [Commit] = []
            for item in snapshot.children {
                let commit = Commit(snapshot: item as! FIRDataSnapshot)
                commitList.append(commit)
            }
            self.commits = commitList
            self.constructTableViewCells(commitList: self.commits, messageList: self.messages)
        })
        
        messageRef.observe(.value, with: { (snapshot) in
            var messageList : [Message] = []
            for item in snapshot.children {
                let message = Message.init(snapshot: item as! FIRDataSnapshot)
                messageList.append(message)
            }
            self.messages = messageList
            self.constructTableViewCells(commitList: self.commits, messageList: self.messages)
        })
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(MCViewController.hideKeyboard))
        tapGesture.cancelsTouchesInView = true
        tableView.addGestureRecognizer(tapGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(MCViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(MCViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 60
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    // MARK: Functions
    func gitCommit(owner: String, repoName: String) -> JSON {
        
        let url = URL(string: "https://api.github.com/repos/\(owner)/\(repoName)/commits")!
        let data = try? Data(contentsOf: url)
        let json = JSON(data: data!)
        
        return json
    }
    
    func constructTableViewCells(commitList: [Commit], messageList: [Message]) {
        
        tableCellList = [MessageCommitProtocol]()
        for commit in commitList {
            tableCellList.append(commit)
        }
        for message in messageList {
            tableCellList.append(message)
        }
        self.tableCellList = tableCellList.sorted(by: {$0.date < $1.date})
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.scrollToLastRow()
        }
        
        
    }
    
    func scrollToLastRow() {
        let indexPath = NSIndexPath(row: self.tableCellList.count - 1, section: 0)
            
        self.tableView.scrollToRow(at: indexPath as IndexPath, at: .bottom, animated: true)
    }
    
    func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    func updateCommits() {
        let commitJsons = gitCommit(owner: repo.owner, repoName: repo.name)
        for (_, subJson):(String, JSON) in commitJsons {
            let author = subJson["commit"]["committer"]["name"].stringValue
            let date = subJson["commit"]["committer"]["date"].stringValue
            let message = subJson["commit"]["message"].stringValue
            let sha = subJson["sha"].stringValue
            
            let commit = Commit(author: author, message: message, sha: sha, date: date)
            self.commitRef.child(sha).observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.exists() == false {
                    self.commitRef.updateChildValues([sha : commit.toAnyObject()])
                }
            })
        }
    }
    
    func saveMessage(text: String, date: String, uid: String) {

        userRef.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let postCount = value?["PostCount"] as? Int ?? 0
            let userName = value?["Nickname"] as? String ?? ""
            let messageUID = self.user.uid + "-" + String(describing: postCount)
            let message = Message.init(author: userName, text: text, date: date)
            
//            self.messageRef?.updateChildValues([messageUID : message.toAnyObject()])
            let uniqueMessageRef = self.messageRef?.child(messageUID)
            uniqueMessageRef?.setValue(message.toAnyObject())
            self.userRef.updateChildValues(["PostCount" : postCount + 1])
            self.userRef.child("messages").child(messageUID).setValue(uniqueMessageRef?.url)
            self.messageTextField.text = ""
            self.messageTextField.resignFirstResponder()
        })

        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.postMessage()
        return true
    }

    @IBAction func postButtonDidTouch(_ sender: Any) {
        
        self.postMessage()
    }
    
    func postMessage() {
        
        let stringFromDate = Date().iso8601    // "2017-03-22T13:22:13.933Z"
        let messageText = messageTextField.text!
        
        if messageText != "" {
            saveMessage(text: messageText, date: stringFromDate, uid: user.uid)
        }
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.bottomConstraint.constant < keyboardSize.height{
                UIView.animate(withDuration: 1, animations: {
                    self.bottomConstraint.constant += keyboardSize.height
                    self.view.layoutIfNeeded()
                    self.scrollToLastRow()
                })
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.bottomConstraint.constant >= keyboardSize.height {
                UIView.animate(withDuration: 0.5, animations: {
                    self.bottomConstraint.constant -= keyboardSize.height
                    self.view.layoutIfNeeded()
                })
            }
        }
    }
    
    func showCommit(_ index: Int) {
        
        let commit = self.tableCellList[index] as! Commit
        let sha = commit.sha
        let owner = repo.owner
        let name = repo.name
        if let url = URL(string: "https://github.com/\(owner)/\(name)/commit/\(sha)") {
            let vc = SFSafariViewController(url: url, entersReaderIfAvailable: true)
            present(vc, animated: true)
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
        return tableCellList.count
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if tableCellList[indexPath.row] is Commit {
            return true
        } else {
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?
    {
        let inspect = UITableViewRowAction(style: .normal, title: "Inspect Commit") { (action, indexPath) in
            tableView.isEditing = false
            self.showCommit(indexPath.row)
            
        }
        inspect.backgroundColor = UIColor.gray
        
        
        return [inspect]
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if let commit = tableCellList[indexPath.row] as? Commit {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommitCell", for: indexPath) as! CommitCell
            
            cell.name.text = commit.author
            cell.comment.text = commit.message
            
            return cell
        }
            
        else if let message = tableCellList[indexPath.row] as? Message {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as! MessageCell
            
            cell.name.text = message.author
            cell.comment.text = message.text
            
            return cell
        }
        
        else {
            
            let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "ErrorCell")
            return cell
        
        }
        
        
    }
    
}
