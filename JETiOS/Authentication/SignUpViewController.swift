//
//  SignUpViewController.swift
//  JETiOS
//
//  Created by MACBOOK on 6/22/19.
//  Copyright © 2019 Alexander. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth



class SignUpViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet var EmailText: UITextField!
    @IBOutlet var PasswordText: UITextField!
    @IBOutlet var RetypePasswordText: UITextField!
    
    
    override func viewDidLoad() {
        self.hideKeyboardWhenTappedAround()
        EmailText.delegate = self
        PasswordText.delegate = self
        RetypePasswordText.delegate = self
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {   //delegate method
        EmailText.resignFirstResponder()
        PasswordText.resignFirstResponder()
        RetypePasswordText.resignFirstResponder()
        return true
    }
    
    
    
    @IBAction func signUpAction(_ sender: Any) {
        if PasswordText.text != RetypePasswordText.text {
            let alertController = UIAlertController(title: "Password Incorrect", message: "Please re-type password", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        }
        else{
            Auth.auth().createUser(withEmail: EmailText.text!, password: PasswordText.text!){ (user, error) in
                if error == nil {
                    let user = user?.user
                    print("User has Signed In")
                    if user!.isEmailVerified {
                    self.performSegue(withIdentifier: "signupToHome", sender: self)
                }
                }
                else {
                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
}
