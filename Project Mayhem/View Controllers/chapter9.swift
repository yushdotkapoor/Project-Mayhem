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
    @IBOutlet weak var secondStack: UIStackView!
    @IBOutlet weak var thirdStack: UIStackView!
    @IBOutlet weak var hint: UIButton!
    @IBOutlet weak var toolbar: UIStackView!
    @IBOutlet weak var pass: UILabel!
    @IBOutlet weak var stackCenter: NSLayoutConstraint!
    
    var customAlert = HintAlert()
    
    let codeToMatch = "kapoor is lying"
    
    var keyboardAdded: CGFloat = 0.0
    var open = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        game.setValue("chap9", forKey: "active")
        pass.text = codeToMatch
        secondStack.alpha = 0.0
        thirdStack.alpha = 0.0
        wait {
            self.secondStack.flickerIn()
            wait(time: 0.5, actions: {
                self.thirdStack.fadeIn()
            })
        }
        
        wait(time: 15) {
            if game.string(forKey: "active") == "chap9" {
                if self.open {
                    self.stackCenter.constant += self.keyboardAdded
                    self.open = false
                }
                self.alert(title: "!", message: "It might do you some good to take a hint.", actionTitle: "Sure, I guess")
            }
        }
        
        
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
        if open {
            return
        }
        let bounds = UIScreen.main.bounds
        let deviceHeight = bounds.size.height
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            let labelHeight = deviceHeight - thirdStack.frame.origin.y
            let add = keyboardHeight - labelHeight + 70
            keyboardAdded = add
            stackCenter.constant -= add
            open = true
        }
    }
    
    @objc func keyboardWillHide() {
        if open {
            stackCenter.constant += keyboardAdded
            open = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        nextChap.alpha = 0.0
        nextChap.isUserInteractionEnabled = false
    }
    
    func complete() {
        game.setValue(true, forKey: "chap9")
        game.setValue("none", forKey: "active")
        NotificationCenter.default.removeObserver(self)
        nextChap.isUserInteractionEnabled = true
        impact(style: .success)
        nextChap.fadeIn()
    }
    
    @IBAction func submit(_ sender: Any) {
        if textField.text?.removeLastSpace().lowercased() == codeToMatch {
            view.endEditing(true)
            vibrate(count: 5)
            textField.textColor = .green
            wait {
                self.complete()
            }
            
        }
        else if textField.text != ""{
            textField.shake()
            impact(style: .error)
            textField.text = ""
        }
    }
    
    @IBAction func goBack(_ sender: Any) {
        NotificationCenter.default.removeObserver(self)
        self.performSegue(withIdentifier: "chap9ToHome", sender: nil)
    }
    
    @IBAction func goNext(_ sender: Any) {
        self.performSegue(withIdentifier: "chap9ToChap10", sender: nil)
    }
    
    @IBAction func hint(_ sender: Any) {
        if menuState {
            //if menu open and want to close
            dismissAlert()
        }
        else {
            menuState = true
            //if menu closed and want to open
            hint.rotate(rotation: 0.49999, duration: 0.5, option: [])
            UIView.animate(withDuration: 0.5) {
                self.hint.tintColor = UIColor.lightGray
            }
            customAlert = HintAlert()
            customAlert.showAlert(message: "9", viewController: self, hintButton: hint, toolbar: toolbar)
        }
        
    }
    
    func dismissAlert() {
        customAlert.dismissAlert()
    }
    
    
}
