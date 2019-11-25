//
//  MarthaRequest.swift
//  Exercice6.4
//
//  Created by Guillaume Globensky on 2019-11-07.
//  Copyright © 2019 Guillaume Globensky. All rights reserved.
//

import UIKit
import CommonCrypto

extension Date {
    func asString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.string(from: self)
    }
    
    var age: Int {
        return Calendar.current.dateComponents([.year], from: self, to: Date()).year!
    }
    
    
}

extension String {
    
    func hmac(key: String) -> String {
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA256), key, key.count, self, self.count, &digest)
        let data = Data(bytes: digest)
        return data.map { String(format: "%02hhx", $0) }.joined()
    }
    
    func asDate() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" //Your date format
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT+0:05") //Current time zone
        //according to date format your date string
        guard let date = dateFormatter.date(from: self) else {
            fatalError()
        }
        return date //Convert String to Date
    }
    
}

class MarthaRequest{
    private static let auth = Data("team6:XnOa0pUyIz".utf8).base64EncodedString()
    //private static let auth = Data("globensky:s3Jtl4yx".utf8).base64EncodedString()
    private static let MAXHEIGHT: Int = 120
    private static let MAXWIDTH: Int = 120
    
    private static func request(query: String, params: Data? = nil, completion: @escaping ([String:Any]?)->Void){
        let url = URL(string: "http://martha.jh.shawinigan.info/queries/\(query)/execute")!
        let session = URLSession.shared
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(auth, forHTTPHeaderField: "auth")
        request.httpBody = params
        
        let task = session.dataTask(with: request as URLRequest) { (httpData, httpResponse, httpError) in
            
            if let error = httpError{
                print(error)
                completion(nil)
                
            } else if let data = httpData{
                do{
                    let jsonResponse = try JSONSerialization.jsonObject(with: data)
                    if let json = jsonResponse as? [String: Any]{
                        completion(json)
                    } else {
                        print("Invalid JSON")
                        completion(nil)
                    }
                } catch let parsingError{
                    print("Parsing error \(parsingError)")
                    completion(nil)
                }
                
            } else {
                print("Unknown error")
                completion(nil)
            }
            
        }
        task.resume()
    }
    
    public static func fetchUsers(completion: @escaping ([User]?) -> Void){
        let query = "select-users"
        request(query: query) {(jsonObjectResponse) in
            
            if let jsonObject = jsonObjectResponse,
                let success = jsonObject["success"] as? Bool,
                let itemsJson = jsonObject["data"] as? [Any] {
                if (success){
                    var users: [User] = []
                    
                    for itemJson in itemsJson{
                        if let itemJsonObject = itemJson as? [String:Any],
                            let user = User(json: itemJsonObject){
                            users.append(user)
                        }
                    }
                    completion(users)
                } else {
                    print("fetch failed")
                    completion(nil)
                }
                
            } else {
                print("Request failed, invalid format")
                completion(nil)
            }
        }
        
    }
    
    public static func addConversation(completion: @escaping (Int?) -> Void){
        let query = "add-conversation"
        
        request(query: query) {(jsonObjectResponse) in
            
            if let jsonObject = jsonObjectResponse,
                let success = jsonObject["success"] as? Bool,
                let id = jsonObject["lastInsertId"] as? Int {
                if (success){
                    
                    completion(id)
                    
                } else {
                    print("fetch failed")
                    completion(nil)
                }
                
            } else {
                
                print("Request failed, invalid format")
                completion(nil)
            }
        }
        
    }
    
    public static func addUserConversation(user_id:Int, conversation_id:Int, completion: @escaping (Bool?) -> Void){
        let query = "add-userConversation"
        
        let jsonObject: [Any]  = [
            [
                "user_id": user_id,
                "conversation_id": conversation_id
            ]
        ]
        
        let params = try! JSONSerialization.data(withJSONObject: jsonObject)
        request(query: query, params: params) {(jsonObjectResponse) in
            
            if let jsonObject = jsonObjectResponse,
                let success = jsonObject["success"] as? Bool{
                if (success){
                    completion(success)
                    
                } else {
                    print("fetch failed")
                    completion(nil)
                }
                
            } else {
                
                print("Request failed, invalid format")
                completion(nil)
            }
        }
        
    }
    
    public static func deleteUserConversation(user_id: Int, conversation_id:Int, completion: @escaping (Bool) -> Void){
        let query = "delete-userConversation"
        let jsonObject: [Any]  = [
            [
                "user_id": user_id,
                "conversation_id": conversation_id
            ]
        ]
        
        let params = try! JSONSerialization.data(withJSONObject: jsonObject)
        
        request(query: query, params: params) {(jsonObjectResponse) in
            
            if let jsonObject = jsonObjectResponse,
                let success = jsonObject["success"] as? Bool {
                if (success){
                    completion(success)
                } else {
                    print("fetch failed")
                    completion(success)
                }
                
            } else {
                print("Request failed, invalid format")
                completion(false)
            }
        }
        
    }
    
    public static func deleteProject(user_id: Int, project_id:Int, completion: @escaping (Bool) -> Void){
        let query = "delete-project"
        let jsonObject: [Any]  = [
            [
                "user_id": user_id,
                "project_id": project_id
            ]
        ]
        
        let params = try! JSONSerialization.data(withJSONObject: jsonObject)
        
        request(query: query, params: params) {(jsonObjectResponse) in
            
            if let jsonObject = jsonObjectResponse,
                let success = jsonObject["success"] as? Bool {
                if (success){
                    completion(success)
                } else {
                    print("fetch failed")
                    completion(success)
                }
                
            } else {
                print("Request failed, invalid format")
                completion(false)
            }
        }
        
    }
    
    public static func fetchProjects(id: Int, completion: @escaping ([Project]?) -> Void){
        let query = "select-projects"
        let params = try! JSONSerialization.data(withJSONObject: ["user_id": id])
        request(query: query, params: params) {(jsonObjectResponse) in
            
            if let jsonObject = jsonObjectResponse,
                let success = jsonObject["success"] as? Bool,
                let itemsJson = jsonObject["data"] as? [Any] {
                if (success){
                    var projects: [Project] = []
                    
                    for itemJson in itemsJson{
                        if let itemJsonObject = itemJson as? [String:Any],
                            let project = Project(json: itemJsonObject){
                           projects.append(project)
                        }
                    }
                    completion(projects)
                } else {
                    print("fetch failed")
                    completion(nil)
                }
                
            } else {
                print("Request failed, invalid format")
                completion(nil)
            }
        }
        
    }
    
    
    public static func addProject(name: String, author_id: Int, completion: @escaping (Int?) -> Void){
           let query = "add-project"
    
           
         
           let jsonObject: [Any]  = [
               [
                   "name": name,
                   "author_id": author_id
                   
               ]
           ]
           
           let params = try! JSONSerialization.data(withJSONObject: jsonObject)
           request(query: query, params: params) {(jsonObjectResponse) in
               
               if let jsonObject = jsonObjectResponse,
                   let success = jsonObject["success"] as? Bool,
                   let id = jsonObject["lastInsertId"] as? Int {
                   if (success){
                       
                    
                       completion(id)
                       
                    
                   } else {
                       print("add failed")
                       completion(nil)
                   }
                   
               } else {
                   
                   print("Request failed, invalid format")
                   completion(nil)
               }
           }
           
       }
    
    public static func addUserProject(user_id:Int, project_id:Int, completion: @escaping (Bool?) -> Void){
        let query = "add-userProject"
        
        let jsonObject: [Any]  = [
            [
                "user_id": user_id,
                "project_id": project_id
            ]
        ]
        
        let params = try! JSONSerialization.data(withJSONObject: jsonObject)
        request(query: query, params: params) {(jsonObjectResponse) in
            
            if let jsonObject = jsonObjectResponse,
                let success = jsonObject["success"] as? Bool,
                let id = jsonObject["lastInsertId"] as? Int {
                if (success){
                    
                    completion(success)
                    
                } else {
                    print("add failed")
                    completion(nil)
                }
                
            } else {
                
                print("Request failed, invalid format")
                completion(nil)
            }
        }
        
    }
    
    
    
    public static func fetchConversations(id: Int, completion: @escaping ([Conversation]?) -> Void){
        let query = "select-conversations"
        let params = try! JSONSerialization.data(withJSONObject: ["user_id": id])
        request(query: query, params: params) {(jsonObjectResponse) in
            
            if let jsonObject = jsonObjectResponse,
                let success = jsonObject["success"] as? Bool,
                let itemsJson = jsonObject["data"] as? [Any] {
                if (success){
                    var conversations: [Conversation] = []
                    
                    for itemJson in itemsJson{
                        if let itemJsonObject = itemJson as? [String:Any],
                            let conversation = Conversation(json: itemJsonObject){
                            conversations.append(conversation)
                        }
                    }
                    completion(conversations)
                } else {
                    print("fetch failed")
                    completion(nil)
                }
                
            } else {
                print("Request failed, invalid format")
                completion(nil)
            }
        }
        
    }
    
    public static func fetchMessages(id: Int, completion: @escaping ([Message]?) -> Void){
        let query = "select-messages"
        let params = try! JSONSerialization.data(withJSONObject: ["conversation_id": id])
        request(query: query, params: params) {(jsonObjectResponse) in
            
            if let jsonObject = jsonObjectResponse,
                let success = jsonObject["success"] as? Bool,
                let itemsJson = jsonObject["data"] as? [Any] {
                if (success){
                    var messages: [Message] = []
                    
                    for itemJson in itemsJson{
                        if let itemJsonObject = itemJson as? [String:Any],
                            let message = Message(json: itemJsonObject){
                            
                            messages.append(message)
                        }
                    }
                    completion(messages)
                } else {
                    print("fetch failed")
                    completion(nil)
                }
                
            } else {
                print("Request failed, invalid format")
                completion(nil)
            }
        }
        
    }
    
    public static func deleteMessage(user_id: Int, message_id: Int, completion: @escaping (Bool) -> Void){
        let query = "delete-message"
        
        let jsonObject: [Any]  = [
            [
                "user_id": user_id,
                "message_id": message_id
            ]
        ]
        
        let params = try! JSONSerialization.data(withJSONObject: jsonObject)
        request(query: query, params: params) {(jsonObjectResponse) in
            
            if let jsonObject = jsonObjectResponse,
                let success = jsonObject["success"] as? Bool {
                if (success){
                    completion(success)
                } else {
                    print("fetch failed")
                    completion(success)
                }
                
            } else {
                print("Request failed, invalid format")
                completion(false)
            }
        }
        
    }
    
    
    public static func deleteUser(id: Int, completion: @escaping (Bool) -> Void){
        let query = "delete-user"
        let params = try! JSONSerialization.data(withJSONObject: ["id": id])
        
        request(query: query, params: params) {(jsonObjectResponse) in
            
            if let jsonObject = jsonObjectResponse,
                let success = jsonObject["success"] as? Bool {
                if (success){
                    completion(success)
                } else {
                    print("fetch failed")
                    completion(success)
                }
                
            } else {
                print("Request failed, invalid format")
                completion(false)
            }
        }
        
    }
    
    public static func fetchUser(username: String, completion: @escaping ([User]?) -> Void){
        let query = "select-user"
        let params = try! JSONSerialization.data(withJSONObject: ["username": username])
        
        request(query: query, params: params) {(jsonObjectResponse) in
            
            if let jsonObject = jsonObjectResponse,
                let success = jsonObject["success"] as? Bool,
                let itemsJson = jsonObject["data"] as? [Any] {
                if (success){
                    var users: [User] = []
                    
                    for itemJson in itemsJson{
                        
                        if let itemJsonObject = itemJson as? [String:Any],
                            let user = User(json: itemJsonObject){
                            
                            users.append(user)
                        }
                    }
                    
                    completion(users)
                } else {
                    print("fetch failed")
                    completion(nil)
                }
                
            } else {
                print("Request failed, invalid format")
                completion(nil)
            }
        }
        
    }
    
    public static func fetchUserById(user_id: Int, completion: @escaping ([UserFullName]?) -> Void){
        let query = "select-userById"
        let params = try! JSONSerialization.data(withJSONObject: ["user_id": user_id])
        
        request(query: query, params: params) {(jsonObjectResponse) in
            
            if let jsonObject = jsonObjectResponse,
                let success = jsonObject["success"] as? Bool,
                let itemsJson = jsonObject["data"] as? [Any] {
                if (success){
                    var users: [UserFullName] = []
                    
                    for itemJson in itemsJson{
                        
                        if let itemJsonObject = itemJson as? [String:Any],
                            let user = UserFullName(json: itemJsonObject){
                            
                            users.append(user)
                        }
                    }
                    
                    completion(users)
                } else {
                    print("fetch failed")
                    completion(nil)
                }
                
            } else {
                print("Request failed, invalid format")
                completion(nil)
            }
        }
        
    }
    
    static func resize(image: UIImage, width: Int, height: Int) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), true, 1.0)
        image.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return resizedImage
    }
    
    public static func updateMessage(message_id: Int, content: String, completion: @escaping (Bool) -> Void){
        let query = "update-message"
        
        let jsonObject: [Any]  = [
            [
                "message_id": message_id,
                "content": content
            ]
        ]
        
        let params = try! JSONSerialization.data(withJSONObject: jsonObject)
        request(query: query, params: params) {(jsonObjectResponse) in
            
            if let jsonObject = jsonObjectResponse,
                let success = jsonObject["success"] as? Bool {
                if (success){
                    
                    completion(success)
                    
                } else {
                    print("fetch failed")
                    completion(false)
                }
                
            } else {
                
                print("Request failed, invalid format")
                completion(false)
            }
        }
        
    }
    
    public static func addMessage(author_id: Int, content: String, conversation_id: Int, completion: @escaping (Message?) -> Void){
        let query = "add-message"
        
        let jsonObject: [Any]  = [
            [
                "author_id": author_id,
                "content": content,
                "conversation_id": conversation_id
            ]
        ]
        
        let params = try! JSONSerialization.data(withJSONObject: jsonObject)
        request(query: query, params: params) {(jsonObjectResponse) in
            
            if let jsonObject = jsonObjectResponse,
                let success = jsonObject["success"] as? Bool,
                let id = jsonObject["lastInsertId"] as? Int {
                if (success){
                    
                    let message = Message.getMessage(message_id: id, author_id: author_id, content: content)
                    completion(message)
                    
                } else {
                    print("fetch failed")
                    completion(nil)
                }
                
            } else {
                
                print("Request failed, invalid format")
                completion(nil)
            }
        }
        
    }
    
    
    
    public static func addUser(firstName: String, lastName: String, username: String, password: String, sex: String, dateOfBirth: Date, photo: UIImage, completion: @escaping (User?) -> Void){
        let query = "add-user"
        
        let photoHeight: Float = Float(photo.size.height)
        let photoWidth: Float = Float(photo.size.width)
        
        var height: Int = MAXHEIGHT
        var width: Int = MAXWIDTH
        
        if (photoHeight > photoWidth){
            height = MAXHEIGHT
            width = Int((photoWidth * Float(MAXHEIGHT) / photoHeight).rounded())
        } else if (photoHeight < photoWidth){
            height = Int((photoHeight * Float(MAXWIDTH) / photoWidth).rounded())
            width = MAXWIDTH
        }
        
        print("\(width), \(height)")
        
        let resizedPhoto = resize(image: photo, width: width, height: height)
        
        let jsonObject: [Any]  = [
            [
                "firstName": firstName,
                "lastName": lastName,
                "username": username,
                "password": password.hmac(key: "test"),
                "sex": sex,
                "birth": dateOfBirth.asString(),
                "photo": convertImageToBase64(image: resizedPhoto!)
            ]
        ]
        
        let params = try! JSONSerialization.data(withJSONObject: jsonObject)
        request(query: query, params: params) {(jsonObjectResponse) in
            
            if let jsonObject = jsonObjectResponse,
                let success = jsonObject["success"] as? Bool,
                let id = jsonObject["lastInsertId"] as? Int {
                if (success){
                    
                    let user = User(id: id, name: firstName, surname: lastName, username: username, password: password, sex: sex, dateOfBirth: dateOfBirth, photo: resizedPhoto!)
                    completion(user)
                    
                } else {
                    print("fetch failed")
                    completion(nil)
                }
                
            } else {
                
                print("Request failed, invalid format")
                completion(nil)
            }
        }
        
    }
    
    public static func updateUser(id: Int, firstName: String, lastName: String, username: String, password: String, sex: String, dateOfBirth: Date, photo: UIImage, completion: @escaping (User?) -> Void){
        let query = "update-user"
        
        let jsonObject: [Any]  = [
            [
                "id": id,
                "firstName": firstName,
                "lastName": lastName,
                "username": username,
                "password": password.hmac(key: "test"),
                "sex": sex,
                "birth": dateOfBirth.asString(),
                "photo": convertImageToBase64(image: photo)
            ]
        ]
        
        let params = try! JSONSerialization.data(withJSONObject: jsonObject)
        request(query: query, params: params) {(jsonObjectResponse) in
            
            if let jsonObject = jsonObjectResponse,
                let success = jsonObject["success"] as? Bool {
                if (success){
                    
                    let user = User(id: id, name: firstName, surname: lastName, username: username, password: password, sex: sex, dateOfBirth: dateOfBirth, photo: photo)
                    completion(user)
                    
                } else {
                    print("fetch failed")
                    completion(nil)
                }
                
            } else {
                
                print("Request failed, invalid format")
                completion(nil)
            }
        }
        
    }
    
    static func convertImageToBase64(image: UIImage) -> String?{
        if let data: Data = image.pngData(){
            return data.base64EncodedString()
        } else {
            return nil
        }
    }
    
    static func convertBase64ToImage(string: String) -> UIImage?{
        if let data = Data(base64Encoded: string, options: .ignoreUnknownCharacters){
            return UIImage(data: data)
        } else {
            return nil
        }
    }
}
