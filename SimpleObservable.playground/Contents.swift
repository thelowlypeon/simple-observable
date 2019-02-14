// This playground is meant to demonstrate how SimpleObservable can be useful.
// It builds a crazy simple app that allows you to change people's names in MVVM.

import UIKit
import PlaygroundSupport
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

    func jumbleName() {
        firstName = jumbleString(firstName)
        lastName = jumbleString(lastName)
    }

    private func jumbleString(_ input: String) -> String {
        var characters = Array(input)
        let replace = Int.random(in: 0..<characters.count)
        let with = Int.random(in: 0..<characters.count)
        let replacement = characters[replace]
        characters[replace] = characters[with]
        characters[with] = replacement
        return String(characters)
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
    private let _selectedPerson = Property<Person?>()
    private var _personListener: Listener<Person?>?

    init() {
        _personListener = _selectedPerson.on(next: {[weak self] (person) in
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
        if let person = self.selectedPerson {
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
    var selectedPerson: Person? {
        get { return _selectedPerson.value }
        set { _selectedPerson.value = newValue }
    }
    private(set) var personNameText: String? {
        get { return _personNameText.value }
        set { _personNameText.value = newValue }
    }
}

class PeopleViewModel {
    let _people = Property<[Person]>([])
    var people: [Person] { return _people.value }

    let _title = Property<String>("Loading...")
    var title: String { return _title.value }

    init() {
        fetchPeople()
    }

    private func fetchPeople() {
        //async to simulate remote request
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {[weak self] in
            guard let self = self else { return }
            self._people.value = [
                Person(firstName: "John", lastName: "Lennon"),
                Person(firstName: "Paul", lastName: "McCartney"),
                Person(firstName: "George", lastName: "Harrison"),
                Person(firstName: "Ringo", lastName: "Starr"),
                Person(firstName: "The Lowly", lastName: "Peon")
            ]
            self._title.value = "\(self.people.count) People"
        }
    }

    deinit { print("deinitializing PeopleViewModel") }
}

class PeopleViewController: UITableViewController {
    private var viewModel: PeopleViewModel!
    let reuseIdentifier = "person"

    override func viewWillAppear(_ animated: Bool) {
        if viewModel == nil {
            viewModel = PeopleViewModel()
        }
        viewModel._people.on(next: {[weak self]_ in
            self?.tableView.reloadData()
        })
        viewModel._title.on(next: {[weak self](title) in self?.title = title })
        super.viewWillAppear(animated)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.people.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier)

        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: reuseIdentifier)
            cell.accessoryType = .disclosureIndicator
        }

        let person = viewModel.people[indexPath.row]
        cell.textLabel?.text = "\(person.firstName) \(person.lastName)"

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let person = self.viewModel.people[indexPath.row]
        let vc = UserViewController()
        vc.displayPerson(person)
        self.navigationController?.pushViewController(vc, animated: true)
    }

    deinit { print("deinitializing PeopleViewController") }
}

class UserViewController: UIViewController {
    private let viewModel = UserViewModel()
    private var personNameTextObserver: Listener<String?>?

    lazy var nameLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 200, width: 375, height: 20))
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    lazy var jumblePersonNameButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 300, width: 375, height: 20))
        button.setTitle("Jumble!", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        button.addTarget(self, action: #selector(jumblePersonName), for: .touchUpInside)
        return button
    }()

    override func loadView() {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 375, height: 668))
        view.backgroundColor = .white
        view.addSubview(self.jumblePersonNameButton)
        view.addSubview(self.nameLabel)
        self.view = view
    }

    func displayPerson(_ person: Person) {
        viewModel.selectedPerson = person
    }

    override func viewWillAppear(_ animated: Bool) {
        // want to see how important it is to use [weak self] in callbacks like this?
        // try removing it and see what _doesn't_ get released
        personNameTextObserver = viewModel._personNameText
            //.distinct()
            .on(next: {[weak self](text) in
                self?.nameLabel.text = text
            })
        super.viewWillAppear(animated)
    }

    @objc func jumblePersonName() {
        viewModel.selectedPerson?.jumbleName()
    }

    func viewWillDisappear() {
        personNameTextObserver?.stopObserving()
    }

    deinit { print("deinitializing UserView") }
}


let peopleViewController = PeopleViewController()
let navigationController = UINavigationController(rootViewController: peopleViewController)
PlaygroundPage.current.liveView = navigationController
PlaygroundPage.current.needsIndefiniteExecution = true
