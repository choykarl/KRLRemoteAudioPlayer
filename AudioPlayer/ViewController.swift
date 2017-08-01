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

  let player = KRLAudioPlayer.shared
  override func viewDidLoad() {
    super.viewDidLoad()
    player.delegate = self
  }
  
  
  @IBAction func play(_ sender: UIButton) {
    if let url = URL(string: "http://audio.xmcdn.com/group23/M04/63/C5/wKgJNFg2qdLCziiYAGQxcTOSBEw402.m4a") {
      player.play(url)
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
  func playing(_ player: KRLAudioPlayer, currentTime: TimeInterval, duration: TimeInterval) {
    DispatchQueue.main.async {
      self.playTimeLabel.text = String(format: "%02d:%02d", Int(currentTime) / 60, Int(currentTime) % 60)
      self.totalTimeLabel.text = String(format: "%02d:%02d", Int(duration) / 60, Int(duration) % 60)
      self.playSliderView.value = Float(currentTime / duration)
    }
  }
  
  func playFinish(_player: KRLAudioPlayer) {
    
  }
  
  func loadProgress(_player: KRLAudioPlayer, progress: Float) {
    loadProgressView.setProgress(progress, animated: true)
  }
}

