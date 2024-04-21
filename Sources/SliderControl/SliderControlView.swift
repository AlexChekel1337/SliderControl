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
        var parent: SliderControlView

        init(parent: SliderControlView) {
            self.parent = parent
        }

        @objc func handleValueChange(control: SliderControl) {
            parent.value = control.value
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
        Coordinator(parent: self)
    }

    public func updateUIView(_ uiView: SliderControl, context: Context) {
        if value != uiView.value {
            uiView.value = value
        }
    }
}
