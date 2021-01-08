//
//  AVSlideshowDataSource.swift
//  MediaSlideshow
//
//  Created by Peter Meyers on 1/7/21.
//

import Foundation
#if SWIFT_PACKAGE
import MediaSlideshow
#endif

open class ImageAndVideoSlideshowDataSource: NSObject, MediaSlideshowDataSource {
    public enum Source {
        case image(ImageSource)
        case av(AVSource)
    }

    open var sources: [Source]

    public init(sources: [Source]) {
        self.sources = sources
        super.init()
    }

    public func sourcesInMediaSlideshow(_ mediaSlideshow: MediaSlideshow) -> [MediaSource] {
        sources.map {
            switch $0 {
            case .av(let avSource): return avSource
            case .image(let imageSource): return imageSource
            }
        }
    }

    public func slideForSource(_ source: MediaSource, in mediaSlideshow: MediaSlideshow) -> MediaSlideshowSlideView {
        if let image = source as? ImageSource {
            let slide = MediaSlideshowImageSlide(
                image: image,
                zoomEnabled: mediaSlideshow.zoomEnabled,
                activityIndicator: mediaSlideshow.activityIndicator?.create(),
                maximumScale: mediaSlideshow.maximumScale)
            slide.imageView.contentMode = mediaSlideshow.contentScaleMode
            return slide
        }
        if let av = source as? AVSource {
            let image = UIImage(
                named: "video-play",
                in: Bundle(for: Self.self),
                compatibleWith: nil)
            let pausedOverlayView = UIImageView(image: image)
            pausedOverlayView.contentMode = .center
            return MediaSlideshowAVSlide(
                source: av,
                pausedOverlayView: pausedOverlayView,
                activityIndicator: mediaSlideshow.activityIndicator?.create(),
                mediaContentMode: mediaSlideshow.contentScaleMode)
        }
        fatalError("Unrecognized source")
    }
}
