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

class WunderlistLoginViewController: UIViewController {

    @IBOutlet weak var loginSegmentedControl: UISegmentedControl!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    
    var toDoItemController = ToDoItemController()
    var loginType = LoginType.signUp
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        signUpButton.backgroundColor = UIColor(red: 197, green: 203, blue: 227, alpha: 1.0)
        signUpButton.tintColor = .white
        signUpButton.layer.cornerRadius = 5
        loginSegmentedControl.backgroundColor = UIColor(red: 197, green: 203, blue: 227, alpha: 1.0)
        loginSegmentedControl.tintColor = .white
        loginSegmentedControl.layer.cornerRadius = 5
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func signLogInButtonTapped(_ sender: UIButton) {
        if let email = emailTextField.text,
                    !email.isEmpty,
                    let password = passwordTextField.text,
                    !password.isEmpty {
                    let user = User(username: username, password: password)
                    if loginType == .signUp {
                        toDoItemController?.signUp(with: user, completion: { (result) in
                            do {
                                let success = try result.get()
                                if success {
                                    DispatchQueue.main.async {
                                        let alertController = UIAlertController(title: "Sign Up Successful", message: "Now please log in.", preferredStyle: .alert)
                                        let alertAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                                        alertController.addAction(alertAction)
                                        self.present(alertController, animated: true) {
                                            self.loginType = .signIn
                                            self.loginTypeSegmentedControl.selectedSegmentIndex = 1
                                            self.signInButton.setTitle("Sign In", for: .normal)
                                        }
                                    }
                                }
                            } catch {
                                print("Error signing up: \(error)")
                            }
                        })
                    } else {
                        toDoItemController?.signIn(with: user, completion: { (result) in
                            do {
                                let success = try result.get()
                                if success {
                                    DispatchQueue.main.async {
                                        self.dismiss(animated: true, completion: nil)
                                    }
                                }
                            } catch {
                                if let error = error as? APIController.NetworkError {
                                    switch error {
                                    case .failedSignIn:
                                        print("Sign in failed")
                                    case .noToken, .noData:
                                        print("No data received")
                                    default:
                                        print("Other error occurred")
                                    }
                                }
                            }
                        })
                    }
                }
            }
            
            
        
        
        @IBAction func signInTypeChanged(_ sender: UISegmentedControl) {
            if sender.selectedSegmentIndex == 0 {
                loginType = .signUp
                signUpButton.setTitle("sign Up", for: .normal)
            } else {
                loginType = .signIn
                signUpButton.setTitle("Sign In", for: .normal)
            }
        }
}
