//
//  CommitCell.swift
//  Quintenvanderpost-pset6
//
//  Created by Quinten van der Post on 13/12/2016.
//  Copyright © 2016 Quinten van der Post. All rights reserved.
//

import UIKit

class CommitCell: UITableViewCell {

    @IBOutlet weak var comment: UILabel!
    @IBOutlet weak var name: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
