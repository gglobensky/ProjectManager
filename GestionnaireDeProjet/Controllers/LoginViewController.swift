//
//  LoginViewController.swift
//  Exercice6.4
//
//  Created by Guillaume Globensky on 2019-11-07.
//  Copyright © 2019 Guillaume Globensky. All rights reserved.
//

import UIKit


class LoginViewController: UIViewController{
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!

    private var user: User? = nil
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController!.navigationBar.topItem!.title = "Gestionnaire de projet";
    }
    
    @IBAction func connexionButtonPressed(_ sender: Any) {
        let usernameText = username.text
        let passwordText = password.text
        
        if usernameText != "", passwordText != "" {
            MarthaRequest.fetchUser(username: usernameText!) { (users) in
                if let fetchedUser = users{
                    if (fetchedUser.count > 0){
                        self.user = fetchedUser[0]
                        //print(self.user)
                        
                        if self.user!.password == passwordText!.hmac(key: "test"){
                            print("Login successful")
                            
                            let defaults = UserDefaults.standard
                            defaults.set(usernameText, forKey: "CONNECTED_USER")
                            defaults.set(self.user?.id, forKey: "CONNECTED_USERID")
                                
                            defaults.set(self.user?.name, forKey: "CONNECTED_USERNAME")
                            
                            DispatchQueue.main.async {
                                self.username.text = ""
                                self.password.text = ""
                                self.username.becomeFirstResponder()
                                self.performSegue(withIdentifier: "showHub", sender: self)
                            }
                        } else {
                            DispatchQueue.main.async {
                                Helper.showMessage(message: "Informations invalides", viewController: self)
                            }
                        }
                    } else {
                        DispatchQueue.main.async {
                            Helper.showMessage(message: "Informations invalides", viewController: self)
                        }
                    }
                }
            }
        }
    }


    
}
