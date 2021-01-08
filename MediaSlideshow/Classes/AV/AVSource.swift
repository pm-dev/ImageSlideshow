//
//  AVSource.swift
//  MediaSlideshow
//
//  Created by Peter Meyers on 1/5/21.
//

import AVFoundation
import Foundation
#if SWIFT_PACKAGE
import MediaSlideshow
#endif

@objcMembers
open class AVSource: NSObject, MediaSource {

    public let autoplay: Bool
    public let asset: AVAsset
    public private(set) lazy var item = AVPlayerItem(asset: asset)
    public private(set) lazy var player = AVPlayer(playerItem: item)

    public init(asset: AVAsset, autoplay: Bool) {
        self.asset = asset
        self.autoplay = autoplay
        super.init()
    }

    public convenience init(url: URL, autoplay: Bool) {
        self.init(asset: AVAsset(url: url), autoplay: autoplay)
    }
}

