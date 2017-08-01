//
//  ViewController.swift
//  AudioPlayer
//
//  Created by karl on 2017/07/28.
//  Copyright © 2017年 Karl. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  @IBOutlet weak var playTimeLabel: UILabel!
  @IBOutlet var totalTimeLabel: UILabel!
  @IBOutlet weak var loadProgressView: UIProgressView!
  @IBOutlet weak var playSliderView: UISlider!
  
  var timer: Timer?

  let player = KRLAudioPlayer.shared
  override func viewDidLoad() {
    super.viewDidLoad()
    player.delegate = self
  }
  
  
  @IBAction func play(_ sender: UIButton) {
    if let url = URL(string: "http://audio.xmcdn.com/group23/M04/63/C5/wKgJNFg2qdLCziiYAGQxcTOSBEw402.m4a") {
      player.play(url)
      timer = Timer(timeInterval: 1, repeats: true, block: { [weak self] (timer) in
        guard let weakSelf = self else { return }
        weakSelf.playTimeLabel.text = String(format: "%02d:%02d", Int(weakSelf.player.currentTime) / 60, Int(weakSelf.player.currentTime) % 60)
        
        weakSelf.totalTimeLabel.text = String(format: "%02d:%02d", Int(weakSelf.player.duration) / 60, Int(weakSelf.player.duration) % 60)
        
        weakSelf.playSliderView.value = Float(weakSelf.player.currentTime / weakSelf.player.duration)
      })
      RunLoop.current.add(timer!, forMode: RunLoopMode.commonModes)
    }
    
  }
  
  @IBAction func pause(_ sender: UIButton) {
    player.pause()
  }
  
  @IBAction func resume(_ sender: UIButton) {
    player.resume()
  }
  
  
  @IBAction func kuaitui(_ sender: UIButton) {
    player.seek(-3)
  }
  
  
  @IBAction func kuaijin(_ sender: UIButton) {
    player.seek(3)
  }
  
  @IBAction func rate(_ sender: UIButton) {
    sender.isSelected = !sender.isSelected
    player.rate = sender.isSelected ? 2 : 1
  }
  
  
  @IBAction func mute(_ sender: UIButton) {
    sender.isSelected = !sender.isSelected
    player.isMuted = sender.isSelected
  }
  
  
  @IBAction func timeSliderAction(_ sender: UISlider) {
    player.setPlayProgress(sender.value)
  }
  
  
  @IBAction func volumeSliderAction(_ sender: UISlider) {
    player.volumd = sender.value
  }
}

// MARK: - KRLAudioPlayerDelegate
extension ViewController: KRLAudioPlayerDelegate {
  func playFinish(_player: KRLAudioPlayer) {
    timer?.invalidate()
  }
  
  func loadProgress(_player: KRLAudioPlayer, progress: Float) {
    loadProgressView.setProgress(progress, animated: true)
  }
}

