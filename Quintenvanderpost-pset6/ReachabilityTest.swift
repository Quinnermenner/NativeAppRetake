//
//  ReachabilityTest.swift
//  Quintenvanderpost-pset6
//
//  Created by Quinten on 17/05/2017.
//  Copyright © 2017 Quinten van der Post. All rights reserved.
//

import Foundation
import ReachabilitySwift


// Singleton used to test network connection.
class reachabilityTest {
    
    static let sharedInstance = reachabilityTest()
    private var online: Bool!
    private let reachability = Reachability()!
    
    private init () {
        
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged),name: ReachabilityChangedNotification,object: reachability)
        do {
            try reachability.startNotifier()
        } catch {
            print("could not start reachability notifier")
        }
    }
    
    @objc func reachabilityChanged(note: NSNotification) {
        
        let netTest = note.object as! Reachability
        
        if netTest.isReachable {
            
            self.online = true
            print("Network reachable")
        } else {
            
            self.online = false
            print("Network not reachable")
        }
    }
    
    func test() -> Bool {
        
        return self.online
    }
    
    func alert(viewController: UIViewController) {
        
        let alert = UIAlertController(title: "Oops!",
                                      message: "You are not connected to the internet.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Continue", style: .default))
        viewController.present(alert,animated: true, completion: nil)
    }
}
