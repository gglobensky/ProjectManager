//
//  Helper.swift
//  GestionnaireDeProjet
//
//  Created by Guillaume Globensky on 2019-11-30.
//  Copyright © 2019 Guillaume Globensky. All rights reserved.
//

import UIKit

class Helper{
    
    static func showMessage(message: String, viewController: UIViewController){
        let alertMessage = UIAlertController(title: "", message: message, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Ok", style: .cancel)
        
        alertMessage.addAction(cancelAction)
        
        viewController.present(alertMessage, animated: true, completion: nil)
    }
    
}
