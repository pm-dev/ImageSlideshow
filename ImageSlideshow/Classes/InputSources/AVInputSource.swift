//
//  AVInputSource.swift
//  ImageSlideshow
//
//  Created by Peter Meyers on 1/5/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import AVFoundation
import UIKit
#if SWIFT_PACKAGE
import ImageSlideshow
#endif

@objcMembers
open class AVInputSource: NSObject, InputSource {

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

    public func load(to imageView: UIImageView, with callback: @escaping (UIImage?) -> Void) {
        imageView.image = nil
        callback(nil)
    }
}

