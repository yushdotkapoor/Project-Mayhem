//
//  chapter11.swift
//  Project Mayhem
//
//  Created by Yush Raj Kapoor on 02/02/21.
//

import UIKit

class chapter11: UIViewController {
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
        //game.setValue(true, forKey: "chap11")
        game.setValue("none", forKey: "active")
        nextChap.isUserInteractionEnabled = true
        nextChap.fadeIn()
        
    }

    @IBAction func goBack(_ sender: Any) {
    //self.performSegue(withIdentifier: "chap11ToHome", sender: nil)
    }
    
    @IBAction func goNext(_ sender: Any) {
   // self.performSegue(withIdentifier: "chap11ToChap12", sender: nil)
    }


}
