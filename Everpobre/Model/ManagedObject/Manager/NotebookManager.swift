//
//  NotebookManager.swift
//  Everpobre
//
//  Created by VINACHES LOPEZ JORGE on 12/04/2018.
//  Copyright © 2018 Jorge Vinaches. All rights reserved.
//

import Foundation
import CoreData

struct NotebookManager {
    static func createNotebook(name: String, isDefault: Bool, completion: (() -> Void)?) {
        let privateMOC = DataManager.sharedManager.persistentContainer.newBackgroundContext()
        
        privateMOC.perform {
            let notebook = NSEntityDescription.insertNewObject(forEntityName: "Notebook", into: privateMOC) as! Notebook
            notebook.name = name
            notebook.isDefault = isDefault
            
            try! privateMOC.save()
            
            if let completion = completion {
                completion()
            }
        }
    }
    
    static func setDefaultNotebook(notebook: Notebook, completion: (() -> Void)?) {
        let privateMOC = notebook.managedObjectContext!
        
        privateMOC.perform {
            let fetchRequestNotebook = NSFetchRequest<Notebook>(entityName: "Notebook")
            
            let sortByName = NSSortDescriptor(key: "name", ascending: true)
            fetchRequestNotebook.sortDescriptors = [sortByName]
            
            let fetchedResultNotebookController = NSFetchedResultsController(fetchRequest: fetchRequestNotebook, managedObjectContext: privateMOC, sectionNameKeyPath: nil, cacheName: nil)
            
            try! fetchedResultNotebookController.performFetch()
            
            if let fetchedResult = fetchedResultNotebookController.fetchedObjects {
                for notebook in fetchedResult {
                    notebook.isDefault = false
                }
            }
            
            notebook.isDefault = true
            
            try! privateMOC.save()
            
            completion?()
        }
    }
    
    static func deleteNotebook(notebook: Notebook, completion: (() -> Void)?) {
        let privateMOC = notebook.managedObjectContext!
        
        privateMOC.perform {
            let fetchRequestNotes = NSFetchRequest<Note>(entityName: "Note")
            
            let sortByTitle = NSSortDescriptor(key: "title", ascending: true)
            fetchRequestNotes.sortDescriptors = [sortByTitle]
            
            let predicate = NSPredicate(format: "notebook.name == %@", notebook.name!)
            fetchRequestNotes.predicate = predicate
            
            let fetchedResultNotesController = NSFetchedResultsController(fetchRequest: fetchRequestNotes, managedObjectContext: privateMOC, sectionNameKeyPath: nil, cacheName: nil)
            
            try! fetchedResultNotesController.performFetch()
            
            if let fetchedResult = fetchedResultNotesController.fetchedObjects {
                for note in fetchedResult {
                    privateMOC.delete(note)
                }
            }
            
            privateMOC.delete(notebook)
            
            try! privateMOC.save()
            
            completion?()
        }
    }
}
