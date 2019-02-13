// This playground is meant to demonstrate how SimpleObservable can be useful.
// It builds a crazy simple app that allows you to change people's names in MVVM.

import UIKit
import SimpleObservable

class Person {
    let _firstName: Property<String>
    let _middleName: Property<String?>
    let _lastName: Property<String>

    init(firstName: String, lastName: String) {
        self._firstName = Property<String>(firstName)
        self._middleName = Property<String?>(nil)
        self._lastName = Property<String>(lastName)
    }

    func isBeatle() -> Bool {
        return ["John", "Paul", "George", "Ringo"].contains(firstName)
    }

    deinit {
        print("deinitializing \(_firstName.value)")
    }
}

// prefer simpler setters and getters? just make computed properties that update
// the observed properties' values. this is by no means necessary! just an idea.
extension Person {
    var firstName: String {
        get { return _firstName.value }
        set { _firstName.value = newValue }
    }
    var middleName: String? {
        get { return _middleName.value }
        set { _middleName.value = newValue }
    }
    var lastName: String {
        get { return _lastName.value }
        set { _lastName.value = newValue }
    }
}

class UserViewModel {
    // MARK - observable properties
    let _personNameText = Property<String?>()

    // MARK -- observe changes to the person
    private let _person = Property<Person?>()
    private var _personListener: Listener<Person?>?

    init() {
        _personListener = _person.filter(nil, {(person) in
            return person?.isBeatle() ?? true // only update if the person is a beatle or nil
        }).on(next: {[weak self] (person) in
            guard let self = self else { return }
            if let person = person {
                person._firstName.on(next: {[weak self] _ in self?.updateNameString() })
                person._lastName.on(next: {[weak self] _ in self?.updateNameString() })
            } else {
                self.updateNameString()
            }
        })
    }

    private func updateNameString() {
        if let person = self.person {
            personNameText = "\(person.firstName) \(person.lastName)"
        } else {
            personNameText = nil
        }
    }

    deinit {
        print("deinitializing UserViewModel")
        _personListener = nil
    }
}

extension UserViewModel {
    var person: Person? {
        get { return _person.value }
        set { _person.value = newValue }
    }
    private(set) var personNameText: String? {
        get { return _personNameText.value }
        set { _personNameText.value = newValue }
    }
}

class UserView {
    private var people: [Person]
    private let viewModel: UserViewModel
    private var personNameTextObserver: Listener<String?>?

    var nameLabel: UILabel!
    var changePersonButton: UIButton!
    var changePersonNameButton: UIButton!

    init(people: [Person]) {
        self.nameLabel = UILabel(frame: CGRect.zero)
        self.people = people
        self.viewModel = UserViewModel()
    }

    func fetchPeople(completionHandler: (() -> Void)?) {
        DispatchQueue.global(qos: .background).async {
            self.people = [
                Person(firstName: "John", lastName: "L"),
                Person(firstName: "Paul", lastName: "M"),
                Person(firstName: "George", lastName: "H"),
                Person(firstName: "Ringo", lastName: "S"),
                Person(firstName: "Peter", lastName: "C")
            ]
            completionHandler?()
        }
    }

    func viewWillAppear() {
        // want to see how important it is to use [weak self] in callbacks like this?
        // try removing it and see what _doesn't_ get released
        personNameTextObserver = viewModel._personNameText
            .distinct()
            .on(next: {[weak self](text) in
                self?.nameLabel.text = text
                self?.render()
            })
    }

    func viewWillDisappear() {
        personNameTextObserver?.stopObserving()
    }

    func chooseRandomPerson() {
        self.viewModel.person = people.randomElement()
    }

    func render() {
        print("View shows: \(nameLabel.text ?? "nil")")
    }

    deinit { print("deinitializing UserView") }
}

var view: UserView? = UserView(people: [])
view!.viewWillAppear()
view!.fetchPeople {
    for _ in 0...20 {
        view!.chooseRandomPerson()
    }
}

DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(2)) {
    view!.viewWillDisappear()
    view = nil
    print("reference count: \(SimpleObservableReferenceManager.shared.getCount())")
}
