//
//  ToDoListTableViewCell.swift
//  Wunderlist2.0
//
//  Created by Claudia Contreras on 6/22/20.
//  Copyright © 2020 thecoderpilot. All rights reserved.
//

import UIKit

class ToDoListTableViewCell: UITableViewCell {

    // MARK: - Properties
    static let reuseIdentifier = "toDoListCell"
    
    var toDoList: ToDoList? {
        didSet {
            updateViews()
        }
    }
    // MARK: - IBOutlet
    @IBOutlet var TitleLabel: UILabel!
    @IBOutlet var completedButton: UIButton!
    
    // MARK: - IBAction
    @IBAction func completedIButtonToggled(_ sender: Any) {
        toDoList?.complete.toggle()
        
        guard let toDoList = toDoList else { return }
        
        completedButton.setImage((toDoList.complete) ? UIImage(systemName: "checkmark.circle.fill") : UIImage(systemName: "circle"), for: .normal)
            
            do {
                try CoreDataStack.shared.mainContext.save()
            } catch {
                NSLog("Error Saving managed object context: \(error)")
            }
        }
    
    // MARK: - Functions
    private func updateViews() {
        guard let toDoList = toDoList else { return }
        
        TitleLabel.text = toDoList.title
        completedButton.setImage((toDoList.complete) ? UIImage(systemName: "checkmark.circle.fill") : UIImage(systemName: "circle"), for: .normal)
    }

    }
    
