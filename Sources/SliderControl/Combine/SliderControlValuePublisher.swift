//
// SliderControl.swift
// SliderControl
//
// Created by Alexander Chekel on 19.09.2023.
// Copyright © 2023 Alexander Chekel. All rights reserved.
//

import Combine
import UIKit

public class SliderControlValueSubscription<S: Subscriber>: Subscription where S.Input == Float {
    private let subscriber: S
    private weak var control: SliderControl?

    public init(subscriber: S, control: SliderControl) {
        self.subscriber = subscriber
        self.control = control

        self.control?.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
    }

    public func request(_ demand: Subscribers.Demand) {
        // Cannot request more .valueChanged events
    }

    public func cancel() {
        control?.removeTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        control = nil
    }

    @objc private func sliderValueChanged(sender: SliderControl) {
        _ = subscriber.receive(sender.value)
    }
}

public struct SliderControlValuePublisher: Publisher {
    public typealias Output = Float
    public typealias Failure = Never

    private weak var control: SliderControl?

    public init(control: SliderControl) {
        self.control = control
    }

    public func receive<S>(subscriber: S) where S : Subscriber, S.Failure == Never, S.Input == Float {
        guard let control else {
            subscriber.receive(completion: .finished)
            return
        }

        let subscription = SliderControlValueSubscription(subscriber: subscriber, control: control)
        subscriber.receive(subscription: subscription)
    }
}
