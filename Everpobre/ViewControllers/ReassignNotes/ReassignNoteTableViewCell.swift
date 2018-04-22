//
//  ReassignNoteTableViewCell.swift
//  Everpobre
//
//  Created by VINACHES LOPEZ JORGE on 17/04/2018.
//  Copyright © 2018 Jorge Vinaches. All rights reserved.
//

import UIKit

protocol ReassignNoteTableViewCellDelegate: class {
    func didChangePickerView(row: Int, selectedOption: Int)
}

class ReassignNoteTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var notebooksPickerView: UIPickerView!
    
    var tableIndex: Int!
    var notebooks: [Notebook]!
    var delegate: ReassignNoteTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        notebooksPickerView.dataSource = self
        notebooksPickerView.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func selectedOption(_ option: Int) {
        notebooksPickerView.selectRow(option, inComponent: 0, animated: false)
    }
}

extension ReassignNoteTableViewCell: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return notebooks.count + 1
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel = view as? UILabel
        
        if (pickerLabel == nil) {
            pickerLabel = UILabel()
            pickerLabel?.textAlignment = NSTextAlignment.center
        }
        
        let mutableString: NSMutableAttributedString?
        if row == 0 {
            pickerLabel?.font = UIFont.systemFont(ofSize: 20)
            mutableString = NSMutableAttributedString(string: "Delete note")
            mutableString!.addAttribute(.foregroundColor, value: UIColor.red, range: NSMakeRange(0, mutableString!.length))
        } else {
            pickerLabel?.font = UIFont.systemFont(ofSize: 14)
            mutableString = NSMutableAttributedString(string: notebooks[row-1].name ?? "")
        }

        pickerLabel?.attributedText = mutableString
        
        return pickerLabel!;
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        delegate?.didChangePickerView(row: tableIndex, selectedOption: row)
    }
}
