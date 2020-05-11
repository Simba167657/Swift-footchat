//
//  HostListWindow.swift
//  footchat
//
//  Created by Marten on 10/21/19.
//  Copyright © 2019 Marten. All rights reserved.
//

import UIKit

class HostListWindow: UIView {

    @IBOutlet weak var hostnameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!    
    @IBOutlet weak var timeLabel: UILabel!    
   
   
    @IBAction func didTapInButton(_ sender: Any) {
        print("button tapped")
    }
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "HostListWindowView", bundle: nil).instantiate(withOwner: self, options: nil).first as! UIView
    }

}
