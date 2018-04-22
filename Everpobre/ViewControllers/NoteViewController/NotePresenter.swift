//
//  NotePresenter.swift
//  Everpobre
//
//  Created by VINACHES LOPEZ JORGE on 19/04/2018.
//  Copyright © 2018 Jorge Vinaches. All rights reserved.
//

import Foundation
import CoreData

protocol NotePresenterDelegate: class {
    
}

class NotePresenter {
    private let viewController: NoteViewController
    private weak var delegate: NotePresenterDelegate?
    var notebooks: [Notebook] {
        get {
            return fetchedResultController?.fetchedObjects ?? []
        }
    }
    
    private var fetchedResultController: NSFetchedResultsController<Notebook>!
    
    init(viewController: NoteViewController, delegate: NotePresenterDelegate) {
        self.viewController = viewController
        self.delegate = delegate
    }
    
    func fetchNotebooks(less notebookName: String) {
        let viewMOC = DataManager.sharedManager.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<Notebook>(entityName: "Notebook")
        
        let sortByDefault = NSSortDescriptor(key: "isDefault", ascending: false)
        let sortByName = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortByDefault, sortByName]
        
        let predicate = NSPredicate(format: "name != %@", notebookName)
        fetchRequest.predicate = predicate
        
        fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: viewMOC, sectionNameKeyPath: nil, cacheName: nil)
        
        try! fetchedResultController.performFetch()
    }
    
    func getNotebook(at position: Int) -> Notebook {
        return fetchedResultController.fetchedObjects![position]
    }
}
