//
//  Player.swift
//  footchat
//
//  Created by Marten on 10/3/19.
//  Copyright © 2019 Marten. All rights reserved.
//

import UIKit
import Foundation
class Player{
    var name:String
    var uid:String
    var imageURL:String
    var age:String
    var location:String
    var position:String
    
    init(name:String,uid:String,imageURL:String,age:String,location:String,position:String){
        self.name  = name
        self.uid = uid
       // self.punctualRating = punctualRating
     //   self.respectfulRating = respectfulRating
        self.imageURL = imageURL
        self.age = age
        self.location = location
        self.position = position
   
        
    }
}
