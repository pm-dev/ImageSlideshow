//
//  SlideshowItem.swift
//  ImageSlideshow
//
//  Created by Peter Meyers on 1/6/21.
//

import UIKit

public typealias SlideshowItem = SlideshowItemProtocol & UIView

@objc
public protocol SlideshowItemProtocol {

    var mediaContentMode: UIView.ContentMode { get set }

    func transitionImageView() -> UIImageView

    func didAppear(in slideshow: ImageSlideshow)

    func didDisappear(in slideshow: ImageSlideshow)

    func willStartFullscreenTransition(_ type: FullscreenTransitionType)

    func didEndFullscreenTransition(_ type: FullscreenTransitionType)

    func willBeRemoved(from slideshow: ImageSlideshow)

    func loadMedia()

    func releaseMedia()
}
