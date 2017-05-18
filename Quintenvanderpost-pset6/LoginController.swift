//
//  LoginController.swift
//  Quintenvanderpost-pset6
//
//  Created by Quinten van der Post on 11/12/2016.
//  Copyright © 2016 Quinten van der Post. All rights reserved.
//

import UIKit
import Firebase
import SwiftyJSON
import SystemConfiguration
import ReachabilitySwift


class LoginController: UIViewController, UITextFieldDelegate  {
    
    // MARK: Outlets
    @IBOutlet weak var loginEmail: UITextField!
    @IBOutlet weak var loginPass: UITextField!
    
    // MARK: Properties
    let network = reachabilityTest.sharedInstance
    var user: User!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginPass.delegate = self
        loginPass.tag = 0
        
        loginEmail.delegate = self
        loginEmail.tag = 1
        
        // Listener that segues to repos if user is already logged in.
        FIRAuth.auth()?.addStateDidChangeListener() { auth, user in
            if user != nil && self.navigationController?.visibleViewController == self {
                print("Found a login!")
                self.performSegue(withIdentifier: "segueLogin", sender: nil)
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Show the navigation bar on other view controllers
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        
        // Only tag 0 should perform login action.
        switch textField.tag {
        case 0:
            loginDidTouch(self)
            textField.resignFirstResponder()
        case 1:
            loginPass.becomeFirstResponder()
        default:
            return true
        }
        
        return true
    }
    
    func registerUser(email: String, password: String) {
        
        FIRAuth.auth()!.createUser(withEmail: email, password: password) { user, error in
            if error == nil {
                let ref : FIRDatabaseReference!
                ref = FIRDatabase.database().reference()
                ref.child("users").child(user!.uid).setValue([
                    "Email": email,
                    "Nickname": email,
                    "Repos": [],
                    "PostCount": 0])
                self.loginUser(login: email, password: password)
            } else {
                let alert = UIAlertController(title: "Oops!",
                                              message: "These credentials are not allowed.",
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Continue", style: .default))
                self.present(alert,animated: true, completion: nil)
            }
        }
    }
    
    func loginUser(login: String, password: String) {
        
        // Perform login to database and alert if anything goes wrong.
        if network.test() {
            FIRAuth.auth()!.signIn(withEmail: login, password: password) { (user, error) in
                if error != nil {
                    let alert = UIAlertController(title: "Oops!",
                                                  message: "This combination of login and password does not match any user in the database.",
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Continue", style: .default))
                    self.present(alert,animated: true, completion: nil)
                } else {
                    
                    // Perform segue on successful login.
                    self.user = User(authData: user!)
                    self.performSegue(withIdentifier: "segueLogin", sender: self)
                }
            }
        } else { network.alert(viewController: self) }
    }
    
    @IBAction func loginDidTouch(_ sender: AnyObject) {
        
        self.loginUser(login: loginEmail.text!, password: loginPass.text!)
    }
    
    @IBAction func registerDidTouch(_ sender: AnyObject) {
        
        // Start register procedure.
        let alert = UIAlertController(title: "Registration",
                                      message: "Register a new account",
                                      preferredStyle: .alert)
        
        // Textfields for user information.
        alert.addTextField { (textField) in
            textField.placeholder = "User Email"
        }
        alert.addTextField { (textField) in
            textField.placeholder = "Password"
            textField.isSecureTextEntry = true
        }
        
        let emailField = alert.textFields![0]
        let passwordField = alert.textFields![1]
        
        let saveAction = UIAlertAction(title: "Add", style: .default) { _ in
            guard emailField.text != nil, passwordField.text != nil else { return }
                self.registerUser(email: emailField.text!, password: passwordField.text!)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)

        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueLogin" {
            if let navVC = segue.destination as? UINavigationController {
                if let destination = navVC.topViewController as? RepoController {
                    destination.user = user
                }
            }
        }
    }
    
    override func encodeRestorableState(with coder: NSCoder) {
        
        // Encode current user.
        if user != nil {
            user?.encode(with: coder)
        }
        
        
        super.encodeRestorableState(with: coder)
    }
    
    override func decodeRestorableState(with coder: NSCoder) {
        
        // Restore user.
        if let _ = coder.decodeObject(forKey: "userEmail") {
            user = User.init(coder: coder)
        }
        
        super.decodeRestorableState(with: coder)
    }
}
