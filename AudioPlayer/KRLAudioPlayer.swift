//
//  AudioPlayer.swift
//  AudioPlayer
//
//  Created by karl on 2017/07/28.
//  Copyright © 2017年 Karl. All rights reserved.
//

import UIKit
import AVFoundation

@objc protocol KRLAudioPlayerDelegate: class {
  // 此方法异步
  @objc optional func audioPlayer(_ player: KRLAudioPlayer, currentTime: TimeInterval, duration: TimeInterval)
  @objc optional func audioPlayer(_ player: KRLAudioPlayer, loadProgress: Float)
  @objc optional func audioPlayer(_ player: KRLAudioPlayer, seekStatus: Bool)
  @objc optional func playFinish(_ player: KRLAudioPlayer)
}

enum KRLPlayStatus {
  case unknow
  case playing
  case pause
  case stop
  case failed
}

class KRLAudioPlayer: NSObject {
  // MARK: - public property
  static let shared = KRLAudioPlayer()
  fileprivate(set) var url: URL?
  var status = KRLPlayStatus.unknow
  weak var delegate: KRLAudioPlayerDelegate?
  var rate: Float = 1 {
    didSet {
      player.rate = rate
    }
  }
  
  var isMuted: Bool = false {
    didSet {
      player.isMuted = isMuted
    }
  }
  
  var volumd: Float = 1 {
    didSet {
      player.volume = volumd
    }
  }
  
  var currentTime: TimeInterval {
    guard let playerItem = player.currentItem else { return 0 }
    let time = CMTimeGetSeconds(playerItem.currentTime()).timeInterval
    return !time.isNaN ? time : 0
  }
  
  var duration: TimeInterval {
    guard let playerItem = player.currentItem else { return 0 }
    let time = CMTimeGetSeconds(playerItem.duration).timeInterval
    return !time.isNaN ? time : 0
  }
  
  // MARK: - private
  fileprivate let player = AVPlayer()
  fileprivate var playingObserver: Any? // 播放过程中的观察者
  
  deinit {
    removeObserve()
  }
}

// MARK: - public func
extension KRLAudioPlayer {
  func play(_ url: URL) {
    
    /*
     如果当前的URL和之前的一样
     1: 判断当前是暂停就继续播放
     2: 其他状态不用管
     
     如果当前的URL和之前不一样
     1: 干掉之前的重新播放
     */
    if self.url == url {
      switch status {
      case .playing:
        return
      case .pause:
        resume()
        return
      case .failed, .stop, .unknow:
        break
      }
    }
    
    // 移除老的kvo
    if let _ = self.player.currentItem {
      removeObserve()
      playFinish()
    }
    
    self.url = url
    let asset = AVURLAsset(url: url)
    let item = AVPlayerItem(asset: asset)
    player.replaceCurrentItem(with: item)
    
    // 用kvo监听资源的准备状态
    addObserver()
    
    playingObserver = player.addPeriodicTimeObserver(forInterval: CMTimeMake(1, 1), queue: DispatchQueue.global()) { [weak self] (cmTime) in
      guard let weakSelf = self else { return }
      let currentTime = CMTimeGetSeconds(cmTime).timeInterval
      weakSelf.delegate?.audioPlayer?(weakSelf, currentTime: currentTime, duration: weakSelf.duration)
    }
  }
  
  func pause() {
    status = .pause
    player.pause()
  }
  
  func resume() {
    status = .playing
    player.play()
  }
  
  func seek(_ time: TimeInterval) {
    let progress = (currentTime + time) / duration
    setPlayProgress(Float(progress))
  }
  
  func setPlayProgress(_ progress: Float) {
    guard progress == 0 ... 1, player.status == .readyToPlay else { return }
    // 算出应该加载到的时间
    let currentTime = duration * TimeInterval(progress)
    let seekTime = CMTimeMakeWithSeconds(Float64(currentTime), 1)
    player.currentItem?.seek(to: seekTime, completionHandler: { [weak self] (bool) in
      if let weakSelf = self {
        weakSelf.delegate?.audioPlayer?(weakSelf, seekStatus: bool)
      }
    })
  }
}

// MARK: - KVO
extension KRLAudioPlayer {
  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    if keyPath == "status", let rawValue = change?[.newKey] as? Int, let value = AVPlayerItemStatus(rawValue: rawValue) {
      switch value {
      case .readyToPlay:
        print("准备完毕")
        resume()
      case .failed:
        print("失败")
        status = .failed
      case .unknown:
        print("unknow")
        status = .unknow
      }
    } else if keyPath == "playbackLikelyToKeepUp" {
      print(change?[.newKey] ?? "")
    } else if keyPath == "loadedTimeRanges" {
      loadProgress()
    }
  }
  
  fileprivate func addObserver() {
    player.currentItem?.addObserver(self, forKeyPath: "status", options: [.new], context: nil)
    player.currentItem?.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: [.new], context: nil)
    player.currentItem?.addObserver(self, forKeyPath: "loadedTimeRanges", options: [.new], context: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(playFinish), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
  }

  
  fileprivate func removeObserve() {
    player.currentItem?.removeObserver(self, forKeyPath: "status")
    player.currentItem?.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
    player.currentItem?.removeObserver(self, forKeyPath: "loadedTimeRanges")
    NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
  }
}

extension KRLAudioPlayer {
  
  @objc fileprivate func playFinish() {
    guard let observer = playingObserver else {return }
    status = .stop
    player.removeTimeObserver(observer)
    playingObserver = nil
    delegate?.playFinish?(self)
    print("播放完毕")
  }
  
  @objc fileprivate func loadProgress() {
    guard let timeRange = player.currentItem?.loadedTimeRanges.last?.timeRangeValue else { return }
    
    /*:< 两种方式
    1:
    let startSeconds = CMTimeGetSeconds(timeRange.start)
    let durationSeconds = CMTimeGetSeconds(timeRange.duration)
    let loadTime = startSeconds + durationSeconds// 计算缓冲总进度
    */
    
    // 2:
    let loadCMTime = CMTimeAdd(timeRange.start, timeRange.duration)
    let loadTime = CMTimeGetSeconds(loadCMTime).timeInterval
    
    delegate?.audioPlayer?(self, loadProgress: Float(loadTime / duration))
  }
}

extension Float64 {
  var timeInterval: TimeInterval {
    return TimeInterval(self)
  }
}

protocol RangeComparable {}
extension RangeComparable where Self: Comparable  {
  static func ==(lhs: Self, rhs: ClosedRange<Self>) -> Bool {
    return rhs.contains(lhs)
  }
}

extension Float: RangeComparable {}
