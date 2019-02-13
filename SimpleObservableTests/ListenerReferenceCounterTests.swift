//
//  ListenerReferenceCounterTests.swift
//  SimpleObservableTests
//
//  Created by Peter Compernolle on 10/1/18.
//  Copyright © 2018 Peter Compernolle. All rights reserved.
//

import XCTest
@testable import SimpleObservable

class Bla<ValueType>: Property<ValueType> {
    override func end() {
        super.end()
    }
}

//extension Property {
//    public func on(next onNextHandler: @escaping NextValueHandler<ValueType>, sendInitialValue: Bool? = nil) -> OnNextListener<ValueType> {
//        let listener = OnNextListener(self, onNext: onNextHandler, sendInitialValue: sendInitialValue ?? true)
//        self.register(listener: listener)
//        return listener
//    }
//}
//
//extension Property {
//    public func map<MappedValueType>(_ mapper: @escaping ValueMapper<ValueType, MappedValueType>) -> Property<MappedValueType> {
//        let listener = MappedListener<ValueType, MappedValueType>(self, mapper: mapper)
//        self.register(listener: listener)
//        return listener.mappedValue
//    }
//}

class ListenerReferenceCounterTests: XCTestCase {
    let initialValue = "initial value"
    let newValue = "new value"
    var property: Property<String>?
    var listener: Listener<String>?

    override func setUp() {
        property = Property<String>(initialValue)
        listener = Listener<String>()
    }

    func testNoReferenceIsHeldWhenListenerIsRemoved() {
        let exp = expectation(description: "listener is deinitialized")
        listener!.deinitClosure = { exp.fulfill() }
        let _ = property!.register(listener: listener!)
        property!.value = newValue
        property!.remove(listener: listener!)
        DispatchQueue.global(qos: .background).async {
            self.listener = nil
        }
        waitForExpectations(timeout: 1)
    }

    func testNoReferenceIsHeldWhenPropertyIsRemoved() {
        let exp = expectation(description: "listener is deinitialized")
        listener!.deinitClosure = { exp.fulfill() }
        let _ = property!.register(listener: listener!)
        property!.value = newValue
        property!.remove(listener: listener!)
        DispatchQueue.global(qos: .background).async {
            self.property = nil
            self.listener = nil
        }
        waitForExpectations(timeout: 1)
    }

}
