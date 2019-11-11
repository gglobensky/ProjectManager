//
//  ViewController.swift
//  Exercice6.4
//
//  Created by Guillaume Globensky on 2019-09-12.
//  Copyright © 2019 Guillaume Globensky. All rights reserved.
//

import UIKit

class UserCreationViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var surname: UITextField!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var passwordConfirm: UITextField!
    @IBOutlet weak var sex: UISegmentedControl!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var avatarImage: UIImageView!
    
    var user: User? = nil
    
    @IBAction func avatarImageTapped(_ sender: UITapGestureRecognizer) {

        // UIImagePickerController is a view controller that lets a user pick media from their photo library.
        let imagePickerController = UIImagePickerController()
        
        // Only allow photos to be picked, not taken.
        imagePickerController.sourceType = .photoLibrary
        
        // Make sure ViewController is notified when the user picks an image.
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if user != nil{
            fillFields()
        }
    }
    
    public func setUser(userObj: User){
        self.user = userObj
    }
    
    func fillFields(){
        name.text = user!.name
        surname.text = user!.surname
        username.text = user!.username
        var sexIndex: Int = 0
        
        switch user!.sex{
        case "M":
            sexIndex = 0
        case "F":
            sexIndex = 1
        case "A":
            sexIndex = 2
        default:
            sexIndex = 0
        }
        
        sex.selectedSegmentIndex = sexIndex
        datePicker.date = user!.dateOfBirth
        avatarImage.image = user!.photo
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        
        // The info dictionary may contain multiple representations of the image. You want to use the original.
        guard let selectedImage = info[.originalImage] as? UIImage else {
        fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        // Set photoImageView to display the selected image.
        avatarImage.image = selectedImage
        
        // Dismiss the picker.
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func acceptButtonPressed(_ sender: Any) {
        let nameText = name.text
        let surnameText = surname.text
        let usernameText = username.text
        let passwordText = password.text
        let passwordConfirmText = passwordConfirm.text
        let sexText: String
        
        switch sex.selectedSegmentIndex{
        case 0:
            sexText = "M"
        case 1:
            sexText = "F"
        case 2:
            sexText = "A"
        default:
            sexText = "M"
        }
        
        
        if nameText != "", surnameText != "", usernameText != "", passwordText != "", passwordConfirmText != "" {
            if (passwordText == passwordConfirmText){
                if user == nil{

                    MarthaRequest.addUser(firstName: nameText!, lastName: surnameText!, username: usernameText!, password: passwordText!, sex: sexText, dateOfBirth: datePicker.date, photo: avatarImage.image!, completion: {(newUser) in
                        
                        DispatchQueue.main.async {
                            if newUser != nil{
                                self.navigationController?.popViewController(animated: true)
                            } else {
                                self.showMessage(message: "Pseudo indisponible")
                            }
                        }
                    })
                } else {
                    verifyPassword(id: user!.id, firstName: nameText!, lastName: surnameText!, username: usernameText!, password: passwordText!, sex: sexText, dateOfBirth: datePicker.date, photo: avatarImage.image!)
                }
            } else {
                showMessage(message: "Les mots de passes ne sont pas identiques")
            }
        } else {
            showMessage(message: "Vous devez remplir tous les champs")
        }
    }
    
    func showMessage(message: String){
        let alertMessage = UIAlertController(title: "", message: message, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Ok", style: .cancel)
        
        alertMessage.addAction(cancelAction)
        
        self.present(alertMessage, animated: true, completion: nil)
    }
    
    func updateUser(id: Int, firstName: String, lastName: String, username: String, password: String, sex: String, dateOfBirth: Date, photo: UIImage){
        MarthaRequest.updateUser(id: id, firstName: firstName, lastName: lastName, username: username, password: password, sex: sex, dateOfBirth: dateOfBirth, photo: photo, completion: {(newUser) in
            DispatchQueue.main.async {
                if newUser != nil{
                    let defaults = UserDefaults.standard
                    defaults.set(newUser?.username, forKey: "CONNECTED_USER")
                    
                    ColleagueViewController.updateColleagueView()
                    self.navigationController?.popViewController(animated: true)

                } else {
                    self.showMessage(message: "Pseudo indisponible")
                }
            }
        })
    }
    
    func verifyPassword(id:Int, firstName: String, lastName: String, username: String, password: String, sex: String, dateOfBirth: Date, photo: UIImage){
        let alertMessage = UIAlertController(title: "", message: "Veuillez entrer votre mot de passe", preferredStyle: .alert)
        
        alertMessage.addTextField { (textField) in
            textField.isSecureTextEntry = true
            textField.text = ""
        }
        
        alertMessage.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alertMessage] (_) in
            let textField = alertMessage!.textFields![0]
            
            let defaults = UserDefaults.standard
            let connectedUserAlias = defaults.string(forKey: "CONNECTED_USER") ?? ""
            
            MarthaRequest.fetchUser(username: connectedUserAlias) { (users) in
                if let fetchedUser = users{
                    if (fetchedUser.count > 0){
                        self.user = fetchedUser[0]
                        //print(self.user)
                        
                        if self.user!.password == textField.text!.hmac(key: "test"){
                            print("Login successful")
                            self.updateUser(id: id, firstName: firstName, lastName: lastName, username: username, password: password, sex: sex, dateOfBirth: dateOfBirth, photo: photo)
                            
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
        
        }))
        self.present(alertMessage, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


}

