//
//  Credits.swift
//  Project Mayhem
//
//  Created by Yush Raj Kapoor on 3/2/21.
//

import UIKit
import MessageUI
import StoreKit

class Credits: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var flashingSwitch: UISwitch!
    @IBOutlet weak var dhruvSoundCloud: UIButton!
    @IBOutlet weak var version: UILabel!
    @IBOutlet weak var purchaseprice: UILabel!
    @IBOutlet weak var betterHintButton: UIButton!
    @IBOutlet weak var purchaseRestore: CustomButtonOutline!
    @IBOutlet weak var welcStatementButton: CustomButtonOutline!
    @IBOutlet weak var feedbackButton: CustomButtonOutline!
    @IBOutlet weak var fiveHintsButton: UIButton!
    @IBOutlet weak var fiveHintPurchasePrice: UILabel!
    @IBOutlet weak var fiveHintsDescription: UILabel!
    @IBOutlet weak var titl: UILabel!
    @IBOutlet weak var dev: UILabel!
    @IBOutlet weak var mus: UILabel!
    @IBOutlet weak var buy: UILabel!
    @IBOutlet weak var betterHintDescription: UILabel!
    @IBOutlet weak var vol: UILabel!
    @IBOutlet weak var volumeDescription: UILabel!
    @IBOutlet weak var minFlash: UILabel!
    @IBOutlet weak var minFlashDescription: UILabel!
    @IBOutlet weak var bestExp: UILabel!
    @IBOutlet weak var reduceMotion: UILabel!
    @IBOutlet weak var reduceMotionDescription: UILabel!
    @IBOutlet weak var motionSwitch: UISwitch!
    @IBOutlet weak var languageTitle: UILabel!
    @IBOutlet weak var languageDescription: UILabel!
    @IBOutlet weak var languageRepresentation: UIButton!
    @IBOutlet weak var cellularSwitch: UISwitch!
    @IBOutlet weak var celularTitle: UILabel!
    @IBOutlet weak var cellularDescription: UILabel!
    @IBOutlet weak var purchaseMerchStack: UIStackView!
    
    var toolBar = UIToolbar()
    var picker  = UIPickerView()
    
    var pickerSelection:Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //hides the Project Mayhem Merchandise Purchase thing
        purchaseMerchStack.isHidden = true
        
        setLocalizations()
        
        let volume = game.float(forKey: "volume")
        let sensitive = game.bool(forKey: "photosensitive")
        let mot = game.bool(forKey: "reduceMotion")
        let cell = game.bool(forKey: "useCellular")
        
        flashingSwitch.setOn(sensitive, animated: false)
        motionSwitch.setOn(mot, animated: false)
        cellularSwitch.setOn(cell, animated: false)
        
        slider.value = volume
        
        purchaseRestore.setupButton()
        welcStatementButton.setupButton()
        feedbackButton.setupButton()
        
        checkIfPurchased()
        
        for i in [betterHintButton, fiveHintsButton,welcStatementButton, purchaseRestore, feedbackButton] {
            i?.titleLabel?.minimumScaleFactor = 0.5
            i?.titleLabel?.adjustsFontSizeToFitWidth = true
        }
        
        
    }
    
    func resizeStuff() {
        for i in [betterHintButton, fiveHintsButton,welcStatementButton, purchaseRestore, feedbackButton] {
            i?.titleLabel?.minimumScaleFactor = 0.5
            i?.titleLabel?.adjustsFontSizeToFitWidth = true
        }
    }
    
    func setLocalizations() {
        initLanguagesArray()
        
        titl.text = "Settings".localized()
        dev.text = "Developer:".localized()
        mus.text = "Music:".localized()
        buy.text = "Buy Project Mayhem Merchandise".localized()
        betterHintButton.setTitle("Better Hints".localized(), for: .normal)
        betterHintDescription.text = "Purchase Hints for all levels".localized()
        fiveHintsButton.setTitle("Five Hints".localized(), for: .normal)
        fiveHintsDescription.text = "Purchase Extra hints for 5 levels".localized()
        vol.text = "Volume:".localized()
        volumeDescription.text = "This slider only controls the relative volume of the background music, and will not affect the videos".localized()
        minFlash.text = "Minimize Flashing:".localized()
        minFlashDescription.text = "This option is prefered for photosensitive users and will minimize sudden flashing colors or lights".localized()
        bestExp.text = "For best experience, make sure haptics (Settings) are on and that minimize flashing (above) is turned off.".localized()
        purchaseRestore.setTitle("Restore Purchases".localized(), for: .normal)
        welcStatementButton.setTitle("Welcome Statement".localized(), for: .normal)
        feedbackButton.setTitle("Leave Feedback".localized(), for: .normal)
        reduceMotion.text = "Reduce Motion:".localized()
        reduceMotionDescription.text = "This option will reduce any gyroscopic motion animations".localized()
        languageTitle.text = "Language:".localized()
        languageDescription.text = "Set your language preference".localized()
        cellularDescription.text = "Use Cellular data to Download content for gameplay".localized()
        celularTitle.text = "Use Cellular Data:".localized()
        
        let p1 = "Version".localized()
        version.text = "\(p1) \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? "null")"
        
        
        
        let lan = game.string(forKey: "AppleLanguage")!
        let languageT = getLanguageFromCode(code: lan)
        languageRepresentation.setTitle(languageT, for: .normal)
    }
    
    
    
    func checkIfPurchased() {
        
        let numPurchase = game.integer(forKey: "fivePackPurchaseCount")
        let numHints = game.integer(forKey: ProjectMayhemProducts.fiveHints)
        //let lvlsToUnlock = 15 - (((numPurchase) * 5) - numHints)
        
        if numPurchase > 0 && numHints > 0 {
            let p1 = "Purchase an Extra Five Hints".localized()
            let p2 = "Unlockable Hints:".localized()
            fiveHintsDescription.text = "\(p1)\n\(p2) \(numHints)/15"
        } else {
            fiveHintsDescription.text = "Purchase Extra Hints For Five Levels".localized()
        }
        
        
        let allHintsUnlocked = ProjectMayhemProducts.store.isProductPurchased(ProjectMayhemProducts.hints)
        if allHintsUnlocked {
            purchaseprice.text = "Purchased".localized()
            purchaseprice.font = purchaseprice.font.withSize(14)
            purchaseprice.minimumScaleFactor = 0.4
            betterHintButton.tintColor = .gray
            betterHintButton.isUserInteractionEnabled = false
            
            fiveHintPurchasePrice.text = "All Hints Unlocked".localized()
            fiveHintPurchasePrice.font = fiveHintPurchasePrice.font.withSize(14)
            fiveHintPurchasePrice.minimumScaleFactor = 0.4
            fiveHintsButton.tintColor = .gray
            fiveHintsButton.isUserInteractionEnabled = false
            fiveHintsDescription.text = "All hints have been unlocked.".localized()
            return
        } else {
            purchaseprice.text = "$\(getIAP(productIdentifier: ProjectMayhemProducts.hints).price)"
        }
        
        if game.integer(forKey: "fivePackPurchaseCount") >= 3 {
            purchaseprice.text = "All Hints Unlocked".localized()
            purchaseprice.font = purchaseprice.font.withSize(14)
            purchaseprice.minimumScaleFactor = 0.4
            betterHintButton.tintColor = .gray
            betterHintButton.isUserInteractionEnabled = false
            
            fiveHintPurchasePrice.text = "Max Purchased".localized()
            fiveHintPurchasePrice.font = purchaseprice.font.withSize(14)
            fiveHintPurchasePrice.minimumScaleFactor = 0.4
            fiveHintsButton.tintColor = .gray
            fiveHintsButton.isUserInteractionEnabled = false
            return
        } else {
            fiveHintPurchasePrice.text = "$\(getIAP(productIdentifier: ProjectMayhemProducts.fiveHints).price)"
        }
    }
    
    
    
    @IBAction func feedback(_ sender: Any) {
        rList.removeAll()
        
        goToChat(vc: self)
    }
    
    @IBAction func visionConsolidatedWebsite(_ sender: Any) {
        openLink(st: "https://visionconsolidated.wixsite.com/website/project-mayhem-shop")    }
    
    
    @IBAction func instagram(_ sender: Any) {
        openLink(st: "https://www.instagram.com/vision_consolidated/")
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
    
    @IBAction func cellularSwitchChanged(_ sender: Any) {
        let state = cellularSwitch.isOn
        game.setValue(state, forKey: "useCellular")
    }
    
    @IBAction func language(_ sender: Any) {
        picker = UIPickerView.init()
        picker.delegate = self
        picker.dataSource = self
        picker.backgroundColor = UIColor.black
        picker.setValue(UIColor.white, forKey: "textColor")
        picker.autoresizingMask = .flexibleWidth
        picker.contentMode = .center
        let languageRow = getRowOfLanguageCode(code: game.string(forKey: "AppleLanguage")!)
        
        picker.selectRow(languageRow, inComponent: 0, animated: false)
        
        picker.frame = CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 300)
        self.view.addSubview(picker)
        
        toolBar = UIToolbar.init(frame: CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 50))
        toolBar.barStyle = .black
        toolBar.sizeToFit()
        let cancelButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.cancel, target: self, action: #selector(self.onCancelButtonTapped))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(self.onDoneButtonTapped))
        toolBar.setItems([cancelButton, flexibleSpace, doneButton], animated: false)
        
        self.view.addSubview(toolBar)
    }
    
    @objc func onCancelButtonTapped() {
        self.toolBar.removeFromSuperview()
        self.picker.removeFromSuperview()
    }
    
    @objc func onDoneButtonTapped() {
        toolBar.removeFromSuperview()
        picker.removeFromSuperview()
        
        
        if let row = pickerSelection {
            let languageString = getLanguage(row: row)
            print(languageString)
            
            let lang = getLanguageCode(row: row)
            
            Bundle.setLanguage(lang)
            game.set(lang, forKey: "AppleLanguage")
            game.synchronize()
            
            languageRepresentation.setTitle(languageString, for: .normal)
            setLocalizations()
            
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return languages.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let lan = getLanguage(row: row).localized()
        let str = "\(lan) (\(languages[lan]!))"
        return str
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerSelection = row
    }
    
    
    
    @IBAction func betterHints(_ sender: Any) {
        let product = getIAP(productIdentifier: ProjectMayhemProducts.hints)
        ProjectMayhemProducts.store.buyProduct(product, funcTo: checkIfPurchased)
    }
    
    
    @IBAction func fiveHints(_ sender: Any) {
        let product = getIAP(productIdentifier: ProjectMayhemProducts.fiveHints)
        ProjectMayhemProducts.store.buyProduct(product, funcTo: checkIfPurchased)
    }
    
    
    @IBAction func sliderChanged(_ sender: Any) {
        print(slider.value)
        game.setValue(slider.value, forKey: "volume")
        MusicPlayer.shared.volumeControl(factor: 0.4)
    }
    
    @IBAction func switchChanged(_ sender: Any) {
        let state = flashingSwitch.isOn
        game.setValue(state, forKey: "photosensitive")
    }
    
    @IBAction func reduceMotionSwitchChanged(_ sender: Any) {
        let state = motionSwitch.isOn
        game.setValue(state, forKey: "reduceMotion")
    }
    
    
    @IBAction func restorePurchases(_ sender: Any) {
        ProjectMayhemProducts.store.restorePurchases()
        let alertController = UIAlertController(title: "Restore".localized(), message: "Purchase Restore Complete.".localized(), preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "Okay".localized(), style: .cancel, handler: nil)
        alertController.addAction(defaultAction)
        wait {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func statement(_ sender: Any) {
        game.setValue("settings", forKey: "active")
        performSegue(withIdentifier: "settingsToIntroduction", sender: self)
    }
    
}
