import UIKit
import SimpleObservable

class Person {
    let op_firstName: ObservableProperty<String>
    let op_lastName: ObservableProperty<String>

    init(firstName: String, lastName: String) {
        op_firstName = ObservableProperty<String>(firstName)
        op_lastName = ObservableProperty<String>(lastName)
    }

    func isBeatle() -> Bool {
        return ["John", "Paul", "George", "Ringo"].contains(firstName)
    }

    func abbreviateName() {
        
    }
}

extension Person {
    var firstName: String {
        get { return op_firstName.value }
        set { op_firstName.value = newValue }
    }
    var lastName: String {
        get { return op_lastName.value }
        set { op_lastName.value = newValue }
    }
}

class UserViewModel {
    // MARK - observable properties
    let op_personNameText = ObservableProperty<String?>()

    // MARK -- observe changes to the person
    private let op_person = ObservableProperty<Person?>()
    private let personObserver: Observer<Person?>
    private var personFirstNameObserver: Observer<String>?
    private var personLastNameObserver: Observer<String>?

    init() {
        self.personObserver = op_person.observe()
            .filter { $0?.isBeatle() ?? true }
        self.personObserver.onNext({(p) in
            self.personFirstNameObserver = self.person?.op_firstName
                .observe().onNext { _ in self.updateNameString() }
            self.personLastNameObserver = self.person?.op_lastName
                .observe().onNext { _ in self.updateNameString() }
        })
    }

    deinit {
        personFirstNameObserver = nil
        personLastNameObserver = nil
        personObserver.end()
    }

    private func updateNameString() {
        if let person = self.person {
            personNameText = "\(person.firstName) \(person.lastName)"
        } else {
            personNameText = nil
        }
    }
}

extension UserViewModel {
    var person: Person? {
        get { return op_person.value }
        set { op_person.value = newValue }
    }
    private(set) var personNameText: String? {
        get { return op_personNameText.value }
        set { op_personNameText.value = newValue }
    }
}

class UserView {
    private var people: [Person]
    private let viewModel: UserViewModel
    private var personNameTextObserver: Observer<String?>?

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
        personNameTextObserver = viewModel.op_personNameText.observe()
            .distinct()
            .onNext({(text) in
                self.nameLabel.text = text
                self.render()
            })
    }

    func viewWillDisappear() {
        personNameTextObserver = nil
    }

    func chooseRandomPerson() {
        self.viewModel.person = people.randomElement()
    }

    func render() {
        print("View shows: \(nameLabel.text ?? "nil")")
    }
}

let view = UserView(people: [])
view.viewWillAppear()
view.fetchPeople {
    print("done fetching people")
    for _ in 0...10 {
        print("choosing a random beatle")
        view.chooseRandomPerson()
    }
}
