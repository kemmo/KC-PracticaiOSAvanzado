//
//  EditNotebooksViewController.swift
//  Everpobre
//
//  Created by VINACHES LOPEZ JORGE on 16/04/2018.
//  Copyright © 2018 Jorge Vinaches. All rights reserved.
//

import UIKit
import CoreData

class EditNotebooksViewController: UIViewController, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    private lazy var presenter = EditNotebooksPresenter(viewController: self, delegate: self)

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        presenter.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter.fetchNotebooks()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addAction(_ sender: Any) {
        showNotebookNameAlert()
    }
    
    func showNotebookNameAlert() {
        let alertController = UIAlertController(title: "Create new Notebook", message: "", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Save", style: .default, handler: {
            alert -> Void in
            let nameField = alertController.textFields![0] as UITextField
            
            if nameField.text != "", nameField.text != "" {
                NotebookManager.createNotebook(name: nameField.text!, isDefault: false, completion: nil)
            } else {
                let errorAlert = UIAlertController(title: "Error", message: "Please write a name", preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: {
                    alert -> Void in
                    self.present(alertController, animated: true, completion: nil)
                }))
                self.present(errorAlert, animated: true, completion: nil)
            }
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { alert -> Void in
            alertController.dismiss(animated: false, completion: nil)
        }))
        
        alertController.addTextField(configurationHandler: { (textField) -> Void in
            textField.placeholder = "Name"
            textField.textAlignment = .center
        })
        
        self.present(alertController, animated: true, completion: nil)
    }

}

extension EditNotebooksViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.notebooks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "reuseIdentifier")
        }
        let notebook = presenter.getNotebook(at: indexPath)
        cell?.textLabel?.text = notebook.name
        if notebook.isDefault {
            cell?.accessoryType = .checkmark
        } else {
            cell?.accessoryType = .none
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let notebook = presenter.getNotebook(at: indexPath)

        if notebook.isDefault {
            return []
        }
        
        var rowActions = [UITableViewRowAction]()
        
        let delete =  UITableViewRowAction(style: .destructive, title: "Delete") { action, index in
            let alertController = UIAlertController(title: "Delete notebook \(notebook.name!)", message: "Choose an option for the notes in the notebook", preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: "Reassign notes to other notebook", style: .default, handler: { alert -> Void in
                self.presenter.reassignNotes(for: indexPath)
            }))
            
            alertController.addAction(UIAlertAction(title: "Delete all notes", style: .destructive, handler: { alert -> Void in
                self.presenter.deleteNotebook(for: indexPath)
            }))
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { alert -> Void in
                alertController.dismiss(animated: false, completion: nil)
            }))
            
            self.present(alertController, animated: true, completion: nil)
        }
        rowActions.append(delete)
        
        let setDefault =  UITableViewRowAction(style: .normal, title: "Set default") { action, index in
            self.presenter.selectDefaultNotebook(at: indexPath)
        }
        rowActions.append(setDefault)
        
        return rowActions
    }
}

extension EditNotebooksViewController: EditNotebooksPresenterDelegate {
    func reloadData() {
        tableView.reloadData()
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension EditNotebooksViewController {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if let _ = controller as? NSFetchedResultsController<Notebook> {
            presenter.fetchNotebooks()
        }
    }
}
