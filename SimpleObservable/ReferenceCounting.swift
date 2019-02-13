//
//  ReferenceCounting.swift
//  SimpleObservable
//
//  Created by Peter Compernolle on 2/13/19.
//  Copyright © 2019 Peter Compernolle. All rights reserved.
//

fileprivate let sharedInstance = SimpleObservableReferenceManager()

public class SimpleObservableReferenceManager {
    public static var shared: SimpleObservableReferenceManager {
        return sharedInstance
    }

    private var count = 0

    public func getCount() -> Int {
        return count
    }

    public func up() {
        count += 1
    }

    public func down() {
        count -= 1
    }
}
