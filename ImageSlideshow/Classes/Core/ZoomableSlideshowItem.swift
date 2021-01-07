//
//  ZoomableSlideshowItem.swift
//  ImageSlideshow
//
//  Created by Peter Meyers on 1/7/21.
//

import UIKit

/**
 A ZoomableSlideshowItem is a slideshow item that can be further
 zoomed in after transitioning to fullscreen.
 */
public protocol ZoomableSlideshowItem: SlideshowItemProtocol {
    var zoomInInitially: Bool { get }

    var maximumZoomScale: CGFloat { get }

    func isZoomed() -> Bool

    func zoomOut()
}

extension ZoomableSlideshowItem where Self: UIScrollView {
    public func isZoomed() -> Bool {
        return self.zoomScale != self.minimumZoomScale
    }

    public func zoomOut() {
        self.setZoomScale(minimumZoomScale, animated: false)
    }
}
