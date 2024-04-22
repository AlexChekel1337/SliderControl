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

    private let providesHapticFeedback: Bool

    public init(value: Binding<Float>, providesHapticFeedback: Bool = true) {
        self._value = value
        self.providesHapticFeedback = providesHapticFeedback
    }

    public func makeUIView(context: Context) -> SliderControl {
        let coordinator = context.coordinator
        let control = SliderControl()
        control.providesHapticFeedback = providesHapticFeedback
        control.addTarget(coordinator, action: #selector(Coordinator.handleValueChange(control:)), for: .valueChanged)
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
    }
}
