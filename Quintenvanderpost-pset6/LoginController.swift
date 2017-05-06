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

class LoginController: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var loginEmail: UITextField!
    @IBOutlet weak var loginPass: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        FIRAuth.auth()!.addStateDidChangeListener() { auth, user in
            if user != nil {
                self.performSegue(withIdentifier: "segueLogin", sender: nil)
            }
        }
    }
    
    @IBAction func loginDidTouch(_ sender: AnyObject) {
        print("pressed login")
        FIRAuth.auth()!.signIn(withEmail: loginEmail.text!,
                               password: loginPass.text!)
    }
    
    @IBAction func registerDidTouch(_ sender: AnyObject) {
        let alert = UIAlertController(title: "Registration",
                                      message: "Register a new account",
                                      preferredStyle: .alert)
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
                // TODO: Implement GitAPI and make classes
                FIRAuth.auth()!.createUser(withEmail: emailField.text!,
                                           password: passwordField.text!) { user, error in
                                                if error == nil {
                                                // 3
                                                FIRAuth.auth()!.signIn(withEmail: emailField.text!,password: passwordField.text!)
                                                    }
                                        }
                                       
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .default)

    
    alert.addAction(saveAction)
    alert.addAction(cancelAction)
    
    present(alert, animated: true, completion: nil)
    }
}
