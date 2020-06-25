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
    @IBOutlet weak var dateLabel: UILabel!
    
    // MARK: - IBAction
    @IBAction func completedIButtonToggled(_ sender: Any) {
        guard let toDoList = toDoList else { return }
        
        toDoList.complete.toggle()
        
        completedButton.setImage((toDoList.complete) ? UIImage(systemName: "circle.fill") : UIImage(systemName: "circle"), for: .normal)
        
        do {
            try CoreDataStack.shared.mainContext.save()
        } catch {
            NSLog("Error Saving managed object context: \(error)")
        }
    }
    
    // MARK: - Functions
    private func updateViews() {
        guard let toDoList = toDoList else { return }
        print("ToDo: \(toDoList)")
        TitleLabel.text = toDoList.title
        
        dateLabel.text = dateFormatter.string(from: toDoList.date!)
    }
    
    var dateFormatter: DateFormatter =  {
           let formatter = DateFormatter()
           formatter.dateFormat = "MM-dd-yyyy h:mm a"
           formatter.timeZone = TimeZone(abbreviation: "PST")
           return formatter
       }()
       
       func string(from date: Date) -> String {
              
              return dateFormatter.string(from: date)
          }
    
}




