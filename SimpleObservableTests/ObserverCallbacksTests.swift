//
//  ObserverCallbacksTests.swift
//  SimpleObservableTests
//
//  Created by Peter Compernolle on 10/1/18.
//  Copyright © 2018 Peter Compernolle. All rights reserved.
//

import XCTest
@testable import SimpleObservable

class ObserverCallbacksTests: XCTestCase {
    let initialValue = "initial value"
    let newValue = "new value"
    var observableProperty: ObservableProperty<String>!
    var observer: Observer<String>!

    override func setUp() {
        observableProperty = ObservableProperty<String>(initialValue)
        observer = observableProperty.observe()
    }

    func testCallbackIsCalledWithInitialValue() {
        let initialValueExpectation = expectation(description: "observer callback was called with initial value")
        let _ = observer.onNext({(value) in
            if value == self.initialValue {
                initialValueExpectation.fulfill()
            }
        })
        observer.send(newValue)
        waitForExpectations(timeout: 1)
    }

    func testCallbackIsCalledWithNewValueWhenValueIsChanged() {
        let newValueExpectation = expectation(description: "observer callback was called with new value")
        let _ = observer.onNext({(value) in
            if value == self.newValue {
                newValueExpectation.fulfill()
            }
        })
        observer.send(newValue)
        waitForExpectations(timeout: 1)
    }

    func testObserverWithMultipleCallbacks() {
        let expectationCallback1 = expectation(description: "first callback was called")
        let expectationCallback2 = expectation(description: "second callback was called")
        let _ = observer.onNext({(value) in
            expectationCallback1.fulfill()
        }).onNext({(value) in
            expectationCallback2.fulfill()
        })
        waitForExpectations(timeout: 1)
    }
}
