//
//  HostViewCell.swift
//  footchat
//
//  Created by Marten on 10/23/19.
//  Copyright © 2019 Marten. All rights reserved.
//

import UIKit

class HostViewCell: UITableViewCell {

    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var typeTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var distanceTextField: UITextField!
    @IBOutlet weak var hostTextField: UITextField!
    @IBOutlet weak var startTimeTextField: UITextField!    
    @IBOutlet weak var endTimeTextField: UITextField!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func setExpanded() {
       // statusButton.setImage(#imageLiteral(resourceName: "arw_red_top"), for: .normal)
    }
    
    func setCollapsed() {
       // statusButton.setImage(#imageLiteral(resourceName: "arw_red_bottom"), for: .normal)
    }

}
