//
//  CreateProjectViewController.swift
//  GestionnaireDeProjet
//
//  Created by dae2 on 2019-11-25.
//  Copyright © 2019 Guillaume Globensky. All rights reserved.
//

import UIKit

class CreateProjectViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    
    
    @IBOutlet weak var nameProject: UITextField!
    
    private var project: Project? = nil
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController!.navigationBar.topItem!.title = "Liste des projets";
    }
    
    @IBAction func CreateButtonPressed(_ sender: Any) {
        let defaults = UserDefaults.standard
        let nameText = nameProject.text
        let connectedUserId = defaults.integer(forKey: "CONNECTED_USERID")
        
        if nameText != ""
        {
            print(nameText)
            print(connectedUserId)
            MarthaRequest.addProject(name: nameText!, author_id: connectedUserId) { (convID) in
                if let fetchedConversationID = convID{
                    
            
                   
                    
                   
                    print(fetchedConversationID)
                    
                    MarthaRequest.addUserProject(user_id: connectedUserId, project_id: fetchedConversationID) { (success) in
                        if let fetchResponse = success{
                            
                            
                            DispatchQueue.main.async {
                                self.performSegue(withIdentifier: "RewindCreateProject", sender: self)
                                
                            }
                        }
                    }
                }
            
            
        }
    }
    
    
    
    
    func ShowMessage(message: String){
        let alertMessage = UIAlertController(title: "", message: message, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Ok", style: .cancel)
        
        alertMessage.addAction(cancelAction)
        
        self.present(alertMessage, animated: true, completion: nil)
    }

    
    
}
    
    

    
    


}
