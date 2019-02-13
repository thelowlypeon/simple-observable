//
//  OnNextListenerTests.swift
//  SimpleObservableTests
//
//  Created by Peter Compernolle on 10/1/18.
//  Copyright © 2018 Peter Compernolle. All rights reserved.
//

import XCTest
@testable import SimpleObservable

class OnNextListenerTests: XCTestCase {
    let initialValue = "initial value"
    let newValue = "new value"
    var property: Property<String>!

    override func setUp() {
        property = Property<String>(initialValue)
    }

    func testCallbackIsCalledWithInitialValue() {
        let initialValueExpectation = expectation(description: "observer callback was called with initial value")
        let _ = property.on(next: {(value) in
            if value == self.initialValue {
                initialValueExpectation.fulfill()
            }
        })
        waitForExpectations(timeout: 1)
    }

    func testCallbackIsCalledWithNewValueWhenValueIsChanged() {
        let newValueExpectation = expectation(description: "observer callback was called with new value")
        let _ = property.on(next: {(value) in
            if value == self.newValue {
                newValueExpectation.fulfill()
            }
        })
        property.value = newValue
        waitForExpectations(timeout: 1)
    }

    func testObserverWithMultipleCallbacks() {
        let expectationCallback1 = expectation(description: "first callback was called")
        let _ = property.on(next: {(value) in
            expectationCallback1.fulfill()
        })
        let expectationCallback2 = expectation(description: "second callback was called")
        let _ = property.on(next: {(value) in
            expectationCallback2.fulfill()
        })
        waitForExpectations(timeout: 1)
    }
}
