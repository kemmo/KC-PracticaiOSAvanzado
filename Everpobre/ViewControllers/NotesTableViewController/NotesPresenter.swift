//
//  NotesPresenter.swift
//  Everpobre
//
//  Created by VINACHES LOPEZ JORGE on 12/04/2018.
//  Copyright © 2018 Jorge Vinaches. All rights reserved.
//

import Foundation
import UIKit
import CoreData

protocol NotesPresenterDelegate: class {
    func reloadData()
}

struct NotesPresenter {
    let viewController: NotesTableViewController
    weak var delegate: NotesPresenterDelegate?
    var notes: [Note] {
        get {
            return (fetchedDefaultResultController.fetchedObjects ?? []) + (fetchedNotDefaultResultController.fetchedObjects ?? [])
        }
    }
    
    private var fetchedDefaultResultController: NSFetchedResultsController<Note>!
    private var fetchedNotDefaultResultController: NSFetchedResultsController<Note>!
    
    init(viewController: NotesTableViewController, delegate: NotesPresenterDelegate) {
        self.viewController = viewController
        self.delegate = delegate
    }
    
    mutating func viewDidLoad() {
        fetchNotes()
    }
    
    private mutating func fetchNotes() {
        let viewMOC = DataManager.sharedManager.persistentContainer.viewContext
        
        let fetchNotDefaultRequest = NSFetchRequest<Note>(entityName: "Note")
        
        let sortByName = NSSortDescriptor(key: "notebook.name", ascending: true)
        fetchNotDefaultRequest.sortDescriptors = [sortByName]
        
        let predicate = NSPredicate(format: "notebook.isDefault == %d", false)
        fetchNotDefaultRequest.predicate = predicate
        
        fetchNotDefaultRequest.fetchBatchSize = 25
        
        fetchedNotDefaultResultController = NSFetchedResultsController(fetchRequest: fetchNotDefaultRequest, managedObjectContext: viewMOC, sectionNameKeyPath: "notebook.name", cacheName: nil)
        
        try! fetchedNotDefaultResultController.performFetch()
        
        fetchedNotDefaultResultController.delegate = viewController
        
        let fetchDefaultRequest = NSFetchRequest<Note>(entityName: "Note")
        fetchDefaultRequest.sortDescriptors = [sortByName]
        
        let predicateDefault = NSPredicate(format: "notebook.isDefault == %d", true)
        fetchDefaultRequest.predicate = predicateDefault
        
        fetchedDefaultResultController = NSFetchedResultsController(fetchRequest: fetchDefaultRequest, managedObjectContext: viewMOC, sectionNameKeyPath: "notebook.name", cacheName: nil)
        
        try! fetchedDefaultResultController.performFetch()
        
        fetchedDefaultResultController.delegate = viewController
        
        delegate?.reloadData()
    }
    
    func getNote(at indexPath: IndexPath) -> Note {
        if (fetchedDefaultResultController.sections?.count ?? 0) == 0 {
            return fetchedNotDefaultResultController.sections![indexPath.section].objects![indexPath.row] as! Note
        } else {
            if indexPath.section == 0 {
                return fetchedDefaultResultController.sections![0].objects![indexPath.row] as! Note
            } else {
                return fetchedNotDefaultResultController.sections![indexPath.section-1].objects![indexPath.row] as! Note
            }
        }
    }
    
    func getNumberOfNotebooks() -> Int {
        if let fetchedDefaultResultController = fetchedDefaultResultController, let fetchedNotDefaultResultController = fetchedNotDefaultResultController {
            return (fetchedDefaultResultController.sections?.count ?? 0) + (fetchedNotDefaultResultController.sections?.count ?? 0)
        }
        
        return 0
    }
    
    func getNotebook(_ section: Int) -> String {
        if (fetchedDefaultResultController.sections?.count ?? 0) == 0 {
            return fetchedNotDefaultResultController.sections![section].name
        } else {
            if section == 0 {
                return fetchedDefaultResultController.sections![0].name
            } else {
                return fetchedNotDefaultResultController.sections![section-1].name
            }
        }
    }
    
    func getNotesForNotebook(_ section: Int) -> Int {
        if (fetchedDefaultResultController.sections?.count ?? 0) == 0 {
            return fetchedNotDefaultResultController.sections?[section].numberOfObjects ?? 0
        } else {
            if section == 0 {
                return fetchedDefaultResultController.sections?[0].numberOfObjects ?? 0
            } else {
                return fetchedNotDefaultResultController.sections?[section-1].numberOfObjects ?? 0
            }
        }
    }
    
    func isSectionDefault(_ section: Int) -> Bool {
        if (fetchedDefaultResultController.sections?.count ?? 0) == 0 {
            return false
        } else {
            if section == 0 {
                return true
            } else {
                return false
            }
        }
    }
}
