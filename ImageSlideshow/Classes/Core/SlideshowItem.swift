//
//  SlideshowItem.swift
//  ImageSlideshow
//
//  Created by Peter Meyers on 1/6/21.
//

import UIKit

public typealias SlideshowItem = SlideshowItemProtocol & UIScrollView

@objc
public protocol SlideshowItemProtocol: UIScrollViewDelegate {

    var mediaContentMode: UIView.ContentMode { get set }

    func transitionImageView() -> UIImageView

    var zoomInInitially: Bool { get }

    func isZoomed() -> Bool

    func zoomOut()

    func didAppear(in slideshow: ImageSlideshow)

    func didDisappear(in slideshow: ImageSlideshow)

    func willStartZoomTransition(_ type: ZoomAnimatedTransitionType)

    func didEndZoomTransition(_ type: ZoomAnimatedTransitionType)

    func willBeRemoved(from slideshow: ImageSlideshow)

    func loadMedia()

    func releaseMedia()
}
