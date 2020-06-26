//
//  ToDoTableViewCell.swift
//  Wunderlist2.0
//
//  Created by David Williams on 6/19/20.
//  Copyright © 2020 thecoderpilot. All rights reserved.
//

import UIKit

class ToDoTableViewCell: UITableViewCell {
    // MARK: - IBOutlets
    
    @IBOutlet weak var completeButton: UIButton!
    @IBOutlet weak var toDoTitleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    // MARK: - Properties
    var toDoItem: ToDoItem? {
        didSet {
            updateViews()
        }
    }

    // MARK: - IBActions
    
    @IBAction func toggleComplete(_ sender: UIButton) {
        toDoItem?.complete.toggle()
        
        guard let toDoItem = toDoItem else { return }
        
        completeButton.setImage((toDoItem.complete) ? UIImage(systemName: "checkmark.circle.fill") : UIImage(systemName: "circle"), for: .normal)
        
        do {
            try CoreDataStack.shared.mainContext.save()
        } catch {
            NSLog("Error Saving managed object context: \(error)")
        }
    }
    
    // MARK: - Functions
    private func updateViews() {
        guard let toDoItem = toDoItem else { return }
        
        toDoTitleLabel.text = toDoItem.description
        completeButton.setImage((toDoItem.complete) ? UIImage(systemName: "checkmark.circle.fill") : UIImage(systemName: "circle"), for: .normal)
    }
    
}
