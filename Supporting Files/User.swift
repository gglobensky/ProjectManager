//
//  User.swift
//  Exercice6.4
//
//  Created by Guillaume Globensky on 2019-11-07.
//  Copyright © 2019 Guillaume Globensky. All rights reserved.
//

import UIKit

struct User{
    var id: Int
    var name: String
    var surname: String
    var username: String
    var password: String
    var sex: String
    var dateOfBirth: Date
    var photo: UIImage
    //photo
    init?(json: [String:Any]){
        if let id = json["id"] as? Int,
            let name = json["firstName"] as? String,
            let surname = json["lastName"] as? String,
            let username = json["username"] as? String,
            let password = json["password"] as? String,
            let sex = json["sex"] as? String,
            let dateOfBirth = json["birth"] as? String,
            let photoText = json["photo"] as? String{
            
            if let photo = MarthaRequest.convertBase64ToImage(string: photoText){
            
                self.id = id
                self.name = name
                self.surname = surname
                self.username = username
                self.password = password
                self.sex = sex
                self.dateOfBirth = dateOfBirth.asDate()
                self.photo = photo
            } else {
                //problem decoding photo
                return nil
            }
        } else {
            return nil
        }
        
    }
    
    init(id: Int, name: String, surname: String, username: String, password: String, sex: String, dateOfBirth: Date, photo: UIImage){
        
        self.id = id
        self.name = name
        self.surname = surname
        self.username = username
        self.password = password
        self.sex = sex
        self.dateOfBirth = dateOfBirth
        self.photo = photo
    }
}
