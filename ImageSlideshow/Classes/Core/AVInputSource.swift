//
//  AVInputSource.swift
//  ImageSlideshow
//
//  Created by Peter Meyers on 1/5/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import AVFoundation
import UIKit

public struct AVOptions {
    let autoplay: Bool
    public init(autoplay: Bool = false) {
        self.autoplay = autoplay
    }
}

public protocol AVInputSource: InputSource {
    var options: AVOptions { get }
    var player: AVPlayer { get }
    func resetPlayer()
}

/// Input Source to image using SDWebImage
@objcMembers
open class VideoSource: NSObject, AVInputSource {

    public let options: AVOptions
    public var player: AVPlayer
    private let videoUrl: URL
    private var thumbnail: UIImage?

    public init(videoUrl: URL, options: AVOptions = AVOptions()) {
        self.videoUrl = videoUrl
        self.options = options
        self.player = AVPlayer(url: videoUrl)
        super.init()
    }

    public func resetPlayer() {
        player = AVPlayer(url: videoUrl)
    }

    public func load(to imageView: UIImageView, with callback: @escaping (UIImage?) -> Void) {
        if let thumbnail = thumbnail {
            imageView.image = thumbnail
            callback(thumbnail)
        } else {
            DispatchQueue.global(qos: .background).async { [weak self] in
                guard let self = self else { return }
                let thumbnail = self.generateThumbnail()
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.thumbnail = thumbnail
                    imageView.image = thumbnail
                    callback(thumbnail)
                }
            }
        }
    }

    func generateThumbnail() -> UIImage? {
        guard let asset = player.currentItem?.asset else { return nil }
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        let time = CMTime(value: 0, timescale: 1)
        if let imageRef = try? generator.copyCGImage(at: time, actualTime: nil) {
            return UIImage(cgImage: imageRef)
        }
        return nil
    }
}

