//
//  DistinctValueObserver.swift
//  SimpleObservable
//
//  Created by Peter Compernolle on 10/1/18.
//  Copyright © 2018 Peter Compernolle. All rights reserved.
//

import Foundation

public class DistinctValueObserver<T: Equatable>: Observer<T> {
    override func shouldSend(_ newValue: T) -> Bool {
        print("checking should send with \(newValue) and old \(currentValue)")
        return passesDistinctValueFilter(newValue) && super.shouldSend(newValue)
    }

    private func passesDistinctValueFilter(_ newValue: T) -> Bool {
        return newValue != currentValue
    }
}
