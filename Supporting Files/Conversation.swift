//
//  User.swift
//  Exercice6.4
//
//  Created by Guillaume Globensky on 2019-11-07.
//  Copyright © 2019 Guillaume Globensky. All rights reserved.
//

import Foundation

struct Conversation{
    var id:Int
    var participants: String
    var author: String
    var content: String

    init?(json: [String:Any]){
        if let participants = json["participants"] as? String,
            let id = json["id"] as? Int{
            
            self.participants = participants
            self.id = id
            if let author = json["author"] as? String,
                let content = json["content"] as? String {
                

                self.author = author
                self.content = content
            } else {
                
                self.author = ""
                self.content = ""
            }
        } else {
            return nil
        }
        
    }
    
    init(id:Int, participants: String, author: String, content: String){
        
        self.id = id
        self.participants = participants
        self.author = author
        self.content = content
    }
    
}
