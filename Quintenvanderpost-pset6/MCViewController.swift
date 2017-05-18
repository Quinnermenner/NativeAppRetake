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
import DZNEmptyDataSet

class MCViewController: UIViewController, UITextFieldDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    // Mark: Constants
    let network = reachabilityTest.sharedInstance
    
    // MARK: Initializers
    var repo: Repo?
    var user: User?
    var userRef: FIRDatabaseReference?
    var commitRef: FIRDatabaseReference?
    var messageRef: FIRDatabaseReference?
    var commits = [Commit]()
    var messages = [Message]()
    var tableCellList = [MessageCommitProtocol]()
    var searchingCommit = true
   
    
    // MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set delegates
        tableView.dataSource = self
        tableView.delegate = self
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        messageTextField.delegate = self
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        
        self.title = repo?.name
        
        
        DispatchQueue.main.async {
            self.prepareTableView()
        }
        
        // Tapgesture to dismiss keyboard when table is tapped.
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(MCViewController.hideKeyboard))
        tapGesture.cancelsTouchesInView = true
        tableView.addGestureRecognizer(tapGesture)        
        
        // Placeholder values for tableView
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 60
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Allows for constraint update when keyboard shows and hides.
        NotificationCenter.default.addObserver(self, selector: #selector(MCViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MCViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        let defaults = UserDefaults.standard
        constructTableFromDefaults(userDefault: defaults)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // Dismisses observers to preven weird messages.
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        let defaults = UserDefaults.standard
        
        saveCommitsToDefaults(userDefault: defaults)
        saveMessagesToDefaults(userDefault: defaults)
       
    }
    
    // MARK: Functions
    
    func gitCommit(owner: String?, repoName: String?) -> JSON {
        
        // Gets a list of commits from github for specified repo. Returns commits in json format.
        do {
            let url = URL(string: "https://api.github.com/repos/\(owner!)/\(repoName!)/commits")
            let data = try Data(contentsOf: url!)
            let json = JSON(data: data)
            return json
        } catch {
            return [:] as JSON
        }

    }
    
    
    // Sets up the tableView and it's listeners.
    func prepareTableView() {
        
        updateCommits()
        
        commitRef = repo?.ref?.child("commits")
        messageRef = repo?.ref?.child("messages")
        
        // Listen for new commits and update tableView when necessary.
        commitRef?.observe(.value, with: { snapshot in
            var commitList: [Commit] = []
            for item in snapshot.children {
                let commit = Commit(snapshot: item as! FIRDataSnapshot)
                commitList.append(commit)
            }
            self.commits = commitList
            
            // Either construct the tableView or update it if it already exists.
            if self.tableCellList.isEmpty {
                self.constructTableViewCells(commitList: self.commits, messageList: self.messages)
            }
            else {
                self.updateTableViewCells(commitList: self.commits, messageList: self.messages)
            }
        })
        
        // Listen for new messages and update tableView whe nnecessary.
        messageRef?.observe(.value, with: { (snapshot) in
            var messageList : [Message] = []
            for item in snapshot.children {
                let message = Message.init(snapshot: item as! FIRDataSnapshot)
                messageList.append(message)
            }
            self.messages = messageList

            // Either construct the tableView or update it if it already exists.
            if self.tableCellList.isEmpty {
                self.constructTableViewCells(commitList: self.commits, messageList: self.messages)
            }
            else {
                self.updateTableViewCells(commitList: self.commits, messageList: self.messages)
            }
        })
    }
    
    func constructTableViewCells(commitList: [Commit], messageList: [Message]) {
        
        tableCellList = [MessageCommitProtocol]()
        for commit in commitList {
            tableCellList.append(commit)
        }
        for message in messageList {
            tableCellList.append(message)
        }
        // Sort cells by creation date.
        self.tableCellList = tableCellList.sorted(by: {$0.date < $1.date})
        
        DispatchQueue.main.async {
            // Done searching and updateing commits and messages.
            self.tableView.reloadData()
            self.scrollToLastRow()
            self.searchingCommit = false
        }
        
        
    }
    
    func updateTableViewCells(commitList: [Commit], messageList: [Message]) {
        
        var tempCellList = [MessageCommitProtocol]()
        var deltaCellList = [MessageCommitProtocol]()
        
        // Fill the latest CellList
        for commit in commitList {
            tempCellList.append(commit)
        }
        for message in messageList {
            tempCellList.append(message)
        }

        // Check for differnces with current CellList
        for element in tempCellList {
            if self.tableCellList.contains(where: { $0.key == element.key }) {
                
                continue
            } else {
                deltaCellList.append(element)
            }
        }

        // If differences were found; update tableView and relevant data.
        if deltaCellList.isEmpty == false {
            deltaCellList = deltaCellList.sorted(by: {$0.date < $1.date})
            self.tableCellList.append(contentsOf: deltaCellList)

            tableView.beginUpdates()
            tableView.insertRows(at: [IndexPath(row: deltaCellList.count - 1, section: 0)], with: .automatic)
            tableView.endUpdates()
            scrollToLastRow()
            
            for element in deltaCellList {
                
                if let element = element as? Commit {
                    
                    self.commits.append(element)
                }
                else if let element = element as? Message {
                    
                    self.messages.append(element)
                }
            }
        }
    }
    
    // Focus on bottom cell.
    func scrollToLastRow() {
        
        if self.tableCellList.count > 0 {
            let indexPath = NSIndexPath(row: self.tableCellList.count - 1, section: 0)
                
            self.tableView.scrollToRow(at: indexPath as IndexPath, at: .bottom, animated: true)
        }
    }
    
    func hideKeyboard() {
        
        self.view.endEditing(true)
    }

    // Gets the commits and updates the database with new commits.
    func updateCommits() {
        
        if network.test() {
            let commitJsons = gitCommit(owner: repo?.owner, repoName: repo?.name)
            for (_, subJson):(String, JSON) in commitJsons {
                let author = subJson["commit"]["committer"]["name"].stringValue
                let date = subJson["commit"]["committer"]["date"].stringValue
                let message = subJson["commit"]["message"].stringValue
                let sha = subJson["sha"].stringValue
                
                let commit = Commit(author: author, message: message, sha: sha, date: date)
                self.commitRef?.child(sha).observeSingleEvent(of: .value, with: { (snapshot) in
                    if snapshot.exists() == false {
                        self.commitRef?.updateChildValues([sha : commit.toAnyObject()])
                    }
                })
            }
        } else { network.alert(viewController: self) }
    }
    
    // Saves a message to the database to present in everyones tableViews.
    func saveMessage(text: String, date: String, uid: String) {

        userRef?.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let postCount = value?["PostCount"] as? Int ?? 0
            let userName = value?["Nickname"] as? String ?? ""
            let messageUID = self.user!.uid + "-" + String(describing: postCount)
            let message = Message.init(author: userName, text: text, date: date)
            
            let uniqueMessageRef = self.messageRef?.child(messageUID)
            uniqueMessageRef?.setValue(message.toAnyObject())
            self.userRef?.updateChildValues(["PostCount" : postCount + 1])
            self.userRef?.child("messages").child(messageUID).setValue(uniqueMessageRef?.url)
            self.messageTextField.text = ""
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
            saveMessage(text: messageText, date: stringFromDate, uid: user!.uid)
            
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
    
    // Shows the commit details in a safari inapp browser view.
    func showCommit(_ index: Int) {
        
        if network.test() {
            let commit = self.tableCellList[index] as! Commit
            let sha = commit.sha
            let owner = repo!.owner
            let name = repo!.name
            if let url = URL(string: "https://github.com/\(owner)/\(name)/commit/\(sha)") {
                let vc = SFSafariViewController(url: url, entersReaderIfAvailable: true)
                present(vc, animated: true)
            }
        } else { network.alert(viewController: self) }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func encodeRestorableState(with coder: NSCoder) {
        if messageTextField.text != "" {
            coder.encode(messageTextField.text, forKey: "messageText")
        }
        
        // Encode current user.
        user?.encode(with: coder)
        
        // Encode current repo.
        repo?.encode(with: coder)
        
        // Encode user firebase reference.
        coder.encode(userRef!.url, forKey: "userRef")
        
        super.encodeRestorableState(with: coder)
    }
    
    override func decodeRestorableState(with coder: NSCoder) {
        // Decode message text
        let saveMessageText = coder.decodeObject(forKey: "messageText") as? String
        
        // Restore message.
        messageTextField.text = saveMessageText
        
        // Restore repository.
        repo = Repo.init(coder: coder)
        
        // Restore user.
        user = User.init(coder: coder)
        
        // Decode user firebase reference.
        let saveUserRefURL = coder.decodeObject(forKey: "userRef") as? String
        
        // Restore user reference.
        userRef = FIRDatabase.database().reference(fromURL: saveUserRefURL!)
        
        super.decodeRestorableState(with: coder)
    }
    
    override func applicationFinishedRestoringState() {
        
        // Restore vital elements for View.
        self.title = repo?.name
        prepareTableView()
    }
    
    // Shows a nice text for empty tableViews.
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        var text: String = ""
        if self.searchingCommit {
            text = "Searching for commits.."
        } else {
            text = "This repository has no commits!"
        }
        let emptyText = NSMutableAttributedString(
            string: text,
            attributes: [NSFontAttributeName: UIFont(name: "Georgia", size: 18.0)!,
            NSForegroundColorAttributeName: UIColor.darkGray])
        return emptyText
    }
    
    // MARK: Userdefaults
    
    func saveCommitsToDefaults(userDefault: UserDefaults) {
        
        guard self.commits.isEmpty == false else { return }
        let commitData = NSKeyedArchiver.archivedData(withRootObject: self.commits)
        userDefault.set(commitData, forKey: "commits-\(String(describing: repo?.id))")
    }
    
    func saveMessagesToDefaults(userDefault: UserDefaults) {
        
        guard self.messages.isEmpty == false else { return }
        let messageData = NSKeyedArchiver.archivedData(withRootObject: self.messages)
        userDefault.set(messageData, forKey: "messages-\(String(describing: repo?.id))")

    }
    
    func loadCommitsFromDefaults(userDefault: UserDefaults) -> [Commit] {
        
        guard let commitData = userDefault.object(forKey: "commits-\(String(describing: repo?.id))") as? NSData else { return [] }
        guard let commitArray = NSKeyedUnarchiver.unarchiveObject(with: commitData as Data) as? [Commit] else { return [] }

        return commitArray
    }
    
    func loadMessagesFromDefaults(userDefault: UserDefaults) -> [Message] {
        
        guard let messageData = userDefault.object(forKey: "messages-\(String(describing: repo?.id))") as? NSData else { return [] }
        guard let messageArray = NSKeyedUnarchiver.unarchiveObject(with: messageData as Data) as? [Message] else { return [] }
        
        return messageArray
    }
    
    func constructTableFromDefaults(userDefault: UserDefaults) {
        
        let defaultCommits = loadCommitsFromDefaults(userDefault: userDefault)
        let defaultMessages = loadMessagesFromDefaults(userDefault: userDefault)
        
        guard defaultMessages.isEmpty == false || defaultCommits.isEmpty == false else { return }
        constructTableViewCells(commitList: defaultCommits, messageList: defaultMessages)
        
    }

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
    
    // Tableview with two types of cells.
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


