# Simple Observable

This is a crazy simple alternative to Reactive Cocoa and RxSwift,
for those of us who are increasingly tired of repeatedly dealing with
their breaking changes and incompatibilities.

It is designed for 100% Swift compatibility (ie not objective-c),
with zero dependence on KVO or `NSObject`. In other words,
this doesn't require iOS Foundation.

## Observable Properties

The crux of Simple Observable is the `ObservableProperty`.
An observable property is defined with its type and an initial value.

A class that has observable properties may look like this:

```swift
class MyClass {
    let observableString: ObservableProperty<String>
    let observableOptionalString = ObservableProperty<String?>()

    init(string: String, optionalString: String?) {
        observableString = ObservableProperty<String>(string)
        observableOptionalString.value = optionalString
    }
}
```

And a consumer of this class might use it like this:

```swift
let myClass = MyClass(string: "Required", optionalString: nil)
print("require string: \(myClass.observableString.value)")
let observer = myClass.observableString.observe() { print("observable string value changed: \($0) }
myClass.observableString.value = "new value"
```

### Removing Observers

You may want to break all references to property observers, or to a specific observer:

```swift
myClass.observableString.removeObserver(observerInstance)
myClass.observableString.removeObserver(observerIdentifier)
myClass.observableString.removeAllObservers()
```

## Property Observer

A property observer watches for changes on an observable property and
executes callbacks when values change. Optionally filter values, or
execute callbacks only with distinct values.

For example, if we wanted our callback to execute only on distinct values
that aren't nil, we can add an observer on the above class that looks like:

```swift
let observer = myClass.observableOptionalString.observe()
    .distinct()
    .filter { $0 != nil }

observer.onNext { print("here's a unique non-nil value! \($0!) }
```

NOTE: Receiving callbacks on distinct values requires the generic type
to conform to the `Equatable` protocol.

### Methods

#### `filter()`

Control when your callbacks are executed using `filter()`.
Pass a closure that takes a value of type `T` and returns a boolean
for whether to execute your callback.

```swift
//shorthand
myClass.observableString.observe().filter { $0 == "test" }
//verbose
myClass.observableString.observe().filter({(newValue) -> Bool in
  return newValue == "test"
})
```

#### `filter(withOldValue:)`

Like `filter()`, except this will pass the old _and_ new values to your filter:

```swift
myClass.observableString.observe().filter(withOldValue: {(oldValue, newValue) -> Bool in
  return oldValue == nil && (newValue != nil && newValue! > 0)
})
```

#### `addFilter()`

You can optionally declare your own filters. This is particularly useful if you want to reuse them or
specify whether to ignore your filter on the initial value.

```swift
let filter = PropertyChangeFilter<String>({ $0 != $1 }, ignoreOnFirstPass: true)
myClass.observableString.observe.addFilter(filter)
```

By default, property change filters are initialized with a closure that takes the new and old value.
If you want to ignore the old value, using `PropertyChangeFilter:ignoringOldValue:ignoreOnFirstPass:`.

#### `onNext()`

Register a callback to be executed when the observable property's value changes.

```swift
myClass.observableString.observe().onNext { print($0) }
```

You can register multiple callbacks for a single observable property:

```swift
let observer = observableString.observe().filter { $0 != nil }
observer.onNext { print($0) }
observer.onNext { self.prop = $0! }
```
