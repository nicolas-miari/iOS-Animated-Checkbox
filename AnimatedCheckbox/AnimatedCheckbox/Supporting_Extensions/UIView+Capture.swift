//
//  UIView+Capture.swift
//  AnimatedCheckbox
//
//  Created by Nicolás Miari on 2019/08/28.
//  Copyright © 2019 Nicolás Miari. All rights reserved.
//

import UIKit

extension UIView {

    func render() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.isOpaque, 0.0)
        defer {
            UIGraphicsEndImageContext()
        }
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        self.layer.presentation()?.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        return image
    }
}
