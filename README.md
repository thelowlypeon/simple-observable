# Simple Observable

This is a crazy simple alternative to Reactive Cocoa and RxSwift,
for those of us who are increasingly tired of repeatedly dealing with
their breaking changes and incompatibilities.

It is designed for 100% Swift compatibility (ie not objective-c),
with zero dependence on KVO or `NSObject`. In other words,
this doesn't require iOS Foundation.

## Installation

You can "install" this as a git submodule if you'd like.
It is not available using any package manager because its whole purpose is
to avoid that.

For the easiest installation, just grab the code, only a few hundred lines.

## Observable Properties

The crux of Simple Observable is the `Property`.
An observable property is defined with its type and an initial value.

A class that has observable properties may look like this:

```swift
class MyClass {
    let observableString: Property<String>
    let observableOptionalString = Property<String?>()

    init(string: String, optionalString: String?) {
        observableString = Property<String>(string)
        observableOptionalString.value = optionalString
    }
}
```

And a consumer of this class might use it like this:

```swift
let myClass = MyClass(string: "Required", optionalString: nil)
print("require string: \(myClass.observableString.value)")
let listener = myClass.observableString.on(next: { print("observable string value changed: \($0) })
myClass.observableString.value = "new value"
```

### Removing Observers

You may want to break all references to property listeners, or to a specific one:

```swift
myClass.observableString.remove(listener: observerInstance)
myClass.observableString.removeAllListeners()
```

## Property Listeners

A property listener is notified when its property value changes.

For example, if we wanted our callback to execute only on distinct values
that aren't nil, we can add a listener on the above class that looks like:

```swift
let _ = myClass.observableOptionalString
    .filter("", { $0 != nil })
    .map { $0! }
    .distinct()
    .on(next: { print("here's a unique non-nil value! \($0) })
```

### Methods

#### `onNext()`

This is the heart of Simple Observable: provide a callback to be executed with
the new value of the observed property whenever it changes.

```swift
myClass.observableString.on(next: { print($0) })
```

You can register multiple callbacks for a single observable property:

```swift
let filteredListener = observableString.filter("default", { $0 != nil }).map { $0! }
filteredListener.on(next: { print($0) })
//...
filteredListener.on(next: { self.prop = $0 })
```

#### `map()`

Map the new value to another using a simple closure. This is incredibly handy for things like
translating an `Error` to its localized string, or returning a boolean for whether a value is valid as it changes.

```swift
// wrap strings in bold tags
observableString.map({(unmappedValue) in
  return "<b>\(unmappedValue)</b>"
}).on(next: { print($0) })

// map from one type to another
var label: String = "default"
observableOptionalString.map({(optionalString) in
    optionalString ?? "default"
}).on(next: { label = $0 })
```

#### `filter()`

Control when your callbacks are executed using `filter()`.
Pass a closure that takes returns a boolean given the sent value
for whether to send the value along the chain.

```swift
myClass.observableString.filter("default", {(newValue) -> Bool in
  return newValue == "test"
})
```

Note that `filter()` takes an initial value as its first parameter. This is because
the current, initial value of the observed property may not pass your filter.

#### `distinct()`

Calling this will prevent duplicate values from being sent:

```swift
observableString.distinct().on(next: { print($0) })
observableString.value = "once" // prints "once"
observableString.value = "twice" // prints "twice"
observableString.value = "twice" // doesn't print
```

## Contributing

Feel free to contribute! Fork the repo and submit a pull request.

## TODO

* Bindings! I want to be able to bind a property's value to one of my own. That's kind of the whole point.
* Better handling of `initialValue`. Specifically, this is problematic when there is no reasonable default
value when `filter`ing
* Something like a `Command` in ReactiveCocoa, that contains a closure to run when the command is executed, an observable Bool for whether the command is being run at the moment, and an observable `Error?`
* `combine()` or `flatten()`, that accepts multiple properties and sends either the latest value of each, or maps them based on a closure
