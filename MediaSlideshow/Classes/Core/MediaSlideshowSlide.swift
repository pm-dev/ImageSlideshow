//
//  MediaSlideshowSlide.swift
//  MediaSlideshow
//
//  Created by Peter Meyers on 1/7/21.
//

import UIKit

public typealias MediaSlideshowSlideView = MediaSlideshowSlide & UIView

@objc
public protocol MediaSlideshowSlide {

    var mediaContentMode: UIView.ContentMode { get set }

    func transitionImageView() -> UIImageView

    func willBeRemoved(from slideshow: MediaSlideshow)

    func loadMedia()

    func releaseMedia()

    func didAppear(in slideshow: MediaSlideshow)

    func didDisappear(in slideshow: MediaSlideshow)

    func willStartFullscreenTransition(_ type: FullscreenTransitionType)
}
