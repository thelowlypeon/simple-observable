//
//  PropertyTest.swift
//  SimpleObservableTests
//
//  Created by Peter Compernolle on 9/30/18.
//  Copyright © 2018 Peter Compernolle. All rights reserved.
//

import XCTest
@testable import SimpleObservable

class PropertyTest: XCTestCase {
    var initialValue = "initial string"
    let newValue = "new value"
    var observableString: Property<String>!
    var observableOptionalString: Property<String?>!

    override func setUp() {
        observableString = Property<String>(initialValue)
    }

    func testInitialValue() {
        XCTAssertEqual(observableString.value, initialValue)
    }

    func testMutatingValue() {
        observableString.value = newValue
        XCTAssertEqual(observableString.value, newValue)
    }

    func testNilLiteralInitializer() {
        observableOptionalString = Property<String?>()
        XCTAssertNil(observableOptionalString.value)
    }
}
