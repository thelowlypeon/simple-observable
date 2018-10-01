//
//  Observer.swift
//  SimpleObservable
//
//  Created by Peter Compernolle on 9/30/18.
//  Copyright © 2018 Peter Compernolle. All rights reserved.
//

import Foundation

public typealias PropertyObserverIdentifier = UUID

public class Observer<T> {
    public let identifier = PropertyObserverIdentifier()

    private(set) var currentValue: T

    public init(initialValue: T) {
        self.currentValue = initialValue
    }

    public func send(_ value: T) {
        currentValue = value
    }
}
