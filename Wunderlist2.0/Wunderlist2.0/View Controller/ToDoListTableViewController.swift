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

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var searchBar: UISearchBar!
    
    
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
    

//    lazy var fetchedResultsController: NSFetchedResultsController<ToDoItem> = {
//        let fetchRequest: NSFetchRequest<ToDoItem> = ToDoItem.fetchRequest()
//        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true),
//                                        NSSortDescriptor(key: "title", ascending: true)]
//        let moc = CoreDataStack.shared.mainContext
//        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: moc, sectionNameKeyPath: "date", cacheName: nil)
//        frc.delegate = self
//        try! frc.performFetch()
//        return frc
//    }()
    
    override func viewDidLoad() {
        view.backgroundColor = UIColor(red: 239/255, green: 226/255, blue: 186/255, alpha: 1.0)
        UISegmentedControl.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor(red: 64/255, green: 86/255, blue: 161/255, alpha: 1.0)], for: .selected)
        segmentedControl.backgroundColor = UIColor(red: 197/255, green: 203/255, blue: 227/255, alpha: 1.0)
        super.viewDidLoad()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         toDoItemController.fetchToDoItemsFromServer()
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
       return 1
//        return fetchedResultsController.sections?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
        return ToDoLists.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ToDoListTableViewCell.reuseIdentifier, for: indexPath) as? ToDoListTableViewCell else { return UITableViewCell() }
        cell.toDoList = ToDoLists[indexPath.row]
        return cell
    }
    
//    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        guard let sectionInfo = fetchedResultsController.sections?[section] else { return nil }
//        return sectionInfo.name.capitalized
//    }

//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            let toDoToDelete = fetchedResultsController.object(at: indexPath)
//
//            toDoItemController.deleteToDoItemFromServer(toDoToDelete)
//
//            let moc = CoreDataStack.shared.mainContext
//            moc.delete(toDoToDelete)
//            do {
//                try moc.save()
//            } catch {
//                moc.reset()
//                NSLog("Error saving managed object context: \(error)")
//            }
//        }
//    }

    
  // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "LoginViewModalSegue",
            let loginVC = segue.destination as? WunderlistLoginViewController {
            loginVC.loginController = loginController
        }
        if segue.identifier == "ToDodetail",
            let detailVC = segue.destination as? ToDoListDetailViewController {
            if let indexPath = tableView.indexPathForSelectedRow {
                detailVC.toDo = ToDoLists[indexPath]
                detailVC.toDoItemController = toDoItemController
            }
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
        print("ToDoLists: \(ToDoLists)")
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

