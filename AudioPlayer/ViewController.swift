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
  @IBOutlet weak var timeSliderView: UISlider!
  var timeSliderViewIsTouchDown = false
  var preparePlay = false
  var seeking = false

  let player = KRLAudioPlayer.shared
  override func viewDidLoad() {
    super.viewDidLoad()
    player.delegate = self
  }
  
  
  @IBAction func play() {
    if let url = URL(string: "http://audio.xmcdn.com/group28/M02/B6/BA/wKgJXFlLT1nzyS8YAE2G2tYI3ek072.m4a") {
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
    seek(-3)
  }
  
  
  @IBAction func kuaijin(_ sender: UIButton) {
    seek(3)
  }
  
  func seek(_ time: TimeInterval) {
    player.seek(time)
    seeking = true
  }
  
  @IBAction func rate(_ sender: UIButton) {
    sender.isSelected = !sender.isSelected
    player.rate = sender.isSelected ? 2 : 1
  }
  
  
  @IBAction func mute(_ sender: UIButton) {
    sender.isSelected = !sender.isSelected
    player.isMuted = sender.isSelected
  }
  
  
  @IBAction func timeSliderValueChange(_ sender: UISlider) {
    if player.status == .unknow || player.status == .stop {
      preparePlay = true
      return
    }
    let duration = player.duration
    let currentTime = Float(duration) * sender.value
    playTimeLabel.text = String(format: "%02d:%02d", Int(currentTime) / 60, Int(currentTime) % 60)
    totalTimeLabel.text = String(format: "%02d:%02d", Int(duration) / 60, Int(duration) % 60)
  }
  
  @IBAction func timeSliderTouchDowm(_ sender: UISlider) {
    timeSliderViewIsTouchDown = true
  }
  
  @IBAction func timeSliderTouchUpInside(_ sender: UISlider) {
    timeSliderViewIsTouchDown = false
    if preparePlay == true {
      play()
      preparePlay = false
    }
    player.setPlayProgress(sender.value)
    seeking = true
  }
  
  @IBAction func volumeSliderAction(_ sender: UISlider) {
    player.volumd = sender.value
  }
}

// MARK: - KRLAudioPlayerDelegate
extension ViewController: KRLAudioPlayerDelegate {
  func audioPlayer(_ player: KRLAudioPlayer, currentTime: TimeInterval, duration: TimeInterval) {
    if timeSliderViewIsTouchDown || seeking { return }
    DispatchQueue.main.async {
      self.playTimeLabel.text = String(format: "%02d:%02d", Int(currentTime) / 60, Int(currentTime) % 60)
      self.totalTimeLabel.text = String(format: "%02d:%02d", Int(duration) / 60, Int(duration) % 60)
      self.timeSliderView.value = Float(currentTime / duration)
    }
  }

  func audioPlayer(_ player: KRLAudioPlayer, loadProgress: Float) {
    loadProgressView.setProgress(loadProgress, animated: true)
  }
  
  func audioPlayer(_ player: KRLAudioPlayer, seekStatus: Bool) {
    seeking = false
  }
  
  func playFinish(_ player: KRLAudioPlayer) {
    play()
  }
  
}

