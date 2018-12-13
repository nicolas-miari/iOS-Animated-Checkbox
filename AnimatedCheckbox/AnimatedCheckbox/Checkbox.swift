//
//  Checkbox.swift
//  AnimatedCheckbox
//
//  Created by Nicolás Miari on 2018/12/11.
//  Copyright © 2018 Nicolás Miari. All rights reserved.
//

import UIKit

/**
 A checkbox-like toggle switch control. The box can be styled in rounded,
 square, circle or superellipse (squircle) shape. Additionally, an optional
 title label can be displayed to the left or right of the checkbox.

 The control receives touches both within the bounds of checkbox itself as well
 as on those of the title label. Transitions between the checked (selected) and
 unchecked (deselcted) states are animated much like the standard checkboxes in
 macOS. The colors of various components, as well as the label layout and
 checkbox shape can be customized; see the exposed properties for further
 details.
 */
@IBDesignable class Checkbox: UIControl {

    // MARK: - Configuration (Interfce Builder)

    /*
     NOTE: Most inspectable properties are wrappers around stored properties but
     with a shorter name, more suited to the little space available to property
     name labels in Interface Builder's Attribute Inspector (to avoid truncation).
     */

    @IBInspectable var title: String = "" {
        didSet {
            titleLabel.text = title
            updateComponentFrames()
        }
    }

    @IBInspectable var size: CGFloat {
        set {
            self.sideLength = newValue
        }
        get {
            return sideLength
        }
    }

    @IBInspectable var textColor: UIColor = .darkGray {
        didSet {
            titleLabel.textColor = textColor
        }
    }

    @IBInspectable var offBorder: UIColor {
        set {
            normalBorderColor = newValue
        }
        get {
            return normalBorderColor
        }
    }

    @IBInspectable var onBorder: UIColor {
        set {
            self.selectedBorderColor = newValue
        }
        get {
            return selectedBorderColor
        }
    }

    @IBInspectable var autoOnBorder: Bool {
        set {
            self.useAutomaticSelectedBorderColor = newValue
        }
        get {
            return useAutomaticSelectedBorderColor
        }
    }

    @IBInspectable var overcheck: Bool {
        set {
            self.overdrawFill = newValue
        }
        get {
            return overdrawFill
        }
    }

    @IBInspectable var leftTitle: Bool {
        set {
            self.titlePosition = newValue ? .left : .right
        }
        get {
            return titlePosition == .left
        }
    }

    @IBInspectable var radio: Bool {
        set {
            self.style = newValue ? .circle : .square
        }
        get {
            return style == .circle
        }
    }

    @IBInspectable var ellipsoid: Bool {
        set {
            self.style = newValue ? .superellipse : .square
        }
        get {
            return style == .superellipse
        }
    }

    // MARK: - Configuration (Programmatic)

    /// Color of the checkbox's outline when unchecked.
    ///
    var normalBorderColor: UIColor = .lightGray {
        didSet {
            if !isSelected {
                frameLayer.strokeColor = normalBorderColor.cgColor
            }
        }
    }

    /**
     Color of the checkbox's outline when checked. Ignored if `overdrawFill` is
     true.
     */
    var selectedBorderColor: UIColor = .lightGray {
        didSet {
            if isSelected {
                if useAutomaticSelectedBorderColor {
                    return
                }
                frameLayer.strokeColor = selectedBorderColor.cgColor
            }
        }
    }

    /**
     Setting to `true` causes the `selectedBorderColor` to be set to the dimmed
     version of the selected **fill** color (i.e., `adjustedTintColor`).
     Setting to `false` causes the `selectedBorderColor` to be set to the same
     value as `normalBorderColor`.
    */
    var useAutomaticSelectedBorderColor: Bool = false {
        didSet {
            if useAutomaticSelectedBorderColor {
                selectedBorderColor = adjustedTintColor
            } else {
                selectedBorderColor = normalBorderColor
            }
        }
    }

    /// Font used in the title label.
    ///
    var font: UIFont = UIFont.systemFont(ofSize: 17) {
        didSet {
            titleLabel.font = font
            updateComponentFrames()
        }
    }

    enum Style {
        case square
        case circle
        case superellipse
    }

    /// Visual style (shape) of the box component.
    ///
    var style: Style = .square {
        didSet {
            updatePaths()
        }
    }

    /**
     Constants specifying the options for laying out the title label with
     respect to the checkbox component.
     */
    enum TitlePosition {
        /// Title label is positioned to the **left** of the checkbox.
        case left

        /// Title label is positioned to the **right** of the checkbox.
        case right
    }

    /**
     Layout of the title label with respect to the checkbox component. The
     default is `.left`.
     */
    var titlePosition: TitlePosition = .left {
        didSet {
            updateComponentFrames()
        }
    }

    /**
     If true, the checked state is drawn on top, obscuring the box outline. In
     this case, the property `selectedBorderColor` is seen only briefly, during
     the transition.
     */
    var overdrawFill: Bool = false {
        didSet {
            if overdrawFill {
                fillLayer.removeFromSuperlayer()
                self.layer.addSublayer(fillLayer)
            } else {
                fillLayer.removeFromSuperlayer()
                self.layer.insertSublayer(fillLayer, at: 0)
            }
        }
    }

    // MARK: - Internal Structure

    // Displayes the (optional) title.
    private let titleLabel: UILabel

    // Displayes the outline of the checkbox component in the UNCHECKED (unselected) state.
    private var frameLayer: CAShapeLayer!

    // Displays the fill color and checkmark of checkbox component in the CHECKED (selected) state.
    private var fillLayer: CAShapeLayer!

    // When checked, fill and checkmark fade in while growing from this scale
    // factor to full size (1.0).
    private let shrinkingFactor: CGFloat = 0.5

    // The side length of the checkbox (or diameter of the radio button), in points.
    private var sideLength: CGFloat = 28 {
        didSet {
            configureComponents()
        }
    }

    private var boxSize: CGSize {
        return CGSize(width: sideLength, height: sideLength)
    }

    // Margin set between the checkbox and the (nonempty) title label.
    private var innerMargin: CGFloat {
        guard !title.isEmpty else {
            return 0
        }
        return 8
    }

    // The corner radius of the checkbox. For radio button, it equals sideLength/2.
    private var cornerRadius: CGFloat = 6

    // The color of the filled (checked) backgrond, when highlighted (about to deselect).
    // TODO: Considered making a stored property, and update it only when tint changes.
    private var adjustedTintColor: UIColor! {
        return tintColor.darkened(byPercentage: 0.2)
    }

    // MARK: - UIView

    override var tintColor: UIColor! {
        didSet {
            if isHighlighted {
                fillLayer.fillColor = adjustedTintColor.cgColor
            } else {
                fillLayer.fillColor = tintColor.cgColor
            }
        }
    }

    override var intrinsicContentSize: CGSize {
        titleLabel.sizeToFit()
        let labelSize = titleLabel.intrinsicContentSize

        let width = labelSize.width + innerMargin + boxSize.width
        let height = max(labelSize.height, boxSize.height)

        return CGSize(width: width, height: height)
    }

    override var frame: CGRect {
        didSet {
            updateComponentFrames()
        }
    }

    // MARK: - UIControl

    override var isEnabled: Bool {
        didSet {
            if isEnabled {
                self.alpha = 1
            } else {
                self.alpha = 0.5
            }
        }
    }

    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                if isSelected {
                    fillLayer.fillColor = adjustedTintColor.cgColor
                } else {
                    frameLayer.lineWidth = 4
                }
            } else {
                if isSelected {
                    fillLayer.fillColor = tintColor.cgColor
                } else {
                    frameLayer.lineWidth = 2
                }
            }
        }
    }

    override var isSelected: Bool {
        didSet {
            if isSelected {
                fillLayer.opacity = 1
                fillLayer.transform = CATransform3DIdentity

                if overdrawFill {
                    frameLayer.strokeColor = tintColor.cgColor
                } else {
                    frameLayer.strokeColor = selectedBorderColor.cgColor
                }
            } else {
                fillLayer.opacity = 0
                fillLayer.transform = CATransform3DMakeScale(shrinkingFactor, shrinkingFactor, 1)

                frameLayer.strokeColor = normalBorderColor.cgColor
            }
            sendActions(for: .valueChanged)
        }
    }

    override init(frame: CGRect) {
        self.titleLabel = UILabel(frame: .zero)

        super.init(frame: frame)

        addSubview(titleLabel)
        configureComponents()
    }

    required init?(coder aDecoder: NSCoder) {
        self.titleLabel = UILabel(frame: .zero)

        super.init(coder: aDecoder)

        addSubview(titleLabel)
        configureComponents()
    }

    override func tintColorDidChange() {
        super.tintColorDidChange()

        // Update all color properties that depend on tint.
        // (adjustedTintColor is computed)
        fillLayer.fillColor = adjustedTintColor.cgColor
        if useAutomaticSelectedBorderColor {
            selectedBorderColor = adjustedTintColor
        }
        fillLayer.setNeedsDisplay()
    }

    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        self.isHighlighted = true
        return true
    }

    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        self.isHighlighted = isTouchInside
        return true
    }

    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        self.isHighlighted = false
        if isTouchInside {
            isSelected = !isSelected
        }
    }

    // MARK: - Support

    private func configureComponents() {
        // Remove existing sublayers (clean slate allows for calling the method
        // multiple times, e.g. when box size changes).
        frameLayer?.removeFromSuperlayer()
        fillLayer?.removeFromSuperlayer()

        self.clipsToBounds = false

        titleLabel.text = title
        titleLabel.font = font
        titleLabel.textColor = UIColor.darkGray
        titleLabel.sizeToFit()

        // Rounded gray frame (uncheked state)
        self.frameLayer = CAShapeLayer()
        frameLayer.bounds = CGRect(origin: .zero, size: boxSize)
        frameLayer.lineWidth = 2
        frameLayer.strokeColor = UIColor.lightGray.cgColor
        frameLayer.fillColor = UIColor.clear.cgColor
        self.layer.addSublayer(frameLayer)

        // Rounded blue square (checked state)
        self.fillLayer = CAShapeLayer()
        fillLayer.bounds = CGRect(origin: .zero, size: boxSize)
        fillLayer.strokeColor = UIColor.clear.cgColor
        fillLayer.fillColor = tintColor.cgColor
        fillLayer.opacity = 0
        fillLayer.transform = CATransform3DMakeScale(shrinkingFactor, shrinkingFactor, 1)

        if overdrawFill {
            self.layer.addSublayer(fillLayer)
        } else {
            self.layer.insertSublayer(fillLayer, at: 0)
        }

        // White Tick (checked state)
        let scalingFactor: CGFloat = sideLength / 40

        let tickPath = UIBezierPath()
        tickPath.move(to: CGPoint(x: 11 * scalingFactor, y: 21 * scalingFactor))
        tickPath.addLine(to: CGPoint(x: 17 * scalingFactor, y: 28 * scalingFactor))
        tickPath.addLine(to: CGPoint(x: 30 * scalingFactor, y: 12 * scalingFactor))

        let tickLayer = CAShapeLayer()
        tickLayer.path = tickPath.cgPath
        tickLayer.fillColor = nil
        tickLayer.strokeColor = UIColor.white.cgColor
        tickLayer.lineWidth = 3
        tickLayer.lineCap = .round
        tickLayer.lineJoin = .round
        /*
        tickLayer.shadowColor = UIColor.black.cgColor
        tickLayer.shadowOpacity = 0.25
        tickLayer.shadowOffset = CGSize(width: 0, height: 2)
        tickLayer.shadowRadius = 1
         */
        fillLayer.addSublayer(tickLayer)

        updateComponentFrames()
        updatePaths()
    }

    private func updatePaths() {
        switch style {
        case .square:
            frameLayer.path = CGPath(roundedRect: frameLayer.bounds, cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil)
            fillLayer.path = CGPath(roundedRect: fillLayer.bounds, cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil)
        case .circle:
            frameLayer.path = CGPath(ellipseIn: frameLayer.bounds, transform: nil)
            fillLayer.path = CGPath(ellipseIn: fillLayer.bounds, transform: nil)

        case .superellipse:
            frameLayer.path = UIBezierPath.superellipse(in: frameLayer.bounds, cornerRadius: 15).cgPath
            fillLayer.path = UIBezierPath.superellipse(in: frameLayer.bounds, cornerRadius: 15).cgPath
        }
    }

    private func updateComponentFrames() {

        titleLabel.sizeToFit()
        guard frameLayer != nil else {
            return
        }

        let size = intrinsicContentSize
        let labelBounds = titleLabel.bounds

        switch titlePosition {
        case .left:
            // Label: to the left, centered vertically
            let labelOrigin = CGPoint(x: 0, y: round((size.height - labelBounds.height)/2))
            let labelFrame = CGRect(origin: labelOrigin, size: labelBounds.size)
            titleLabel.frame = labelFrame

            let boxOrigin = CGPoint(
                x: labelFrame.width + innerMargin,
                y: round((size.height - boxSize.height)/2)
            )
            let boxFrame = CGRect(origin: boxOrigin, size: boxSize)

            frameLayer?.frame = boxFrame
            fillLayer?.frame = boxFrame
            fillLayer?.bounds = CGRect(origin: .zero, size: boxSize)

        case .right:
            let boxFrame = CGRect(origin: .zero, size: boxSize)
            frameLayer?.frame = boxFrame
            fillLayer?.frame = boxFrame

            fillLayer?.bounds = CGRect(origin: .zero, size: boxSize)

            let labelOrigin = CGPoint(x: boxSize.width + innerMargin, y: round((size.height - labelBounds.height)/2))
            let labelFrame = CGRect(origin: labelOrigin, size: labelBounds.size)
            titleLabel.frame = labelFrame
        }
    }
}
