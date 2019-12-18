//
//  CreateProjectViewController.swift
//  GestionnaireDeProjet
//
//  Created by dae2 on 2019-11-25.
//  Copyright © 2019 Guillaume Globensky. All rights reserved.
//

import UIKit


class CreateProjectViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource , UISearchBarDelegate {
    
    var usernames:[UsernameID] = []
    var selectedUsernames:[String] = []
    
    var searching:Bool = false
    var searchResults = [String]()
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var nameProject: UITextField!
    
    private var project: Project? = nil
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController!.navigationBar.topItem!.title = "Liste des projets";
    }
    
    @IBAction func CreateButtonPressed(_ sender: Any) {
        let defaults = UserDefaults.standard
        let nameText = nameProject.text
        let connectedUserId = defaults.integer(forKey: "CONNECTED_USERID")
        
        if nameText != ""
        {
            print(nameText)
            print(connectedUserId)
            MarthaRequest.addProject(name: nameText!, author_id: connectedUserId) { (convID) in
                if let fetchedProjectID = convID{
                    
       
                   
                    print(fetchedProjectID)
                    
                  for u in self.usernames{
                        if (self.selectedUsernames.contains(u.username)){
                            print("user id : \(u.id) et project id : \(fetchedProjectID) !")
                            MarthaRequest.addUserProject(user_id: u.id, project_id: fetchedProjectID) { (success) in
                                if let fetchResponse = success{
                                    print("Added  \(u.username) successfully")
                                    
                                    }
                                }
                            }
                           
                        }
                    
                   
                        MarthaRequest.addUserProject(user_id: connectedUserId, project_id: fetchedProjectID) { (success) in
                        if let fetchResponse = success{
                            print("Added author successfully")
                    
                            }
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                    
                    }
                    
                    
            
            
        }
    }
        
        }}

    
    

    @IBAction func cancelButtonPressed(_ sender: Any) {
        
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }
    override func viewDidLoad() {
           tableView.dataSource = self
           tableView.delegate = self
           
       }
    
    override func viewDidAppear(_ animated: Bool) {
        fillList()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching{
            return searchResults.count
        }
        return usernames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if (!searching){
            if (usernames.count > indexPath.row){
                cell.textLabel?.text = usernames[indexPath.row].username
                
                cell.selectionStyle = .none
            }
        }
        else{
            cell.textLabel?.text = searchResults[indexPath.row]
    
            cell.selectionStyle = .none
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (selectedUsernames.contains(cell.textLabel!.text!)){
            cell.accessoryType = .checkmark
            print("\(cell.accessoryType) added")
        } else {
            cell.accessoryType = .none
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let cell = tableView.cellForRow(at: indexPath)!
        
        var selectedUsername:String
        if (searching){
            selectedUsername = searchResults[indexPath.row]
        }
        else{
            selectedUsername = usernames[indexPath.row].username
        }
        if (selectedUsernames.contains(selectedUsername)){
            selectedUsernames.remove(at: selectedUsernames.firstIndex(of: usernames[indexPath.row].username)!)
            
            /*cell.accessoryType = .none
             tableView.reloadRows(at: [indexPath], with: .none)*/
            
        } else {
            selectedUsernames.append(selectedUsername)
            
            /*cell.accessoryType = .checkmark
             tableView.reloadRows(at: [indexPath], with: .none)*/
            //cell.backgroundColor = .blue
        }
        
        let cells = self.tableView.visibleCells
        
        for cell in cells {
            if (selectedUsernames.contains(cell.textLabel!.text!)){
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
            
        }
        
        DispatchQueue.main.async {
            self.tableView.setNeedsDisplay()
        }
        
       
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
            //self.parentViewController?.reloadInputViews()
        }
        
        
      
        
        print("\(selectedUsernames)")
        
    }
    
    public func fillList(){
        let defaults = UserDefaults.standard
        let connectedUserAlias = defaults.string(forKey: "CONNECTED_USER") ?? ""
        
        usernames.removeAll()
        
        MarthaRequest.fetchUsers() { (users) in
            if let fetchedUsers = users{
                
                for user in fetchedUsers{
                    if (user.username != connectedUserAlias){
                        self.usernames.append(UsernameID(id: user.id, username: user.username))
                    }
                }
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }


}
