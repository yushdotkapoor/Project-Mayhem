//
//  VideoPlayer.swift
//  Project Mayhem
//
//  Created by Yush Raj Kapoor on 2/18/21.
//

import AVKit
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
    var videoTitle:String?
    
    
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
    var isGreen = false
    
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
    
    var notificationTimer:Timer?
    var noPacketsTimer:Timer?
    var networkAlert = false
    
    
    // MARK: - Init
    convenience init(urlAss:String, view:PlayerView, arr:[Double], startTime:Double, volume: Float) {
        self.init()
        
        videoTitle = urlAss
        MusicPlayer.shared.volumeControl(factor: volume)
        pauseArray = arr
        playerView = view
        currentTime = startTime
        
        if let playView = playerView, let playerLayer = playView.layer as? AVPlayerLayer {
            playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        }
        
     
        let u = retrieveVideo(name: urlAss)
        if u != "" {
            initialSetupWithURL(url: URL(string: "file://\(u)")!)
            prepareToPlay()
        } else {
            //alert
            let v = validateVideos()
            downloadVideos(vidNames: v)
            print("Error Detected")
            game.setValue(v, forKey: "QueuedDownloads")
            for k in v {
                game.setValue(0.0, forKey: "\(k)DownloadProgress")
            }
            wait {
                let alertController = UIAlertController(title: "Error".localized(), message: "For some reason, the files for this chapter are corrupted. A fix has been deployed, but make sure your internet connection is stable. Please stay in the chapter and the chapter should automatically start once files are downloaded. If this problem persists, please contact me through the game chat.".localized(), preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "Okay".localized(), style: .cancel, handler: {_ in
                    self.overlayTag()
                })
                alertController.addAction(defaultAction)
                godThread!.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    func overlayTag() {
        let screenWidth = UIScreen.main.bounds.width
        
        let back = UIView(frame: CGRect(x: 20, y: 64, width: screenWidth - 40, height: 90))
        back.clipsToBounds = false
        back.layer.cornerRadius = 10
        back.backgroundColor = UIColor(named: "MayhemBlue")
        
        let circleRadius:CGFloat = 25
        
        let lbl = UILabel(frame: CGRect(x: 20, y: 20, width: back.frame.width - circleRadius*2 - 40, height: 50))
        lbl.textColor = .white
        lbl.text = "\("Connecting".localized())"
        lbl.numberOfLines = 0
        lbl.textAlignment = .left
        
        
        let circle = CircularProgressBarView(frame: CGRect(x: back.frame.width - circleRadius*2 - 20, y: 20, width: circleRadius*2, height: circleRadius*2))
        circle.createCircularPath(radius: Int(circleRadius))
        
        
        back.addSubview(lbl)
        back.addSubview(circle)
        back.alpha = 0
        
        godThread?.view.addSubview(back)
        back.fadeIn()
        
        noPacketsTimer = Timer.scheduledTimer(withTimeInterval: 15, repeats: false) { timer in
            self.checkNoIncomingPackets()
        }
        
        notificationTimer = Timer.scheduledTimer(withTimeInterval: 1.1, repeats: true) { timer in
            self.checkNotification(v: circle, l: lbl, fullAssCard: back)
        }
        
    }
    
    func checkForInternet() {
        if !CheckInternet.Connection() {
            networkAlert = true
            let alertController = UIAlertController(title: "Error".localized(), message: "It seems that you do not have stable network connection for downloading this game's content. To proceed, please connect to an internet network.".localized(), preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "Okay".localized(), style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            godThread!.present(alertController, animated: true, completion: nil)
        }
    }
    
    @objc func checkNoIncomingPackets() {
        let prog = game.double(forKey: "Chap1IntroDownloadProgress")
        if prog == 0.0 && CheckInternet.Connection() {
            let alertController = UIAlertController(title: "Error".localized(), message: "It seems that you have a poor internet connection. Try reseting your connection or change your connection to a faster one.".localized(), preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "Okay".localized(), style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            godThread!.present(alertController, animated: true, completion: nil)
        }
        
    }
    
    @objc func checkNotification(v: CircularProgressBarView, l: UILabel, fullAssCard: UIView) {
        var prog = 0.0
        let QDown = game.array(forKey: "QueuedDownloads")
        for n in QDown ?? [] {
            let progress = game.double(forKey: "\(n)DownloadProgress")
            prog += progress
        }
        prog = prog/Double((QDown ?? []).count)
        print("prog \(prog)")
        
        if !networkAlert && prog != 1.0 {
            checkForInternet()
        }
        if l.alpha == 0 {
            l.fadeIn()
        } else {
            l.fadeOut()
        }
        
        if prog == 1.0 {
            game.setValue(true, forKey: "introViewed")
            wait {
                fullAssCard.fadeOut()
                self.notificationTimer?.invalidate()
                self.noPacketsTimer?.invalidate()
                let u = retrieveVideo(name: self.videoTitle!)
                self.initialSetupWithURL(url: URL(string: "file://\(u)")!)
                self.prepareToPlay()
            }
        }
        
        
        let dist:Double = prog
        let dur = 0.5
        
        
        l.text = "\("Downloading Content".localized()) (\(String(format: "%.2f", (dist*100)))%)"
        
        v.grow(distance: dist, duration: dur)
        
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
                    impact(style: .light)
                }
                else {
                    impact(style: .error)
                }
                break
            }
        }
    }
    
    func viewDidTripleTap(willPass: Bool) {
        if !willPass {
            impact(style: .light)
            return
        }
        if let pauseTime = pauseArray?.last {
            var time = 0.0
            if let player = assetPlayer {
                time = CMTimeGetSeconds(player.currentTime())
            }
            
            if pauseTime > time {
                if pauseTime > time + 3.1 && video!.isPlaying(){
                    seekToPosition(seconds: pauseTime - 3)
                    impact(style: .light)
                }
                else {
                    impact(style: .error)
                }
            }
        }
    }
    
    func startFlash(lbl:UILabel, chap:[String], willFlash:Bool) {
        startFlash(lbl: lbl, chap: chap, willFlash: willFlash, hasTriple: false)
    }
    
    func startFlash(lbl:UILabel, chap:[String], willFlash:Bool, hasTriple:Bool) {
        let alpha = lbl.alpha
        let active = game.string(forKey: "active")
        if willFlash && !stopFlash {
            for i in pauseArray! {
                if i - currentTime > 0 && i - currentTime < 4 {
                    lbl.fadeOut()
                    wait {
                        self.startFlash(lbl:lbl, chap:chap, willFlash: willFlash, hasTriple: hasTriple)
                    }
                    return
                }
            }
            
            
            if chap.contains(active!) && isPlaying() {
                if alpha == 0.0 {
                    if hasTriple {
                        if isGreen {
                            lbl.text = "Triple Tap to Skip All".localized()
                            lbl.textColor = .red
                            isGreen = false
                        } else {
                            lbl.text = "Double Tap to Skip".localized()
                            lbl.textColor = .green
                            isGreen = true
                        }
                    }
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
                self.startFlash(lbl:lbl, chap:chap, willFlash: willFlash, hasTriple: hasTriple)
            }
        }
    }
    
    func stopFlashing(lbl:UILabel) {
        stopFlash = true
        lbl.fadeOut()
    }
    
    func loopTillReady(pl: AVPlayer) {
        if (pl.currentItem?.status == .readyToPlay) {
            print("PLAY w/out options")
            pl.play()
        } else if pl.currentItem?.status == .failed {
            let alertController = UIAlertController(title: "Error".localized(), message: "For some reason, the video player is failing. This should not happen, and this is an Apple issue. Contact me if the problem persists as you may have to redownload the app.".localized(), preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "Okay".localized(), style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            godThread!.present(alertController, animated: true, completion: nil)
        } else {
            wait {
                self.loopTillReady(pl:pl)
            }
        }
    }
    
    func seekToPosition(seconds:Float64) {
        if let player = assetPlayer {
            pause()
            if let timeScale = player.currentItem?.asset.duration.timescale {
                player.seek(to: CMTimeMakeWithSeconds(seconds, preferredTimescale: timeScale), completionHandler: { [self] (complete) in
                    self.functionCalled = false
                    self.playBlock = false
                    loopTillReady(pl: player)
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
        
        
        NotificationCenter.default.removeObserver(self)
        pause()
        assetPlayer = nil
        playerItem = nil
        urlAsset = nil
        stopFlash = true
        MusicPlayer.shared.volumeControl(factor: 0.4)
        
        notificationTimer?.invalidate()
        noPacketsTimer?.invalidate()
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
                        
                        if let group = asset.mediaSelectionGroup(forMediaCharacteristic: AVMediaCharacteristic.legible) {
                           
                           // let code = Locale.preferredLanguages.first
                            let code = game.string(forKey: "AppleLanguage")
                            let locale = Locale(identifier: code ?? "en-US")
                            
                            let options =
                                AVMediaSelectionGroup.mediaSelectionOptions(from: group.options, with: locale)
                            if let option = options.first {
                                playerItem?.select(option, in: group)
                            }
                        } else {
                            if videoTitle != "Chap1Intro" {
                                downloadVideos()
                            }
                        }
                        
                        
                        assetPlayer?.currentItem?.textStyleRules = [AVTextStyleRule(textMarkupAttributes: [kCMTextMarkupAttribute_OrthogonalLinePositionPercentageRelativeToWritingDirection as String: 50])!]
                        
                        
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
            wait {
            let alertController = UIAlertController(title: "Error".localized(), message: "Functionality of the application will not work if you are in a call, please disconnect the call to continue playing".localized(), preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "Okay".localized(), style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            godThread!.present(alertController, animated: true, completion: nil)
            }
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
    
    private func moviePlayerLoadedTimeRangeDidUpdated(ranges:Array<NSValue>) {
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
    
    deinit {
        cleanUp()
    }
    
    private func initialSetupWithURL(url:URL) {
        let options = [AVURLAssetPreferPreciseDurationAndTimingKey : true]
        urlAsset = AVURLAsset(url: url, options: options)
    }
    
    // MARK: - Observations
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == videoContext {
            if let key = keyPath {
                if key == "status", let player = assetPlayer {
                    playerDidChangeStatus(status: player.status)
                } else if key == "loadedTimeRanges", let item = playerItem {
                    moviePlayerLoadedTimeRangeDidUpdated(ranges: item.loadedTimeRanges)
                }
            }
        }
    }
}
