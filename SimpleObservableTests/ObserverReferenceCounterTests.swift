//
//  ObserverReferenceCounterTests.swift
//  SimpleObservableTests
//
//  Created by Peter Compernolle on 10/1/18.
//  Copyright © 2018 Peter Compernolle. All rights reserved.
//

import XCTest
@testable import SimpleObservable

class ObserverWithTestableDeinit<T>: Observer<T> {
    var deinitClosure: (() -> Void)?
    deinit { deinitClosure?() }
}

class ObservableWithTestableDeinit<T>: ObservableProperty<T> {
    var deinitClosure: (() -> Void)?
    deinit { deinitClosure?() }
}

class ObserverReferenceCounterTests: XCTestCase {
    let initialValue = "initial value"
    var observableProperty: ObservableWithTestableDeinit<String>?
    var observer: ObserverWithTestableDeinit<String>?

    override func setUp() {
        observer = ObserverWithTestableDeinit<String>(initialValue: initialValue)
        observableProperty = ObservableWithTestableDeinit<String>(initialValue)
    }

    func testNoReferenceIsHeldWhenObserverIsRemoved() {
        let exp = expectation(description: "observer is deinitialized")
        observer!.deinitClosure = { exp.fulfill() }
        let _ = observableProperty!.register(observer: observer!)
        observableProperty!.stopObserving(observer!.identifier)
        DispatchQueue.global(qos: .background).async {
            self.observer = nil
        }
        waitForExpectations(timeout: 1)
    }

    func testNoReferenceIsHeldWhenObservablePropertyIsRemoved() {
        let exp = expectation(description: "observable is deinitialized")
        observableProperty!.deinitClosure = { exp.fulfill() }
        let _ = observableProperty!.register(observer: observer!)
        observableProperty!.stopObserving(observer!.identifier)
        DispatchQueue.global(qos: .background).async {
            self.observableProperty = nil
        }
        waitForExpectations(timeout: 1)
    }
}
