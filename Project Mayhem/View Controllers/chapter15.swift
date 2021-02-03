//
//  chapter15.swift
//  Project Mayhem
//
//  Created by Yush Raj Kapoor on 02/02/21.
//

import UIKit

class chapter15: UIViewController {
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
        //game.setValue(true, forKey: "chap15")
        game.setValue("none", forKey: "active")
        nextChap.isUserInteractionEnabled = true
        nextChap.fadeIn()
        
    }

    @IBAction func goBack(_ sender: Any) {
    //self.performSegue(withIdentifier: "chap15ToHome", sender: nil)
    }
    
    @IBAction func goNext(_ sender: Any) {
   // self.performSegue(withIdentifier: "chap15ToChap16", sender: nil)
    }


}

