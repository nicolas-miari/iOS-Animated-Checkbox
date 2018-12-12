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
     Based on: https://stackoverflow.com/a/49426030/433373.
     */
    static func superellipsoid(in rect: CGRect) -> UIBezierPath {

        let rectSize: CGFloat = rect.width
        let rectangle = CGRect(x: rect.midX - rectSize / 2, y: rect.midY - rectSize / 2, width: rectSize, height: rectSize)

        let topLPoint = CGPoint(x: rectangle.minX, y: rectangle.minY)
        let topRPoint = CGPoint(x: rectangle.maxX, y: rectangle.minY)
        let botLPoint = CGPoint(x: rectangle.minX, y: rectangle.maxY)
        let botRPoint = CGPoint(x: rectangle.maxX, y: rectangle.maxY)

        let midRPoint = CGPoint(x: rectangle.maxX, y: rectangle.midY)
        let botMPoint = CGPoint(x: rectangle.midX, y: rectangle.maxY)
        let topMPoint = CGPoint(x: rectangle.midX, y: rectangle.minY)
        let midLPoint = CGPoint(x: rectangle.minX, y: rectangle.midY)

        let bezierCurvePath = UIBezierPath()
        bezierCurvePath.move(to: midLPoint)
        bezierCurvePath.addCurve(to: topMPoint, controlPoint1: topLPoint, controlPoint2: topLPoint)
        bezierCurvePath.addCurve(to: midRPoint, controlPoint1: topRPoint, controlPoint2: topRPoint)
        bezierCurvePath.addCurve(to: botMPoint, controlPoint1: botRPoint, controlPoint2: botRPoint)
        bezierCurvePath.addCurve(to: midLPoint, controlPoint1: botLPoint, controlPoint2: botLPoint)

        return bezierCurvePath
    }
}
