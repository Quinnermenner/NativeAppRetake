//
//  AccountDetailsViewController.swift
//  Quintenvanderpost-pset6
//
//  Created by Quinten on 15/05/2017.
//  Copyright © 2017 Quinten van der Post. All rights reserved.
//

import UIKit
import Firebase

class AccountDetailsViewController: UIViewController {
    
    // MARK: Constants
    let baseRef = FIRDatabase.database().reference()
    
    // MARK: Properties
    var userRef: FIRDatabaseReference!
    var user: User!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
