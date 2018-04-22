//
//  NoteManager.swift
//  Everpobre
//
//  Created by VINACHES LOPEZ JORGE on 12/04/2018.
//  Copyright © 2018 Jorge Vinaches. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class NoteManager {
    static func createQuickNote() {
        let privateMOC = DataManager.sharedManager.persistentContainer.newBackgroundContext()
        
        privateMOC.perform {
            let note = NSEntityDescription.insertNewObject(forEntityName: "Note", into: privateMOC) as! Note

            let fetchRequestNotebook = NSFetchRequest<Notebook>(entityName: "Notebook")
            
            let sortByName = NSSortDescriptor(key: "name", ascending: true)
            fetchRequestNotebook.sortDescriptors = [sortByName]
            
            let predicate = NSPredicate(format: "isDefault == %d", true)
            fetchRequestNotebook.predicate = predicate
            
            let fetchedResultNotebookController = NSFetchedResultsController(fetchRequest: fetchRequestNotebook, managedObjectContext: privateMOC, sectionNameKeyPath: nil, cacheName: nil)
            
            try! fetchedResultNotebookController.performFetch()
            
            if let fetchedResult = fetchedResultNotebookController.fetchedObjects {
                if fetchedResult.count > 0 {
                    note.title = "newNote"
                    note.createdAtTI = Date().timeIntervalSince1970
                    note.notebook = fetchedResult[0]
                    
                    try! privateMOC.save()
                } else {
                    NotebookManager.createNotebook(name: "Mi notebook", isDefault: false, completion: {
                        self.createQuickNote()
                    })
                }
            } else {
                NotebookManager.createNotebook(name: "Mi notebook", isDefault: false, completion: {
                    self.createQuickNote()
                })
            }
        }
    }
    
    static func createNote(with title: String, createdDate: Double, expirationDate: Double, content: String, latitude: Double?, longitude: Double?, pictures: [UIImage], in notebook: String, completion: (() -> Void)?) {
        let privateMOC = DataManager.sharedManager.persistentContainer.newBackgroundContext()
        
        privateMOC.perform {
            let note = NSEntityDescription.insertNewObject(forEntityName: "Note", into: privateMOC) as! Note
            
            let fetchRequestNotebook = NSFetchRequest<Notebook>(entityName: "Notebook")
            
            let sortByName = NSSortDescriptor(key: "name", ascending: true)
            fetchRequestNotebook.sortDescriptors = [sortByName]
            
            let predicate = NSPredicate(format: "name == %@", notebook)
            fetchRequestNotebook.predicate = predicate
            
            let fetchedResultNotebookController = NSFetchedResultsController(fetchRequest: fetchRequestNotebook, managedObjectContext: privateMOC, sectionNameKeyPath: nil, cacheName: nil)
            
            try! fetchedResultNotebookController.performFetch()
            
            if let fetchedResult = fetchedResultNotebookController.fetchedObjects {
                if fetchedResult.count > 0 {
                    note.title = title
                    note.createdAtTI = createdDate
                    note.expiredAtTI = expirationDate
                    note.content = content
                    note.notebook = fetchedResult[0]
                    note.hasMap = false
                    
                    if let latitude = latitude, let longitude = longitude {
                        note.latitude = latitude
                        note.longitude = longitude
                        note.hasMap = true
                    }
                    
                    try! privateMOC.save()
                    
                    for picture in pictures {
                        let p = NSEntityDescription.insertNewObject(forEntityName: "Picture", into: privateMOC) as! Picture
                        p.picture = UIImageJPEGRepresentation(picture, 0.0)
                        p.note = note
                        
                        try! privateMOC.save()
                    }
                    
                    completion?()
                } else {
                    NotebookManager.createNotebook(name: "Mi notebook", isDefault: false, completion: {
                        self.createNote(with: title, createdDate: createdDate, expirationDate: expirationDate, content: content, latitude: latitude, longitude: longitude, pictures: pictures, in: notebook, completion: completion)
                    })
                }
            } else {
                NotebookManager.createNotebook(name: "Mi notebook", isDefault: false, completion: {
                    self.createNote(with: title, createdDate: createdDate, expirationDate: expirationDate, content: content, latitude: latitude, longitude: longitude, pictures: pictures, in: notebook, completion: completion)
                    
                })
            }
        }
    }
    
    static func deleteNote(note: Note) {
        let privateMOC = note.managedObjectContext!
        
        privateMOC.perform {
            privateMOC.delete(note)
            
            try! privateMOC.save()
        }
    }
}
