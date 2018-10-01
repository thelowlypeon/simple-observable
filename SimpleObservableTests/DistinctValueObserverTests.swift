//
//  DistinctValueObserverTests.swift
//  SimpleObservableTests
//
//  Created by Peter Compernolle on 10/1/18.
//  Copyright © 2018 Peter Compernolle. All rights reserved.
//

import XCTest
@testable import SimpleObservable

class DistinctValueObserverTests: XCTestCase {
    let initialValue = "initial value"
    let newValue = "new value"
    var property: ObservableProperty<String>!

    override func setUp() {
        property = ObservableProperty<String>(initialValue)
    }

    func testObserveDistinctValueReturnsDistinctValueObserver() {
        let observer = property.distinct()
        XCTAssert(observer is DistinctValueObserver)
    }

    func testObserveReturnsObserverWithInitialValue() {
        let observer = property.distinct()
        XCTAssertEqual(observer.currentValue, initialValue)
    }

    func testObserveReturnsRegisteredObserver() {
        let observer = property.distinct()
        property.value = newValue
        XCTAssertEqual(observer.currentValue, newValue)
    }

    func testDistinctObserverShouldNotSendEqualValues() {
        let observer = property.distinct()
        let shouldSend = observer.shouldSend(initialValue)
        XCTAssertFalse(shouldSend)
    }

    func testDistinctObserverShouldSendDistinctValues() {
        let observer = property.distinct()
        let shouldSend = observer.shouldSend(newValue)
        XCTAssert(shouldSend)
    }

    func testMultipleAssignmentsOfSameValueAreIgnored() {
        let observer = property.distinct()
        var initialValuePassed = false
        let exp = expectation(description: "new value was sent")
        let _ = observer.onNext({(value) in
            if value == self.initialValue {
                if initialValuePassed {
                    XCTFail("initial value was passed multiple times")
                }
                initialValuePassed = true
            } else if value == self.newValue {
                exp.fulfill()
            }
        })
        property.value = initialValue
        property.value = initialValue
        property.value = newValue
        waitForExpectations(timeout: 1)
    }
}
