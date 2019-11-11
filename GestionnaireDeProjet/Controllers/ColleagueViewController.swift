//
//  ColleagueViewController.swift
//  Exercice6.4
//
//  Created by Guillaume Globensky on 2019-11-07.
//  Copyright © 2019 Guillaume Globensky. All rights reserved.
//

import UIKit

class ColleagueViewController : UIViewController {
    
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var fullname: UILabel!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var age: UILabel!
    @IBOutlet weak var sex: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var modifyButton: UIButton!
    var user: User? = nil
    static var vcEntity: ColleagueViewController? = nil
    
    @IBAction func deleteButtonPressed() {
        MarthaRequest.deleteUser(id: user!.id) { (success) in
            if (success){
                
                let defaults = UserDefaults.standard
                defaults.removeObject(forKey: "CONNECTED_USER")
                
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "backToLogin", sender: nil)
                }
            } else {
                print("delete failed")
            }
        }
    }
    
    public func setUser(user: User){
        if let userObject = user as? User{
            DispatchQueue.main.async {
                if self.avatarImage != nil{
                    self.avatarImage.image = userObject.photo
                    
                    self.fullname.text = userObject.name + " " + userObject.surname

                    self.username.text = userObject.username

                    self.age.text = "\(userObject.dateOfBirth.age)"

                    self.sex.text = userObject.sex
                    
                    self.reloadInputViews()
                }
            }
        }
    }
    
    public func loadConnectedUser(){
        
        let defaults = UserDefaults.standard
        let connectedUserAlias = defaults.string(forKey: "CONNECTED_USER") ?? ""
        
        MarthaRequest.fetchUser(username: connectedUserAlias) { (users) in
            if let fetchedUser = users{
                DispatchQueue.main.async {
                    self.user = fetchedUser[0]
                    self.setUser(user: fetchedUser[0])
                }
            }
        }
    }
    
    public static func updateColleagueView(){
        vcEntity!.loadConnectedUser()
    }
    
    func manageButtons(showButtons: Bool){
        if showButtons{
            modifyButton.isEnabled = true
            modifyButton.isHidden = false
            deleteButton.isEnabled = true
            deleteButton.isHidden = false
        } else {
            modifyButton.isEnabled = false
            modifyButton.isHidden = true
            deleteButton.isEnabled = false
            deleteButton.isHidden = true
        }
    }
    
    public func showConnectedUser(){
        
        manageButtons(showButtons: true)
        loadConnectedUser()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "modifyUser" {
            if let vc = segue.destination as? UserCreationViewController{
                vc.setUser(userObj: user!)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if ColleagueViewController.vcEntity == nil{
            ColleagueViewController.vcEntity = self
        }
        let defaults = UserDefaults.standard
        let connectedUserAlias = defaults.string(forKey: "CONNECTED_USER") ?? ""
        
        
        if user == nil || user?.username != connectedUserAlias{
            manageButtons(showButtons: false)
        } else {
            setUser(user: user!)
        }
    }
    
    func showMessage(message: String){
        let alertMessage = UIAlertController(title: "", message: message, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Ok", style: .cancel)
        
        alertMessage.addAction(cancelAction)
        
        self.present(alertMessage, animated: true, completion: nil)
    }
    
}
