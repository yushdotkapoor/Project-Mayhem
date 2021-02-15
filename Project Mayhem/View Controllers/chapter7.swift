//
//  chapter7.swift
//  Project Mayhem
//
//  Created by Yush Raj Kapoor on 01/30/21.
//

import UIKit

class chapter7: UIViewController {
    @IBOutlet weak var nextChap: UIButton!
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    @IBOutlet weak var button4: UIButton!
    @IBOutlet weak var button5: UIButton!
    @IBOutlet weak var button6: UIButton!
    @IBOutlet weak var button7: UIButton!
    @IBOutlet weak var button8: UIButton!
    @IBOutlet weak var button9: UIButton!
    @IBOutlet weak var button10: UIButton!
    @IBOutlet weak var button11: UIButton!
    @IBOutlet weak var button12: UIButton!
    @IBOutlet weak var button13: UIButton!
    @IBOutlet weak var button14: UIButton!
    @IBOutlet weak var button15: UIButton!
    @IBOutlet weak var button16: UIButton!
    @IBOutlet weak var hint: UIButton!
    @IBOutlet weak var toolbar: UIStackView!
    
    let customAlert = HintAlert()
    
    var current = 0
    var orderString:[String] = []
    var masterOrder = ["2", "14", "7", "3", "12", "9", "10", "1", "5", "16", "11", "6", "15", "4", "8", "13"]
    
    override func viewDidLoad() {
           super.viewDidLoad()
        orderString = []
        current = 0
        
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
        game.setValue(true, forKey: "chap7")
        game.setValue("none", forKey: "active")
        nextChap.isUserInteractionEnabled = true
        nextChap.fadeIn()
        
    }

    @IBAction func goBack(_ sender: Any) {
        self.performSegue(withIdentifier: "chap7ToHome", sender: nil)
    }
    
    @IBAction func goNext(_ sender: Any) {
        self.performSegue(withIdentifier: "chap7ToChap8", sender: nil)
    }
    
    func getData(string: String) -> [UIButton] {
        if string == "ordered" {
            return [button2, button14, button7, button3, button12, button9, button10, button1, button5, button16, button11, button6, button15, button4, button8, button13]
        }
        else {
            return [button1, button2, button3, button4, button5, button6, button7, button8, button9, button10, button11, button12, button13, button14, button15, button16]
        }
    }
    
    func checkOrder() {
        if orderString[current] == masterOrder[current] {
            let arr:[UIButton] = getData(string: "ordered")
            arr[current].fadeOut()
            current += 1
            if current == 16 {
                complete()
            }
        }
        else {
            orderString = []
            reform()
            current = 0
        }
    }
    
    func reform() {
        let arr:[UIButton] = getData(string: "numerical")
        for i in arr {
            i.fadeIn()
        }
    }
    
    @IBAction func press1(_ sender: Any) {
        orderString.append("1")
        checkOrder()
    }
    
    @IBAction func press2(_ sender: Any) {
        orderString.append("2")
        checkOrder()
    }
    
    @IBAction func press3(_ sender: Any) {
        orderString.append("3")
        checkOrder()
    }
    
    @IBAction func press4(_ sender: Any) {
        orderString.append("4")
        checkOrder()
    }
    
    @IBAction func press5(_ sender: Any) {
        orderString.append("5")
        checkOrder()
    }
    
    @IBAction func press6(_ sender: Any) {
        orderString.append("6")
        checkOrder()
    }
    
    @IBAction func press7(_ sender: Any) {
        orderString.append("7")
        checkOrder()
    }
    
    @IBAction func press8(_ sender: Any) {
        orderString.append("8")
        checkOrder()
    }
    
    @IBAction func press9(_ sender: Any) {
        orderString.append("9")
        checkOrder()
    }
    
    @IBAction func press10(_ sender: Any) {
        orderString.append("10")
        checkOrder()
    }
    
    @IBAction func press11(_ sender: Any) {
        orderString.append("11")
        checkOrder()
    }
    
    @IBAction func press12(_ sender: Any) {
        orderString.append("12")
        checkOrder()
    }
    
    @IBAction func press13(_ sender: Any) {
        orderString.append("13")
        checkOrder()
    }
    
    @IBAction func press14(_ sender: Any) {
        orderString.append("14")
        checkOrder()
    }
    
    @IBAction func press15(_ sender: Any) {
        orderString.append("15")
        checkOrder()
    }
    
    @IBAction func press16(_ sender: Any) {
        orderString.append("16")
        checkOrder()
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
            customAlert.showAlert(message: "Rule number 1: have patience. Rule number 2: have good memory skills. Rule number 3: see what happens when you tap (r1,c2).", viewController: self, hintButton: hint)
            view.bringSubviewToFront(toolbar)
        }
        
    }
    
    func dismissAlert() {
        customAlert.dismissAlert()
    }
    
    

}
