//
//  AVSlideshowItem.swift
//  ImageSlideshow
//
//  Created by Peter Meyers on 1/5/21.
//

import AVFoundation
import AVKit
import UIKit
#if SWIFT_PACKAGE
import ImageSlideshow
#endif

public class AVSlideshowItem: AVPlayerView, SlideshowItemProtocol {

    private let source: AVInputSource
    private var playerTimeControlStatusObservation: NSKeyValueObservation?
    private var activityIndicator: ActivityIndicatorView?
    private let pausedOverlayView: UIView?
    private let transitionView: UIImageView

    public init(
        source: AVInputSource,
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

    // MARK: - ImageSlideshowItem

    public var mediaContentMode: UIView.ContentMode {
        didSet {
            setPlayerViewVideoGravity()
        }
    }

    public func didEndFullscreenTransition(_ type: FullscreenTransitionType) {}

    public func willBeRemoved(from slideshow: ImageSlideshow) {}

    public func loadMedia() {
        _ = source.player
    }

    public func releaseMedia() {}

    public func transitionImageView() -> UIImageView {
        transitionView.frame = videoRect
        transitionView.contentMode = mediaContentMode
        transitionView.image = renderToImage(rect: transitionView.frame)
        return transitionView
    }

    public func willStartFullscreenTransition(_ type: FullscreenTransitionType) {
        source.player.pause()
    }

    public func didAppear(in slideshow: ImageSlideshow) {
        slideshow.pauseTimer()
        if source.autoplay {
            source.player.play()
        }
    }

    public func didDisappear(in slideshow: ImageSlideshow) {
        slideshow.unpauseTimer()
        source.player.pause()
    }
}

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

private extension UIView {
    func renderToImage(rect: CGRect) -> UIImage {
        UIGraphicsImageRenderer(bounds: rect).image { _ in
            drawHierarchy(in: bounds, afterScreenUpdates: true)
        }
    }

    func embed(_ view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        NSLayoutConstraint.activate([
            view.centerXAnchor.constraint(equalTo: centerXAnchor),
            view.centerYAnchor.constraint(equalTo: centerYAnchor),
            view.widthAnchor.constraint(equalTo: widthAnchor),
            view.heightAnchor.constraint(equalTo: heightAnchor)
        ])
    }
}
