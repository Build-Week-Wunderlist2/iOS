//
//  ToDoListDetailViewController.swift
//  Wunderlist2.0
//
//  Created by David Williams on 6/23/20.
//  Copyright © 2020 thecoderpilot. All rights reserved.
//

import UIKit

class ToDoListDetailViewController: UIViewController {
    
    // MARK: - Properties
    
    var wasEdited: Bool = false
    
    var toDoItemController: ToDoItemController? = nil
    var toDo: ToDoItem? {
        didSet {
            updateViews()
        }
    }
    
    // MARK: - Outlets
    @IBOutlet weak var toDoNameTextField: UITextField!
    @IBOutlet weak var completeButton: UIButton!
    @IBOutlet weak var toDoDescriptionTextView: UITextView!
    @IBOutlet weak var repeatButton: UIButton!
    @IBOutlet weak var repeatSegmentedControl: UISegmentedControl!
    @IBOutlet weak var saveToDo: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = editButtonItem
        view.backgroundColor = UIColor(red: 239/255, green: 226/255, blue: 186/255, alpha: 1.0)
         updateViews()
        toDoDescriptionTextView.backgroundColor = UIColor(white: 0.85, alpha: 0.75)
        saveToDo.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if wasEdited {
            guard let title = toDoNameTextField.text,
                let description = toDoDescriptionTextView.text,
                !title.isEmpty,
                !description.isEmpty,
                let toDo = toDo else { return }
            
            let complete = completeButton.isSelected
            
            toDo.title = title
            toDo.toDoDescription = description
            toDo.complete = complete
            toDoItemController?.put(toDoItem: toDo, completion: {_ in })
            do {
                try CoreDataStack.shared.mainContext.save()
            } catch {
                NSLog("Error saving managed object context: \(error)")
            }
        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        if editing { wasEdited = true }
        
        [toDoNameTextField, toDoDescriptionTextView, completeButton, repeatButton, repeatSegmentedControl].forEach { $0.isUserInteractionEnabled = editing }
         navigationItem.hidesBackButton = editing
    }
    
    private func updateViews() {
        guard let toDo = toDo else { return }
        toDoNameTextField.text = toDo.title
        toDoDescriptionTextView.text = toDo.toDoDescription
        
        
        completeButton.setImage((toDo.complete) ? UIImage(systemName: "circle.fill") : UIImage(systemName: "circle"), for: .normal)
    }

    @IBAction func completeButtonTapped(_ sender: UIButton) {
        guard let toDo = toDo else { return }
        toDo.complete.toggle()
        completeButton.setImage(((toDo.complete)) ? UIImage(systemName: "circle.fill") : UIImage(systemName: "circle"), for: .normal)
    }
    
    @IBAction func saveToDoButtonTapped(_ sender: Any) {
        
    }
}
