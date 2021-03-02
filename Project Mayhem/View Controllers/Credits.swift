//
//  Credits.swift
//  Project Mayhem
//
//  Created by Yush Raj Kapoor on 3/2/21.
//

import UIKit

class Credits: UIViewController {
    @IBOutlet weak var donateLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let volume = game.float(forKey: "volume")
        slider.value = volume
        
        donateLabel.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(donate(tapGestureRecognizer:)))
        donateLabel.addGestureRecognizer(tapGesture)
    }
    
    
    @objc func donate(tapGestureRecognizer: UITapGestureRecognizer) {
        guard let url = URL(string: "https://www.paypal.com/paypalme/yushkapoor") else { return }
        UIApplication.shared.open(url)
    }
    
    
    @IBAction func sliderChanged(_ sender: Any) {
        print(slider.value)
        game.setValue(slider.value, forKey: "volume")
        MusicPlayer.shared.updateVolume()
    }
}
