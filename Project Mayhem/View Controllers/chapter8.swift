//
//  chapter8.swift
//  Project Mayhem
//
//  Created by Yush Raj Kapoor on 1/30/21.
//

import UIKit

class chapter8: UIViewController {
    @IBOutlet weak var nextChap: UIButton!
    
    override func viewDidLoad() {
           super.viewDidLoad()
        
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
        //game.setValue(true, forKey: "chap1")
        game.setValue("none", forKey: "active")
        nextChap.isUserInteractionEnabled = true
        nextChap.fadeIn()
        
    }

    @IBAction func goBack(_ sender: Any) {
        self.performSegue(withIdentifier: "chap8ToHome", sender: nil)
    }
    
    @IBAction func goNext(_ sender: Any) {
        self.performSegue(withIdentifier: "chap8ToChap9", sender: nil)
    }


}
