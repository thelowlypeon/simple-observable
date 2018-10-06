//
//  ObservableProperty.swift
//  SimpleObservable
//
//  Created by Peter Compernolle on 9/30/18.
//  Copyright © 2018 Peter Compernolle. All rights reserved.
//

import Foundation

public class ObservableProperty<T> {
    public var value: T { didSet { sendNextValue() } }
    private var observers = [PropertyObserverIdentifier: Observer<T>]()

    public init(_ initialValue: T) {
        self.value = initialValue
    }

    private func sendNextValue() {
        for observer in observers.values {
            observer.send(value)
        }
    }
}

extension ObservableProperty {
    public func observe(_ onNext: PropertyChangedCallback<T>? = nil) -> Observer<T> {
        let observer = Observer<T>(initialValue: value)
        return register(observer: observer)
    }

    public func register(observer: Observer<T>) -> Observer<T> {
        observers[observer.identifier] = observer
        return observer
    }

    public func stopObserving(_ identifier: PropertyObserverIdentifier) {
        observers.removeValue(forKey: identifier)
    }

    public func removeAllObservers() {
        observers.removeAll()
    }
}

extension ObservableProperty where T: ExpressibleByNilLiteral {
    public convenience init() {
        self.init(nil)
    }
}
