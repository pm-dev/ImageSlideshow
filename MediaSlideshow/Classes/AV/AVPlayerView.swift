//
//  AVPlayerView.swift
//  MediaSlideshow
//
//  Created by Peter Meyers on 1/7/21.
//

import AVFoundation
import Foundation

open class AVPlayerView: UIView {
    open override class var layerClass: AnyClass {
        AVPlayerLayer.self
    }

    open var playerLayer: AVPlayerLayer {
        layer as! AVPlayerLayer
    }

    open var player: AVPlayer? {
        get { playerLayer.player }
        set { playerLayer.player = newValue }
    }

    open var videoGravity: AVLayerVideoGravity {
        get { playerLayer.videoGravity }
        set { playerLayer.videoGravity = newValue }
    }

    open var isReadyForDisplay: Bool {
        playerLayer.isReadyForDisplay
    }

    open var videoRect: CGRect {
        playerLayer.videoRect
    }

    open var pixelBufferAttributes: [String : Any]? {
        get { playerLayer.pixelBufferAttributes }
        set { playerLayer.pixelBufferAttributes = newValue }
    }
}
