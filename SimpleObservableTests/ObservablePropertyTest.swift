//
//  ObservablePropertyTest.swift
//  SimpleObservableTests
//
//  Created by Peter Compernolle on 9/30/18.
//  Copyright © 2018 Peter Compernolle. All rights reserved.
//

import XCTest
@testable import SimpleObservable

class ObservablePropertyTest: XCTestCase {
    var initialValue = "initial string"
    let newValue = "new value"
    var observableString: ObservableProperty<String>!
    var observableOptionalString: ObservableProperty<String?>!

    override func setUp() {
        observableString = ObservableProperty<String>(initialValue)
    }

    func testInitialValue() {
        XCTAssertEqual(observableString.value, initialValue)
    }

    func testMutatingValue() {
        observableString.value = newValue
        XCTAssertEqual(observableString.value, newValue)
    }

    func testNilLiteralInitializer() {
        observableOptionalString = ObservableProperty<String?>()
        XCTAssertNil(observableOptionalString.value)
    }

    func testObserveReturnsObserverWithInitialValue() {
        let observer = observableString.observe()
        XCTAssertEqual(observer.currentValue, initialValue)
    }

    func testObserveReturnsRegisteredObserver() {
        let observer = observableString.observe()
        observableString.value = newValue
        XCTAssertEqual(observer.currentValue, newValue)
    }
}
