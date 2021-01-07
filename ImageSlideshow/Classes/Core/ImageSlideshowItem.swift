//
//  ZoomablePhotoView.swift
//  ImageSlideshow
//
//  Created by Petr Zvoníček on 30.07.15.
//

import UIKit

public protocol ZoomableSlideshowItem: SlideshowItemProtocol {
    var contentView: UIView { get }

    var maximumScale: CGFloat { get }

    var zoomEnabled: Bool { get }
}

extension ZoomableSlideshowItem where Self: UIScrollView {
    // MARK: - Image zoom & size

    func screenSize() -> CGSize {
        return CGSize(width: frame.width, height: frame.height)
    }

    func calculateMaximumScale() -> CGFloat {
        return maximumScale
    }

    func setContentViewToCenter() {
        var intendHorizon = (screenSize().width - contentView.frame.width ) / 2
        var intendVertical = (screenSize().height - contentView.frame.height ) / 2
        intendHorizon = intendHorizon > 0 ? intendHorizon : 0
        intendVertical = intendVertical > 0 ? intendVertical : 0
        contentInset = UIEdgeInsets(top: intendVertical, left: intendHorizon, bottom: intendVertical, right: intendHorizon)
    }

    func isFullScreen() -> Bool {
        return contentView.frame.width >= screenSize().width && contentView.frame.height >= screenSize().height
    }

    func clearContentInsets() {
        contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}



/// Used to wrap a single slideshow item and allow zooming on it
@objcMembers
open class ImageSlideshowItem: UIScrollView, SlideshowItemProtocol, ZoomableSlideshowItem {

    public var contentView: UIView {
        imageViewWrapper
    }

    private let imageView = UIImageView()

    /// Activity indicator shown during image loading, when nil there won't be shown any
    public let activityIndicator: ActivityIndicatorView?

    /// Input Source for the item
    public let image: InputSource

    /// Guesture recognizer to detect double tap to zoom
    open var gestureRecognizer: UITapGestureRecognizer?

    /// Holds if the zoom feature is enabled
    public let zoomEnabled: Bool

    /// Maximum zoom scale
    open var maximumScale: CGFloat = 2.0

    fileprivate var lastFrame = CGRect.zero
    fileprivate var imageReleased = false
    fileprivate var isLoading = false
    fileprivate(set) var singleTapGestureRecognizer: UITapGestureRecognizer?
    fileprivate var loadFailed = false {
        didSet {
            singleTapGestureRecognizer?.isEnabled = loadFailed
            gestureRecognizer?.isEnabled = !loadFailed
        }
    }

    /// Wraps around ImageView so RTL transformation on it doesn't interfere with UIScrollView zooming
    let imageViewWrapper = UIView()

    // MARK: - Life cycle

    /**
        Initializes a new ImageSlideshowItem
        - parameter image: Input Source to load the image
        - parameter zoomEnabled: holds if it should be possible to zoom-in the image
    */
    init(image: InputSource, zoomEnabled: Bool, activityIndicator: ActivityIndicatorView? = nil, maximumScale: CGFloat = 2.0, mediaContentMode: UIView.ContentMode) {
        self.zoomEnabled = zoomEnabled
        self.image = image
        self.activityIndicator = activityIndicator
        self.maximumScale = maximumScale
        self.imageView.contentMode = mediaContentMode

        super.init(frame: CGRect.null)

        imageViewWrapper.addSubview(imageView)
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.isAccessibilityElement = true
        imageView.accessibilityTraits = .image
        if #available(iOS 11.0, *) {
            imageView.accessibilityIgnoresInvertColors = true
        }

        imageViewWrapper.clipsToBounds = true
        imageViewWrapper.isUserInteractionEnabled = true
        if UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft {
            imageView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
        }

        setContentViewToCenter()

        // scroll view configuration
        delegate = self
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        addSubview(imageViewWrapper)
        minimumZoomScale = 1.0
        maximumZoomScale = calculateMaximumScale()

        if let activityIndicator = activityIndicator {
            addSubview(activityIndicator.view)
        }

        // tap gesture recognizer
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(ImageSlideshowItem.tapZoom))
        tapRecognizer.numberOfTapsRequired = 2
        imageViewWrapper.addGestureRecognizer(tapRecognizer)
        gestureRecognizer = tapRecognizer

        singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(retryLoadImage))
        singleTapGestureRecognizer!.numberOfTapsRequired = 1
        singleTapGestureRecognizer!.isEnabled = false
        imageViewWrapper.addGestureRecognizer(singleTapGestureRecognizer!)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func layoutSubviews() {
        super.layoutSubviews()

        if !zoomEnabled {
            imageViewWrapper.frame.size = frame.size
        } else if !isZoomed() {
            imageViewWrapper.frame.size = calculatePictureSize()
        }

        if isFullScreen() {
            clearContentInsets()
        } else {
            setContentViewToCenter()
        }

        self.activityIndicator?.view.center = imageViewWrapper.center

        // if self.frame was changed and zoomInInitially enabled, zoom in
        if lastFrame != frame && zoomInInitially {
            setZoomScale(maximumZoomScale, animated: false)
        }

        lastFrame = self.frame

        contentSize = imageViewWrapper.frame.size
        maximumZoomScale = calculateMaximumScale()
    }

    /// Request to load Image Source to Image View
    public func loadImage() {
        if self.imageView.image == nil && !isLoading {
            isLoading = true
            imageReleased = false
            activityIndicator?.show()
            image.load(to: self.imageView) {[weak self] image in
                // set image to nil if there was a release request during the image load
                if let imageRelease = self?.imageReleased, imageRelease {
                    self?.imageView.image = nil
                } else {
                    self?.imageView.image = image
                }
                self?.activityIndicator?.hide()
                self?.loadFailed = image == nil
                self?.isLoading = false

                self?.setNeedsLayout()
            }
        }
    }

    func releaseImage() {
        imageReleased = true
        cancelPendingLoad()
        self.imageView.image = nil
    }

    func cancelPendingLoad() {
        image.cancelLoad?(on: imageView)
    }

    func retryLoadImage() {
        self.loadImage()
    }

    // MARK: - ImageSlideshowItem

    open func transitionImageView() -> UIImageView {
        imageView
    }

    open var zoomInInitially = false

    open func isZoomed() -> Bool {
        return self.zoomScale != self.minimumZoomScale
    }

    open func zoomOut() {
        self.setZoomScale(minimumZoomScale, animated: false)
    }

    open var mediaContentMode: UIView.ContentMode {
        get { imageView.contentMode }
        set { imageView.contentMode = newValue }
    }

    open func didAppear(in slideshow: ImageSlideshow) {}

    open func didDisappear(in slideshow: ImageSlideshow) {
        zoomOut()
    }

    open func willStartZoomTransition(_ type: ZoomAnimatedTransitionType) {}

    open func didEndZoomTransition(_ type: ZoomAnimatedTransitionType) {}

    open func willBeRemoved(from slideshow: ImageSlideshow) {
        cancelPendingLoad()
    }

    open func loadMedia() {
        loadImage()
    }

    open func releaseMedia() {
        releaseImage()
    }

    fileprivate func calculatePictureSize() -> CGSize {
        if let image = imageView.image, imageView.contentMode == .scaleAspectFit {
            let picSize = image.size
            let picRatio = picSize.width / picSize.height
            let screenRatio = screenSize().width / screenSize().height

            if picRatio > screenRatio {
                return CGSize(width: screenSize().width, height: screenSize().width / picSize.width * picSize.height)
            } else {
                return CGSize(width: screenSize().height / picSize.height * picSize.width, height: screenSize().height)
            }
        } else {
            return CGSize(width: screenSize().width, height: screenSize().height)
        }
    }

    func tapZoom() {
        if isZoomed() {
            self.setZoomScale(minimumZoomScale, animated: true)
        } else {
            self.setZoomScale(maximumZoomScale, animated: true)
        }
    }

    // MARK: UIScrollViewDelegate

    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        setContentViewToCenter()
    }

    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return zoomEnabled ? contentView : nil
    }
}
