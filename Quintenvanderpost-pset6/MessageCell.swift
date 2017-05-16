//
//  MessageCell.swift
//  Quintenvanderpost-pset6
//
//  Created by Quinten on 13/05/2017.
//  Copyright © 2017 Quinten van der Post. All rights reserved.
//

import UIKit

class MessageCell: UITableViewCell {

    @IBOutlet weak var comment: UILabel!
    @IBOutlet weak var name: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
