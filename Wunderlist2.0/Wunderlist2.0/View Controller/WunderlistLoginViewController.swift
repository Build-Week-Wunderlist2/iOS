//
//  WunderlistLoginViewController.swift
//  Wunderlist2.0
//
//  Created by David Williams on 6/19/20.
//  Copyright © 2020 thecoderpilot. All rights reserved.
//

import UIKit

enum LoginType {
    case signUp
    case signIn
}

class WunderlistLoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var loginSegmentedControl: UISegmentedControl!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    
    var loginController: LoginController?
    var loginType = LoginType.signUp
    var toDoItemController: ToDoItemController?
    var toDoListController: ToDoListController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        signUpButton.backgroundColor = UIColor(red: 197/255, green: 203/255, blue: 227/255, alpha: 1.0)
        signUpButton.tintColor = .white
        signUpButton.layer.cornerRadius = 5
        loginSegmentedControl.backgroundColor = UIColor(red: 197/255, green: 203/255, blue: 227/255, alpha: 1.0)
        loginSegmentedControl.tintColor = .white
        loginSegmentedControl.layer.cornerRadius = 5
    }
    
    @IBAction func signLogInButtonTapped(_ sender: UIButton) {
        guard let loginController = loginController else { return }
        
        guard let email = emailTextField.text, !email.isEmpty,
            let password = passwordTextField.text, !password.isEmpty  else { return }
        
            let user = User(username: email, password: password)
            
            switch loginType {
            case .signUp:
                loginController.signUp(with: user) { (error) in
                    guard error == nil else {
                        print("Error signing up: \(error!)")
                        return
                    }
                    DispatchQueue.main.async {
                        let alertController = UIAlertController(title: "Sign Up Successful", message: "Now please log in.", preferredStyle: .alert)
                        let alertAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                        alertController.addAction(alertAction)
                        self.present(alertController, animated: true) {
                            self.loginType = .signIn
                            self.loginSegmentedControl.selectedSegmentIndex = 1
                            self.signUpButton.setTitle("Sign In", for: .normal)
                        }
                    }
                }
            case .signIn:
                loginController.signIn(with: user) { (error) in
                    guard error == nil else {
                        print("Error login in: \(error!)")
                        return
                    }
                    guard let bearer = loginController.bearer else { return }
                    self.toDoItemController?.bearer = bearer
                    self.toDoListController?.bearer = bearer
                    
                    DispatchQueue.main.async {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
            
        }
    
    @IBAction func signInTypeChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            loginType = .signUp
            signUpButton.setTitle("Sign Up", for: .normal)
        } else {
            loginType = .signIn
            signUpButton.setTitle("Sign In", for: .normal)
        }
    }
}
