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

override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    nextChap.alpha = 0.0
    nextChap.isUserInteractionEnabled = false
    hint.alpha = 0.0
    hint.isUserInteractionEnabled = false
    game.setValue("projectVenom", forKey: "active")
}

override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    game.setValue(true, forKey: "projectVenom")
}


@IBAction func goBack(_ sender: Any) {
self.performSegue(withIdentifier: "venomPreviewToHome", sender: nil)
}

}

