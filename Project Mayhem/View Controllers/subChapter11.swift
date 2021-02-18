//
//  subChapter11.swift
//  Project Mayhem
//
//  Created by Yush Raj Kapoor on 2/18/21.
//

import UIKit

class subChapter11: UIViewController {
    @IBOutlet weak var toolbar: UIStackView!
    @IBOutlet weak var hint: UIButton!
    @IBOutlet weak var nextChap: UIButton!
    @IBOutlet weak var textField: nonPastableTextField!
    @IBOutlet weak var textStack: UIStackView!
    @IBOutlet weak var textFieldConstraint: NSLayoutConstraint!
    
    let customAlert = HintAlert()
    
    var keyboardAdded: CGFloat = 0.0
    var open = false
    
    override func viewDidLoad() {
           super.viewDidLoad()
        
        //TODO: add hint
        //TODO: add image
        
        nextChap.isUserInteractionEnabled = false
        nextChap.isHidden = true
        
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
            let labelHeight = deviceHeight - textStack.frame.origin.y
            let add = keyboardHeight - labelHeight + 70
            keyboardAdded = add
            textFieldConstraint.constant += add
            open = true
            }
    }
    
    @objc func keyboardWillHide() {
        textFieldConstraint.constant -= keyboardAdded
        open = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        alert.showAlert(title: "Message from Victoria Lambson", message: "You might want to see this.", viewController: self, buttonPush: #selector(dismissMessageAlert))
       view.bringSubviewToFront(toolbar)
    }


// defines alert
let alert = MessageAlert()

//function that gets called to dismiss the alertView
@objc func dismissMessageAlert() {
    alert.dismissAlert()
    //add code if needed
}

    @IBAction func goBack(_ sender: Any) {
    self.performSegue(withIdentifier: "subChap11ToHome", sender: nil)
    }
    
    @IBAction func submit(_ sender: Any) {
        let text = textField.text
        
        if text == "" {
            return
        }
        
        if text?.lowercased() == "murder" {
            vibrate(count: 5)
            view.endEditing(true)
            textField.textColor = .green
            textStack.isUserInteractionEnabled = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.textStack.flickerOut()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.performSegue(withIdentifier: "subChap11ToChap11", sender: nil)
            }
        }
        else {
            textField.shake()
            textField.text = ""
            impact(style: .light)
            
        }
        
        
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
            customAlert.showAlert(message: "", viewController: self, hintButton: hint)
            view.bringSubviewToFront(toolbar)
        }
        
    }
    
    func dismissAlert() {
        customAlert.dismissAlert()
    }

}
