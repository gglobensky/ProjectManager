//
//  UITabBarController.swift
//  Exercice6.4
//
//  Created by Guillaume Globensky on 2019-11-08.
//  Copyright © 2019 Guillaume Globensky. All rights reserved.
//

import UIKit

class MainUITabBarController : UITabBarController, UITabBarControllerDelegate{


    override func viewDidLoad() {
        self.delegate = self
    }
    
    // UITabBarDelegate
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {

        if (self.selectedIndex == 1){
            var controller = self.viewControllers![1] as! ColleagueViewController
            self.navigationItem.setHidesBackButton(true, animated:true);
            
            controller.showConnectedUser()
        } else {
            self.navigationItem.setHidesBackButton(false, animated:true);
        }

    }

}
