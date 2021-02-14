//
//  chapter13.swift
//  Project Mayhem
//
//  Created by Yush Raj Kapoor on 02/02/21.
//

import UIKit
import ARKit

class chapter13: UIViewController {
    @IBOutlet weak var nextChap: UIButton!
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var textField: nonPastableTextField!
    @IBOutlet weak var labelStack: UIStackView!
    @IBOutlet weak var labelStackBottom: NSLayoutConstraint!
    @IBOutlet weak var quakeLabel: UILabel!
    @IBOutlet weak var Reset: CustomButtonOutline!
    @IBOutlet weak var hint: UIButton!
    @IBOutlet weak var toolbar: UIStackView!
    
    let customAlert = HintAlert()
    
    var hintText = ""
    
    let config = ARWorldTrackingConfiguration()
    
    var keyboardAdded: CGFloat = 0.0
    var open = false
    
    var ct = 0
    
    let xArr:[Float] = [0.05, 0.025, 0, -0.025, -0.05, -0.025, -0.0125, 0, -0.025, -0.05, 0, -0.025, -0.05, 0, -0.025, -0.025, -0.0125, 0, -0.025, -0.05, 0.025, 0, -0.025]
    let zArr:[Float] = [-0.5, -0.525, -0.5, -0.475, -0.5, -0.425, -0.4, -0.425, -0.45, -0.425, -0.35, -0.375, -0.35, -0.275, -0.3, -0.2, -0.175, -0.2, -0.225, -0.2, -0.125, -0.125, -0.125]
    let xTrans:[Bool] = [true, false, true, false, true, true, false, true, false, true, true, false, true, true, false, true, false, true, false, true, false, true, false]
    var nameArr:[SCNNode] = []
    let shakeOrder:[Int] = [0, 5, 10, 13, 15, 20, 23]
    
    
    override func viewDidLoad() {
           super.viewDidLoad()
        Reset.setupButton()
        Reset.alpha = 0.5
        textField.alpha = 0.2
        quakeLabel.numberOfLines = 3
        quakeLabel.text = "Sometimes we need to take a step back to get some perspective"
        hintText = "Dude c'mon. The text on the screen IS the hint"
        
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
            let labelHeight = deviceHeight - labelStack.frame.origin.y
            let add = keyboardHeight - labelHeight + 70
            keyboardAdded = add
            labelStackBottom.constant += add
            open = true
            }
    }
    
    @objc func keyboardWillHide() {
        labelStackBottom.constant -= keyboardAdded
        open = false
    }
    
    func nd() -> SCNNode {
        return SCNNode(geometry: SCNCapsule(capRadius: 0.002, height: 0.05))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        nextChap.alpha = 0.0
        nextChap.isUserInteractionEnabled = false
        game.setValue("chap13", forKey: "active")
        setupAR()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.sceneView.session.pause()
    }
    
    func setupAR() {
        sceneView.session.run(config)
        
        let text = SCNText(string: "quake", extrusionDepth: 5)
        
        let node = SCNNode()
        node.position = SCNVector3(x:-0.3, y:-0.1, z:1)
        node.scale = SCNVector3(x:0.1, y:0.1, z:0.1)
        node.geometry = text
        
        sceneView.scene.rootNode.addChildNode(node)
        sceneView.autoenablesDefaultLighting = true
        
        let Sa = nd()
        let Sb = nd()
        let Sc = nd()
        let Sd = nd()
        let Se = nd()
        let E1a = nd()
        let E1b = nd()
        let E1c = nd()
        let E1d = nd()
        let E1e = nd()
        let Ca = nd()
        let Cb = nd()
        let Cc = nd()
        let Ra = nd()
        let Rb = nd()
        let E2a = nd()
        let E2b = nd()
        let E2c = nd()
        let E2d = nd()
        let E2e = nd()
        let Ta = nd()
        let Tb = nd()
        let Tc = nd()
        
        nameArr = [Sa, Sb, Sc, Sd, Se, E1a, E1b, E1c, E1d, E1e, Ca, Cb, Cc, Ra, Rb, E2a, E2b, E2c, E2d, E2e, Ta, Tb, Tc]
    }
    
    func translateAll(xArr:[Float], zArr:[Float], xTrans:[Bool], nameArr:[SCNNode], limit:Int) {
        while (ct != limit) {
            let factorX:Float = 1.0
            let factorZ:Float = 1.0
            let factorY:Float = 0.0
            if ct == 6 || ct == 16 {
                // for the half line in e
                nameArr[ct].geometry = SCNCapsule(capRadius: 0.002, height: 0.025)
            }
            let y = Float.random(in: -1...(-0.7))
            nameArr[ct].position = SCNVector3(factorX + xArr[ct], factorY + y, factorZ + zArr[ct])
            if xTrans[ct] {
                nameArr[ct].eulerAngles = SCNVector3(Double.pi/2,0,0)
            }
            else {
                nameArr[ct].eulerAngles = SCNVector3(0,0,Double.pi/2)
            }
            sceneView.scene.rootNode.addChildNode(nameArr[ct])
            ct += 1
        }
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        let active = game.string(forKey: "active")
        if active == "chap13.1" {
        if motion == .motionShake {
            var lmt = 0
            for (j, i) in shakeOrder.enumerated() {
                if j + 1 == shakeOrder.count {
                    return
                }
                if ct == i {
                    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                    hintText = "Earthquake simulator? Look to your right :)"
                    lmt = shakeOrder[j + 1]
                    translateAll(xArr: xArr, zArr: zArr, xTrans: xTrans, nameArr: nameArr, limit:lmt)
                    return
                }
            }
        }
        }
    }
    
    
    @IBAction func submit(_ sender: Any) {
        let active = game.string(forKey: "active")
        if active == "chap13" {
            if textField.text?.lowercased() == "quake" {
                quakeLabel.text = "Quake"
                quakeLabel.numberOfLines = 1
                textField.text = ""
                view.endEditing(true)
                hintText = "Earthquake simulator?"
                sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
                    node.removeFromParentNode()
                }
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                game.setValue("chap13.1", forKey: "active")
            }
            else if textField.text != "" {
                textField.shake()
                textField.text = ""
            }
        }
        else {
        if textField.text?.lowercased() == "secret" {
            quakeLabel.text = "secret"
            textField.text = ""
            view.endEditing(true)
            textField.isUserInteractionEnabled = false
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            complete()
        }
        else if textField.text != "" {
            textField.shake()
            textField.text = ""
        }
        }
    }
    
    func complete() {
        game.setValue(true, forKey: "chap13")
        game.setValue("none", forKey: "active")
        nextChap.isUserInteractionEnabled = true
        nextChap.fadeIn()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    @IBAction func reset(_ sender: Any) {
        sceneView.session.pause()
        sceneView.session.run(config,
                                  options: .resetTracking)
    }
    
    

    @IBAction func goBack(_ sender: Any) {
        self.performSegue(withIdentifier: "chap13ToHome", sender: nil)
    }
    
    @IBAction func goNext(_ sender: Any) {
        self.performSegue(withIdentifier: "chap13ToChap14", sender: nil)
    }
    

    @IBAction func hint(_ sender: Any) {
        if menuState {
            //if menu open and want to close
            dismissAlert()
        }
        else {
            menuState = true
            //if menu closed and want to open
            hint.rotate(rotation: 0.49999, duration: 0.5)
            UIView.animate(withDuration: 0.5) {
                self.hint.tintColor = UIColor.lightGray
            }
            customAlert.showAlert(message: hintText, viewController: self, hintButton: hint)
            view.bringSubviewToFront(toolbar)
        }
        
    }
    
    func dismissAlert() {
        customAlert.dismissAlert()
    }


}

