//
//  MappedListenerTests.swift
//  SimpleObservableTests
//
//  Created by Peter Compernolle on 2/13/19.
//  Copyright © 2019 Peter Compernolle. All rights reserved.
//

import XCTest
@testable import SimpleObservable

class MappedListenerTests: XCTestCase {
    let initialValue = 1
    var property: Property<Int>!

    override func setUp() {
        property = Property<Int>(initialValue)
    }

    func testMapperDoublesAllSentValues() {
        let sentValues = [1, 2, 3, 4, 5, 6]
        let expectedValues = [2, 2, 4, 6, 8, 10, 12] // include initial value
        var actualReceivedValues = [Int]()
        let receivedAllValues = expectation(description: "received all values")

        _ = property.map { $0 * 2 }.on(next: {(value) in
            actualReceivedValues.append(value)
            if actualReceivedValues.count == expectedValues.count {
                receivedAllValues.fulfill()
            }
        })
        for value in sentValues {
            property.value = value
        }

        waitForExpectations(timeout: 1)
        XCTAssertEqual(expectedValues, actualReceivedValues)
    }
}

