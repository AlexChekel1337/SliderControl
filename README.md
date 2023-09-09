# SliderControl

SliderControl is a small Swift Package aiming to recreate volume and track sliders found in Apple Music on iOS 16 and later.

![Default configuration](./Media/default.gif)

## Usage

`SliderControl` maintains an API similar to built-in `UISlider`. It has the same properties, like `value` and `isContinuous`. Progress observation is done the same way, by adding a target and an action:

```swift
sliderControl.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
```

## Customization

There are a few properties to customize `SliderControl`'s appearance:
- `defaultTrackColor` sets a track color for default state;
- `defaultProgressColor` sets a progress color for default state;
- `enlargedTrackColor` sets a track color for state when user actively changing the progress;
- `enlargedProgressColor` sets a progress color for state when user actively changing the progress.

The default value of `enlargedTrackColor` and `enlargedProgressColor` is `nil`, so the slider won't change color upon interaction in its default configuration. However, by setting different colors, you can configure the slider to change its appearance when user interacts with it. Here's an example: 

![Different colors](./Media/colors.gif)

```swift
sliderControl.defaultTrackColor = .quaternarySystemFill
sliderControl.defaultProgressColor = .tertiarySystemFill
sliderControl.enlargedTrackColor = .secondarySystemFill
sliderControl.enlargedProgressColor = .systemFill
```