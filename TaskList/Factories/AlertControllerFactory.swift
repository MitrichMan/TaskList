//
//  AlertControllerFactory.swift
//  TaskList
//
//  Created by Dmitrii Melnikov on 06.04.2023.
//

import UIKit

protocol AlertControllerProtocol {
    func createAlert(completion: @escaping (String) -> Void) -> UIAlertController
}

final class AlertControllerFactory: AlertControllerProtocol {
    let userAction: UserAction
    let taskTitle: String?
    
    init(userAction: UserAction, taskTitle: String?) {
        self.userAction = userAction
        self.taskTitle = taskTitle
    }
    
    func createAlert(completion: @escaping (String) -> Void) -> UIAlertController {
        let alert = UIAlertController(
            title: userAction.title,
            message: userAction.message,
            preferredStyle: .alert
        )
        
        let saveAction = UIAlertAction(title: "Save Task", style: .default) { _ in
            guard let task = alert.textFields?.first?.text, !task.isEmpty else { return }
            guard !task.isEmpty else { return }
            completion(task)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        alert.addTextField { [weak self] textField in
            textField.placeholder = "Task"
            textField.text = self?.taskTitle
        }
        
        return alert
    }
}

extension AlertControllerFactory {
    enum UserAction {
        case add
        case edit
        
        var title: String {
            switch self {
            case .add:
                return "New Task"
            case .edit:
                return  "Redact Task"
            }
        }
        
        var message: String {
            switch self {
            case .add:
                return "What do you want to do?"
            case .edit:
                return "Enter new name for the task"
            }
        }
    }
}
