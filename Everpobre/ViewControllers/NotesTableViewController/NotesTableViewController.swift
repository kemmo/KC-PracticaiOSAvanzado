//
//  NotesTableViewController.swift
//  Everpobre
//
//  Created by Joaquin Perez on 12/03/2018.
//  Copyright © 2018 Joaquin Perez. All rights reserved.
//

import UIKit
import CoreData

class NotesTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    var fetchedResultController : NSFetchedResultsController<Note>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewNote))
        
        // Fetch Request.
        let viewMOC = DataManager.sharedManager.persistentContainer.viewContext
        
        //        // 1.- Creamos el objeto
        //        let fetchRequest =  NSFetchRequest<Note>()
        //
        //        // 2.- Que entidad es de la que queremos objeto.
        //        fetchRequest.entity = NSEntityDescription.entity(forEntityName: "Note", in: viewMOC)
        
        //   let fetchRequest = Note.fetchNoteRequest()
        
        let fetchRequest = NSFetchRequest<Note>(entityName: "Note")
        
        // 3.- (Opcional) Indicamos orden.
        let sortByDate = NSSortDescriptor(key: "createdAtTI", ascending: true)
        let sortByTitle = NSSortDescriptor(key: "title", ascending: true)
        fetchRequest.sortDescriptors = [sortByDate,sortByTitle]
        
        // 4.- (Opcional) Filtrado.
        let created24H = Date().timeIntervalSince1970 - 24 * 3600
        let predicate = NSPredicate(format: "createdAtTI >= %f", created24H)
        fetchRequest.predicate = predicate
        
        fetchRequest.fetchBatchSize = 25
        
        fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: viewMOC, sectionNameKeyPath: nil, cacheName: nil)
        
        try! fetchedResultController.performFetch()
        
        fetchedResultController.delegate = self
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultController.sections!.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultController.sections![section].numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "reuseIdentifier")
        }
        
        cell?.textLabel?.text = fetchedResultController.object(at: indexPath).title
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let noteViewController = NoteViewByCodeController()
        noteViewController.note = fetchedResultController.object(at: indexPath)
        
        //let noteViewController = NoteViewController()
        navigationController?.pushViewController(noteViewController, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return fetchedResultController.sections![section].name
    }
    
    @objc func addNewNote()  {
        // Tradicionalmente.
        let privateMOC = DataManager.sharedManager.persistentContainer.newBackgroundContext()
        
        privateMOC.perform {
            let note = NSEntityDescription.insertNewObject(forEntityName: "Note", into: privateMOC) as! Note
            
            let dict = ["main_title":"Nueva nota from KVC","createdAtTI":Date().timeIntervalSince1970] as [String : Any]
            
            // note.title = "Nueva nota"
            // note.createdAtTI = Date().timeIntervalSince1970
            
            note.setValuesForKeys(dict)
            
            try! privateMOC.save()
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }
}
