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
    
    private lazy var presenter = NotesPresenter(viewController: self, delegate: self)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "NotesTableViewCell", bundle: nil), forCellReuseIdentifier: "notesTableCell")
        tableView.register(UINib(nibName: "NotesSectionTableViewCell", bundle: nil), forCellReuseIdentifier: "notesSectionCell")
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewNote))
        navigationItem.title = "Everpobre"
        
        presenter.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        presenter.fetchNotes()
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return presenter.getNumberOfNotebooks()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.getNotesForNotebook(section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "notesTableCell") as! NotesTableViewCell
        cell.setNote(note: presenter.getNote(at: indexPath))
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        goToNote(note: presenter.getNote(at: indexPath))
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableCell(withIdentifier: "notesSectionCell") as! NotesSectionTableViewCell
        view.titleLabel.text = presenter.getNotebook(section).description
        view.countLabel.text = "Notes: \(presenter.getNotesForNotebook(section))"
        
        if presenter.isSectionDefault(section) {
            view.backgroundColor = self.view.tintColor
        }
        
        return view
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return presenter.getNotebook(section).description
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        var rowActions = [UITableViewRowAction]()
        
        let delete =  UITableViewRowAction(style: .destructive, title: "Delete") { action, index in
            NoteManager.deleteNote(note: self.presenter.getNote(at: indexPath))
        }
        rowActions.append(delete)

        return rowActions
    }
    
    @objc func addNewNote()  {
        let actionSheetAlert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let quickNote = UIAlertAction(title: "Create quick note", style: .default) { (alertAction) in
            NoteManager.createQuickNote()
        }
        
        let createNote = UIAlertAction(title: "New note", style: .default) { (alertAction) in
            self.goToNote(note: nil)
        }
        
        let editNotebooks = UIAlertAction(title: "Edit notebooks", style: .default) { (alertAction) in
            self.goToEditNotebooks()
        }
        
        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .destructive, handler: nil)
        
        actionSheetAlert.addAction(quickNote)
        actionSheetAlert.addAction(createNote)
        actionSheetAlert.addAction(editNotebooks)
        actionSheetAlert.addAction(cancel)
        
        if let popoverController = actionSheetAlert.popoverPresentationController {
            popoverController.barButtonItem = navigationItem.rightBarButtonItem
        }
        
        present(actionSheetAlert, animated: true, completion: nil)
    }
    
    private func goToEditNotebooks() {
        presenter.goToEditNotebooks()
    }
    
    private func goToNote(note: Note?) {
        presenter.goToNote(note: note)
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        presenter.fetchNotes()
    }
}

extension NotesTableViewController: NotesPresenterDelegate {
    func reloadData() {
        tableView.reloadData()
    }
}
