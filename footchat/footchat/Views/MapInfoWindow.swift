//
//  MapInfoWindow.swift
//  footchat
//
//  Created by Marten on 10/16/19.
//  Copyright © 2019 Marten. All rights reserved.
//

import UIKit

class MapInfoWindow: UIView {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!   
    @IBOutlet weak var positionLabel: UILabel!    
    @IBOutlet weak var chatButton: UIButton!
    @IBAction func didTapInButton(_ sender: Any) {
        print("button tapped")
    }
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "MapInfoWindowView", bundle: nil).instantiate(withOwner: self, options: nil).first as! UIView
    }

    @IBAction func chatButton(_ sender: UIButton) {
       // print("dddddd")
    }
    
}
