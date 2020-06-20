//
//  WunderListViewController.swift
//  Wunderlist2.0
//
//  Created by David Williams on 6/19/20.
//  Copyright © 2020 thecoderpilot. All rights reserved.
//

import UIKit

class WunderListViewController: UIViewController {

    var signLogIn = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func signInLogInButtonPressed(_ sender: UIButton) {
    switch sender.tag {
          case 0:
              signLogIn = "Sign Up"
          case 1:
               signLogIn = "Log In"
          default:
              break
          }
             
                  let alert = UIAlertController(title: "Email & Password", message: "", preferredStyle: .alert)
                  alert.addTextField { (textField) in
                      textField.text = ""
                      textField.placeholder = "Please enter your email"
                      textField.font = UIFont(name: "Alegreya", size: 14)
                      
                  }
                  
                  alert.addTextField { (textField) in
                      textField.text = ""
                      textField.placeholder = "Please enter your password"
                      textField.textContentType = .password
                      textField.font = UIFont(name: "Alegreya", size: 14)
                  }
                  alert.addAction(UIAlertAction(title: "\(signLogIn)", style: .destructive, handler: { [weak alert](_) in
                      if let textField = alert?.textFields?[0],
                          let password = alert?.textFields?[1] {
                          if let email = textField.text,
                              !email.isEmpty,
                              let password = password.text,
                              !password.isEmpty {
                              
                          }
                      }
                  }))
                  self.present(alert, animated: true, completion: nil)
    }
}
