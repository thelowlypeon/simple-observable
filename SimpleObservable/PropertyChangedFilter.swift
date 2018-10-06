//
//  PropertyChangedFilter.swift
//  SimpleObservable
//
//  Created by Peter Compernolle on 10/6/18.
//  Copyright © 2018 Peter Compernolle. All rights reserved.
//

import Foundation

public typealias PropertyChangedFilterClosure<T> = ((T) -> Bool)
public typealias PropertyChangedFromFilterClosure<T> = ((T, T) -> Bool)

public struct PropertyChangedFilter<T> {
    private let closure: PropertyChangedFromFilterClosure<T>
    private let ignoreOnFirstPass: Bool

    public init(_ closure: @escaping PropertyChangedFromFilterClosure<T>, ignoreOnFirstPass: Bool = false) {
        self.closure = closure
        self.ignoreOnFirstPass = ignoreOnFirstPass
    }

    public init(ignoringOldValue: @escaping PropertyChangedFilterClosure<T>, ignoreOnFirstPass: Bool = false) {
        self.init({(newValue, _) in
            return ignoringOldValue(newValue)
        }, ignoreOnFirstPass: ignoreOnFirstPass)
    }

    internal func perform(_ newValue: T, oldValue: T, firstPass: Bool = false) -> Bool {
        return (firstPass && ignoreOnFirstPass) || closure(newValue, oldValue)
    }
}
