//
// SliderControl.swift
// SliderControl
//
// Created by Alexander Chekel on 09.09.2023.
// Copyright © 2023 Alexander Chekel. All rights reserved.
//

import UIKit

/// Implements a slider control similar to one found in Apple Music on iOS 16.
open class SliderControl: UIControl {
    /// Indicates whether changes in the slider's value generate continuous update events.
    /// Default value of this property is `true`.
    public var isContinuous: Bool = true
    /// A layout guide that follows track size changes in different states.
    public let trackLayoutGuide: UILayoutGuide = .init()
    /// Indicates whether slider should provide haptic feedback upon reaching minimum or maximum values.
    /// Default value of this property is `true`.
    open var providesHapticFeedback: Bool = true
    /// Feedback generator used to provide haptic feedback when slider reaches minimum or maximum value.
    /// Default value of this property is `UIImpactFeedbackGenerator(style: .light)`.
    open private(set) var feedbackGenerator: UIFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)

    /// A color set to track when user is not interacting with the slider.
    /// Default value of this property is `secondarySystemFill`.
    open var defaultTrackColor: UIColor = .secondarySystemFill {
        didSet {
            updateColors()
        }
    }
    /// A color set to progress when user is not interacting with the slider.
    /// Default value of this property is `.systemFill`.
    open var defaultProgressColor: UIColor = .systemFill {
        didSet {
            updateColors()
        }
    }
    /// A color set to track when user is interacting with the slider.
    /// Assigning `nil` to this property disables color changes in interactive state.
    /// Default value of this property is `nil`.
    open var enlargedTrackColor: UIColor? {
        didSet {
            updateColors()
        }
    }
    /// A color set to progress when user is interacting with the slider.
    /// Assigning `nil` to this property disables color changes in interactive state.
    /// Default value of this property is `nil`.
    open var enlargedProgressColor: UIColor? {
        didSet {
            updateColors()
        }
    }

    /// The slider's current value. Ranges between `0.0` and `1.0`.
    public var value: Float {
        get {
            return Float(progressView.bounds.width / trackView.bounds.width)
        }
        set {
            let normalizedValue = max(0.0001, min(1, newValue))
            let cgFloatValue = CGFloat(normalizedValue)
            progressConstraint = progressConstraint.constraintWithMultiplier(cgFloatValue)
        }
    }

    public override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: Self.intrinsicHeight)
    }

    private static let intrinsicHeight: CGFloat = 24
    private static let defaultTrackHeight: CGFloat = 7
    private static let enlargedTrackHeight: CGFloat = 12

    private let trackView: UIView = .init()
    private let progressView: UIView = .init()

    private var heightConstraint: NSLayoutConstraint = .init()
    private var progressConstraint: NSLayoutConstraint = .init()
    private var hasPreviousSessionChangedProgress: Bool = false

    override public init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)

        setup()
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        trackView.layer.cornerRadius = trackView.bounds.height / 2
    }

    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        enlargeTrack()
    }

    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)

        if let touch = touches.first {
            let previousLocation = touch.previousLocation(in: self)
            let location = touch.location(in: self)
            let translationX = location.x - previousLocation.x
            let newWidth = effectiveUserInterfaceLayoutDirection == .leftToRight
                ? progressView.bounds.width + translationX
                : progressView.bounds.width - translationX

            let progress = progressView.bounds.width / trackView.bounds.width
            let newProgress = max(0, min(1, newWidth / trackView.bounds.width))

            if newProgress != progress {
                switch newProgress {
                    case 0:
                        provideHapticFeedbackForMinimumValue()
                    case 1:
                        provideHapticFeedbackForMaximumValue()
                    default:
                        break
                }
            }

            let normalizedConstraintMultiplier = max(0.0001, min(1, newProgress))
            progressConstraint = progressConstraint.constraintWithMultiplier(normalizedConstraintMultiplier)

            hasPreviousSessionChangedProgress = true
            if isContinuous {
                sendActions(for: .valueChanged)
            }
        }
    }

    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)

        reduceTrack()

        if hasPreviousSessionChangedProgress {
            hasPreviousSessionChangedProgress = false
            sendActions(for: .valueChanged)
        }
    }

    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)

        reduceTrack()

        if hasPreviousSessionChangedProgress {
            hasPreviousSessionChangedProgress = false
            sendActions(for: .valueChanged)
        }
    }

    private func setup() {
        isMultipleTouchEnabled = false
        backgroundColor = .clear

        trackView.clipsToBounds = true
        trackView.backgroundColor = defaultTrackColor
        trackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(trackView)

        addLayoutGuide(trackLayoutGuide)

        progressView.clipsToBounds = true
        progressView.backgroundColor = defaultProgressColor
        progressView.translatesAutoresizingMaskIntoConstraints = false
        trackView.addSubview(progressView)

        heightConstraint = trackView.heightAnchor.constraint(equalToConstant: Self.defaultTrackHeight)
        progressConstraint = progressView.widthAnchor.constraint(equalTo: trackView.widthAnchor, multiplier: 0.5)

        NSLayoutConstraint.activate([
            heightConstraint,
            trackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            trackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            trackView.trailingAnchor.constraint(equalTo: trailingAnchor),

            trackLayoutGuide.topAnchor.constraint(equalTo: trackView.topAnchor),
            trackLayoutGuide.leadingAnchor.constraint(equalTo: trackView.leadingAnchor),
            trackView.bottomAnchor.constraint(equalTo: trackLayoutGuide.bottomAnchor),
            trackView.trailingAnchor.constraint(equalTo: trackLayoutGuide.trailingAnchor),

            progressConstraint,
            progressView.topAnchor.constraint(equalTo: trackView.topAnchor),
            progressView.leadingAnchor.constraint(equalTo: trackView.leadingAnchor),
            progressView.bottomAnchor.constraint(equalTo: trackView.bottomAnchor)
        ])
    }

    /// The control calls this method upon reaching minimum value. Override this
    /// implementation to customize haptic feedback. Your implementation should
    /// not call `super.provideHapticFeedbackForMinimumValue()` at any point.
    /// You should not call this method directly.
    open func provideHapticFeedbackForMinimumValue() {
        guard providesHapticFeedback else { return }

        (feedbackGenerator as? UIImpactFeedbackGenerator)?.impactOccurred(intensity: 0.75)
    }

    /// The control calls this method upon reaching maximum value. Override this
    /// implementation to customize haptic feedback. Your implementation should
    /// not call `super.provideHapticFeedbackForMaximumValue()` at any point.
    /// You should not call this method directly.
    open func provideHapticFeedbackForMaximumValue() {
        guard providesHapticFeedback else { return }

        (feedbackGenerator as? UIImpactFeedbackGenerator)?.impactOccurred(intensity: 1)
    }

    private func enlargeTrack() {
        heightConstraint.constant = Self.enlargedTrackHeight
        setNeedsLayout()

        UIView.animate(
            withDuration: 0.25,
            delay: 0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 0,
            options: [.curveEaseIn, .allowAnimatedContent, .allowUserInteraction]
        ) { [unowned self] in
            enlargedTrackColor.map { trackView.backgroundColor = $0 }
            enlargedProgressColor.map { progressView.backgroundColor = $0 }

            layoutIfNeeded()
        }
    }

    private func reduceTrack() {
        heightConstraint.constant = 7
        setNeedsLayout()

        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 1,
            options: [.curveEaseOut, .allowAnimatedContent, .allowUserInteraction]
        ) { [unowned self] in
            trackView.backgroundColor = defaultTrackColor
            progressView.backgroundColor = defaultProgressColor

            layoutIfNeeded()
        }
    }

    private func updateColors() {
        if heightConstraint.constant == Self.defaultTrackHeight {
            trackView.backgroundColor = defaultTrackColor
            progressView.backgroundColor = defaultProgressColor
        } else {
            enlargedTrackColor.map { trackView.backgroundColor = $0 }
            enlargedProgressColor.map { progressView.backgroundColor = $0 }
        }
    }
}
