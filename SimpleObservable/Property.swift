//
//  Property.swift
//  SimpleObservable
//
//  Created by Peter Compernolle on 2/12/19.
//  Copyright © 2019 Peter Compernolle. All rights reserved.
//

public class Property<ValueType> {

    public var value: ValueType { didSet { self.notify() } }

    private var listeners = Set<Listener<ValueType>>()

    public init(_ initialValue: ValueType) {
        self.value = initialValue
    }

    private func notify() {
        for listener in listeners {
            if listener.isObserving {
                listener.valueChanged(value)
            }
        }
    }

    public func end() {
        removeAllListeners()
    }

    // an optional closure run when the property is deinitialized.
    // this is primarily for testing, to ensure we're keeping references
    // in line with swift's ARC.
    internal var deinitClosure: (() -> Void)?

    deinit {
        end()
        deinitClosure?()
    }
}

extension Property {
    public func register(listener: Listener<ValueType>) {
        self.listeners.insert(listener)
    }

    public func remove(listener: Listener<ValueType>) {
        listener.stopObserving()
        self.listeners.remove(listener)
    }

    public func removeAllListeners() {
        for listener in listeners {
            self.remove(listener: listener)
        }
    }
}

extension Property where ValueType: ExpressibleByNilLiteral {
    public convenience init() {
        self.init(nil)
    }
}
