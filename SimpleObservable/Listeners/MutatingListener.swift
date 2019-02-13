//
//  MutatingListener.swift
//  SimpleObservable
//
//  Created by Peter Compernolle on 2/13/19.
//  Copyright © 2019 Peter Compernolle. All rights reserved.
//

public class MutatingListener<ValueType>: Listener<ValueType> {
    public let property: Property<ValueType>

    internal init(initialValue: ValueType) {
        self.property = Property<ValueType>(initialValue)
        super.init()
    }

    internal func shouldUpdateMutatedProperty(_ newValue: ValueType) -> Bool {
        return true
    }

    override internal func valueChanged(_ newValue: ValueType) {
        if shouldUpdateMutatedProperty(newValue) {
            property.value = newValue
        }
    }

    override public func stopObserving() {
        super.stopObserving()
        property.end()
    }
}
