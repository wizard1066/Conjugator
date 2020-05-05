//
//  PlayerPage.swift
//  Conjugator
//
//  Created by localadmin on 03.05.20.
//  Copyright © 2020 Mark Lucking. All rights reserved.
//

import Foundation
import SwiftUI
import AVFoundation
import Combine

let timePublisher = PassthroughSubject<TimeInterval, Never>()
let videoFinished = PassthroughSubject<Void, Never>()
let nextFrame = PassthroughSubject<Void, Never>()

//class PlayerTimeObserver {
////  let publisher = PassthroughSubject<TimeInterval, Never>()
//  private var timeObservation: Any?
//
//  init(player: AVPlayer) {
//    // Periodically observe the player's current time, whilst playing
//    timeObservation = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.5, preferredTimescale: 600), queue: nil) { [weak self] time in
//      guard let self = self else { return }
//      // Publish the new player time
//      print("time ",time.seconds)
//      self.publisher.send(time.seconds)
//    }
//  }
//}

struct PlayerTimeView: View {
//  let timeObserver: PlayerTimeObserver
  @State private var currentTime: TimeInterval = 0
  
  var body: some View {
    Text("\(currentTime)")
    .onReceive(timePublisher) { time in
      self.currentTime = time
    }
  }
}

class PlayerUIView: UIView {
//  let publisher = PassthroughSubject<TimeInterval, Never>()
  private var timeObservation: Any?
  private let playerLayer = AVPlayerLayer()
  override init(frame: CGRect) {
    super.init(frame: .zero)
    let url = Bundle.main.url(forResource:"AppDemo", withExtension: "mov")
//    let url = URL(string: "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8")!
//    let url = URL(string: "https://www.youtube.com/watch?v=XK8METRgK_U")!
    let player = AVPlayer(url: url!)
    player.play()
    
    timeObservation = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.5, preferredTimescale: 600), queue: nil) { [weak self] time in
      guard let self = self else { return }
      // Publish the new player time
      print("time.seconds ",time.seconds)
      timePublisher.send(time.seconds)
      
      NotificationCenter.default.addObserver(self, selector: #selector(self.finishVideo), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    playerLayer.player = player
    layer.addSublayer(playerLayer)
  }
  required init?(coder: NSCoder) {
   fatalError("init(coder:) has not been implemented")
  }
  override func layoutSubviews() {
    super.layoutSubviews()
    playerLayer.frame = CGRect(x: 0, y: -115, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
  }
  
  @objc func finishVideo() {
        print("Video Finished")
        NotificationCenter.default.removeObserver(NSNotification.Name.AVPlayerItemDidPlayToEndTime)
        videoFinished.send()
        nextFrame.send()
  }
  
}



struct PlayerView: UIViewRepresentable {
  func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<PlayerView>) {
  }
  func makeUIView(context: Context) -> UIView {
      PlayerUIView(frame: .zero)
  }
}

struct playerPage: View {
  @EnvironmentObject var env : MyAppEnvironmentData
  @Environment(\.presentationMode) var presentation
  
  var body: some View {
    VStack {
        PlayerView().onReceive(videoFinished) { (_) in
          self.presentation.wrappedValue.dismiss()
        }
      HStack {
        Spacer()
        PlayerTimeView()
          .font(Fonts.avenirNextCondensedBold(size: 16))
        Spacer()
      }
      }
    }
  }
