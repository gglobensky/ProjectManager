//
//  ConversationsViewController.swift
//  GestionnaireDeProjet
//
//  Created by Guillaume Globensky on 2019-11-17.
//  Copyright © 2019 Guillaume Globensky. All rights reserved.
//

import UIKit

class ConversationsViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet var colleagueSelectionView: ColleagueSelectionView!
    
    var conversations:[Conversation] = []
    
    @IBAction func addButtonPressed(_ sender: Any) {
        self.view.addSubview(colleagueSelectionView)
        colleagueSelectionView.center = self.view.center
        
        colleagueSelectionView.tableView.dataSource = colleagueSelectionView
        colleagueSelectionView.tableView.delegate = colleagueSelectionView
        ColleagueSelectionView.setUIView(uiview: colleagueSelectionView)
        
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Quitter") { (action, view, completion) in
            
            let conversation = self.conversations[indexPath.row]
            let defaults = UserDefaults.standard
            let connectedUserId = defaults.integer(forKey: "CONNECTED_USERID")
            
            MarthaRequest.deleteUserConversation(user_id: connectedUserId, conversation_id: conversation.id) { (success) in
                if (success){
                    //self.fillList()
                    DispatchQueue.main.async {
                        self.conversations.remove(at: indexPath.row)
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
    
    func tableView(_ tableView: UITableView,
                            heightForRowAt indexPath: IndexPath) -> CGFloat {

        // Use the default size for all other rows.
        return 120
    }
    
    public func fillList(){
        let defaults = UserDefaults.standard
        let connectedUserId = defaults.integer(forKey: "CONNECTED_USERID")

        conversations.removeAll()
        
        MarthaRequest.fetchConversations(id: connectedUserId) { (convObj) in
            if let fetchedConversations = convObj{
                
                for convObj in fetchedConversations{
                    let conv = Conversation(id: convObj.id, participants: convObj.participants, author: convObj.author, content: convObj.content)
                    self.conversations.append(conv)
                }
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMessages" {
            if let vc = segue.destination as? MessagesViewController{

                vc.fillList(conversation_id: conversations[tableView.indexPathForSelectedRow!.row].id)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fillList()
        self.navigationController!.navigationBar.topItem!.title = "Conversations";
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "manual-cell", for: indexPath) as! ConversationCell
        cell.participantsLabel.text = conversations[indexPath.row].participants
        cell.lastMessageLabel.text = conversations[indexPath.row].content
        cell.authorLabel.text = conversations[indexPath.row].author
        return cell
    }
    
    
}
