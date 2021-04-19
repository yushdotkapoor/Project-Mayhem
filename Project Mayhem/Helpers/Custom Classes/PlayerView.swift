//
//  PlayerView.swift
//  Project Mayhem
//
//  Created by Yush Raj Kapoor on 2/18/21.
//

import AVFoundation
import UIKit

class PlayerView: UIView {
    
    var player: AVPlayer? {
        get {
            return playerLayer.player
        }
        set {
            playerLayer.player = newValue
        }
    }
    
    var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
    
    // Override UIView property
    override static var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
}
