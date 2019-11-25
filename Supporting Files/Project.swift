//
//  Project.swift
//  GestionnaireDeProjet
//
//  Created by jordan payet on 2019-11-24.
//  Copyright © 2019 Guillaume Globensky. All rights reserved.
//

import Foundation

struct Project{
    var id:Int
    var name: String
    var author_id: Int
    

    init?(json: [String:Any]){
        if let name = json["name"] as? String,
            let id = json["id"] as? Int{
            
            self.name = name
            self.id = id
            if let author_id = json["author_id"] as? Int{
                
                

                self.author_id = author_id}
            else{
                
                self.author_id = 10
                
            }
                
            
    } else {
            return nil
        }
        
    }
    
    init(id:Int, name: String, author_id: Int){
        
        self.id = id
        self.name = name
        self.author_id = author_id
        
    }
    
}
