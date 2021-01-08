//
//  AVSlideshowItem.swift
//  ImageSlideshow
//
//  Created by Peter Meyers on 1/5/21.
//

import AVFoundation
import AVKit
#if SWIFT_PACKAGE
import MediaSlideshow
#endif

public class MediaSlideshowAVSlide: AVPlayerView, MediaSlideshowSlide {
    private let source: AVSource
    private var playerTimeControlStatusObservation: NSKeyValueObservation?
    private let activityIndicator: ActivityIndicatorView?
    private let pausedOverlayView: UIView?
    private let transitionView: UIImageView

    public init(
        source: AVSource,
        pausedOverlayView: UIView? = nil,
        activityIndicator: ActivityIndicatorView? = nil,
        mediaContentMode: UIView.ContentMode) {
        self.source = source
        self.mediaContentMode = mediaContentMode
        self.activityIndicator = activityIndicator
        self.pausedOverlayView = pausedOverlayView
        self.transitionView = UIImageView()
        super.init(frame: .zero)
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didSingleTap)))
        player = source.player
        setPlayerViewVideoGravity()
        // Stays hidden, but needs to be apart of the view heirarchy due to how the zoom animation works.
        transitionView.isHidden = true
        embed(transitionView)
        if let pausedOverlayView = pausedOverlayView {
            embed(pausedOverlayView)
        }
        if let activityView = activityIndicator?.view {
            embed(activityView)
        }
        playerTimeControlStatusObservation = source.player.observe(\.timeControlStatus) { [weak self] player, _ in
            guard let self = self else { return }
            switch player.timeControlStatus {
            case .waitingToPlayAtSpecifiedRate:
                self.activityIndicator?.show()
                self.pausedOverlayView?.isHidden = true
            case .playing:
                self.activityIndicator?.hide()
                self.pausedOverlayView?.isHidden = true
            case .paused:
                self.activityIndicator?.hide()
                self.pausedOverlayView?.isHidden = false
            @unknown default: break
            }
        }
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerItemDidPlayToEndTime(notification:)),
            name: .AVPlayerItemDidPlayToEndTime,
            object: source.item)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc
    private func playerItemDidPlayToEndTime(notification: Notification) {
        source.player.seek(to: .zero)        
    }

    @objc
    private func didSingleTap() {
        switch source.player.timeControlStatus {
        case .paused: source.player.play()
        case .playing: source.player.pause()
        case .waitingToPlayAtSpecifiedRate: break
        @unknown default: break
        }
    }
    
    private func setPlayerViewVideoGravity() {
        switch mediaContentMode {
        case .scaleAspectFill: videoGravity = .resizeAspectFill
        case .scaleToFill: videoGravity = .resize
        default: videoGravity = .resizeAspect
        }
    }

    // MARK: - MediaSlideshowSlide

    public var mediaContentMode: UIView.ContentMode {
        didSet {
            setPlayerViewVideoGravity()
        }
    }

    public func willBeRemoved(from slideshow: MediaSlideshow) {}

    public func loadMedia() {
        _ = source.player
    }

    public func releaseMedia() {}

    public func transitionImageView() -> UIImageView {
        transitionView.frame = videoRect
        transitionView.contentMode = mediaContentMode
        let generator = AVAssetImageGenerator(asset: source.asset)
        generator.appliesPreferredTrackTransform = true
        if let imageRef = try? generator.copyCGImage(at: source.player.currentTime(), actualTime: nil) {
            transitionView.image = UIImage(cgImage: imageRef)
        }
        return transitionView
    }

    public func willStartFullscreenTransition(_ type: FullscreenTransitionType) {
        source.player.pause()
    }

    public func didAppear(in slideshow: MediaSlideshow) {
        slideshow.pauseTimer()
        if source.autoplay {
            source.player.play()
        }
    }

    public func didDisappear(in slideshow: MediaSlideshow) {
        slideshow.unpauseTimer()
        source.player.pause()
    }
}
