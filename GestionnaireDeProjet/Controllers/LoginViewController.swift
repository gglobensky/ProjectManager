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
                            
                            DispatchQueue.main.async {
                                self.performSegue(withIdentifier: "showHub", sender: self)
                            }
                        } else {
                            DispatchQueue.main.async {
                                self.showMessage(message: "Informations invalides")
                            }
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.showMessage(message: "Informations invalides")
                        }
                    }
                }
            }
        }
    }
    
    func showMessage(message: String){
        let alertMessage = UIAlertController(title: "", message: message, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Ok", style: .cancel)
        
        alertMessage.addAction(cancelAction)
        
        self.present(alertMessage, animated: true, completion: nil)
    }
    

    
}
