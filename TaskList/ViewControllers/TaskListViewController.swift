//
//  ViewController.swift
//  TaskList
//
//  Created by Alexey Efimov on 02.04.2023.
//

import UIKit

final class TaskListViewController: UITableViewController {
    
    private let storageManager = StorageManager.shared
    
    private let cellID = "task"
    private var taskList: [Task] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        setupNavigationBar()
        fetchData()
    }
    
    private func addNewTask() {
        showAlert(for: .add, nil)
    }
    
    private func fetchData() {
        let fetchRequest = Task.fetchRequest()
        
        do {
            taskList = try storageManager.persistentContainer.viewContext.fetch(fetchRequest)
        } catch {
            print(error)
        }
    }
        
    private func save(_ taskName: String) {
        let task = Task(context: storageManager.persistentContainer.viewContext)
        task.title = taskName
        taskList.append(task)
        
        let indexPath = IndexPath(row: taskList.count - 1, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
        
        saveToCoreData()
    }
    
    private func delete(at indexPath: Int) {
        let taskToDelete = taskList[indexPath]
        
        taskList.remove(at: indexPath)
        
        storageManager.persistentContainer.viewContext.delete(taskToDelete)
        saveToCoreData()
    }
    
    private func redactTask(at indexPath: Int, with value: String) {
        taskList[indexPath].title = value
        saveToCoreData()
            }
    
    private func saveToCoreData() {
        if storageManager.persistentContainer.viewContext.hasChanges {
            do {
                try storageManager.persistentContainer.viewContext.save()
            } catch {
                print(error)
            }
        }
    }
}

// MARK: - Setup UI
private extension TaskListViewController {
    func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.backgroundColor = UIColor(named: "MilkBlue")
        
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            systemItem: .add,
            primaryAction: UIAction { [unowned self] _ in
                addNewTask()
            }
        )
        
        navigationController?.navigationBar.tintColor = .white
    }
}

// MARK: - Alert Controller
extension TaskListViewController {
    func showAlert(for action: Action, _ indexPath: IndexPath?) {
        
        
        let alert = UIAlertController(
            title: action.title,
            message: action.message,
            preferredStyle: .alert
        )
        
        let saveAction = UIAlertAction(title: "Save Task", style: .default) { [weak self] _ in
                guard let task = alert.textFields?.first?.text, !task.isEmpty else { return }
            if action == .add {
                self?.save(task)
            } else {
                guard let indexPath = indexPath else { return }
                self?.redactTask(at: indexPath.row, with: task)
                self?.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        alert.addTextField { [weak self] textField in
            textField.placeholder = "New Task"
            if action == .redact {
                guard let indexPath = indexPath else { return }
                alert.textFields?.first?.text = self?.taskList[indexPath.row].title
            }
        }
        present(alert, animated: true)
    }
    
    enum Action {
        case add
        case redact
        
        var title: String {
            switch self {
            case .add:
                return "New Task"
            case .redact:
                return  "Redact Task"
            }
        }
        
        var message: String {
            switch self {
            case .add:
                return "What do you want to do?"
            case .redact:
                return "Enter new name for the task"
            }
        }
    }
}

// MARK: - UITableViewDelegate
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showAlert(for: .redact, indexPath)
        
    }
}

// MARK: - UITableViewDataSource
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let task = taskList[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = task.title
        cell.contentConfiguration = content
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            delete(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}
