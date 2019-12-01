//
//  ColleagueSelectionViewController.swift
//  GestionnaireDeProjet
//
//  Created by Guillaume Globensky on 2019-11-30.
//  Copyright © 2019 Guillaume Globensky. All rights reserved.
//

import UIKit


struct UsernameID{
    var id:Int
    var username:String
    
    init(id: Int, username: String){
        self.id = id
        self.username = username
    }
}

class ColleagueSelectionViewController : UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    var usernames:[UsernameID] = []
    var selectedUsernames:[String] = []
    
    var searching:Bool = false
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func acceptButtonPressed(_ sender: Any) {
        var conversation_id:Int = 0
        let defaults = UserDefaults.standard
        let connectedUserId = defaults.integer(forKey: "CONNECTED_USERID")
        
        MarthaRequest.addConversation { (convID) in
            if let fetchedConversationID = convID{
                
                conversation_id = fetchedConversationID
                print(conversation_id)
                
                for u in self.usernames{
                    if (self.selectedUsernames.contains(u.username)){
                        MarthaRequest.addUserConversation(user_id: u.id, conversation_id: conversation_id) { (success) in
                            if let fetchResponse = success{
                                print("Added a conversation to \(u.username) successfully")
                            }
                        }
                    }
                }
                
                MarthaRequest.addUserConversation(user_id: connectedUserId, conversation_id: conversation_id) { (success) in
                    if let fetchResponse = success{
                        print("Added a conversation to yourself successfully")
                        DispatchQueue.main.async {
                            self.navigationController?.popViewController(animated: true)
                        }

                    }
                }
            }
            
        }
    }

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
        
        /*DispatchQueue.main.async {
            self.superview?.reloadInputViews()
        }*/
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
            //self.parentViewController?.reloadInputViews()
        }
        
        
        //self.superview?.subviews.re
        
        print("\(selectedUsernames)")
        //cell.accessoryType = .checkmark
        //cell.accessoryView.hidden = false // if using a custom image
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
    
    var searchResults = [String]()
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let tmpUserNames = usernames.filter({$0.username.uppercased().prefix(searchText.count) == searchText.uppercased()})
        searchResults = tmpUserNames.map { $0.username }
        searching = searchText.count > 0
        tableView.reloadData()
    }
}
