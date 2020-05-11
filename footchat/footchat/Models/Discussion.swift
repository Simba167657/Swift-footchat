//
//  Discussion.swift
//  footchat
//
//  Created by Marten on 10/2/19.
//  Copyright © 2019 Marten. All rights reserved.
//

import Foundation
class Discussion{
    var name:String
    var id:String
    var imageUrl :String?
    
    init(name:String, id:String, imageUrl:String?){
        self.name  = name
        self.id = id
        self.imageUrl = imageUrl
    }
}

