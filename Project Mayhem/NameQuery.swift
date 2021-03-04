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
            let alertController = UIAlertController(title: "Question", message: "Would you like to minimize flashing lights? The user experience will be diminished. This is a good option for photosensitive users and can always be changed in the settings tab.", preferredStyle: .alert)
            let no = UIAlertAction(title: "No", style: .default, handler: {_ in
                game.setValue(false, forKey: "photosensitive")
                self.performSegue(withIdentifier: "NameQueryToLevels", sender: nil)
            })
            let yes = UIAlertAction(title: "Yes", style: .default, handler: {_ in
                game.setValue(true, forKey: "photosensitive")
                self.performSegue(withIdentifier: "NameQueryToLevels", sender: nil)
            })
                alertController.addAction(no)
                alertController.addAction(yes)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
}
