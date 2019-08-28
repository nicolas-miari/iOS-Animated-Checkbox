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
     The checkbox's border width in the **normal** state, in points. The default is `2`.
     */
    var normalBorderWidth: CGFloat = 2 {
        didSet {
            if !isHighlighted {
                frameLayer.lineWidth = normalBorderWidth
            }
        }
    }

    /**
     The checkbox's border width in the **highlighted** state, in points. The default is `4`.
     */
    var highlightedBorderWidth: CGFloat = 4 {
        didSet {
            if isHighlighted {
                frameLayer.lineWidth = highlightedBorderWidth
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

    private var recordingEnabled: Bool = false

    // Displayes the (optional) title.
    private let titleLabel: UILabel

    // Container, acts as parent layer of both the checkbox "border" and the "fill".
    private var boxLayer: CALayer!

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
        willSet {
            if !isSelected && recordingEnabled {
                if newValue == true {
                    // Highlighting un-selected control; begin recording:
                    ViewRecorder.beginSession(for: self.superview!)
                }
            }
        }

        didSet {
            if isHighlighted {
                if isSelected {
                    fillLayer.fillColor = adjustedTintColor.cgColor
                } else {
                    frameLayer.lineWidth = highlightedBorderWidth
                }
            } else {
                if isSelected {
                    fillLayer.fillColor = tintColor.cgColor
                } else {
                    frameLayer.lineWidth = normalBorderWidth
                }
            }
        }
    }

    override var isSelected: Bool {
        didSet {
            if isSelected {
                fillLayer.opacity = 1
                /*
                 Selecting: listen to animation did stop to end recording session
                 */
                let keyPath = "transform"
                let transformAnim = CABasicAnimation(keyPath: keyPath)
                transformAnim.fromValue = fillLayer.transform
                transformAnim.toValue = CATransform3DIdentity
                if recordingEnabled {
                    transformAnim.delegate = self
                }
                fillLayer.transform = CATransform3DIdentity

                fillLayer.add(transformAnim, forKey: keyPath)

                if overdrawFill {
                    frameLayer.strokeColor = tintColor.cgColor
                } else {
                    frameLayer.strokeColor = selectedBorderColor.cgColor
                }
            } else {
                fillLayer.transform = CATransform3DMakeScale(shrinkingFactor, shrinkingFactor, 1)

                fillLayer.opacity = 0
                frameLayer.strokeColor = normalBorderColor.cgColor
            }
            sendActions(for: .valueChanged)
        }
    }

    override init(frame: CGRect) {
        self.titleLabel = UILabel(frame: .zero)

        super.init(frame: frame)

        commonSetup()
    }

    required init?(coder aDecoder: NSCoder) {
        self.titleLabel = UILabel(frame: .zero)

        super.init(coder: aDecoder)

        commonSetup()
    }

    private func commonSetup() {
        self.clipsToBounds = false
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

    /**
     Updates the all component subviews and layers to match the current control attributes.

     The title label is preserved, and its properties are modified. The CoreAnimation layers
     that make up the checkbox proper are recreated from scratch. Finally, `updateComponentFrames()`
     is called to propery position the label and checkbox according to the currently specified
     layout.
     */
    private func configureComponents() {

        // [1] Title Label

        titleLabel.text = title
        titleLabel.font = font
        titleLabel.textColor = UIColor.darkGray
        titleLabel.sizeToFit()

        // [2] Checkbox Proper (CoreAnimation Sublayers)

        boxLayer?.removeFromSuperlayer()
        self.boxLayer = CALayer()
        layer.addSublayer(boxLayer)
        /*
         The containing box layer alone has its anchor point on the top-left corner, so it can
         play nicely with UIKit (i.e., the neighbouring label). Its sublayers have the default
         (0.5, 0.5) so the animation transform occurs around the center.
         */
        boxLayer.anchorPoint = .zero

        self.frameLayer = CAShapeLayer()
        frameLayer.strokeColor = isSelected ? selectedBorderColor.cgColor : normalBorderColor.cgColor
        frameLayer.lineWidth = isHighlighted ? highlightedBorderWidth : normalBorderWidth
        frameLayer.fillColor = nil
        frameLayer.bounds = CGRect(origin: .zero, size: boxSize)
        boxLayer.addSublayer(frameLayer)

        self.fillLayer = CAShapeLayer()
        fillLayer.strokeColor = nil
        fillLayer.fillColor = tintColor.cgColor
        fillLayer.opacity = isSelected ? 1 : 0
        fillLayer.bounds = CGRect(origin: .zero, size: boxSize)
        fillLayer.transform = isSelected ? CATransform3DMakeScale(1, 1, 1) : CATransform3DMakeScale(shrinkingFactor, shrinkingFactor, 1)

        if overdrawFill {
            boxLayer.addSublayer(fillLayer)
        } else {
            boxLayer.insertSublayer(fillLayer, at: 0)
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
        tickLayer.lineWidth = sideLength * (3.0 / 28.0)
        tickLayer.lineCap = .round
        tickLayer.lineJoin = .round

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
            let radius: CGFloat = (15.0/28.0) * sideLength
            frameLayer.path = UIBezierPath.superellipse(in: frameLayer.bounds, cornerRadius: radius).cgPath
            fillLayer.path = UIBezierPath.superellipse(in: frameLayer.bounds, cornerRadius: radius).cgPath
        }
    }

    private func updateComponentFrames() {

        titleLabel.sizeToFit()
        guard frameLayer != nil else {
            return
        }

        let size = intrinsicContentSize
        let labelBounds = titleLabel.bounds

        boxLayer.bounds = CGRect(origin: .zero, size: boxSize)
        fillLayer.bounds = CGRect(origin: .zero, size: boxSize)
        boxLayer.bounds = CGRect(origin: .zero, size: boxSize)

        let boxCenter = CGPoint(x: boxSize.width/2, y: boxSize.height/2)
        frameLayer.position = boxCenter
        fillLayer.position = boxCenter

        let yPosition = round((size.height - boxSize.height)/2)

        switch titlePosition {
        case .left:
            let labelOrigin = CGPoint(x: 0, y: round((size.height - labelBounds.height)/2))
            let labelFrame = CGRect(origin: labelOrigin, size: labelBounds.size)
            titleLabel.frame = labelFrame

            boxLayer.position = CGPoint(x: labelFrame.width + innerMargin, y: yPosition)

        case .right:
            boxLayer.position = CGPoint(x: 0, y: yPosition)

            let labelOrigin = CGPoint(x: boxSize.width + innerMargin, y: round((size.height - labelBounds.height)/2))
            let labelFrame = CGRect(origin: labelOrigin, size: labelBounds.size)
            titleLabel.frame = labelFrame
        }
    }
}

extension Checkbox: CAAnimationDelegate {

    func animationDidStart(_ anim: CAAnimation) {

    }

    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let frames = ViewRecorder.endSession(for: self.superview!)
            frames.exportSequence()

            print("Did End Recording (\(frames.count) frames)")
        }
    }
}

