//
// SliderControl.swift
// SliderControl
//
// Created by Alexander Chekel on 09.09.2023.
// Copyright © 2023 Alexander Chekel. All rights reserved.
//

import Combine
import UIKit

/// Implements a slider control similar to one found in Apple Music on iOS 16.
open class SliderControl: UIControl {
    /// Indicates whether changes in the slider's value generate continuous update events.
    /// Default value of this property is `true`.
    public var isContinuous: Bool = true
    /// A layout guide that follows track size changes in different states.
    public let trackLayoutGuide: UILayoutGuide = .init()
    /// Feedback generator used to provide haptic feedback when slider reaches minimum or maximum value.
    /// Set this property to `nil` to disable haptic feedback. Default value of this property is
    /// `ImpactFeedbackGenerator`.
    public var feedbackGenerator: (any SliderFeedbackGenerator)? = ImpactSliderFeedbackGenerator()
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

    /// Range of slider values. Default value is `0...1`.
    public var valueRange: ClosedRange<Float> = 0...1

    /// The slider's current value in range set by `valueRange` property.
    public var value: Float {
        get {
            let progress = Float(progressView.bounds.width / trackView.bounds.width)
            return Self.internalValueRange.convert(value: progress, to: valueRange)
        }
        set {
            guard !isTracking else { return }

            let clampedValue = max(valueRange.lowerBound, min(valueRange.upperBound, newValue))
            let convertedValue = valueRange.convert(value: clampedValue, to: Self.internalValueRange)
            progressConstraint = progressConstraint.constraintWithMultiplier(CGFloat(convertedValue))
        }
    }

    /// Callback for editing changed event. It is called with `true` parameter
    /// when user starts dragging the slider, and then it is called again with
    /// `false` parameter when users lets go of the slider.
    public var onEditingChanged: ((Bool) -> Void)?

    /// A publisher that emits progress updates when user interacts with the slider.
    /// A Combine alternative to adding action for `UIControl.Event.valueChanged`.
    public var valuePublisher: AnyPublisher<Float, Never> {
        valueSubject.eraseToAnyPublisher()
    }

    public override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: Self.intrinsicHeight)
    }

    private static let intrinsicHeight: CGFloat = 24
    private static let defaultTrackHeight: CGFloat = 7
    private static let enlargedTrackHeight: CGFloat = 12
    private static let internalValueRange: ClosedRange<Float> = 0...1

    private let trackView: UIView = .init()
    private let progressView: UIView = .init()

    private let valueSubject: PassthroughSubject<Float, Never> = .init()

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

    public override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        onEditingChanged?(true)
        enlargeTrack()
        feedbackGenerator?.preapre()

        return true
    }

    public override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
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
                    feedbackGenerator?.generateMinimumValueFeedback()
                case 1:
                    feedbackGenerator?.generateMaximumValueFeedback()
                default:
                    break
            }
        }

        progressConstraint = progressConstraint.constraintWithMultiplier(newProgress)

        hasPreviousSessionChangedProgress = true
        if isContinuous {
            sendActions(for: .valueChanged)
        }

        return true
    }

    public override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        reduceTrack()

        if hasPreviousSessionChangedProgress {
            hasPreviousSessionChangedProgress = false
            sendActions(for: .valueChanged)
        }

        onEditingChanged?(false)
    }

    public override func cancelTracking(with event: UIEvent?) {
        reduceTrack()

        if hasPreviousSessionChangedProgress {
            hasPreviousSessionChangedProgress = false
            sendActions(for: .valueChanged)
        }

        onEditingChanged?(false)
    }

    private func setup() {
        isMultipleTouchEnabled = false
        backgroundColor = .clear

        trackView.isUserInteractionEnabled = false
        trackView.clipsToBounds = true
        trackView.backgroundColor = defaultTrackColor
        trackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(trackView)

        addLayoutGuide(trackLayoutGuide)

        progressView.isUserInteractionEnabled = false
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

        addTarget(self, action: #selector(broadcastValueChange), for: .valueChanged)
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
        heightConstraint.constant = Self.defaultTrackHeight
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

    @objc private func broadcastValueChange() {
        valueSubject.send(value)
    }
}
