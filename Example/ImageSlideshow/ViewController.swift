//
//  ViewController.swift
//  ImageSlideshow
//
//  Created by Petr Zvoníček on 30.07.15.
//  Copyright (c) 2015 Petr Zvonicek. All rights reserved.
//

import UIKit
import ImageSlideshow

class ViewController: UIViewController {

    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    @IBOutlet var slideshow: ImageSlideshow!

    let localSource = [BundleImageSource(imageString: "img1"), BundleImageSource(imageString: "img2"), BundleImageSource(imageString: "img3"), BundleImageSource(imageString: "img4")]
    let afNetworkingSource = [AFURLSource(urlString: "https://images.unsplash.com/photo-1432679963831-2dab49187847?w=1080")!, AFURLSource(urlString: "https://images.unsplash.com/photo-1447746249824-4be4e1b76d66?w=1080")!, AFURLSource(urlString: "https://images.unsplash.com/photo-1463595373836-6e0b0a8ee322?w=1080")!]
    let alamofireSource = [AlamofireSource(urlString: "https://images.unsplash.com/photo-1432679963831-2dab49187847?w=1080")!, AlamofireSource(urlString: "https://images.unsplash.com/photo-1447746249824-4be4e1b76d66?w=1080")!, AlamofireSource(urlString: "https://images.unsplash.com/photo-1463595373836-6e0b0a8ee322?w=1080")!]
    let sdWebImageSource = [SDWebImageSource(urlString: "https://images.unsplash.com/photo-1432679963831-2dab49187847?w=1080")!, SDWebImageSource(urlString: "https://images.unsplash.com/photo-1447746249824-4be4e1b76d66?w=1080")!, SDWebImageSource(urlString: "https://images.unsplash.com/photo-1463595373836-6e0b0a8ee322?w=1080")!]
    let kingfisherSource = [KingfisherSource(urlString: "https://images.unsplash.com/photo-1432679963831-2dab49187847?w=1080")!, KingfisherSource(urlString: "https://images.unsplash.com/photo-1447746249824-4be4e1b76d66?w=1080")!, KingfisherSource(urlString: "https://images.unsplash.com/photo-1463595373836-6e0b0a8ee322?w=1080")!]
    let videoSource: [InputSource] = [AVInputSource(
                                        url: URL(string: "https://d16kzk4negkp9h.cloudfront.net/be/1d/47/be1d471f4ea1eedfc811ddc23b217f28/transcoded-_data_user_0_com.nextdoor.android.rc_cache_16098478354299151659910170970293.mp4?Expires=1610008217&Signature=SBjW~YNqthisJgvi2oMvKc~JyFnxILmY4uNypUnzt-8JgDUlMEunAKxrI5Un4OeQ~viB8D0-CUlrlIW2ECwXOhUpjlM9BR9iNDZx9rRGs5uVpTNdoxV9gjjgK4~s24uMpx7VqVthEy5Cc58pajhLgxWplAv0rmY67yBAYm8yx9g_&Key-Pair-Id=APKAIXBZNN3ZZBIBSIDQ")!,
                                        autoplay: true)]


    // can be used with other sample sources as `afNetworkingSource`, `alamofireSource` or `sdWebImageSource` or `kingfisherSource`
    lazy var dataSource = AVSlideshowDataSource(inputs: videoSource + sdWebImageSource)

    override func viewDidLoad() {
        super.viewDidLoad()

        slideshow.slideshowInterval = 5.0
        slideshow.pageIndicatorPosition = .init(horizontal: .center, vertical: .under)
        slideshow.contentScaleMode = UIViewContentMode.scaleAspectFill

        slideshow.pageIndicator = UIPageControl.withSlideshowColors()

        // optional way to show activity indicator during image load (skipping the line will show no activity indicator)
        slideshow.activityIndicator = DefaultActivityIndicator()
        slideshow.delegate = self
        slideshow.dataSource = dataSource
        slideshow.reloadData()

        let recognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.didTap))
        slideshow.addGestureRecognizer(recognizer)
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(ViewController.didTap))
        doubleTap.numberOfTapsRequired = 2
        slideshow.addGestureRecognizer(doubleTap)
    }

    @objc func didTap() {
        let fullScreenController = slideshow.presentFullScreenController(from: self)
        // set the activity indicator for full screen controller (skipping the line will show no activity indicator)
        fullScreenController.slideshow.activityIndicator = DefaultActivityIndicator(style: .white, color: nil)
    }
}

extension ViewController: ImageSlideshowDelegate {
    func imageSlideshow(_ imageSlideshow: ImageSlideshow, didChangeCurrentPageTo page: Int) {
        print("current page:", page)
    }
}
