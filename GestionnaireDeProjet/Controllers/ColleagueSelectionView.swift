//
//  ColleagueSelectionView.swift
//  GestionnaireDeProjet
//
//  Created by Guillaume Globensky on 2019-11-18.
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

extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}

class ColleagueSelectionView : UIView, UITableViewDelegate, UITableViewDataSource  {

    @IBOutlet weak var tableView: UITableView!
    var usernames:[UsernameID] = []
    var selectedUsernames:[String] = []
    static var uiview:UIView? = nil
    
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
                        let cv = self.parentViewController as? ConversationsViewController
                        DispatchQueue.main.async {
                            cv?.colleagueSelectionView.removeFromSuperview()
                            cv?.fillList()
                            self.setNeedsDisplay()
                        }
                    }
                }
            }

        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
    }
    
    public static func setUIView(uiview:UIView){
        self.uiview = uiview
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        commonInit()
    }
    
    private func commonInit() {

    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        fillList()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usernames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if (usernames.count > indexPath.row){
            cell.textLabel?.text = usernames[indexPath.row].username
            
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
        
        if (selectedUsernames.contains(usernames[indexPath.row].username)){
            selectedUsernames.remove(at: selectedUsernames.firstIndex(of: usernames[indexPath.row].username)!)
            
            /*cell.accessoryType = .none
            tableView.reloadRows(at: [indexPath], with: .none)*/

        } else {
            selectedUsernames.append(usernames[indexPath.row].username)

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
            self.setNeedsDisplay()
        }
        
        DispatchQueue.main.async {
            self.superview?.reloadInputViews()
        }
        
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
}
