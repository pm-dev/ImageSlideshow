//
//  AVSlideshowItem.swift
//  ImageSlideshow
//
//  Created by Peter Meyers on 1/5/21.
//

import AVFoundation
import AVKit
import UIKit

public class AVSlideshowItem: ImageSlideshowItem {

    public override var imageViewContentMode: UIView.ContentMode {
        get { super.imageViewContentMode }
        set {
            super.imageViewContentMode = newValue
            switch newValue {
            case .scaleAspectFill: playerViewController.videoGravity = .resizeAspectFill
            case .scaleToFill: playerViewController.videoGravity = .resize
            default: playerViewController.videoGravity = .resizeAspect
            }
        }
    }

    var playerViewController: AVPlayerViewController
    private let source: AVInputSource
    private var didStartObservation: NSKeyValueObservation?
    private var isCurrentItem: Bool = false

    init(
        source: AVInputSource,
        zoomEnabled: Bool,
        activityIndicator: ActivityIndicatorView? = nil,
        maximumScale: CGFloat = 2.0) {
        self.source = source
        self.playerViewController = AVPlayerViewController()
        super.init(
            image: source,
            zoomEnabled: zoomEnabled,
            activityIndicator: activityIndicator,
            maximumScale: maximumScale)
        singleTapGestureRecognizer?.addTarget(self, action: #selector(didSingleTap))
        switch imageViewContentMode {
        case .scaleAspectFill: playerViewController.videoGravity = .resizeAspectFill
        case .scaleToFill: playerViewController.videoGravity = .resize
        default: playerViewController.videoGravity = .resizeAspect
        }
        playerViewController.showsPlaybackControls = true
        playerViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        playerViewController.view.frame = imageViewWrapper.bounds
        playerViewController.view.isAccessibilityElement = true
        playerViewController.view.accessibilityTraits = .startsMediaSession
        imageViewWrapper.addSubview(playerViewController.view)
        setPlayer()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func willEndCurrentItem(_ slideshow: ImageSlideshow) {
        super.willEndCurrentItem(slideshow)
        slideshow.unpauseTimer()
        isCurrentItem = false
        if let player = playerViewController.player {
            player.pause()
        }
    }

    override func willBecomeCurrentItem(_ slideshow: ImageSlideshow) {
        super.willBecomeCurrentItem(slideshow)
        slideshow.pauseTimer()
        isCurrentItem = true
        if source.options.autoplay, let player = playerViewController.player {
            player.play()
        }
    }

    @objc
    private func playerItemDidPlayToEndTime(notification: Notification) {
        source.resetPlayer()
        setPlayer()
    }

    private func setPlayer() {
        playerViewController.player = source.player
        didStartObservation = source.player.currentItem?.observe(\.status, options: []) { [weak self] item, _ in
            guard let self = self else { return }
            if self.source.player.timeControlStatus == .paused,
               item.status == .readyToPlay,
               self.isCurrentItem,
               self.source.options.autoplay {
                self.playerViewController.player?.play()
            }
        }
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerItemDidPlayToEndTime(notification:)),
            name: .AVPlayerItemDidPlayToEndTime,
            object: source.player.currentItem)
    }

    @objc
    private func didSingleTap() {
        // No-op. This prevents image slideshow from trying to reload a nil image, which
        // might be confusing with the tap-to-play functionality of the video player.
    }
}
