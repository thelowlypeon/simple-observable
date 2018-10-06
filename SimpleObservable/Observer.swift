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
    private weak var property: ObservableProperty<T>?
    private(set) var currentValue: T
    private var onNextCallbacks = [PropertyChangedCallback<T>]()
    private var filters = [PropertyChangedFilter<T>]()

    public init(_ property: ObservableProperty<T>, initialValue: T) {
        self.property = property
        self.currentValue = initialValue
    }

    public func onNext(_ callback: @escaping PropertyChangedCallback<T>) -> Self {
        onNextCallbacks.append(callback)
        if passesFilters(currentValue, firstPass: true) {
            callback(currentValue)
        }
        return self
    }

    internal func send(_ value: T) {
        if passesFilters(value) {
            for callback in onNextCallbacks {
                callback(value)
            }
        }
        currentValue = value
    }

    internal func passesFilters(_ newValue: T, firstPass: Bool = false) -> Bool {
        return filters.allSatisfy({(filter) in
            filter.perform(newValue, oldValue: self.currentValue, firstPass: firstPass)
        })
    }

    public func end() {
        property?.stopObserving(identifier)
    }

    deinit {
        print("de-initting \(identifier)")
        end()
    }
}

extension Observer {
    public func addFilter(_ filter: PropertyChangedFilter<T>) -> Self {
        self.filters.append(filter)
        return self
    }

    public func filter(withOldValue oldValueFilterClosure: @escaping PropertyChangedFromFilterClosure<T>) -> Self {
        return self.addFilter(PropertyChangedFilter(oldValueFilterClosure))
    }

    public func filter(_ filterClosure: @escaping PropertyChangedFilterClosure<T>) -> Self {
        return self.addFilter(PropertyChangedFilter(ignoringOldValue: filterClosure))
    }
}

extension Observer where T: Equatable {
    public func distinct() -> Observer<T> {
        return self.addFilter(
            PropertyChangedFilter({(newValue, oldValue) in
                return newValue != oldValue
            }, ignoreOnFirstPass: true)
        )
    }
}
