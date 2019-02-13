//
//  FilteredValueListener.swift
//  SimpleObservable
//
//  Created by Peter Compernolle on 2/13/19.
//  Copyright © 2019 Peter Compernolle. All rights reserved.
//

public typealias ValueFilter<ValueType> = (ValueType) -> Bool

public class FilteredValueListener<ValueType>: MutatingListener<ValueType> {
    private let filter: ValueFilter<ValueType>

    internal init(filter: @escaping ValueFilter<ValueType>, initialValue: ValueType) {
        self.filter = filter
        super.init(initialValue: initialValue)
    }

    override internal func shouldUpdateMutatedProperty(_ newValue: ValueType) -> Bool {
        return filter(newValue)
    }
}

extension Property {
    public func filter(_ initialValue: ValueType, _ filter: @escaping ValueFilter<ValueType>) -> Property<ValueType> {
        let listener = FilteredValueListener<ValueType>(filter: filter, initialValue: initialValue)
        self.register(listener: listener)
        return listener.property
    }
}
