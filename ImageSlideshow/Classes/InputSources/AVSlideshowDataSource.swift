//
//  AVSlideshowDataSource.swift
//  Pods
//
//  Created by Peter Meyers on 1/7/21.
//

import Foundation
#if SWIFT_PACKAGE
import ImageSlideshow
#endif

@objc
open class AVSlideshowDataSource: ImageSlideshowDataSource {
    public override func itemFor(_ input: InputSource, in slideshow: ImageSlideshow) -> SlideshowItem {
        if let avInput = input as? AVInputSource {
            let image = UIImage(named: "video-play", in: Bundle(for: AVSlideshowDataSource.self), compatibleWith: nil)
            let pausedOverlayView = UIImageView(image: image)
            pausedOverlayView.contentMode = .center
            return AVSlideshowItem(
                source: avInput,
                pausedOverlayView: pausedOverlayView,
                activityIndicator: slideshow.activityIndicator?.create(),
                mediaContentMode: slideshow.contentScaleMode)
        }
        return super.itemFor(input, in: slideshow)
    }
}
