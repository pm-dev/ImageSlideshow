//
//  AVPlayerView.swift
//  MediaSlideshow
//
//  Created by Peter Meyers on 1/7/21.
//

import AVFoundation
import Foundation

extension UIView {
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
