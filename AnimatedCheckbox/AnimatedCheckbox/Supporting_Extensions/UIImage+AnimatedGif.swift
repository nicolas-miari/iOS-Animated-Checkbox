//
//  UIImage+AnimatedGif.swift
//  AnimatedCheckbox
//
//  Created by Nicolás Miari on 2019/08/28.
//  Copyright © 2019 Nicolás Miari. All rights reserved.
//

import UIKit
import MobileCoreServices

extension Array where Element == UIImage {

    @discardableResult func exportSequence(fileName: String = "animated.gif") -> Bool {

        let fileProperties: CFDictionary = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFLoopCount as String: 0]]  as CFDictionary
        let frameProperties: CFDictionary = [kCGImagePropertyGIFDictionary as String: [(kCGImagePropertyGIFUnclampedDelayTime as String): 1.0/30.0]] as CFDictionary

        let documentsDirectoryURL: URL? = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let fileURL: URL? = documentsDirectoryURL?.appendingPathComponent(fileName)

        guard let url = fileURL as CFURL? else {
            return false
        }
        guard let destination = CGImageDestinationCreateWithURL(url, kUTTypeGIF, self.count, nil) else {
            return false
        }

        CGImageDestinationSetProperties(destination, fileProperties)
        for image in self {
            if let cgImage = image.cgImage {
                CGImageDestinationAddImage(destination, cgImage, frameProperties)
            }
        }
        if !CGImageDestinationFinalize(destination) {
            print("Failed to finalize the image destination")
        }
        print("Url = \(fileURL.debugDescription)")

        return true
    }
}
