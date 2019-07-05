//
//  SecurityViewController.swift
//  JETiOS
//
//  Created by MACBOOK on 6/22/19.
//  Copyright © 2019 Alexander. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class SecurityViewController: UIViewController {
    
    @IBOutlet var EmailTextField: UITextField!

    @IBOutlet var forgotPassword: UIButton!
    
    @IBOutlet var deleteAccountButton: UIButton!
    
    @IBOutlet var changeEmailButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(red: 119 / 255, green: 139 / 255, blue: 235 / 255, alpha: 1.0)
        let navigationBarAppearace = UINavigationBar.appearance()
        navigationBarAppearace.tintColor = UIColor(rgb: 0xFFFFFF)
    }
    
    @IBAction func passwordResetButton(_ sender: UIButton) {
        
        Auth.auth().sendPasswordReset(withEmail: EmailTextField.text!) { error in
            
        }
    }
    
    @IBAction func deleteAccount(_ sender: Any) {
        
        let user = Auth.auth().currentUser
        
        user?.delete { error in
            if let error = error {
                print("\(error)")
            } else {
                self.performSegue(withIdentifier: "SecurityToStart", sender: self)
                print("Success")
            }
        }
        
    }
    @IBAction func changeEmail(_ sender: Any) {
        
        Auth.auth().currentUser?.updateEmail(to: EmailTextField.text!) { (error) in
            if let error = error {
                print("\(error)")
            } else {
                print("Success")
            }
            
            
        }
        
        
    }
    
}
