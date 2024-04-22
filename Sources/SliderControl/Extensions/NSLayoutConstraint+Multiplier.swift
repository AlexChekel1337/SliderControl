//
// NSLayoutConstraint+Multiplier.swift
// SliderControl
//
// Created by Alexander Chekel on 09.09.2023.
// Copyright © 2023 Alexander Chekel. All rights reserved.
//

import UIKit

extension NSLayoutConstraint {
    func constraintWithMultiplier(_ newMultiplier: CGFloat) -> NSLayoutConstraint {
        let shouldActivate = isActive
        if shouldActivate {
            NSLayoutConstraint.deactivate([self])
        }

        let updatedConstraint = NSLayoutConstraint(
            item: firstItem as Any,
            attribute: firstAttribute,
            relatedBy: relation,
            toItem: secondItem,
            attribute: secondAttribute,
            multiplier: newMultiplier,
            constant: constant
        )
        updatedConstraint.priority = priority
        updatedConstraint.shouldBeArchived = shouldBeArchived
        updatedConstraint.identifier = identifier

        if shouldActivate {
            NSLayoutConstraint.activate([updatedConstraint])
        }

        return updatedConstraint
    }
}
