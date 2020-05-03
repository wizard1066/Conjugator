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

class PlayerUIView: UIView {
  private let playerLayer = AVPlayerLayer()
  override init(frame: CGRect) {
    super.init(frame: .zero)
    let url = Bundle.main.url(forResource:"finalV3", withExtension: "mov")
//    let url = URL(string: "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8")!
//    let url = URL(string: "https://www.youtube.com/watch?v=XK8METRgK_U")!
    let player = AVPlayer(url: url!)
    player.play()
    
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
}

struct PlayerView: UIViewRepresentable {
  func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<PlayerView>) {
  }
  func makeUIView(context: Context) -> UIView {
    return PlayerUIView(frame: .zero)
  }
}

struct playerPage: View {
  
  @EnvironmentObject var env : MyAppEnvironmentData
  
  var body: some View {
    ZStack {
        PlayerView().offset(x: 100, y: -100)
      }
    }
  }
