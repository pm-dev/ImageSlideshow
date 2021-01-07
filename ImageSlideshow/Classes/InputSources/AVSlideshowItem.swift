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

public class AVSlideshowItem: UIScrollView, SlideshowItemProtocol, ZoomableSlideshowItem {

    private let playerView: AVPlayerView
    private let source: AVInputSource
    private var playerTimeControlStatusObservation: NSKeyValueObservation?
    private var isCurrentItem: Bool = false
    private var activityIndicator: ActivityIndicatorView?
    private let pausedOverlayView: UIView?
    private weak var transitionView: UIImageView?

    public init(
        source: AVInputSource,
        pausedOverlayView: UIView? = nil,
        activityIndicator: ActivityIndicatorView? = nil,
        mediaContentMode: UIView.ContentMode,
        zoomEnabled: Bool,
        maximumScale: CGFloat = 2.0) {
        self.source = source
        self.playerView = AVPlayerView()
        self.mediaContentMode = mediaContentMode
        self.activityIndicator = activityIndicator
        self.pausedOverlayView = pausedOverlayView
        self.zoomEnabled = zoomEnabled
        self.maximumScale = maximumScale
        super.init(frame: .zero)
        maximumZoomScale = maximumScale
        delegate = self
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        minimumZoomScale = 1.0
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didSingleTap)))
        if zoomEnabled {
            let doubleTap = UITapGestureRecognizer(target: self, action: #selector(didDoubleTap))
            doubleTap.numberOfTapsRequired = 2
            addGestureRecognizer(doubleTap)
        }
        playerView.player = source.player
        setPlayerViewVideoGravity()

        playerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(playerView)
        if let pausedOverlayView = pausedOverlayView {
            playerView.embed(pausedOverlayView)
        }
        if let activityView = activityIndicator?.view {
            playerView.embed(activityView)
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

    override open func layoutSubviews() {
        super.layoutSubviews()

        if !zoomEnabled {
            playerView.frame.size = bounds.size
        } else if !isZoomed() {
            playerView.frame.size = playerView.videoRect.size
        }

        if isFullScreen() {
            clearContentInsets()
        } else {
            setContentViewToCenter()
        }

//        // if self.frame was changed and zoomInInitially enabled, zoom in
//        if lastFrame != frame && zoomInInitially {
//            setZoomScale(maximumZoomScale, animated: false)
//        }
//
//        lastFrame = self.frame

        contentSize = playerView.frame.size
        maximumZoomScale = calculateMaximumScale()
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
        case .scaleAspectFill: playerView.videoGravity = .resizeAspectFill
        case .scaleToFill: playerView.videoGravity = .resize
        default: playerView.videoGravity = .resizeAspect
        }
    }

    // MARK: - ImageSlideshowItem

    public var mediaContentMode: UIView.ContentMode {
        didSet {
            setPlayerViewVideoGravity()
        }
    }

    public func isZoomed() -> Bool {
        return self.zoomScale != self.minimumZoomScale
    }

    public func zoomOut() {
        self.setZoomScale(minimumZoomScale, animated: false)
    }

    public func didEndZoomTransition(_ type: ZoomAnimatedTransitionType) {}

    public func willBeRemoved(from slideshow: ImageSlideshow) {}

    public var zoomInInitially: Bool {
        false
    }

    public func loadMedia() {
        _ = source.player
    }

    public func releaseMedia() {}

    public func transitionImageView() -> UIImageView {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: playerView.videoRect.size))
        imageView.contentMode = mediaContentMode
        imageView.image = playerView.renderToImage(rect: playerView.videoRect)
        imageView.isHidden = true
        insertSubview(imageView, at: 0)
        transitionView?.removeFromSuperview()
        transitionView = imageView
        return imageView
    }

    public func willStartZoomTransition(_ type: ZoomAnimatedTransitionType) {
        source.player.pause()
    }

    public func didAppear(in slideshow: ImageSlideshow) {
        slideshow.pauseTimer()
        isCurrentItem = true
        if source.autoplay {
            source.player.play()
        }
    }

    public func didDisappear(in slideshow: ImageSlideshow) {
        slideshow.unpauseTimer()
        isCurrentItem = false
        source.player.pause()
    }

    // MARK: ZoomableSlideshowItem

    public var contentView: UIView {
        playerView
    }

    public var maximumScale: CGFloat

    public var zoomEnabled: Bool

    @objc
    func didDoubleTap() {
        if isZoomed() {
            self.setZoomScale(minimumZoomScale, animated: true)
        } else {
            self.setZoomScale(maximumZoomScale, animated: true)
        }
    }

    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        setContentViewToCenter()
    }

    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return zoomEnabled ? contentView : nil
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
