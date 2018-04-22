//
//  ManagedObjects.swift
//  Everpobre
//
//  Created by Joaquin Perez on 13/03/2018.
//  Copyright © 2018 Joaquin Perez. All rights reserved.
//

import Foundation

extension Note {
    override public func setValue(_ value: Any?, forUndefinedKey key: String) {
        let keyToIgn = ["date", "content"]
        
        if keyToIgn.contains(key) {
            
        } else if key == NoteKeys.mainTitle {
            self.setValue(value, forKey: "title")
        } else {
            super.setValue(value, forKey: key)
        }
    }
    
    public override func value(forUndefinedKey key: String) -> Any? {
        if key == NoteKeys.mainTitle {
            return NoteKeys.mainTitle
        } else {
            return super.value(forKey: key)
        }
    }
}
