//
//  NotesSectionTableViewCell.swift
//  Everpobre
//
//  Created by VINACHES LOPEZ JORGE on 22/04/2018.
//  Copyright © 2018 Jorge Vinaches. All rights reserved.
//

import UIKit

class NotesSectionTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
