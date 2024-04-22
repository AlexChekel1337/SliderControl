//
// ImpactSliderFeedbackGenerator.swift
// SliderControl
//
// Created by Alexander Chekel on 23.04.2024.
// Copyright © 2024 Alexander Chekel. All rights reserved.
//

import UIKit

/// Default implementation of `SliderFeedbackGenerator` that uses `UIImpactFeedbackGenerator`.
public class ImpactSliderFeedbackGenerator: SliderFeedbackGenerator {
    private let feedbackGenerator: UIImpactFeedbackGenerator = .init(style: .light)

    public init() {}

    public func preapre() {
        feedbackGenerator.prepare()
    }

    public func generateMinimumValueFeedback() {
        feedbackGenerator.impactOccurred(intensity: 0.75)
    }

    public func generateMaximumValueFeedback() {
        feedbackGenerator.impactOccurred(intensity: 1)
    }
}
