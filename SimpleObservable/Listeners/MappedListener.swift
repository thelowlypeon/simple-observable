//
//  MappedListener.swift
//  SimpleObservable
//
//  Created by Peter Compernolle on 2/13/19.
//  Copyright © 2019 Peter Compernolle. All rights reserved.
//

public typealias ValueMapper<ValueType, MappedValueType> = (ValueType) -> MappedValueType

public class MappedListener<ValueType, MappedValueType>: Listener<ValueType> {
    private let mapper: ValueMapper<ValueType, MappedValueType>
    public let mappedValue: Property<MappedValueType>

    internal init(_ observedProperty: Property<ValueType>, mapper: @escaping ValueMapper<ValueType, MappedValueType>) {
        self.mapper = mapper
        self.mappedValue = Property<MappedValueType>(self.mapper(observedProperty.value))
        super.init()
    }

    override public func stopObserving() {
        super.stopObserving()
        mappedValue.end()
    }

    override internal func valueChanged(_ newValue: ValueType) {
        self.mappedValue.value = self.mapper(newValue)
    }
}

extension Property {
    public func map<MappedValueType>(_ mapper: @escaping ValueMapper<ValueType, MappedValueType>) -> Property<MappedValueType> {
        let listener = MappedListener<ValueType, MappedValueType>(self, mapper: mapper)
        self.register(listener: listener)
        return listener.mappedValue
    }
}
