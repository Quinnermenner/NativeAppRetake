//
//  Protocols.swift
//  Quintenvanderpost-pset6
//
//  Created by Quinten on 14/05/2017.
//  Copyright © 2017 Quinten van der Post. All rights reserved.
//

import Foundation

// Used to merge commit and object types into one array.
protocol MessageCommitProtocol {
    var date: String { get }
    var key: String { get }
}
