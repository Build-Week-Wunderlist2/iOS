//
//  CreateNewToDoItemViewController.swift
//  Wunderlist2.0
//
//  Created by Claudia Contreras on 6/24/20.
//  Copyright © 2020 thecoderpilot. All rights reserved.
//

import UIKit

class CreateNewToDoItemViewController: UIViewController {

    // MARK: - Properties
    var todoItemComplete = false
    var repeatsDaily = false
    var repeatsWeekly = false
    var repeatsMonthly = false
    
    var toDoItemID: Int16 = 0
    var bearer: Bearer?
    
    private var todoItemController = ToDoItemController()
    private var loginController: LoginController?
    
    // MARK: - IBOutlets
    @IBOutlet var completeButton: UIButton!
    @IBOutlet var desctiptionText: UITextField!
    @IBOutlet var repeatsSegmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - IBActions
    @IBAction func completeButtonToggled(_ sender: UIButton) {
        todoItemComplete.toggle()
        
        sender.setImage(todoItemComplete ? UIImage(systemName: "checkmark.circle.fill") : UIImage(systemName: "circle"), for: .normal)
    }

    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let description = desctiptionText.text else { return }
        
        let repeatSelected = repeatsSegmentedControl.selectedSegmentIndex
        let repeatSelection = RepeatSelection.allCases[repeatSelected]
        
        switch repeatSelection {
        case .daily:
            repeatsDaily = true
        case .monthly:
            repeatsMonthly = true
        case .weekly:
            repeatsWeekly = true
        case .none:
            break
        }
        guard let bearer = bearerGlobal else { return }
        
        todoItemController.put(bearer: bearer, complete: todoItemComplete, description: description, toDoID: Int(toDoItemID), repeatsDaily: repeatsDaily, repeatsWeekly: repeatsWeekly, repeatsMonthly: repeatsMonthly)
        ToDoItem(id: 0, date: Date(), complete: todoItemComplete, toDoDescription: description, toDoID: toDoItemID, deadline: Date(), repeatsDaily: repeatsDaily, repeatsWeekly: repeatsWeekly, repeatsMonthly: repeatsMonthly, context: CoreDataStack.shared.mainContext)
        
        do {
                try CoreDataStack.shared.mainContext.save()
                navigationController?.dismiss(animated: true, completion: nil)
            } catch {
                NSLog("Error saving manage object context: \(error)")
            }
        
        navigationController?.dismiss(animated: true, completion: nil)
    }
}
