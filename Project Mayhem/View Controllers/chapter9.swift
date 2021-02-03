//
//  chapter9.swift
//  Project Mayhem
//
//  Created by Yush Raj Kapoor on 1/30/21.
//

import UIKit
import AudioToolbox

class chapter9: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var nextChap: UIButton!
    @IBOutlet weak var textField: nonPastableTextField!
    @IBOutlet weak var firstStack: UIStackView!
    @IBOutlet weak var secondStack: UIStackView!
    @IBOutlet weak var firstStackTop: NSLayoutConstraint!
    @IBOutlet weak var thirdStack: UIStackView!
    
    var keyboardAdded: CGFloat = 0.0
    
    override func viewDidLoad() {
           super.viewDidLoad()
        firstStack.flickerIn()
        secondStack.flickerIn()
        
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(self.doneClicked))
        
        toolBar.setItems([flexibleSpace, doneButton], animated: false)
        textField.inputAccessoryView = toolBar
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.viewTapped(gesture:)))
        view.addGestureRecognizer(tapGesture)
        view.isUserInteractionEnabled = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    @objc func doneClicked() {
        view.endEditing(true)
    }
    
    @objc func viewTapped(gesture: UIGestureRecognizer) {
        view.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        let bounds = UIScreen.main.bounds
        let deviceHeight = bounds.size.height
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                let keyboardHeight = keyboardSize.height
            let labelHeight = deviceHeight - thirdStack.frame.origin.y
            let add = keyboardHeight - labelHeight + 70
            keyboardAdded = add
            firstStackTop.constant -= add
            }
    }
    
    @objc func keyboardWillHide() {
        firstStackTop.constant += keyboardAdded
    }
  
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        nextChap.alpha = 0.0
        nextChap.isUserInteractionEnabled = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func complete() {
        game.setValue(true, forKey: "chap9")
        game.setValue("none", forKey: "active")
        nextChap.isUserInteractionEnabled = true
        nextChap.fadeIn()
    }

    @IBAction func submit(_ sender: Any) {
        if textField.text?.lowercased() == "gravitas" {
            view.endEditing(true)
            complete()
        }
    }
    
    @IBAction func goBack(_ sender: Any) {
        self.performSegue(withIdentifier: "chap9ToHome", sender: nil)
    }
    
    @IBAction func goNext(_ sender: Any) {
        self.performSegue(withIdentifier: "chap9ToChap10", sender: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
}
