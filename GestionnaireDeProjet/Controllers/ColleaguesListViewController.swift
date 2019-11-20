//
//  ColleaguesListViewController.swift
//  Exercice6.4
//
//  Created by Guillaume Globensky on 2019-11-07.
//  Copyright © 2019 Guillaume Globensky. All rights reserved.
//

import UIKit

class ColleaguesListViewController : UITableViewController{
    
    var usernames:[String] = []
    
    private var user: User? = nil
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController!.navigationBar.topItem!.title = "Collègues";
        fillList()
    }

    /*override func viewDidLoad() {
        super.viewDidLoad()
        fillList()
    }*/
    
    public func fillList(){
        let defaults = UserDefaults.standard
        let connectedUserAlias = defaults.string(forKey: "CONNECTED_USER") ?? ""
                print(connectedUserAlias)
        
        usernames.removeAll()
        
        MarthaRequest.fetchUsers() { (users) in
            if let fetchedUsers = users{
                
                for user in fetchedUsers{
                    if (user.username != connectedUserAlias){
                        self.usernames.append(user.username)
                    }
                }
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "UserDetails"){
            if let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell){
                MarthaRequest.fetchUser(username: usernames[indexPath.row]) { (users) in
                    if let fetchedUser = users{

                        self.user = fetchedUser[0]
                       
                        
                        let destinationCV = segue.destination as! ColleagueViewController
                        
                        DispatchQueue.main.async {
                            destinationCV.setUser(user: self.user!)
                        }
                    }

                }
            
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usernames.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = usernames[indexPath.row]
        
        return cell
    }
}
