//
//  UIImage+AnimatedGif.swift
//  AnimatedCheckbox
//
//  Created by Nicolás Miari on 2019/08/28.
//  Copyright © 2019 Nicolás Miari. All rights reserved.
//

import UIKit
import MobileCoreServices // for kUTTypeGIF

extension Array where Element == UIImage {

    /**
     Writes a looping animated gif to the documents folder, using the receiver's elements as the frames.

     - parameter fileName: The desired file name for the animated gif. File extension is appended if absent.
     - parameter framesPerSeconnd: The desired speed of the animation.
     */
    @discardableResult func exportSequence(fileName name: String = "animated.gif", framesPerSecond: Double = 30) -> Bool {
        let fileName: String = {
            let spaceEscaped = name.replacingOccurrences(of: " ", with: "_")
            let components = spaceEscaped.components(separatedBy: ".")
            if components.count > 1, components.last?.lowercased() == "gif" {
                return spaceEscaped
            }
            return spaceEscaped.appending(".gif")
        }()

        let fileProperties: CFDictionary = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFLoopCount as String: 0]]  as CFDictionary
        let frameProperties: CFDictionary = [kCGImagePropertyGIFDictionary as String: [(kCGImagePropertyGIFUnclampedDelayTime as String): 1.0/framesPerSecond]] as CFDictionary

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
        /*
         When running on Simulator, uncomment the print() below and set a breakpoint before returning so
         the URL is logged to the console and you can paste it into Finder's "Go to folder..." prompt,
         and grab the exported files.
         */
        //print("Url = \(fileURL.debugDescription)")

        return true
    }
}
