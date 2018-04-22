//
//  EditNotebooksPresenter.swift
//  Everpobre
//
//  Created by VINACHES LOPEZ JORGE on 16/04/2018.
//  Copyright © 2018 Jorge Vinaches. All rights reserved.
//

import Foundation
import UIKit
import CoreData

protocol EditNotebooksPresenterDelegate: class {
    func reloadData()
}

struct EditNotebooksPresenter {
    private let viewController: EditNotebooksViewController
    private weak var delegate: EditNotebooksPresenterDelegate?
    var notebooks: [Notebook] {
        get {
            return fetchedResultController?.fetchedObjects ?? []
        }
    }
    
    private var fetchedResultController: NSFetchedResultsController<Notebook>!
    
    init(viewController: EditNotebooksViewController, delegate: EditNotebooksPresenterDelegate) {
        self.viewController = viewController
        self.delegate = delegate
    }
    
    mutating func viewDidLoad() {
        fetchNotebooks()
    }
    
    private mutating func fetchNotebooks() {
        let viewMOC = DataManager.sharedManager.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<Notebook>(entityName: "Notebook")
        
        let sortByDefault = NSSortDescriptor(key: "isDefault", ascending: false)
        let sortByName = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortByDefault, sortByName]
                
        fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: viewMOC, sectionNameKeyPath: nil, cacheName: nil)
        
        try! fetchedResultController.performFetch()
        
        fetchedResultController.delegate = viewController
        
        delegate?.reloadData()
    }
    
    func getNotebook(at indexPath: IndexPath) -> Notebook {
        return fetchedResultController.object(at: indexPath)
    }
    
    func getNotesForNotebook(_ section: Int) -> Int {
        return fetchedResultController.sections![section].numberOfObjects
    }
    
    func selectDefaultNotebook(at indexPath: IndexPath) {
        let notebook = fetchedResultController.object(at: indexPath)
        if notebook.isDefault {
            return
        }
        
        NotebookManager.setDefaultNotebook(notebook: notebook) {
            print("//--> SETTED DEFAULT!!")
        }
    }
    
    func deleteNotebook(for indexPath: IndexPath) {
        let notebook = fetchedResultController.object(at: indexPath)
        if notebook.isDefault {
            return
        }
        
        NotebookManager.deleteNotebook(notebook: notebook) {
            print("//--> DELETED!!")
        }
    }
    
    func reassignNotes(for indexPath: IndexPath) {
        let notebook = fetchedResultController.object(at: indexPath)
        if notebook.isDefault {
            return
        }
        
        let reassignNotesViewController = ReassignNotesViewController()
        reassignNotesViewController.notebook = notebook
        
        viewController.navigationController?.pushViewController(reassignNotesViewController, animated: true)
    }
}
