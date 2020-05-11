//
//  Constants.swift
//  footchat
//
//  Created by Marten on 10/2/19.
//  Copyright © 2019 Marten. All rights reserved.
//

import Firebase
struct Constants
{
    struct refs
    {
        static let databaseRoot = Database.database().reference()
        static let databaseChats = databaseRoot.child("chats")
        static let databaseUsers = databaseRoot.child("users")
        static let databaseHost = databaseRoot.child("host")
        static let databaseMessage = databaseRoot.child("messages")
        static let databasePlayerMatch = databaseRoot.child("playermatch")
        
    }
}
