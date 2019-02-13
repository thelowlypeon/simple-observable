//
//  DistinctValueListenerTests.swift
//  SimpleObservableTests
//
//  Created by Peter Compernolle on 10/1/18.
//  Copyright © 2018 Peter Compernolle. All rights reserved.
//

import XCTest
@testable import SimpleObservable

class DistinctValueListenerTests: XCTestCase {
    let initialValue = "initial value"
    let newValue = "new value"
    let thirdValue = "third value"
    var listener: Property<String>!
    var property: Property<String>!

    override func setUp() {
        property = Property<String>(initialValue)
        listener = property.distinct()
    }

    func testListenerSendsOnlyDistinctValues() {
        var actualReceivedValues = [String]()
        let sentValues = [initialValue, newValue, newValue, newValue, thirdValue, thirdValue, newValue]
        let expectedValues = [initialValue, newValue, thirdValue, newValue]

        let receivedAllValuesExpectation = expectation(description: "received duplicate values")
        receivedAllValuesExpectation.isInverted = true

        let _ = listener.on(next: {(value) in
            actualReceivedValues.append(value)
            if actualReceivedValues.count > expectedValues.count {
                receivedAllValuesExpectation.fulfill()
            }
        })
        for value in sentValues {
            property.value = value
        }
        XCTAssertEqual(actualReceivedValues, expectedValues)
        waitForExpectations(timeout: 1)
    }
}
