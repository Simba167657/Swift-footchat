//
//  HostList.swift
//  footchat
//
//  Created by Marten on 10/2/19.
//  Copyright © 2019 Marten. All rights reserved.
//


import UIKit
import Foundation
class HostList{
    var date:String
    var startTime:String
    var endTime:String
    var type:String
    var location:String
    var host:String
    var uid:String
    var hostkey:String
    var distance:Double
   // var name:String
   
    init(date:String,startTime:String,endTime:String,type:String,location:String,host:String,uid:String,hostkey:String,distance:Double){
        self.date  = date
        self.startTime = startTime
        self.endTime = endTime
        self.type = type
        self.location = location
        self.host = host
        self.uid = uid
        self.hostkey = hostkey
        self.distance = distance
    
     
        
    }
}
