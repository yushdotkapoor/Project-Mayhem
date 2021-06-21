//
//  chapter15.swift
//  Project Mayhem
//
//  Created by Yush Raj Kapoor on 02/02/21.
//

import UIKit
import AVFoundation

class chapter15: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate  {
    @IBOutlet weak var nextChap: UIButton!
    @IBOutlet weak var hint: UIButton!
    @IBOutlet weak var toolbar: UIStackView!
    @IBOutlet weak var one: UIImageView!
    @IBOutlet weak var two: UIImageView!
    @IBOutlet weak var three: UIImageView!
    @IBOutlet weak var four: UIImageView!
    @IBOutlet weak var five: UIImageView!
    @IBOutlet weak var six: UIImageView!
    @IBOutlet weak var colorLabel: UILabel!
    @IBOutlet weak var centerCircle: UIImageView!
    @IBOutlet weak var sixHeight: NSLayoutConstraint!
    @IBOutlet weak var smartImage: UIImageView!
    
    var customAlert = HintAlert()
    
    let WIDTH = UIScreen.main.bounds.width
    let HEIGHT = UIScreen.main.bounds.height
    var center: CGPoint = CGPoint(x: UIScreen.main.bounds.width/2-15, y: UIScreen.main.bounds.width/2-15)
    
    let captureSession = AVCaptureSession()
    var backFacingCamera: AVCaptureDevice?
    var currentDevice: AVCaptureDevice?
    
    let oneColor = UIColor(red: 35/255, green: 98/255, blue:143/255, alpha: 1.0)
    let twoColor = UIColor(red: 79/255, green: 143/255, blue: 35/255, alpha: 1.0)
    let threeColor = UIColor(red: 54/255, green: 37/255, blue: 180/255, alpha: 1.0)
    let fourColor = UIColor(red: 191/255, green: 134/255, blue: 160/255, alpha: 1.0)
    let fiveColor = UIColor(red: 169/255, green: 217/255, blue: 142/255, alpha: 1.0)
    let sixColor = UIColor(red: 100/255, green: 76/255, blue:127/255, alpha: 1.0)
    
    var captures:[Bool] = [false, false, false, false, false, false]
    var nextIndex:Int = 0
    var colors:[UIColor] = []
    var rings:[UIImageView] = []
    
    let previewLayer = CALayer()
    let lineShape = CAShapeLayer()
    
    var isInverted = false
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        CVPixelBufferLockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: CVOptionFlags(0)))
        guard let baseAddr = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0) else {
            return
        }
        let width = CVPixelBufferGetWidthOfPlane(imageBuffer, 0)
        let height = CVPixelBufferGetHeightOfPlane(imageBuffer, 0)
        let bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer, 0)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bimapInfo: CGBitmapInfo = [
            .byteOrder32Little,
            CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)]
        
        guard let content = CGContext(data: baseAddr, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bimapInfo.rawValue) else {
            return
        }
        
        guard let cgImage = content.makeImage() else {
            return
        }
        
        DispatchQueue.main.async {
            self.previewLayer.contents = cgImage
            let color = self.previewLayer.pickColor(at: self.center)
            self.colorFixate(c:color!)
        }
    }
    
    func colorFixate(c: UIColor) {
        let rgbColor = CIColor(color: c)
        let red:Int = Int(rgbColor.red * 255)
        let green:Int = Int(rgbColor.green * 255)
        let blue:Int = Int(rgbColor.blue * 255)
        
        let rgbColorNext = CIColor(color: colors[nextIndex])
        let redNext:Int = 255 - Int(rgbColorNext.red * 255)
        let greenNext:Int = 255 - Int(rgbColorNext.green * 255)
        let blueNext:Int = 255 - Int(rgbColorNext.blue * 255)
        let delta = 20
        
        
        let string = "(\(redNext), \(greenNext), \(blueNext))"
        
        let redRange = (string as NSString).range(of: "\(redNext)")
        let greenRange = (string as NSString).range(of: "\(greenNext)")
        let blueRange = (string as NSString).range(of: "\(blueNext)")

        let mutableAttributedString = NSMutableAttributedString.init(string: string)
        mutableAttributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(red: 255/255, green: 0, blue: 0, alpha: 1.0) , range: redRange)
        mutableAttributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.green, range: greenRange)
        mutableAttributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.blue, range: blueRange)
        
        colorLabel.attributedText = mutableAttributedString
        
        if isInverted {
            //colorLabel.isHidden = false
            centerCircle.tintColor = c.inverted()
            for (i,cap) in captures.enumerated() {
                if cap {
                    rings[i].tintColor = c.inverted()
                }
            }
        }
        else {
            colorLabel.text = "evtnir"
            colorLabel.textColor = c
            centerCircle.tintColor = c
            for (i,cap) in captures.enumerated() {
                if cap {
                    rings[i].tintColor = c
                }
            }
            return
        }
        
        if isClose(num: redNext, compareTo: red, delta: delta) && isClose(num: greenNext, compareTo: green, delta: delta) && isClose(num: blueNext, compareTo: blue, delta: delta) {
            
            captures[nextIndex] = true
            impact(style: .medium)
            
            if nextIndex < 5 {
                nextIndex += 1
            }
            else {
                captureSession.stopRunning()
                for (i,cap) in captures.enumerated() {
                    if cap {
                        rings[i].tintColor = colors.last
                    }
                }
                centerCircle.tintColor = colors.last
                UIView.animate(withDuration: 2, delay: 0, options: .curveEaseOut, animations: {
                    self.sixHeight.constant *= 5
                    self.view.layoutIfNeeded()
                }, completion: {
                    action in
                    self.alert.showAlert(title: "\(messageFrom) Yush Raj Kapoor", message: "We need to talk.".localized(), viewController: self, buttonPush: #selector(self.dismissMessageAlert))
                })
            }
        }
        
    }
    
    // defines alert
    let alert = MessageAlert()
    
    //function that gets called to dismiss the alertView
    @objc func dismissMessageAlert() {
        alert.dismissAlert()
        complete()
    }
    
    func isClose(num:Int, compareTo: Int, delta: Int) -> Bool {
        if num <= (compareTo + delta) && num >= (compareTo - delta) {
            return true
        }
        return false
    }
    
    func setupUI() {
        previewLayer.bounds = CGRect(x: 0, y: 0, width: WIDTH-30, height: WIDTH-30)
        previewLayer.position = view.center
        previewLayer.contentsGravity = CALayerContentsGravity.resizeAspectFill
        previewLayer.masksToBounds = true
        previewLayer.setAffineTransform(CGAffineTransform(rotationAngle: CGFloat(.pi / 2.0)))
        view.layer.insertSublayer(previewLayer, at: 0)
        
        
        let linePath = UIBezierPath.init(ovalIn: CGRect.init(x: 0, y: 0, width: 40, height: 40))
        lineShape.frame = CGRect.init(x: WIDTH/2-20, y:HEIGHT/2-20, width: 40, height: 40)
        lineShape.lineWidth = 5
        lineShape.strokeColor = UIColor.red.cgColor
        lineShape.path = linePath.cgPath
        lineShape.fillColor = UIColor.clear.cgColor
        self.view.layer.insertSublayer(lineShape, at: 1)
        
    }
    
    func reColor() {
        if isInverted {
            for (i,col) in colors.enumerated() {
                rings[i].tintColor = col.inverted()
            }
        }
        else {
            for (i,col) in colors.enumerated() {
                rings[i].tintColor = col
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        self.CreateUI()
        rings = [one, two, three, four, five, six]
        colors = [oneColor, twoColor, threeColor, fourColor, fiveColor, sixColor]
        
        for (i,col) in colors.enumerated() {
            rings[i].tintColor = col
        }
        
        game.setValue("chap15", forKey: "active")
        
        let rgbColorNext = CIColor(color: oneColor)
        let redNext:Int = Int(rgbColorNext.red * 255)
        let greenNext:Int = Int(rgbColorNext.green * 255)
        let blueNext:Int = Int(rgbColorNext.blue * 255)
        colorLabel.text = "(\(redNext), \(greenNext), \(blueNext))"
        
        isInverted = UIAccessibility.isInvertColorsEnabled
        
        NotificationCenter.default.addObserver(self, selector: #selector(inverted), name: UIAccessibility.invertColorsStatusDidChangeNotification, object: nil)
        self.smartImage.image = UIImage(named: "lvl15Normal")!
        startImageSwitch()
        view.bringSubviewToFront(toolbar)
        
    }
    
    func startImageSwitch() {
        
        if game.string(forKey: "active") != "chap15" {
            return
        }
        
        var img:UIImage
        
        if smartImage.image == UIImage(named: "lvl15Normal") {
            img = UIImage(named: "lvl15Inverted")!
        }
        else {
            img = UIImage(named: "lvl15Normal")!
        }
        wait {
            self.smartImage.image = img
            self.startImageSwitch()
        }
        
    }
    
    @objc func inverted() {
        let status = UIAccessibility.isInvertColorsEnabled
        isInverted = status
    }
    
    
    func CreateUI() {
        self.captureSession.sessionPreset = AVCaptureSession.Preset.hd1280x720
        
        let devices = AVCaptureDevice.devices(for: AVMediaType.video)
        for device in devices {
            if device.position == AVCaptureDevice.Position.back {
                self.backFacingCamera = device
            }
        }
        
        
        self.currentDevice = self.backFacingCamera
        do {
            
            let captureDeviceInput = try AVCaptureDeviceInput(device: currentDevice!)
            let videoOutput = AVCaptureVideoDataOutput()
            videoOutput.videoSettings = ([kCVPixelBufferPixelFormatTypeKey as AnyHashable: NSNumber(value: kCMPixelFormat_32BGRA)] as! [String : Any])
            videoOutput.alwaysDiscardsLateVideoFrames = true
            videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "com.camera.video.queue"))
            
            if self.captureSession.canAddOutput(videoOutput) {
                self.captureSession.addOutput(videoOutput)
            }
            self.captureSession.addInput(captureDeviceInput)
        } catch {
            print(error)
            return
        }
        self.captureSession.startRunning()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let complete15 = game.bool(forKey: "preChap15")
        let completePost = game.bool(forKey: "postChap15")
        
        if !(complete15 && !completePost) {
            nextChap.alpha = 0.0
            nextChap.isUserInteractionEnabled = false
        }
    }
    
    
    func complete() {
        game.setValue(true, forKey: "preChap15")
        game.setValue("none", forKey: "active")
        NotificationCenter.default.removeObserver(self)
        nextChap.isUserInteractionEnabled = true
        impact(style: .success)
        nextChap.fadeIn()
    }
    
    @IBAction func goBack(_ sender: Any) {
        NotificationCenter.default.removeObserver(self)
        self.performSegue(withIdentifier: "chap15ToHome", sender: nil)
    }
    
    @IBAction func goNext(_ sender: Any) {
        self.performSegue(withIdentifier: "chap15ToSubPostChap15", sender: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.captureSession.stopRunning()
    }
    
    @IBAction func hint(_ sender: Any) {
        if menuState {
            //if menu open and want to close
            dismissAlert()
        }
        else {
            menuState = true
            //if menu closed and want to open
            hint.rotate(rotation: 0.49999, duration: 0.5, option: [])
            UIView.animate(withDuration: 0.5) {
                self.hint.tintColor = UIColor.lightGray
            }
            customAlert = HintAlert()
            customAlert.showAlert(message: "15.1", viewController: self, hintButton: hint, toolbar: toolbar)
        }
        
    }
    
    func dismissAlert() {
        customAlert.dismissAlert()
    }
    
}
