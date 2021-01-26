//
//  chapter4.swift
//  Project Mayhem
//
//  Created by Yush Raj Kapoor on 12/30/20.
//

import UIKit

class chapter4: UIViewController {
    @IBOutlet weak var nextChap: UIButton!
    @IBOutlet weak var label: UILabel!
    
    
    override func viewDidLoad() {
           super.viewDidLoad()
        label.flicker()
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
        game.setValue(true, forKey: "chap4")
        game.setValue("none", forKey: "active")
        nextChap.isUserInteractionEnabled = true
        nextChap.fadeIn()
    }
    
    @IBAction func goBack(_ sender: Any) {
        self.performSegue(withIdentifier: "chap4ToHome", sender: nil)
    }

    @IBAction func goNext(_ sender: Any) {
        self.performSegue(withIdentifier: "chap4ToChap5", sender: nil)
    }
    
}


extension UILabel {
    func flicker() {
        
        var number = 0
        
        UIView.animate(withDuration: 0.2, delay: 0.5, animations: {
            number = Int.random(in: 0...10)
            self.textColor = UIColor.red
            self.frame.origin.x += CGFloat(number)
        }, completion: { _ in
            UIView.animate(withDuration: 0.2, animations: {
                self.textColor = UIColor.green
                self.frame.origin.x -= CGFloat(number)
            }, completion: { _ in
                UIView.animate(withDuration: 0.2, animations: {
                    number = Int.random(in: 0...10)
                    self.textColor = UIColor.blue
                    self.frame.origin.x += CGFloat(number)
                }, completion: { _ in
                    UIView.animate(withDuration: 0.2, animations: {
                        self.textColor = UIColor.yellow
                        self.frame.origin.x -= CGFloat(number)
                    })
                })
            })
        })
        
    }
    
}
