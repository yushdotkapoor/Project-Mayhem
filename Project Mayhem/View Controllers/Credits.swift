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
    @IBOutlet weak var flashingSwitch: UISwitch!
    @IBOutlet weak var dhruvSoundCloud: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let volume = game.float(forKey: "volume")
        let sensitive = game.bool(forKey: "photosensitive")
        flashingSwitch.setOn(sensitive, animated: false)
        
        slider.value = volume
        
        donateLabel.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(donate(tapGestureRecognizer:)))
        donateLabel.addGestureRecognizer(tapGesture)
    }
    
    @IBAction func visionConsolidatedWebsite(_ sender: Any) {
        openLink(st: "https://visionconsolidated.wixsite.com/website")
    }
    
    @IBAction func paypal(_ sender: Any) {
        openLink(st: "https://www.paypal.com/paypalme/yushkapoor")
    }
    
    @IBAction func instagram(_ sender: Any) {
        openLink(st: "https://www.instagram.com/yushrajkapoor/")
    }
    
    @IBAction func dhruvGoelWebsite(_ sender: Any) {
        openLink(st: "https://www.dhruvgoel.com")
    }
    
    @IBAction func dhruvSoundCloudLink(_ sender: Any) {
        openLink(st: "https://soundcloud.com/dhruvgoel")
    }
    
    @objc func donate(tapGestureRecognizer: UITapGestureRecognizer) {
        openLink(st: "https://www.paypal.com/paypalme/yushkapoor")
    }
    
    func openLink(st: String) {
        guard let url = URL(string: st) else { return }
        UIApplication.shared.open(url)
    }
    
    
    @IBAction func sliderChanged(_ sender: Any) {
        print(slider.value)
        game.setValue(slider.value, forKey: "volume")
        MusicPlayer.shared.updateVolume()
    }
    
    @IBAction func switchChanged(_ sender: Any) {
        let state = flashingSwitch.isOn
        game.setValue(state, forKey: "photosensitive")
    }
    
    
}
