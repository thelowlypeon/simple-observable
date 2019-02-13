//
//  OnNextListener.swift
//  SimpleObservable
//
//  Created by Peter Compernolle on 2/13/19.
//  Copyright © 2019 Peter Compernolle. All rights reserved.
//

public typealias NextValueHandler<ValueType> = (ValueType) -> Void

public class OnNextListener<ValueType>: Listener<ValueType> {
    private let nextValueHandler: NextValueHandler<ValueType>

    internal init(_ observedProperty: Property<ValueType>, onNext nextValueHandler: @escaping NextValueHandler<ValueType>, sendInitialValue: Bool) {
        self.nextValueHandler = nextValueHandler
        if sendInitialValue {
            self.nextValueHandler(observedProperty.value)
        }
        super.init()
    }

    override internal func valueChanged(_ newValue: ValueType) {
        nextValueHandler(newValue)
    }
}

extension Property {
    public func on(next onNextHandler: @escaping NextValueHandler<ValueType>, sendInitialValue: Bool? = nil) -> OnNextListener<ValueType> {
        let listener = OnNextListener(self, onNext: onNextHandler, sendInitialValue: sendInitialValue ?? true)
        self.register(listener: listener)
        return listener
    }
}
