//
//  VideoPlayer.swift
//  Project Mayhem
//
//  Created by Yush Raj Kapoor on 2/18/21.
//

import AVFoundation
import Foundation
import UIKit

protocol VideoPlayerDelegate {
    func downloadedProgress(progress:Double)
    func readyToPlay()
    func didUpdateProgress(progress:Double)
    func didFinishPlayItem()
    func didFailPlayToEnd()
}

let videoContext: UnsafeMutableRawPointer? = nil

class VideoPlayer : NSObject {
    
    var assetPlayer:AVPlayer?
    private var playerItem:AVPlayerItem?
    private var urlAsset:AVURLAsset?
    private var videoOutput:AVPlayerItemVideoOutput?
    
    var assetDuration:Double = 0
    private var playerView:PlayerView?
    var currentTime:Double = 0
    
    private var autoRepeatPlay:Bool = false
    private var autoPlay:Bool = true
    
    var pauseArray:[Double]?
    
    var delegate:VideoPlayerDelegate?
    
    var playBlock = false
    var stopFlash = false
    var functionCalled = false
    
    var volumeViolated = false
    
    var requiresVolume = true
    
    
    var playerRate:Float = 1 {
        didSet {
            if let player = assetPlayer {
                player.rate = playerRate > 0 ? playerRate : 0.0
            }
        }
    }
    
    var volume:Float = 1.0 {
        didSet {
            if let player = assetPlayer {
                player.volume = volume > 0 ? volume : 0.0
            }
        }
    }
    
    
    // MARK: - Init
    
    convenience init(urlAsset:String, view:PlayerView, arr:[Double], startTime:Double, volume: Float) {
        self.init(urlAsset: urlAsset, view: view, arr: arr, startTime: startTime, volume: volume, needVolume: true)
    }
    
    convenience init(urlAsset:String, view:PlayerView, arr:[Double], startTime:Double, volume: Float, needVolume: Bool) {
        self.init()
        
        MusicPlayer.shared.volumeControl(factor: volume)
        pauseArray = arr
        playerView = view
        currentTime = startTime
        requiresVolume = needVolume
        
        if let playView = playerView, let playerLayer = playView.layer as? AVPlayerLayer {
            playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        }
        
        initialSetupWithURL(url: urlDict[urlAsset] ?? vidToURL(name: "\(urlAsset)Compressed", type: "mov"))
        
        prepareToPlay()
    }
    
    override init() {
        super.init()
    }
    
    // MARK: - Public
    
    
    func isPlaying() -> Bool {
        if let player = assetPlayer {
            return player.rate > 0
        } else {
            return false
        }
    }
    
    func viewDidDoubleTap(willPass: Bool) {
        if !willPass {
            impact(style: .light)
            return
        }
        for pauseTime in pauseArray! {
            var time = 0.0
            if let player = assetPlayer {
                time = CMTimeGetSeconds(player.currentTime())
            }
            
            if pauseTime > time {
                if pauseTime > time + 3.1 && video!.isPlaying(){
                    seekToPosition(seconds: pauseTime - 3)
                }
                else {
                    impact(style: .light)
                }
                break
            }
        }
    }
    
    func startFlash(lbl:UILabel, chap:[String], willFlash:Bool) {
        let alpha = lbl.alpha
        let active = game.string(forKey: "active")
        if willFlash && !stopFlash {
            for i in pauseArray! {
                if i - currentTime > 0 && i - currentTime < 4 {
                    lbl.fadeOut()
                    wait {
                        self.startFlash(lbl:lbl, chap:chap, willFlash: willFlash)
                    }
                    return
                }
            }
            
            
            if chap.contains(active!) && isPlaying() {
                if alpha == 0.0 {
                    lbl.fadeIn()
                }
                else {
                    lbl.fadeOut()
                }
            }
            else {
                lbl.alpha = 0.0
            }
            wait {
                self.startFlash(lbl:lbl, chap:chap, willFlash: willFlash)
            }
        }
    }
    
    func stopFlashing(lbl:UILabel) {
        stopFlash = true
        lbl.fadeOut()
    }
    
    func seekToPosition(seconds:Float64) {
        if let player = assetPlayer {
            pause()
            if let timeScale = player.currentItem?.asset.duration.timescale {
                player.seek(to: CMTimeMakeWithSeconds(seconds, preferredTimescale: timeScale), completionHandler: { (complete) in
                    self.functionCalled = false
                    self.playBlock = false
                        if (player.currentItem?.status == .readyToPlay) {
                            print("PLAY w/out options")
                            player.play()
                        }
                })
            }
        }
    }
    
    func pause() {
        print("PAUSE")
        if let player = assetPlayer {
            player.pause()
        }
    }
    
    func play() {
        if functionCalled {
            return
        }
        if talk != nil {
        if (talk?.isActive())! {
            wait(time:0.1, actions: {
                self.play()
            })
            return
        }
        }
        if let player = assetPlayer {
            if (player.currentItem?.status == .readyToPlay) {
                player.play()
                player.rate = playerRate
                print("PLAY")
                playingBlock()
            }
            volumeCheck()
        }
    }
    
    func playingBlock() {
        playBlock = true
        wait {
            self.playBlock = false
        }
    }
    
    func cleanUp() {
        print("player cleanUp in progress")
        if let item = playerItem {
            item.removeObserver(self, forKeyPath: "status")
            item.removeObserver(self, forKeyPath: "loadedTimeRanges")
        }
        
        AVAudioSession.sharedInstance().removeObserver(self, forKeyPath: "outputVolume")
        NotificationCenter.default.removeObserver(self)
        pause()
        assetPlayer = nil
        playerItem = nil
        urlAsset = nil
        stopFlash = true
        MusicPlayer.shared.volumeControl(factor: 0.4)
    }
    
    // MARK: - Private
    
    private func prepareToPlay() {
        let keys = ["tracks"]
        if let asset = urlAsset {
            asset.loadValuesAsynchronously(forKeys: keys, completionHandler: {
                DispatchQueue.main.async {
                    self.startLoading()
                }
            })
        }
    }
    
    private func startLoading(){
        var error:NSError?
        guard let asset = urlAsset else {return}
        let status:AVKeyValueStatus = asset.statusOfValue(forKey: "tracks", error: &error)
        
        if status == AVKeyValueStatus.loaded {
            assetDuration = CMTimeGetSeconds(asset.duration)
            
            let videoOutputOptions = [kCVPixelBufferPixelFormatTypeKey as String : Int(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange)]
            videoOutput = AVPlayerItemVideoOutput(pixelBufferAttributes: videoOutputOptions)
            playerItem = AVPlayerItem(asset: asset)
            
            AVAudioSession.sharedInstance().addObserver(self, forKeyPath: "outputVolume", options: [.new], context: nil)
            
            if let item = playerItem {
                item.addObserver(self, forKeyPath: "status", options: .initial, context: videoContext)
                item.addObserver(self, forKeyPath: "loadedTimeRanges", options: [.new, .old], context: videoContext)
                
                NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
                NotificationCenter.default.addObserver(self, selector: #selector(didFailedToPlayToEnd), name: NSNotification.Name.AVPlayerItemFailedToPlayToEndTime, object: nil)
                
                if let output = videoOutput {
                    item.add(output)
                    
                    item.audioTimePitchAlgorithm = AVAudioTimePitchAlgorithm.varispeed
                    assetPlayer = AVPlayer(playerItem: item)
                    
                    if let player = assetPlayer {
                        player.rate = playerRate
                    }
                    
                    addPeriodicalObserver()
                    if let playView = playerView, let layer = playView.layer as? AVPlayerLayer {
                        layer.player = assetPlayer
                        
                        print("player created at time \(currentTime)")
                        seekToPosition(seconds: currentTime)
                        wait {
                            self.phoneCallError()
                        }
                    }
                }
            }
        }
    }
    
    func phoneCallError() {
        if isOnPhoneCall() {
            pause()
            let alertController = UIAlertController(title: "Error", message: "Functionality of the application will not work if you are in a call, please disconnect the call to continue playing", preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
            godThread!.present(alertController, animated: true, completion: nil)
        }
    }
    
    private func addPeriodicalObserver() {
        let timeInterval = CMTimeMake(value: 1, timescale: 20)
        
        if let player = assetPlayer {
            player.addPeriodicTimeObserver(forInterval: timeInterval, queue: DispatchQueue.main, using: { (time) in
                self.playerDidChangeTime(time: time)
            })
        }
    }
    
    private func playerDidChangeTime(time:CMTime) {
        if let player = assetPlayer {
            let timeNow = CMTimeGetSeconds(player.currentTime())
            currentTime = timeNow
            let progress = timeNow / assetDuration
            if !playBlock {
                pauseCheck(time: timeNow)
            }
            delegate?.didUpdateProgress(progress: progress)
        }
    }
    
    private func pauseCheck(time: Double) {
        for reference in pauseArray! {
            if (reference + 0.04) > time && (reference - 0.04) < time && !functionCalled {
                impact(style: .heavy)
                pause()
                functionBlock()
                funcToPass!()
            }
        }
    }
    
    func functionBlock() {
        functionCalled = true
        wait {
            self.functionCalled = false
        }
    }
    
    @objc private func playerItemDidReachEnd() {
        delegate?.didFinishPlayItem()
        
        if let player = assetPlayer {
            if autoRepeatPlay == true {
                player.seek(to: CMTime.zero)
                play()
            }
        }
    }
    
    @objc private func didFailedToPlayToEnd() {
        delegate?.didFailPlayToEnd()
    }
    
    private func playerDidChangeStatus(status:AVPlayer.Status) {
        if status == .failed {
            print("Failed to load video")
        } else if status == .readyToPlay, let player = assetPlayer {
            volume = player.volume
            delegate?.readyToPlay()
            if autoPlay == true && player.rate == 0.0 {
                play()
            }
        }
    }
    
    private func moviewPlayerLoadedTimeRangeDidUpdated(ranges:Array<NSValue>) {
        var maximum:TimeInterval = 0
        for value in ranges {
            let range:CMTimeRange = value.timeRangeValue
            let currentLoadedTimeRange = CMTimeGetSeconds(range.start) + CMTimeGetSeconds(range.duration)
            if currentLoadedTimeRange > maximum {
                maximum = currentLoadedTimeRange
            }
        }
        let progress:Double = assetDuration == 0 ? 0.0 : Double(maximum) / assetDuration
        
        delegate?.downloadedProgress(progress: progress)
    }
    
    func volumeCheck() {
        let vol = AVAudioSession.sharedInstance().outputVolume
        if vol < 0.15 && requiresVolume {
            video?.pause()
            volumeViolated = true
            let alertController = UIAlertController(title: "Volume Error", message: "Certain elements of this level require audio. Please turn your volume up. The level will continue once the required volume is reached.", preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
            godThread!.present(alertController, animated: true, completion: nil)
        }
    }
    
    deinit {
        cleanUp()
    }
    
    private func initialSetupWithURL(url:NSURL) {
        let options = [AVURLAssetPreferPreciseDurationAndTimingKey : true]
        urlAsset = AVURLAsset(url: url as URL, options: options)
    }
    
    // MARK: - Observations
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if context == videoContext {
            if let key = keyPath {
                if key == "status", let player = assetPlayer {
                    playerDidChangeStatus(status: player.status)
                } else if key == "loadedTimeRanges", let item = playerItem {
                    moviewPlayerLoadedTimeRangeDidUpdated(ranges: item.loadedTimeRanges)
                }
            }
        }
        if keyPath == "outputVolume"{
            let audioSession = AVAudioSession.sharedInstance()
            if !(video?.isPlaying())! && audioSession.outputVolume >= 0.15 {
                if volumeViolated {
                    impact(style: .medium)
                    print(volumeViolated)
                    talk?.pause()
                    video?.play()
                    volumeViolated = false
                }
            }
        }
    }
}
