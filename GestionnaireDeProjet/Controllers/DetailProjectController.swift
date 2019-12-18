//
//  DetailProjectController.swift
//  GestionnaireDeProjet
//
//  Created by jordan payet on 2019-12-17.
//  Copyright © 2019 Guillaume Globensky. All rights reserved.
//

import Foundation
import UIKit

class DetailProjectController : UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource
{
    var Project:Project?
    let AuthorName = UserDefaults.standard.string(forKey: "CONNECTED_USERNAME")
    
    @IBOutlet weak var ProjectNameLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var AuthorNameLabel: UILabel!
    
    var participant:[User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (self.Project != nil){
            ProjectNameLabel.text = self.Project?.name
            AuthorNameLabel.text = String(self.Project!.author_id)
            tableView.dataSource = self
            tableView.delegate = self
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        fillList()
    }
    
    
    public func fillList(){
        
        let defaults = UserDefaults.standard
               let connectedUserAlias = defaults.string(forKey: "CONNECTED_USER") ?? ""
                       print(connectedUserAlias)

       participant.removeAll()
              
        MarthaRequest.fetchParticipant(project_id: (self.Project?.id)! ) { (users) in
                  if let fetchedUsers = users{
                      
                      for user in fetchedUsers{
                          if (user.username != connectedUserAlias){
                              self.participant.append(user)
                            
                          }
                      }
                  }
                  DispatchQueue.main.async {
                      self.tableView.reloadData()
                  }
              }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return participant.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellTest", for: indexPath)
        cell.textLabel?.text = participant[indexPath.row].username
        
        
        return cell
    }
    
    
    
    
    
    
    @IBAction func switchTableView(_ sender: UISegmentedControl) {
    }
    
    
}
