//
//  nonPastableTextField.swift
//  Project Mayhem
//
//  Created by Yush Raj Kapoor on 2/1/21.
//

import UIKit

class nonPastableTextField: UITextField {
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(UIResponderStandardEditActions.paste(_:)) {
            return false
        }
        return super.canPerformAction(action, withSender: sender)
    }
}
