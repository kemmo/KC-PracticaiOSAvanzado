//
//  ReassignNotesPresenter.swift
//  Everpobre
//
//  Created by VINACHES LOPEZ JORGE on 17/04/2018.
//  Copyright © 2018 Jorge Vinaches. All rights reserved.
//

import Foundation

import UIKit
import CoreData

protocol ReassignNotesPresenterDelegate: class {
    func reloadData()
    func dismissView()
}

class ReassignNotesPresenter {
    private let viewController: ReassignNotesViewController
    private weak var delegate: ReassignNotesPresenterDelegate?
    private let notebook: Notebook
    
    var notes: [Note] {
        get {
            return fetchedResultController?.fetchedObjects ?? []
        }
    }
    
    var notebooks: [Notebook] {
        get {
            return fetchedNotebookResultController?.fetchedObjects ?? []
        }
    }
    
    private var fetchedResultController: NSFetchedResultsController<Note>!
    private var fetchedNotebookResultController: NSFetchedResultsController<Notebook>!
    
    init(viewController: ReassignNotesViewController, notebook: Notebook, delegate: ReassignNotesPresenterDelegate) {
        self.viewController = viewController
        self.delegate = delegate
        self.notebook = notebook
    }
    
    func viewDidLoad() {
        fetchNotes()
    }
    
    private func fetchNotes() {
        let privateMOC = DataManager.sharedManager.persistentContainer.newBackgroundContext()
    
        let fetchRequestNotes = NSFetchRequest<Note>(entityName: "Note")
        
        let sortByTitle = NSSortDescriptor(key: "title", ascending: true)
        fetchRequestNotes.sortDescriptors = [sortByTitle]
        
        let predicate = NSPredicate(format: "notebook.name == %@", self.notebook.name!)
        fetchRequestNotes.predicate = predicate
        
        fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequestNotes, managedObjectContext: privateMOC, sectionNameKeyPath: nil, cacheName: nil)
        
        try! fetchedResultController.performFetch()
        
        let fetchRequestNotebook = NSFetchRequest<Notebook>(entityName: "Notebook")
        
        let sortByName = NSSortDescriptor(key: "name", ascending: false)
        fetchRequestNotebook.sortDescriptors = [sortByName]
        
        let predicateNotebook = NSPredicate(format: "name != %@", self.notebook.name!)
        fetchRequestNotebook.predicate = predicateNotebook
        
        fetchedNotebookResultController = NSFetchedResultsController(fetchRequest: fetchRequestNotebook, managedObjectContext: privateMOC, sectionNameKeyPath: nil, cacheName: nil)
        
        try! fetchedNotebookResultController.performFetch()
                
        self.delegate?.reloadData()
    }
    
    func getNote(at indexPath: IndexPath) -> Note {
        return fetchedResultController.object(at: indexPath)
    }
    
    func reassignNote(_ note: Note, option: Int, last: Bool) {
        let privateMOC = note.managedObjectContext!
        
        privateMOC.perform {
            if(option == 0) {
                privateMOC.delete(note)
            } else {
                note.notebook = self.notebooks[option-1]
            }
            
            try! privateMOC.save()
            
            if last {
                NotebookManager.deleteNotebook(notebook: self.notebook, completion: {
                    self.delegate?.dismissView()
                })
            }
        }
    }
}
