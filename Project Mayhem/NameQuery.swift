//
//  NameQuery.swift
//  Project Mayhem
//
//  Created by Yush Raj Kapoor on 2/17/21.
//

import UIKit

class NameQuery: UIViewController {
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var stack: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        wait(time: 0.75, actions: {
            self.stack.fadeIn()
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        stack.alpha = 0.0
    }
    
    @IBAction func submit(_ sender: Any) {
        let name = textField.text
        if name == "" {
            return
        }
        view.endEditing(true)
        game.setValue(name, forKey: "name")
        impact(style: .heavy)
        stack.fadeOut()
        wait {
            self.performSegue(withIdentifier: "NameQueryToLevels", sender: nil)
        }
    }
    
}
