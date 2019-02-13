//
//  DistinctValueListener.swift
//  SimpleObservable
//
//  Created by Peter Compernolle on 2/13/19.
//  Copyright © 2019 Peter Compernolle. All rights reserved.
//

public class DistinctValueListener<ValueType: Equatable>: MutatingListener<ValueType> {
    internal init(_ observedProperty: Property<ValueType>) {
        super.init(initialValue: observedProperty.value)
    }

    override internal func shouldUpdateMutatedProperty(_ newValue: ValueType) -> Bool {
        return newValue != property.value
    }
}

extension Property where ValueType: Equatable {
    public func distinct() -> Property<ValueType> {
        let listener = DistinctValueListener<ValueType>(self)
        self.register(listener: listener)
        return listener.property
    }
}
