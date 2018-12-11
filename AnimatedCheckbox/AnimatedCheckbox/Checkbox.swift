//
//  Checkbox.swift
//  AnimatedCheckbox
//
//  Created by Nicolás Miari on 2018/12/11.
//  Copyright © 2018 Nicolás Miari. All rights reserved.
//

import UIKit

/**
 Custom Checkbox control.
 Visual style mimics the standard macOS checkboxes, but at a finger-friendly
 size of 40 x 40 points.
 */
@IBDesignable
class Checkbox: UIControl {

    // MARK: - Configuration

    @IBInspectable var title: String = "" {
        didSet {
            titleLabel.text = title
            updateComponentFrames()
        }
    }

    @IBInspectable var font: UIFont = UIFont.systemFont(ofSize: 17)

    // MARK: - Internal Structure

    private let titleLabel: UILabel

    private var frameLayer: CALayer!

    private var fillLayer: CALayer!

    private let shrinkingFactor: CGFloat = 0.5

    private var boxSize: CGSize = CGSize(width: 40, height: 40)

    private var adjustedTintColor: UIColor! {
        return tintColor.darkened(byPercentage: 0.2)
    }

    // MARK: - UIView

    override var tintColor: UIColor! {
        set {
        }
        get {
            // (Color-picked from macOS checkbox)
            return UIColor(displayP3Red: 86.0/255.0, green: 151.0/255.0, blue: 245.0/255.0, alpha: 1)
        }
    }

    override var intrinsicContentSize: CGSize {
        titleLabel.sizeToFit()
        let labelSize = titleLabel.intrinsicContentSize

        let width: CGFloat = {
            guard labelSize.width > 0 else {
                return boxSize.width
            }
            return labelSize.width + 8 + boxSize.width
        }()
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
                frameLayer.borderWidth = 4
                fillLayer.backgroundColor = adjustedTintColor.cgColor
            } else {
                frameLayer.borderWidth = 2
                self.tintAdjustmentMode = .normal
                fillLayer.backgroundColor = tintColor.cgColor
            }
        }
    }

    override var isSelected: Bool {
        didSet {
            if isSelected {
                fillLayer.opacity = 1
                fillLayer.transform = CATransform3DIdentity
            } else {
                fillLayer.opacity = 0
                fillLayer.transform = CATransform3DMakeScale(shrinkingFactor, shrinkingFactor, 1)
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

        titleLabel.text = title
        titleLabel.font = font
        titleLabel.textColor = UIColor.darkGray
        titleLabel.sizeToFit()

        // Rounded gray frame (uncheked state)
        self.frameLayer = CALayer()
        frameLayer.cornerRadius = 9
        frameLayer.borderWidth = 2
        frameLayer.borderColor = UIColor.lightGray.cgColor
        self.layer.addSublayer(frameLayer)

        // Rounded blue square (checked state)
        self.fillLayer = CALayer()
        fillLayer.backgroundColor = tintColor.cgColor
        fillLayer.cornerRadius = 9
        fillLayer.opacity = 0
        fillLayer.transform = CATransform3DMakeScale(shrinkingFactor, shrinkingFactor, 1)
        self.layer.addSublayer(fillLayer)

        // White Tick (checked state)
        let tickPath = UIBezierPath()
        tickPath.move(to: CGPoint(x: 11, y: 21))
        tickPath.addLine(to: CGPoint(x: 17, y: 28))
        tickPath.addLine(to: CGPoint(x: 30, y: 12))

        let tickLayer = CAShapeLayer()
        tickLayer.path = tickPath.cgPath
        tickLayer.fillColor = nil
        tickLayer.strokeColor = UIColor.white.cgColor
        tickLayer.lineWidth = 4
        tickLayer.lineCap = .round
        tickLayer.lineJoin = .round
        tickLayer.shadowColor = UIColor.black.cgColor
        tickLayer.shadowOpacity = 0.25
        tickLayer.shadowOffset = CGSize(width: 0, height: 2)
        tickLayer.shadowRadius = 1
        fillLayer.addSublayer(tickLayer)
    }

    private func updateComponentFrames() {
        let size = intrinsicContentSize

        // Label: to the left, centered vertically
        titleLabel.sizeToFit()
        let labelBounds = titleLabel.bounds
        let labelOrigin = CGPoint(x: 0, y: round((size.height - labelBounds.height)/2))
        let labelFrame = CGRect(origin: labelOrigin, size: labelBounds.size)
        titleLabel.frame = labelFrame

        let innerMargin: CGFloat = labelFrame.width > 0 ? 8 : 0

        let boxOrigin = CGPoint(
            x: labelFrame.width + innerMargin,
            y: round((size.height - boxSize.height)/2)
        )
        let boxFrame = CGRect(origin: boxOrigin, size: boxSize)

        frameLayer?.frame = boxFrame
        fillLayer?.frame = boxFrame
        fillLayer?.bounds = CGRect(origin: .zero, size: boxSize)
    }
}
