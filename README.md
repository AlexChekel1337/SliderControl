# SliderControl

![Platform badge] ![OS badge] ![SPM badge] ![Swift badge]

SliderControl is a small Swift Package aiming to recreate volume and track sliders found in Apple Music on iOS 16 and later.

![Default configuration](./Media/default.gif)

## Usage

To use `SliderControl` in **UIKit** projects, simply create it and add as a subview like any other view or control. It maintains an API similar to built-in `UISlider` with the same properties, like `value` and `isContinuous`, and allows you to track the progress by employing the target-action pattern:

```swift
sliderControl.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
```

Alternatively, you can subscribe to `valuePublisher` to receive value updates:

```swift
sliderCancellable = sliderControl.valuePublisher.sink { value in
    ...
}
```

To use the control in **SwiftUI** project, create its wrapper view called `SliderControlView`:

```swift
@State private var sliderValue: Float = 0.5

var body: some View {
    SliderControlView(value: $sliderValue)
}
```

## Customization
#### Track color

Slider's track color can be customized by changing the `defaultTrackColor` and the `enlargedTrackColor` properties. By default `enlargedTrackColor` property is set to `nil`, so the slider won't change the track color upon interaction. However, by setting different colors, you can configure the slider to change its track color when user interacts with it.

UIKit:
```swift
sliderControl.defaultTrackColor = .quaternarySystemFill
sliderControl.enlargedTrackColor = .secondarySystemFill
```

SwiftUI:
```swift
SliderControlView(value: $value)
    .trackColor(.gray)
    // or
    .trackColor(.gray, enlarged: .black)
```

#### Progress color
The same customization can also be applied to progress color by changing the `defaultProgressColor` and the `enlargedProgressColor` properties. And again, `enlargedProgressColor` property behaves in the same way as `enlargedTrackColor` and is `nil` by default.

UIKit:
```swift
sliderControl.defaultProgressColor = .tertiarySystemFill
sliderControl.enlargedProgressColor = .systemFill
```

SwiftUI:
```swift
SliderControlView(value: $value)
    .progressColor(.blue)
    // or
    .progressColor(.blue, enlarged: .purple)
```

These customizations allow you to create different appearances for different states of the slider. Here's an example:  
![Different colors](./Media/colors.gif)

#### Haptic feedback

By default `SliderControl` and its SwiftUI wrapper `SliderControlView` provide haptic feedback when slider reaches its minimum or maximum values. This behavior can be changed by setting a custom feedback generator, or setting it to `nil` to disable it completely. To make your own feedback generator, create a class that conforms to `SliderFeedbackGenerator` protocol. Here's an example of custom feedback generator:  
```swift
class MyFeedbackGenerator: SliderFeedbackGenerator {
    private let feedbackGenerator: UINotificationFeedbackGenerator = .init()

    func preapre() {
        feedbackGenerator.prepare()
    }

    func generateMinimumValueFeedback() {
        feedbackGenerator.notificationOccurred(.warning)
    }

    func generateMaximumValueFeedback() {
        feedbackGenerator.notificationOccurred(.success)
    }
}
```

UIKit:
```swift
sliderControl.feedbackGenerator = MyFeedbackGenerator()
// or, to disable the haptic feedback
sliderControl.feedbackGenerator = nil
```

SwiftUI:
```swift
SliderControlView(value: $value)
    .feedbackGenerator(MyFeedbackGenerator())
    // or, to disable the haptic feedback
    .feedbackGenerator(nil)
```

This control provides its own implementation of feedback generator, so if you want to reset this behavior, use `ImpactFeedbackGenerator()` with `feedbackGenerator` property and SwiftUI modifier.

## RTL Support

`SliderControl` and its SwiftUI wrapper `SliderControlView` support right-to-left languages.

![RTL Example](./Media/rtl.gif)

[Platform badge]: https://img.shields.io/badge/Platform-iOS-green
[OS badge]: https://img.shields.io/badge/iOS-13.0+-green
[SPM badge]: https://img.shields.io/badge/SPM-Compatible-green
[Swift badge]: https://img.shields.io/badge/Swift-5.8-orange
