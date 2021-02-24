//
//  videoDelegate.swift
//  Project Mayhem
//
//  Created by Yush Raj Kapoor on 2/23/21.
//

import UIKit

class videoDelegate {
    
    func endRelay() {
        let active = game.string(forKey: "active")
        
        switch active {
        case "subChap1":
            subChapter1().unlock()
            break
        case "subChap1.1":
            subChapter1().nextChapter()
            break
        default:
            break
        }
        
        
    }
}
