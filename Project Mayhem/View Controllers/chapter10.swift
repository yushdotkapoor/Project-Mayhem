//
//  chapter10.swift
//  Project Mayhem
//
//  Created by Yush Raj Kapoor on 1/30/21.
//

import UIKit

class chapter10: UIViewController {
    @IBOutlet weak var nextChap: UIButton!
    @IBOutlet weak var bottomStack: UIStackView!
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var qr11: UIButton!
    @IBOutlet weak var qr12: UIButton!
    @IBOutlet weak var qr13: UIButton!
    @IBOutlet weak var qr21: UIButton!
    @IBOutlet weak var qr22: UIButton!
    @IBOutlet weak var qr23: UIButton!
    @IBOutlet weak var qr31: UIButton!
    @IBOutlet weak var qr32: UIButton!
    @IBOutlet weak var qr33: UIButton!
    @IBOutlet weak var textStack: UIStackView!
    @IBOutlet weak var textField: nonPastableTextField!
    @IBOutlet weak var buttonStackTop: NSLayoutConstraint!
    @IBOutlet weak var hint: UIButton!
    @IBOutlet weak var toolbar: UIStackView!
    @IBOutlet weak var i: UILabel!
    
    var customAlert = HintAlert()
    
    var tiles:[UIButton] = []
    var keyboardAdded: CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buttonView.frame.size.width = UIScreen.main.bounds.size.width - 20
        textStack.alpha = 0.0
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.colors = [UIColor.systemYellow.cgColor, UIColor.systemOrange.cgColor, UIColor.systemRed.cgColor]
        view.layer.addSublayer(gradient)
        view.bringSubviewToFront(bottomStack)
        view.bringSubviewToFront(buttonView)
        view.bringSubviewToFront(i)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(self.doneClicked))
        
        toolBar.setItems([flexibleSpace, doneButton], animated: false)
        textField.inputAccessoryView = toolBar
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.viewTapped(gesture:)))
        view.addGestureRecognizer(tapGesture)
        view.isUserInteractionEnabled = true
        
        
    }
    
    func getTiles() -> [UIButton] {
        return [qr11, qr12, qr13, qr21, qr22, qr23, qr31, qr32, qr33]
    }
    
    func randomRotate() {
        let arr = getTiles()
        for i in arr {
            let rand = Int.random(in: 1...4)
            var rot: CGFloat = 0
            switch rand {
            case 1:
                rot = 0.25
                break
            case 2:
                rot = 0.5
                break
            case 3:
                rot = 0.75
                break
            case 4:
                rot = 1.0
                break
            default:
                break
            }
            i.setRotation(gizmo: rot)
        }
    }
    
    func checkFinish() {
        let arr = getTiles()
        var checkArr:[Bool] = []
        for i in arr {
            let radians:Float = atan2f(Float(i.transform.b), Float(i.transform.a))
            if radians > -1 && radians < 1 {
                checkArr.append(true)
            }
            
            if checkArr.count == 9 {
                print("complete!")
                wait(time: 0.75, actions: {
                    self.nextPhase()
                    self.buttonView.flickerIn()
                    self.buttonView.isUserInteractionEnabled = false
                    UIView.animate(withDuration: 1.0) {
                        self.buttonStackTop.constant -= 150
                        self.view.layoutIfNeeded()
                    }
                })
            }
        }
    }
    
    func nextPhase() {
        wait {
            self.view.bringSubviewToFront(self.textStack)
            self.textStack.fadeIn()
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        nextChap.alpha = 0.0
        nextChap.isUserInteractionEnabled = false
        randomRotate()
    }
    
    func complete() {
        game.setValue(true, forKey: "chap10")
        game.setValue("none", forKey: "active")
        NotificationCenter.default.removeObserver(self)
        nextChap.isUserInteractionEnabled = true
        impact(style: .success)
        nextChap.fadeIn()
        
    }
    
    @IBAction func goBack(_ sender: Any) {
        NotificationCenter.default.removeObserver(self)
        self.performSegue(withIdentifier: "chap10ToHome", sender: nil)
    }
    
    @IBAction func goNext(_ sender: Any) {
        self.performSegue(withIdentifier: "chap10ToSubChap11", sender: nil)
    }
    
    
    @IBAction func submit(_ sender: Any) {
        if textField.text?.removeLastSpace().lowercased() == "burj khalifa" {
            buttonView.fadeOut()
            view.endEditing(true)
            alert.showAlert(title: "\(messageFrom) Victoria Lambson", message: "Again, another location. First Neuschwanstein castle and now Burj Khalifa?".localized(), viewController: self, buttonPush: #selector(dismissMessageAlert))
            
        }
        else {
            textField.shake()
            impact(style: .error)
            textField.text = ""
        }
    }
    
    
    // defines alert
    let alert = MessageAlert()
    
    //function that gets called to dismiss the alertView
    @objc func dismissMessageAlert() {
        alert.dismissAlert()
        complete()
    }
    
    
    @IBAction func qr1_1(_ sender: Any) {
        qr11.rotate(rotation: 0.25, duration: 0.4, option: [])
        checkFinish()
    }
    
    @IBAction func qr1_2(_ sender: Any) {
        qr12.rotate(rotation: 0.25, duration: 0.4, option: [])
        checkFinish()
    }
    
    @IBAction func qr1_3(_ sender: Any) {
        qr13.rotate(rotation: 0.25, duration: 0.4, option: [])
        checkFinish()
    }
    
    @IBAction func qr2_1(_ sender: Any) {
        qr21.rotate(rotation: 0.25, duration: 0.4, option: [])
        checkFinish()
    }
    
    @IBAction func qr2_2(_ sender: Any) {
        qr22.rotate(rotation: 0.25, duration: 0.4, option: [])
        checkFinish()
    }
    
    @IBAction func qr2_3(_ sender: Any) {
        qr23.rotate(rotation: 0.25, duration: 0.4, option: [])
        checkFinish()
    }
    
    @IBAction func qr3_1(_ sender: Any) {
        qr31.rotate(rotation: 0.25, duration: 0.4, option: [])
        checkFinish()
    }
    
    @IBAction func qr3_2(_ sender: Any) {
        qr32.rotate(rotation: 0.25, duration: 0.4, option: [])
        checkFinish()
    }
    
    @IBAction func qr3_3(_ sender: Any) {
        qr33.rotate(rotation: 0.25, duration: 0.4, option: [])
        
        checkFinish()
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        let bounds = UIScreen.main.bounds
        let deviceHeight = bounds.size.height
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            let labelHeight = deviceHeight - textStack.frame.origin.y
            let add = keyboardHeight - labelHeight + 70
            keyboardAdded = add
            buttonStackTop.constant -= add
        }
    }
    
    @objc func keyboardWillHide() {
        buttonStackTop.constant += keyboardAdded
    }
    
    @objc func doneClicked() {
        view.endEditing(true)
    }
    
    @objc func viewTapped(gesture: UIGestureRecognizer) {
        view.endEditing(true)
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
            customAlert.showAlert(message: "10", viewController: self, hintButton: hint, toolbar: toolbar)
        }
        
    }
    
    func dismissAlert() {
        customAlert.dismissAlert()
    }
    
}
