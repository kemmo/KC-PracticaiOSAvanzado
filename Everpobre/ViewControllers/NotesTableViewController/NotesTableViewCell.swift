//
//  NotesTableViewCell.swift
//  Everpobre
//
//  Created by VINACHES LOPEZ JORGE on 22/04/2018.
//  Copyright © 2018 Jorge Vinaches. All rights reserved.
//

import UIKit

class NotesTableViewCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var content: UILabel!
    @IBOutlet weak var pictures: UILabel!
    
    func setNote(note: Note) {
        title.text = note.title!
        
        if let c = note.content {
            if c.isEmpty {
                content.text = "No content"
            } else {
                content.text = note.content
            }
        } else {
            content.text = "No content"
        }
        
        pictures.text = "Pictures: \(note.pictures?.count ?? 0)"
    }
    
}
