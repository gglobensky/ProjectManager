//
//  User.swift
//  Exercice6.4
//
//  Created by Guillaume Globensky on 2019-11-08.
//  Copyright © 2019 Guillaume Globensky. All rights reserved.
//

import Foundation

struct UserFullName{
    var author: String
    var content: String
    
    init?(json: [String:Any]){
        
        if let author = json["author"] as? String,
            let content = json["content"] as? String {
            
            self.author = author
            self.content = content
        } else {
            return nil
        }
        
    }
    
    init(author: Int, content: String){
        MarthaRequest.
        self.author = author
        self.content = content
    }
    
}
