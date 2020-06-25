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
    
    // MARK: - IBOutlets
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var completeButton: UIButton!
    @IBOutlet var toDoDescriptionTextView: UITextView!
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
        guard let title = nameTextField.text, !title.isEmpty,
            let description = toDoDescriptionTextView.text else { return }
        
        let repeatSelected = repeatsSegmentedControl.selectedSegmentIndex
        let repeatSelection = RepeatSelection.allCases[repeatSelected]
        let complete = completeButton
        
        
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
        
        let newTodoItem = ToDoItem(id: 1, title: title, date: Date(), complete: todoItemComplete, toDoDescription: description, toDoID: 1, deadline: Date(), repeatsDaily: repeatsDaily, repeatsWeekly: repeatsWeekly, repeatsMonthly: repeatsMonthly)
        
        do {
            try CoreDataStack.shared.mainContext.save()
            navigationController?.dismiss(animated: true, completion: nil)
        } catch {
            NSLog("Error saving managed object context: \(error)")
        }
        
        navigationController?.dismiss(animated: true, completion: nil)
    }
}
