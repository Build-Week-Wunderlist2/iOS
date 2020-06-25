//
//  ToDoListTableViewController.swift
//  Wunderlist2.0
//
//  Created by Claudia Contreras on 6/22/20.
//  Copyright © 2020 thecoderpilot. All rights reserved.
//

import UIKit
import CoreData

class ToDoListTableViewController: UITableViewController, UITextFieldDelegate {
    
    // MARK: - Properties
    private let loginController = LoginController()
    private let toDoItemController = ToDoItemController()
    private let toDoListController = ToDoListController()
    
    var newListName: UITextField?
    var toDoLists: [ToDoList] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    var bearer: Bearer?
    
    lazy var fetchedResultsController: NSFetchedResultsController<ToDoList> = {
        let fetchRequest: NSFetchRequest<ToDoList> = ToDoList.fetchRequest()
        
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "title", ascending: true)
        ]
        // Create a constant that references your core data stack's mainContext.
        let fetchRequestController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                managedObjectContext: CoreDataStack.shared.mainContext,
                                                                sectionNameKeyPath: "title",
                                                                cacheName: nil)
        
        fetchRequestController.delegate = self
        // Perform the fetch request using the fetched results controller
        try! fetchRequestController.performFetch()
        return fetchRequestController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        #warning("get items from server somehow")
        if  let bearer = bearer {
            toDoListController.fetchToDoListFromServer(bearer: bearer)
            tableView.reloadData()
        }
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
        return fetchedResultsController.sections?.count ?? 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ToDoListTableViewCell.reuseIdentifier, for: indexPath) as? ToDoListTableViewCell else { return UITableViewCell() }
        cell.toDoList = fetchedResultsController.object(at: indexPath)
        return cell
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let list = fetchedResultsController.object(at: indexPath)
            
            //ToDoListController.deleteEntryFromServer(entry: entry)
            
            let context = CoreDataStack.shared.mainContext
            
            context.delete(list)
            
            do {
                try context.save()
            } catch {
                NSLog("Error saving context after deleting Task: \(error)")
                context.reset()
            }
        }
    }
    
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

                self.toDoListController.put(title: userInput, complete: false, bearer: bearer)
                //self.toDoListController.fetchToDoListFromServer(bearer: bearer)
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
    }
    
}

// MARK: - Extension
extension ToDoListTableViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
        default:
            break
        }
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { return }
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .update:
            guard let indexPath = indexPath else { return }
            tableView.reloadRows(at: [indexPath], with: .automatic)
        case .move:
            guard let oldIndexPath = indexPath,
            let newIndexPath = newIndexPath else { return }
            tableView.deleteRows(at: [oldIndexPath], with: .automatic)
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .delete:
            guard let indexPath = indexPath else { return }
            tableView.deleteRows(at: [indexPath], with: .automatic)
        @unknown default:
            break
        }
    }
}
