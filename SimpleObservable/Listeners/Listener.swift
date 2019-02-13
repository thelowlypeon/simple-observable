//
//  Listener.swift
//  SimpleObservable
//
//  Created by Peter Compernolle on 2/12/19.
//  Copyright © 2019 Peter Compernolle. All rights reserved.
//

public class Listener<ValueType> {
    private let identifier = Int(arc4random_uniform(UInt32.max))

    private(set) var isObserving = true

    public func stopObserving() {
        isObserving = false
    }

    internal init() {
        SimpleObservableReferenceManager.shared.up()
    }

    internal func valueChanged(_ newValue: ValueType) {}

    internal var deinitClosure: (() -> Void)?

    deinit {
        deinitClosure?()
        SimpleObservableReferenceManager.shared.down()
    }
}

extension Listener: Hashable {
    public static func == (lhs: Listener<ValueType>, rhs: Listener<ValueType>) -> Bool {
        return lhs.identifier == rhs.identifier
    }

    public var hashValue: Int {
        return identifier
    }
}
