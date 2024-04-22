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

    public init(value: Binding<Float>) {
        _value = value
    }

    public func makeUIView(context: Context) -> SliderControl {
        let coordinator = context.coordinator
        let control = SliderControl()
        control.addTarget(coordinator, action: #selector(Coordinator.handleValueChange(control:)), for: .valueChanged)
        return control
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(value: $value)
    }

    public func updateUIView(_ uiView: SliderControl, context: Context) {
        if value != uiView.value {
            uiView.value = value
        }
    }
}
