//
//  AccountDetailsViewController.swift
//  Quintenvanderpost-pset6
//
//  Created by Quinten on 15/05/2017.
//  Copyright © 2017 Quinten van der Post. All rights reserved.
//

import UIKit
import Firebase

class AccountDetailsViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: Constants
    let baseRef = FIRDatabase.database().reference()
    let network = reachabilityTest.sharedInstance
    
    // MARK: Properties
    var userRef: FIRDatabaseReference?
    var user: User?
    var nicknameText: String = ""
    var activeTextField = UITextField()
    
    // MARK: Outlets
    @IBOutlet weak var nickName: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var currentPassword: UITextField!
    @IBOutlet weak var newPassword: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Account Details"
        self.navigationItem.backBarButtonItem?.title = "Repos"
        
        // Get current user information.
        userRef?.observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            self.nicknameText = value?["Nickname"] as? String ?? ""
            self.nickName.text = self.nicknameText
        })
        
        // Set delegates and tags
        nickName.delegate = self
        nickName.tag = 0
        
        currentPassword.delegate = self
        currentPassword.tag = 1
        
        newPassword.delegate = self
        newPassword.tag = 2
        
        // Tapgesture to dismiss keyboard when clicking in scrollView.
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(AccountDetailsViewController.hideKeyboard))
        tapGesture.cancelsTouchesInView = true
        scrollView.addGestureRecognizer(tapGesture)
        
        // Observers to change constraints when keyboard shows and hides.
        NotificationCenter.default.addObserver(self, selector: #selector(AccountDetailsViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(AccountDetailsViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    // Different actions for different textFields. (No different actions yet, but perhaps someday)
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        self.activeTextField = textField
        switch textField.tag {
        case 0:
            self.constructEditButtons()
        case 1:
            self.constructEditButtons()
        case 2:
            self.constructEditButtons()
        default:
            print("This is not a textfield")
        }
    }
    
    
    // Different actions for when different textFields lose focus.
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        switch textField.tag {
        case 0:
            textField.text = self.nicknameText
            self.deconstructEditButtons()
        case 1:
            self.deconstructEditButtons()
            if self.activeTextField.tag != 2 {
                textField.text = ""
                newPassword.text = ""
            }
        case 2:
            self.deconstructEditButtons()
            if self.activeTextField.tag != 1 {
                textField.text = ""
                currentPassword.text = ""
            }
        default:
            print("This is not a textfield")
        }
    }
    
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        self.activeTextField = textField
        return true
    }
    
    func cancelButtonTapped() {
        
        self.activeTextField.text = ""
        self.activeTextField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        self.activeTextField = textField
        self.doneButtonTapped()
        return true
    }
    
    // Different actions for different textfields done editing.
    func doneButtonTapped() {
        
        switch self.activeTextField.tag {
        case 0:
            if let newNickname = activeTextField.text, newNickname != ""{
                updateNickname(newNickname: newNickname)
            } else {
                let alert = UIAlertController(title: "Oops!",
                                              message: "You cannot have that nickname.",
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Continue", style: .default))
                self.present(alert,animated: true, completion: nil)
            }
            self.activeTextField.resignFirstResponder()
        case 1:
            self.newPassword.becomeFirstResponder()
        case 2:
            self.updatePassword()
        default:
            print("Implement more cases!!")
        }
    }
    
    func updatePassword() {
        
        if network.test() {
            
            let curPassword = self.currentPassword.text!
            let newPassword = self.activeTextField.text!
            
            if newPassword != "" {
                
                reauthUser(curPassword: curPassword) { success in
                    
                    if success {
                        
                        // Attempt to set password in database.
                        self.setPassword(newPassword: newPassword, curPassword: curPassword)
                    }
                    else {
                    
                        // Alert when reauthentication fails.
                        let alert = UIAlertController(title: "Oops!",
                                                      message: "Incorrect password.",
                                                      preferredStyle: .alert)
                        
                        // Dismiss alert and focus on current password textField.
                        alert.addAction(UIAlertAction(title: "Continue", style: .default) {_ in
                            
                            self.currentPassword.becomeFirstResponder()
                            self.newPassword.text = newPassword
                        })
                        
                        self.present(alert,animated: true, completion: nil)
                    }
                }
            } else {
                
                // Alert that empty passwords are not allowed.
                let alert = UIAlertController(title: "Oops!",
                                              message: "Cannot set empty passwords!",
                                              preferredStyle: .alert)
                
                // Allow for retyping new password
                alert.addAction(UIAlertAction(title: "Continue", style: .default) {_ in
                    self.newPassword.becomeFirstResponder()
                    self.currentPassword.text = curPassword
                })
                self.present(alert,animated: true, completion: nil)
            }
        } else { network.alert(viewController: self) }
    }
    
    func setPassword(newPassword: String, curPassword: String) {
        
        FIRAuth.auth()?.currentUser?.updatePassword(newPassword) { (error) in
            if error != nil {
                
                // Alert when new password cannot be set.
                let alert = UIAlertController(title: "Oops!",
                                              message: "Could not set that password.",
                                              preferredStyle: .alert)
                
                // Allow for retyping new password.
                alert.addAction(UIAlertAction(title: "Continue", style: .default) {_ in
                    self.newPassword.becomeFirstResponder()
                    self.currentPassword.text = curPassword
                })
                self.present(alert,animated: true, completion: nil)
            }
        }
        
        // Congratulate on updating password.
        let alert = UIAlertController(title: "Succes!",
                                      message: "Your password has been updated.",
                                      preferredStyle: .alert)
        
        // Tidy up view after updating.
        alert.addAction(UIAlertAction(title: "Continue", style: .default) {_ in
            
            // Empty out the textFields
            self.newPassword.text = ""
            self.currentPassword.text = ""
            self.activeTextField.resignFirstResponder()
        })
        self.present(alert,animated: true, completion: nil)
    }
    
    // Reauthenticate user with completionhandler.
    func reauthUser(curPassword: String, completionHandler: @escaping (Bool) -> ()) {
        
        // Construct current user details.
        let curUser = FIRAuth.auth()?.currentUser
        let credential = FIREmailPasswordAuthProvider.credential(withEmail: user!.email, password: curPassword)
        
        // Attempt reauthentication and tell update process to handle success.
        curUser?.reauthenticate(with: credential) { error in
            if error != nil {
                
                completionHandler(false)
            } else {
                
                completionHandler(true)
            }
        }
    }
    
    func updateNickname(newNickname: String) {
        
        self.nicknameText = newNickname
        
        self.userRef?.child("Nickname").setValue(newNickname)
        
        self.userRef?.observeSingleEvent(of: .value, with: { (snapshot) in
            
            // Set nickname to all messages posted by user in every repository.
            let value = snapshot.value as? NSDictionary
            let nick = value?["Nickname"] as? String ?? self.nicknameText
            if let messages = value?["messages"] as? NSDictionary {
                for (_, messageRef) in messages {
                    
                    let ref = FIRDatabase.database().reference(fromURL: String(describing: messageRef))
                    ref.child("author").setValue(nick)
                }
            }
            
        }) { (error) in
            let alert = UIAlertController(title: "Oops!", message: "Could not update your nickname. Please contact your database manager.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Continue", style: .default))
            self.present(alert,animated: true, completion: nil)
            print(error.localizedDescription)
        }
    }
    
    // Create buttons in navigation bar when editing.
    func constructEditButtons() {
        
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(self.cancelButtonTapped))
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.doneButtonTapped))
        self.navigationItem.setHidesBackButton(true, animated: true)
        self.navigationItem.setLeftBarButton(cancelButton, animated: true)
        self.navigationItem.setRightBarButton(doneButton, animated: true)
    }
    
    // Remove buttons in naviagation bar when done editing.
    func deconstructEditButtons() {
        
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.rightBarButtonItem = nil
        self.navigationItem.setHidesBackButton(false, animated: true)
    }
    
    func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.bottomConstraint.constant < keyboardSize.height{
                UIView.animate(withDuration: 1, animations: {
                    self.bottomConstraint.constant += keyboardSize.height
                    self.view.layoutIfNeeded()
                })
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.bottomConstraint.constant >= keyboardSize.height {
                UIView.animate(withDuration: 1, animations: {
                    self.bottomConstraint.constant -= keyboardSize.height
                    self.view.layoutIfNeeded()
                })
            }
        }
    }

    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func encodeRestorableState(with coder: NSCoder) {
        
        // Encode current nickname.
        if nickName.text != "" {
            coder.encode(nickName.text, forKey: "nickNameText")
        }
        
        // Encode current user.
        user?.encode(with: coder)
        
        // Encode user firebase reference.
        coder.encode(userRef!.url, forKey: "userRef")
        
        super.encodeRestorableState(with: coder)
    }
    
    override func decodeRestorableState(with coder: NSCoder) {
        
        // Restore nickname.
        if let saveNickNameText = coder.decodeObject(forKey: "nickNameText") as? String {
        
            nickName.text = saveNickNameText
            nickName.becomeFirstResponder()
        }
        
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
        userRef?.observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            self.nicknameText = value?["Nickname"] as? String ?? ""
        })
    }
    
}
