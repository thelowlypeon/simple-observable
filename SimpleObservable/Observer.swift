//
//  Observer.swift
//  SimpleObservable
//
//  Created by Peter Compernolle on 9/30/18.
//  Copyright © 2018 Peter Compernolle. All rights reserved.
//

import Foundation

public typealias PropertyObserverIdentifier = UUID
public typealias PropertyChangedCallback<T> = ((T) -> Void)

public class Observer<T> {
    public let identifier = PropertyObserverIdentifier()

    private(set) var currentValue: T
    private var onNextCallbacks = [PropertyChangedCallback<T>]()

    public init(initialValue: T) {
        self.currentValue = initialValue
    }

    public func onNext(_ callback: @escaping PropertyChangedCallback<T>) -> Self {
        onNextCallbacks.append(callback)
        callback(currentValue)
        return self
    }

    internal func shouldSend(_ newValue: T) -> Bool {
        return true
    }

    internal func send(_ value: T) {
        if shouldSend(value) {
            for callback in onNextCallbacks {
                callback(value)
            }
        }
        currentValue = value
    }
}
