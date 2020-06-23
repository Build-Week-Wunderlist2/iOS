//
//  ToDoListTableViewController.swift
//  Wunderlist2.0
//
//  Created by Claudia Contreras on 6/22/20.
//  Copyright © 2020 thecoderpilot. All rights reserved.
//

import UIKit

class ToDoListTableViewController: UITableViewController, UITextFieldDelegate {

    // MARK: - Properties
    private let loginController = LoginController()
    private let toDoItemController = ToDoItemController()
    
    var newListName: UITextField?
    var ToDoLists: [ToDoList] = [] {
        didSet {
        tableView.reloadData()
        }
    }
    var bearer: Bearer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if loginController.bearer == nil {
            performSegue(withIdentifier: "LoginViewModalSegue", sender: self)
        }
    }

    // MARK: - IBAction
    @IBAction func addNewToDoList(_ sender: Any) {
        addNewList()
    }
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ToDoLists.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ToDoListTableViewCell.reuseIdentifier, for: indexPath) as? ToDoListTableViewCell else { return UITableViewCell() }

        cell.toDoList = ToDoLists[indexPath.row]
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
  // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "LoginViewModalSegue",
            let loginVC = segue.destination as? WunderlistLoginViewController {
            loginVC.loginController = loginController
        }
    }
    
    // MARK: - Functions
    func addNewList() {
                bearer = loginController.bearer
        let dialogMessage = UIAlertController(title: "NewList", message: "Enter your new list name", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default) { (action) in
            guard let bearer = self.bearer else { return }
            
            if let userInput = self.newListName!.text {
                let newList = ToDoList(id: nil, title: userInput, userID: Int16(bearer.userID), date: Date(), complete: false)
                self.ToDoLists.append(newList)
            }
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
        }
        
        dialogMessage.addAction(ok)
        dialogMessage.addAction(cancel)
        
        dialogMessage.addTextField { (textfield) in
            self.newListName = textfield
            self.newListName?.placeholder = "Type your list name"
        }
        self.present(dialogMessage, animated: true, completion: nil)
        tableView.reloadData()
        print(ToDoLists)
    }

}
