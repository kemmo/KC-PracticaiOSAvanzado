//
//  ReassignNotesViewController.swift
//  Everpobre
//
//  Created by VINACHES LOPEZ JORGE on 17/04/2018.
//  Copyright © 2018 Jorge Vinaches. All rights reserved.
//

import UIKit
import CoreData

class ReassignNotesViewController: UIViewController, NSFetchedResultsControllerDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    var notebook: Notebook!
    private lazy var presenter = ReassignNotesPresenter(viewController: self, notebook: self.notebook, delegate: self)
    private var noteStates = [Int: Int]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "ReassignNoteTableViewCell", bundle: nil), forCellReuseIdentifier: "reassignNoteCell")
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(ReassignNotesViewController.reassignNotes))

        
        presenter.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    @objc func reassignNotes() {
        if presenter.notes.count > 0 {
            for i in 0...presenter.notes.count-1 {
                let last = (i == presenter.notes.count-1)
                presenter.reassignNote(presenter.notes[i], option: noteStates[i]!, last: last)
            }
        }
    }
}

extension ReassignNotesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "reassignNoteCell") as! ReassignNoteTableViewCell
        
        let note = presenter.getNote(at: indexPath)
        cell.delegate = self
        cell.tableIndex = indexPath.row
        cell.titleLabel.text = note.title
        cell.contentLabel.text = note.content
        cell.dateLabel.text = String(note.createdAtTI)
        cell.notebooks = presenter.notebooks
        cell.selectedOption(noteStates[indexPath.row]!)
        
        return cell
    }
}

extension ReassignNotesViewController: ReassignNotesPresenterDelegate {
    func reloadData() {
        if presenter.notes.count > 0 {
            for i in 0...presenter.notes.count-1 {
                noteStates[i] = 0
            }
        }
        
        tableView.reloadData()
    }
    
    func dismissView() {
        self.dismiss(animated: true, completion: nil)
    }
}

extension ReassignNotesViewController: ReassignNoteTableViewCellDelegate {
    func didChangePickerView(row: Int, selectedOption: Int) {
        noteStates[row] = selectedOption
    }
}
