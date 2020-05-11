//
//  PlayerTableViewCell.swift
//  footchat
//
//  Created by Marten on 10/3/19.
//  Copyright © 2019 Marten. All rights reserved.
//

import UIKit

class PlayerTableViewCell: UITableViewCell {
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var nameTextField: UILabel!
    @IBOutlet weak var ageTextField: UILabel!
    @IBOutlet weak var positionTextField: UILabel!    
    @IBOutlet weak var locationTextField: UILabel!    
  
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
