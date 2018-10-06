//
//  RegisteringObserverTests.swift
//  SimpleObservableTests
//
//  Created by Peter Compernolle on 9/30/18.
//  Copyright © 2018 Peter Compernolle. All rights reserved.
//

import XCTest
@testable import SimpleObservable

class RegisteringObserverTests: XCTestCase {
    let initialValue = "initial value"
    let newValue = "new value"
    lazy var observableProperty: ObservableProperty<String> = {
        return ObservableProperty<String>(initialValue)
    }()
    lazy var observer1: Observer<String> = {
        return Observer<String>(observableProperty, initialValue: initialValue)
    }()
    lazy var observer2: Observer<String> = {
        return Observer<String>(observableProperty, initialValue: initialValue)
    }()

    func testRegisteringMultipleObservers() {
        let _ = observableProperty.register(observer: observer1)
        let _ = observableProperty.register(observer: observer2)
        observableProperty.value = newValue
        XCTAssertEqual(observer1.currentValue, newValue)
        XCTAssertEqual(observer2.currentValue, newValue)
    }

    func testUnregisteringObserversByIdentifier() {
        let _ = observableProperty.register(observer: observer1)
        observableProperty.stopObserving(observer1.identifier)
        observableProperty.value = newValue
        XCTAssertEqual(observer1.currentValue, initialValue)
    }

    func testUnregisteringAllObservers() {
        let _ = observableProperty.register(observer: observer1)
        let _ = observableProperty.register(observer: observer2)
        observableProperty.removeAllObservers()
        observableProperty.value = newValue
        XCTAssertEqual(observer1.currentValue, initialValue)
        XCTAssertEqual(observer2.currentValue, initialValue)
    }

}
