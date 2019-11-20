//
//  User.swift
//  Exercice6.4
//
//  Created by Guillaume Globensky on 2019-11-08.
//  Copyright © 2019 Guillaume Globensky. All rights reserved.
//

import Foundation

struct Message{
    var author_id: Int
    var message_id: Int
    var author: String
    var content: String
    
    init?(json: [String:Any]){

        if let author = json["author"] as? String,
            let content = json["content"] as? String,
            let author_id = json["author_id"] as? Int,
            let message_id = json["message_id"] as? Int{
           
            self.author_id = author_id
            self.message_id = message_id
            self.author = author
            self.content = content
        } else {
            return nil
        }
        
    }
    
    public static func getMessage(message_id: Int, author_id: Int, content: String)->Message{
        var _author: String = ""
        var _content: String = ""

        MarthaRequest.fetchUserById(user_id: author_id){ (userFullName) in
        
            _author = userFullName![0].fullName
            _content = content

        }
        return Message(author_id: author_id, message_id: message_id, author: _author, content: _content)
    }
    
    init(author_id: Int, message_id: Int, author: String, content: String){
        self.author_id = author_id
        self.message_id = message_id
        self.author = author
        self.content = content
    }
    
}
