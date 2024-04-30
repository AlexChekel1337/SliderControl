//
// ClosedRangeExtensionsTests.swift
// SliderControl
//
// Created by Alexander Chekel on 30.04.2024.
// Copyright © 2024 Alexander Chekel. All rights reserved.
//

import Foundation
import XCTest
@testable import SliderControl

class ClosedRangeExtensionsTests: XCTestCase {
    func testPositiveDoubleValue() {
        let value: Double = 0.5
        let range: ClosedRange<Double> = 0...1
        let targetRange: ClosedRange<Double> = 100...1100
        let convertedValue = range.convert(value: value, to: targetRange)
        XCTAssertEqual(convertedValue, 600)
    }

    func testNegativeDoubleValue() {
        let value: Double = 0.5
        let range: ClosedRange<Double> = 0...1
        let targetRange: ClosedRange<Double> = -1100 ... -100
        let convertedValue = range.convert(value: value, to: targetRange)
        XCTAssertEqual(convertedValue, -600)
    }

    func testPositiveFloatValue() {
        let value: Float = 0.5
        let range: ClosedRange<Float> = 0...1
        let targetRange: ClosedRange<Float> = 100...1100
        let convertedValue = range.convert(value: value, to: targetRange)
        XCTAssertEqual(convertedValue, 600)
    }

    func testNegativeFloatValue() {
        let value: Float = 0.5
        let range: ClosedRange<Float> = 0...1
        let targetRange: ClosedRange<Float> = -1100 ... -100
        let convertedValue = range.convert(value: value, to: targetRange)
        XCTAssertEqual(convertedValue, -600)
    }
}
