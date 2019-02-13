//
//  RegisteringListenersTests.swift
//  SimpleObservableTests
//
//  Created by Peter Compernolle on 9/30/18.
//  Copyright © 2018 Peter Compernolle. All rights reserved.
//

import XCTest
@testable import SimpleObservable

class TestableListener<ValueType: Equatable>: Listener<ValueType> {
    var valueChangedExpectation: XCTestExpectation?
    var expectedValue: ValueType?

    override func valueChanged(_ newValue: ValueType) {
        if expectedValue! == newValue {
            valueChangedExpectation?.fulfill()
        }
    }
}

class RegisteringListenersTests: XCTestCase {
    let initialValue = "initial value"
    let newValue = "new value"
    lazy var property: Property<String> = {
        return Property<String>(initialValue)
    }()

    func register(with expectation: XCTestExpectation) -> TestableListener<String> {
        let listener = TestableListener<String>()
        listener.valueChangedExpectation = expectation
        listener.expectedValue = newValue
        property.register(listener: listener)
        return listener
    }

    func testRegisteringMultipleListeners() {
        _ = register(with: expectation(description: "first listener received value"))
        _ = register(with: expectation(description: "first listener received value"))
        property.value = newValue
        waitForExpectations(timeout: 1)
    }

    func testUnregisteringListener() {
        let exp = expectation(description: "received value")
        exp.isInverted = true
        let listener = register(with: exp)
        property.remove(listener: listener)
        property.value = newValue
        waitForExpectations(timeout: 1)
    }

    func testUnregisteringAllListeners() {
        let exp = expectation(description: "received value")
        exp.isInverted = true
        _ = register(with: exp)
        property.removeAllListeners()
        property.value = newValue
        waitForExpectations(timeout: 1)
    }

    func testPropertyDoesntNotifyListenerThatHasStoppedObserving() {
        let exp = expectation(description: "received value")
        exp.isInverted = true
        let listener = register(with: exp)
        listener.stopObserving()
        property.value = newValue
        waitForExpectations(timeout: 1)
    }
}
