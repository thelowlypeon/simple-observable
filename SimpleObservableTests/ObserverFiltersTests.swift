//
//  ObserverFiltersTests.swift
//  SimpleObservableTests
//
//  Created by Peter Compernolle on 10/6/18.
//  Copyright © 2018 Peter Compernolle. All rights reserved.
//

import XCTest
@testable import SimpleObservable

class ObserverWithMockedFilters<T>: Observer<T> {
    var mockPassesFilters: Bool?
    override func passesFilters(_ newValue: T, firstPass: Bool = false) -> Bool {
        if let mock = mockPassesFilters {
            return mock
        }
        return super.passesFilters(newValue, firstPass: firstPass)
    }
}

class ObserverFiltersTests: XCTestCase {
    let initialValue = "initial value"
    let newValue = "new value"
    var observer: ObserverWithMockedFilters<String>!
    var filter: PropertyChangedFilterClosure<String>!

    override func setUp() {
        observer = ObserverWithMockedFilters<String>(initialValue: initialValue)
    }

    func testFilterAllowsValue() {
        let _ = observer.filter {(_) in return true }
        XCTAssert(observer.passesFilters(newValue))
    }

    func testFilterFiltersValue() {
        let _ = observer.filter {(_) in return false }
        XCTAssertFalse(observer.passesFilters(newValue))
    }

    func testWhenMultipleFiltersAllowValue() {
        let _ = observer.filter {(_) in return true }
            .filter {(_) in return true }
        XCTAssert(observer.passesFilters(newValue))
    }

    func testWhenOneFilterFails() {
        let _ = observer.filter {(_) in return true }
            .filter {(_) in return false }
        XCTAssertFalse(observer.passesFilters(newValue))
    }

    func testFailingFirstFilterPreventsSubsequentFilters() {
        let newValueExpectation = expectation(description: "received new value")
        let _ = observer.filter({(value) in
            if value == self.newValue {
                newValueExpectation.fulfill()
            }
            return false
        }).filter({(_) in
            XCTFail("should not have run second filter")
            return false
        })
        observer.send(newValue)
        waitForExpectations(timeout: 1)
    }

    func testWhenFiltersFailOnNextIsNotCalled() {
        observer.mockPassesFilters = false
    }
}
