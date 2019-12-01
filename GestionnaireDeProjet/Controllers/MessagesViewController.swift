//
//  MessagesViewController.swift
//  GestionnaireDeProjet
//
//  Created by Guillaume Globensky on 2019-11-18.
//  Copyright © 2019 Guillaume Globensky. All rights reserved.
//

import UIKit

class MessagesViewController : UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {


    @IBOutlet weak var inputTextView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var inputTextField: UITextView!
    @IBOutlet weak var tableView: UITableView!
    var messages:[Message] = []
    var currentConversationId: Int = 0
    var currentUserFullName:String = ""
    var currentUserId: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        let defaults = UserDefaults.standard
        currentUserId = defaults.integer(forKey: "CONNECTED_USERID")
        inputTextView.delegate = self
        sendButton.isEnabled = false
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        pollServer()
    }
    
    func pollServer(){
        let timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { timer in
            self.fillList(conversation_id: self.currentConversationId, scrollView: false)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alert = UIAlertController(title: "Modification message", message: "", preferredStyle: .alert)
        let currentMessage = self.messages[indexPath.row]
        
        if (currentMessage.author_id == currentUserId){
            alert.addTextField()
            alert.textFields?[0].text = currentMessage.content
            alert.addAction(
                UIAlertAction(title:"OK", style: .default, handler:{ _ in
                    
                    let text = alert.textFields?[0].text ?? ""
                    
                    MarthaRequest.updateMessage(message_id: currentMessage.message_id, content: text) { (success) in
                        if success{
                            print("Succesfully updated message")
                            self.messages[indexPath.row].content = text
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        }
                    }
                })
            )
            
            alert.addAction(UIAlertAction(title:"Cancel", style: .cancel))
            
            self.present(alert, animated: true)
        } else {
            //showMessage(message: "Vous ne pouvez modifier que vos messages")
            tableView.cellForRow(at: indexPath)?.setSelected(false, animated: false)
            
        }
    }
    
    @IBAction func sendButtonPressed(_ sender: Any) {
        let defaults = UserDefaults.standard
        let connectedUserId = defaults.integer(forKey: "CONNECTED_USERID")
        
        MarthaRequest.addMessage(author_id: connectedUserId, content: inputTextField.text!, conversation_id: currentConversationId, completion: {
            (newMsg) in
            
            DispatchQueue.main.async {
                if newMsg != nil{
                    //New msg is empty... long story short because it returns author id and content and i need fullName and content -> I need to reupdate the whole list with a query
                    self.fillList(conversation_id: self.currentConversationId)
                    self.inputTextField.text = ""
                } else {
                    //ERROR
                }
            }
        })
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let defaults = UserDefaults.standard
        let connectedUserId = defaults.integer(forKey: "CONNECTED_USERID")

        let deleteAction = UIContextualAction(style: .destructive, title: "Supprimer") { (action, view, completion) in
            
            if (self.messages.count > 0 && connectedUserId == self.messages[indexPath.row].author_id){
                MarthaRequest.deleteMessage(user_id: self.messages[indexPath.row].author_id, message_id: self.messages[indexPath.row].message_id) { (success) in
                    if success{
                        
                        print("Successfully deleted message")
                        self.messages.remove(at: indexPath.row)
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }

                    } else {
                        print("Error deleting message")
                    }
                }
            } else {
                tableView.cellForRow(at: indexPath)?.setSelected(false, animated: false)
                //Helper.showMessage(message: "Vous ne pouvez pas effacer les messages des autres", viewController: self)
            }
            completion(false)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    public func fillList(conversation_id: Int, scrollView: Bool = true){
        currentConversationId = conversation_id
        messages.removeAll()
        
        let defaults = UserDefaults.standard
        let connectedUserId = defaults.integer(forKey: "CONNECTED_USERID")
        
        MarthaRequest.fetchUserById(user_id: connectedUserId){ (userFullName) in
            
            self.currentUserFullName = userFullName![0].fullName
            
        }
        
        MarthaRequest.fetchMessages(id: conversation_id) { (msgObj) in
            if let fetchedMessages = msgObj{
                
                for msgObj in fetchedMessages{
                    let msg = Message(author_id: msgObj.author_id, message_id: msgObj.message_id, author: msgObj.author, content: msgObj.content)
                    self.messages.append(msg)
                }

            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
                
                if (scrollView){
                    let bottomOffset = CGPoint(x: 0, y: self.tableView.contentSize.height - self.tableView.frame.size.height)
                    self.tableView.setContentOffset(bottomOffset, animated: false)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "manual-cell", for: indexPath) as! MessagesCell

        if messages[indexPath.row].author_id == currentUserId{
            cell.messageLabel.textAlignment = .left
            cell.messageLabel.text = "Moi : \(messages[indexPath.row].content)"
        } else {
            cell.messageLabel.textAlignment = .right
            cell.messageLabel.text = "\(messages[indexPath.row].author) : \(messages[indexPath.row].content)"
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        tableView.estimatedRowHeight = 85.0
        let val = UITableView.automaticDimension
        // Use the default size for all other rows.
        return val
    }
    
    func textViewDidChange(_ textView: UITextView) { //Handle the text changes here
        if (textView.text.count == 0){
            sendButton.isEnabled = false
        }
        else{
            sendButton.isEnabled = true
        }
    }
}
