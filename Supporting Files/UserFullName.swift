//
//  User.swift
//  Exercice6.4
//
//  Created by Guillaume Globensky on 2019-11-08.
//  Copyright © 2019 Guillaume Globensky. All rights reserved.
//

import Foundation

struct UserFullName{
    public var fullName: String

    init?(json: [String:Any]){
        
        if let author = json["fullName"] as? String {
            
            self.fullName = author
            
        } else {
            return nil
        }
        
    }

    init(fullName: String){
        self.fullName = fullName
    }
    
}
