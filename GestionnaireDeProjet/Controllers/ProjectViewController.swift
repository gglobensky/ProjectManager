//
//  ProjectViewController.swift
//  GestionnaireDeProjet
//
//  Created by jordan payet on 2019-11-24.
//  Copyright © 2019 Guillaume Globensky. All rights reserved.
//

import UIKit
import Foundation

class ProjectViewController : UITableViewController {
   
    
    
    @IBOutlet weak var projectView: UITableView!
    
   
    
    var projects:[Project] = []
    
    
  /*
    @IBAction func addButtonPressed(_ sender: Any) {
        self.view.addSubview(colleagueSelectionView)
        colleagueSelectionView.center = self.view.center
        
        colleagueSelectionView.tableView.dataSource = colleagueSelectionView
        colleagueSelectionView.tableView.delegate = colleagueSelectionView
        ColleagueSelectionView.setUIView(uiview: colleagueSelectionView)
        
    }
    */
    
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Quitter") { (action, view, completion) in
            
            let project = self.projects[indexPath.row]
            let defaults = UserDefaults.standard
            let connectedUserId = defaults.integer(forKey: "CONNECTED_USERID")
            
            MarthaRequest.deleteProject(user_id: connectedUserId, project_id: project.id ) { (success) in
                if (success){
                    //self.fillList()
                    DispatchQueue.main.async {
                        self.projects.remove(at: indexPath.row)
                        self.tableView.reloadData()
                        completion(true)
                    }
                } else {
                    print("delete failed")
                    completion(false)
                }
            }
            
            completion(false)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    func showMessage(message: String){
        let alertMessage = UIAlertController(title: "", message: message, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Ok", style: .cancel)
        
        alertMessage.addAction(cancelAction)
        
        self.present(alertMessage, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
    }
    
    override func tableView(_ tableView: UITableView,
                            heightForRowAt indexPath: IndexPath) -> CGFloat {

        // Use the default size for all other rows.
        return 120
    }
    
    public func fillList(){
        let defaults = UserDefaults.standard
        let connectedUserId = defaults.integer(forKey: "CONNECTED_USERID")

        projects.removeAll()
        
        MarthaRequest.fetchProjects(id: connectedUserId) { (progObj) in
            if let fetchedProject = progObj{
                
                for progObj in fetchedProject{
                    let prog = Project(
                        id: progObj.id,
                        name: progObj.name, author_id: progObj.author_id)
                    self.projects.append(prog)
                }
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
  /*
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMessages" {
            if let vc = segue.destination as? MessagesViewController{

                vc.fillList(conversation_id: conversations[tableView.indexPathForSelectedRow!.row].id)
            }
        }
    }*/
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fillList()
        self.navigationController!.navigationBar.topItem!.title = "Projets";
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return projects.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProjectCell", for: indexPath) as! ProjectCell
        cell.textLabel?.text = projects[indexPath.row].name
       
        return cell
    }
    
    
    
}
