//
// SliderControlView.swift
// SliderControl
//
// Created by Alexander Chekel on 21.04.2024.
// Copyright © 2024 Alexander Chekel. All rights reserved.
//

import SwiftUI

public struct SliderControlView: UIViewRepresentable {
    public typealias UIViewType = SliderControl

    public class Coordinator: NSObject {
        @Binding private var value: Float

        init(value: Binding<Float>) {
            _value = value
        }

        @objc func handleValueChange(control: SliderControl) {
            value = control.value
        }
    }

    @Binding var value: Float

    var isContinuous: Bool
    var feedbackGenerator: (any SliderFeedbackGenerator)?
    var defaultTrackColor: UIColor
    var defaultProgressColor: UIColor
    var enlargedTrackColor: UIColor?
    var enlargedProgressColor: UIColor?
    var onEditingChanged: ((Bool) -> Void)?
    var valueRange: ClosedRange<Float>

    /// Creates a slider similar to the track slider found in Apple Music on iOS 16.
    /// - parameters:
    ///     - value: Selected slider value binding.
    ///     - onEditingChanged: A callback for when editing begins or ends.
    public init(
        value: Binding<Float>,
        in valueRange: ClosedRange<Float> = 0...1,
        onEditingChanged: ((Bool) -> Void)? = nil
    ) {
        self._value = value
        self.isContinuous = true
        self.feedbackGenerator = ImpactSliderFeedbackGenerator()
        self.defaultTrackColor = .secondarySystemFill
        self.defaultProgressColor = .systemFill
        self.enlargedTrackColor = nil
        self.enlargedProgressColor = nil
        self.onEditingChanged = onEditingChanged
        self.valueRange = valueRange
    }

    public func makeUIView(context: Context) -> SliderControl {
        let coordinator = context.coordinator
        let control = SliderControl()
        control.isContinuous = isContinuous
        control.feedbackGenerator = feedbackGenerator
        control.defaultTrackColor = defaultTrackColor
        control.defaultProgressColor = defaultProgressColor
        control.enlargedTrackColor = enlargedTrackColor
        control.enlargedProgressColor = enlargedProgressColor
        control.onEditingChanged = onEditingChanged
        control.valueRange = valueRange
        control.addTarget(coordinator, action: #selector(Coordinator.handleValueChange(control:)), for: .valueChanged)
        control.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return control
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(value: $value)
    }

    public func updateUIView(_ uiView: SliderControl, context: Context) {
        if value != uiView.value {
            // When the UIView updates the binding, SwiftUI calls the
            // updateUIView(_:context:) method again, which may cause
            // a CPU usage spike, or, as in case of this view,
            // a drawing issue.
            uiView.value = value
        }

        uiView.isContinuous = isContinuous
        uiView.feedbackGenerator = feedbackGenerator
        uiView.defaultTrackColor = defaultTrackColor
        uiView.defaultProgressColor = defaultProgressColor
        uiView.enlargedTrackColor = enlargedTrackColor
        uiView.enlargedProgressColor = enlargedProgressColor
    }
}

public extension SliderControlView {
    /// Sets track colors.
    /// - parameters:
    ///     - defaultTrackColorName: A name of asset color for the track.
    ///     - enlargedTrackColorName: A name of asset color for the track in interaction state.
    @available(iOS, deprecated: 14, message: "Use .trackColor(_:enlargedTrackColor:) modifier instead.")
    func trackColor(
        named defaultTrackColorName: String,
        enlargedTrackColorNamed enlargedTrackColorName: String? = nil
    ) -> SliderControlView {
        var view = self
        if let defaultTrackColor = UIColor(named: defaultTrackColorName) {
            view.defaultTrackColor = defaultTrackColor
        }
        view.enlargedTrackColor = enlargedTrackColorName.flatMap(UIColor.init(named:))
        return view
    }

    /// Sets track colors.
    /// - parameters:
    ///     - defaultTrackColor: A color for the track.
    ///     - enlargedTrackColor: A color for the track in interaction state.
    @available(iOS 14, *)
    func trackColor(_ defaultTrackColor: Color, enlarged enlargedTrackColor: Color? = nil) -> SliderControlView {
        var view = self
        view.defaultTrackColor = UIColor(defaultTrackColor)
        view.enlargedTrackColor = enlargedTrackColor.map(UIColor.init)
        return view
    }

    /// Sets progress fill colors.
    /// - parameters:
    ///     - defaultProgressColorName: A name of asset color for the progress fill.
    ///     - enlargedProgressColorName: A name of asset color for the progress fill in interaction state.
    @available(iOS, deprecated: 14, message: "Use .progressColor(_:enlargedProgressColor:) modifier instead.")
    func progressColor(
        named defaultProgressColorName: String,
        enlargedProgressColorNamed enlargedProgressColorName: String? = nil
    ) -> SliderControlView {
        var view = self
        if let defaultProgressColor = UIColor(named: defaultProgressColorName) {
            view.defaultProgressColor = defaultProgressColor
        }
        view.enlargedProgressColor = enlargedProgressColorName.flatMap(UIColor.init(named:))
        return view
    }

    /// Sets progress fill colors.
    /// - parameters:
    ///     - defaultProgressColor: A color for the progress fill.
    ///     - enlargedProgressColor: A color for the progress fill in interaction state.
    @available(iOS 14, *)
    func progressColor(_ defaultProgressColor: Color, enlarged enlargedProgressColor: Color? = nil) -> SliderControlView {
        var view = self
        view.defaultProgressColor = UIColor(defaultProgressColor)
        view.enlargedProgressColor = enlargedProgressColor.map(UIColor.init)
        return view
    }

    /// Specifies whether slider should continuously update the value binding.
    /// If set to `true`, the slider will update the value binding as user drags across.
    /// If set to `false`, the value binding will be updated when user lets go of the slider.
    func continuouslyUpdatesValue(_ isContinuous: Bool) -> SliderControlView {
        var view = self
        view.isContinuous = isContinuous
        return view
    }

    /// Sets slider's feedback generator. Pass `nil` to disable haptic feedback.
    func feedbackGenerator(_ generator: (any SliderFeedbackGenerator)?) -> SliderControlView {
        var view = self
        view.feedbackGenerator = generator
        return view
    }
}
