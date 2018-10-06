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
    var observer: Observer<String>!
    var observableProperty: ObservableProperty<String>!

    override func setUp() {
        observableProperty = ObservableProperty<String>(initialValue)
        observer = observableProperty.observe().distinct()
    }

    func testObserverSendsOnlyDistinctValues() {
        let newValueExpectation = expectation(description: "received new value")
        var receivedInitialValue = false
        let _ = observer.onNext({(value) in
            if value == self.initialValue {
                if receivedInitialValue {
                }
                receivedInitialValue = true
            } else {
                newValueExpectation.fulfill()
            }
        })
        observer.send(initialValue)
        observer.send(newValue)
        waitForExpectations(timeout: 1)
    }
}
