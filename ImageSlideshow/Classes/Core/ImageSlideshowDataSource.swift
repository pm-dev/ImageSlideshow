//
//  ImageSlideshowDataSource.swift
//  ImageSlideshow
//
//  Created by Peter Meyers on 1/7/21.
//

import Foundation

@objc
open class ImageSlideshowDataSource: NSObject, SlideshowDataSource {

    open var inputs: [InputSource]

    public init(inputs: [InputSource] = []) {
        self.inputs = inputs
        super.init()
    }

    open func inputsIn(_ slideshow: ImageSlideshow) -> [InputSource] {
        inputs
    }

    public func itemFor(_ input: InputSource, in slideshow: ImageSlideshow) -> SlideshowItem {
        ImageSlideshowItem(
            image: input,
            zoomEnabled: slideshow.zoomEnabled,
            activityIndicator: slideshow.activityIndicator?.create(),
            maximumScale: slideshow.maximumScale,
            mediaContentMode: slideshow.contentScaleMode)
    }
}
