import UIKit

/// Implements a slider control similar to one found in Apple Music on iOS 16.
public class SliderControl: UIControl {
    /// Indicates whether changes in the slider’s value generate continuous update events.
    public var isContinuous: Bool = true

    /// The slider's current value.
    public var value: Float {
        get {
            return Float(progressView.bounds.width / trackView.bounds.width)
        }
        set {
            let normalizedValue = max(0, min(1, newValue))
            let cgFloatValue = CGFloat(normalizedValue)
            progressConstraint = progressConstraint.constraintWithMultiplier(cgFloatValue)
        }
    }

    private let trackView: UIView = .init()
    private let progressView: UIView = .init()

    private var heightConstraint: NSLayoutConstraint = .init()
    private var progressConstraint: NSLayoutConstraint = .init()
    private var internalValue: Float = 0.5

    // MARK: Overrides

    public override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: 24)
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        trackView.layer.cornerRadius = trackView.bounds.height / 2
    }

    // MARK: Initialization & setup

    override public init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setup()
    }

    private func setup() {
        trackView.clipsToBounds = true
        trackView.backgroundColor = .quaternarySystemFill // .systemSecondaryFill
        trackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(trackView)

        progressView.clipsToBounds = true
        progressView.backgroundColor = .tertiarySystemFill // .systemFill // .tertiaryFill
        progressView.translatesAutoresizingMaskIntoConstraints = false
        trackView.addSubview(progressView)

        heightConstraint = trackView.heightAnchor.constraint(equalToConstant: 7)
        progressConstraint = progressView.widthAnchor.constraint(equalTo: trackView.widthAnchor, multiplier: 0.5)

        NSLayoutConstraint.activate([
            heightConstraint,
            trackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            trackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            trackView.trailingAnchor.constraint(equalTo: trailingAnchor),

            progressConstraint,
            progressView.topAnchor.constraint(equalTo: trackView.topAnchor),
            progressView.leadingAnchor.constraint(equalTo: trackView.leadingAnchor),
            progressView.bottomAnchor.constraint(equalTo: trackView.bottomAnchor)
        ])
    }

    // MARK: Event handling

    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        heightConstraint.constant = 12
        setNeedsLayout()

        UIView.animate(
            withDuration: 0.25,
            delay: 0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 0,
            options: [.curveEaseIn, .allowAnimatedContent, .allowUserInteraction]
        ) { [unowned self] in
            trackView.backgroundColor = .secondarySystemFill
            progressView.backgroundColor = .systemFill
            layoutIfNeeded()
        }
    }

    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)

        if let touch = touches.first {
            let previousLocation = touch.previousLocation(in: self)
            let location = touch.location(in: self)
            let translationX = location.x - previousLocation.x

            let newWidth = progressView.bounds.width + translationX
            let newProgress = max(0.0001, min(1, newWidth / trackView.bounds.width))
            progressConstraint = progressConstraint.constraintWithMultiplier(newProgress)

            if isContinuous {
                sendActions(for: .valueChanged)
            }
        }
    }

    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)

        heightConstraint.constant = 7
        setNeedsLayout()

        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 1,
            options: [.curveEaseOut, .allowAnimatedContent, .allowUserInteraction]
        ) { [unowned self] in
            trackView.backgroundColor = .quaternarySystemFill
            progressView.backgroundColor = .tertiarySystemFill
            layoutIfNeeded()
        }

        if !isContinuous {
            sendActions(for: .valueChanged)
        }
    }

    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
    }
}
