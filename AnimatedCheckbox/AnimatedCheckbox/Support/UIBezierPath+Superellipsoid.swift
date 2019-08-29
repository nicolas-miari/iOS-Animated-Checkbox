//
//  UIBezierPath+Superellipsoid.swift
//  AnimatedCheckbox
//
//  Created by Nicolás Miari on 2018/12/12.
//  Copyright © 2018 Nicolás Miari. All rights reserved.
//

import UIKit

extension UIBezierPath {

    /**
     Draws the super-elliptic analog of a rounded rect. Unlike the regular rounded rect, the rounded corners
     are the quadrants of a superellipse (i.e., parabolic segments), _not_ circular arcs.
     If `rect` is a square and `cornerRadius` is equal to half the length or more, and actual superellipse is
     drawn (no straight sections along its boundary) just like doing the same with a rounded rect results in a
     circle being drawn.

     - parameter rect: The rectangle in which to inscribe the superelliptic path.
     - parameter cornerRadius: How much of the extent of each edge (on each end) is replaced by the parabolic
     arcs. If it exceeds half of the length of the rectangle's shorter side, it is clamped to that amount.

     [Superellipse reference](https://en.wikipedia.org/wiki/Superellipse) (Wikipedia)
     */
    static func superellipse(in rect: CGRect, cornerRadius: CGFloat) -> UIBezierPath {
        /*
         Corner radius can't exceed half of the shorter side; correct if necessary:
         */
        let minSide = min(rect.width, rect.height)
        let radius = min(cornerRadius, minSide/2)

        let topLeft = CGPoint(x: rect.minX, y: rect.minY)
        let topRight = CGPoint(x: rect.maxX, y: rect.minY)
        let bottomLeft = CGPoint(x: rect.minX, y: rect.maxY)
        let bottomRight = CGPoint(x: rect.maxX, y: rect.maxY)

        // The two points of the segment along the top side (clockwise):
        let p0 = CGPoint(x: rect.minX + radius, y: rect.minY)
        let p1 = CGPoint(x: rect.maxX - radius, y: rect.minY)

        // The two points of the segment along the right side (clockwise):
        let p2 = CGPoint(x: rect.maxX, y: rect.minY + radius)
        let p3 = CGPoint(x: rect.maxX, y: rect.maxY - radius)

        // The two points of the segment along the bottom side (clockwise):
        let p4 = CGPoint(x: rect.maxX - radius, y: rect.maxY)
        let p5 = CGPoint(x: rect.minX + radius, y: rect.maxY)

        // The two points of the segment along the left side (clockwise):
        let p6 = CGPoint(x: rect.minX, y: rect.maxY - radius)
        let p7 = CGPoint(x: rect.minX, y: rect.minY + radius)

        let path = UIBezierPath()
        path.move(to: p0)
        path.addLine(to: p1)
        path.addCurve(to: p2, controlPoint1: topRight, controlPoint2: topRight)
        path.addLine(to: p3)
        path.addCurve(to: p4, controlPoint1: bottomRight, controlPoint2: bottomRight)
        path.addLine(to: p5)
        path.addCurve(to: p6, controlPoint1: bottomLeft, controlPoint2: bottomLeft)
        path.addLine(to: p7)
        path.addCurve(to: p0, controlPoint1: topLeft, controlPoint2: topLeft)

        return path
    }
}
