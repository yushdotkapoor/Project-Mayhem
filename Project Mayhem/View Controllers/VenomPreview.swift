//
//  VenomPreview.swift
//  Project Mayhem
//
//  Created by Yush Raj Kapoor on 2/25/21.
//

import UIKit

class VenomPreview: UIViewController {
    @IBOutlet weak var nextChap: UIButton!
    @IBOutlet weak var hint: UIButton!
    @IBOutlet weak var toolbar: UIStackView!
    @IBOutlet weak var backButton: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        backButton.alpha = 0.0
        backButton.isUserInteractionEnabled = false
        hint.alpha = 0.0
        hint.isUserInteractionEnabled = false
        game.setValue("projectVenom", forKey: "active")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        game.setValue(true, forKey: "projectVenom")
    }
    
    @IBAction func nextChap(_ sender: Any) {
        self.performSegue(withIdentifier: "venomPreviewToCredits", sender: nil)
    }
    
    
}

