//
//  FilteredListenerTests.swift
//  SimpleObservableTests
//
//  Created by Peter Compernolle on 10/6/18.
//  Copyright © 2018 Peter Compernolle. All rights reserved.
//

import XCTest
@testable import SimpleObservable

class FilteredListenerTests: XCTestCase {
    let initialValue = "initial value"
    let newValue = "new value"
    var property: Property<String>!
    let allow: ValueFilter<String> = {(_) in return true }
    let deny: ValueFilter<String> = {(_) in return false }

    override func setUp() {
        property = Property<String>(initialValue)
    }

    func testFilterSendsInitialValueEvenWhenFilterDenies() {
        let initialValueExp = expectation(description: "got initial value")
        _ = property.filter(initialValue, deny)
            .on(next: {(value) in
                if value == self.initialValue {
                    initialValueExp.fulfill()
                }
            })
        waitForExpectations(timeout: 1)
    }

    func testFilterSendsInitialValueWhenFilterAllows() {
        let initialValueExp = expectation(description: "got initial value")
        _ = property.filter(initialValue, allow)
            .on(next: {(value) in
                if value == self.initialValue {
                    initialValueExp.fulfill()
                }
            })
        waitForExpectations(timeout: 1)
    }

    func testFilterDeniesDeniedValues() {
        let newValueExp = expectation(description: "got new value")
        newValueExp.isInverted = true
        _ = property.filter(initialValue, deny)
            .on(next: {(value) in
                if value != self.initialValue {
                    newValueExp.fulfill()
                }
            })
        property.value = newValue
        waitForExpectations(timeout: 1)
    }

    func testFilterAllowsAllowedValues() {
        let newValueExp = expectation(description: "got new value")
        _ = property.filter(initialValue, allow)
            .on(next: {(value) in
                if value != self.initialValue {
                    newValueExp.fulfill()
                }
            })
        property.value = newValue
        waitForExpectations(timeout: 1)
    }

    func testFilterAllowsVowelsAndDefaultValue() {
        let sentValues = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j"]
        let expectedValues = ["default value", "a", "e", "i"]
        var actualReceivedValues = [String]()
        let receivedAllValues = expectation(description: "received all values")

        _ = property.filter("default value", {(string) in
            return ["a", "e", "i", "o", "u"].contains(string)

        }).on(next: {(value) in
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
