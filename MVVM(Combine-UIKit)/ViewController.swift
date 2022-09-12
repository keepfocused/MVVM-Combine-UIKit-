//
//  ViewController.swift
//  MVVM(Combine+UIKit)
//
//  Created by Danil  on 09.09.2022.
//

import UIKit
import Combine

class ViewController: UITableViewController {

    // MARK: - Outlets
    
    @IBOutlet weak var emailAddressField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var passwordConfirmationField: UITextField!
    @IBOutlet weak var agreeTermsSwitch: UISwitch!
    @IBOutlet weak var signUpButton: BigButton!
    
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - View Lifecycle
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        formIsValid
            .assign(to: \.isEnabled, on: signUpButton)
            .store(in: &cancellables)
        
        setValidColor(field: emailAddressField, publisher: emailIsValid)
        setValidColor(field: passwordField, publisher: passwordIsValid)
        setValidColor(field: passwordConfirmationField, publisher: passwordMatchesConfirmation)
        
        formattedEmailAddress
            .filter { [weak self] in $0 != self?.emailSubject.value}
            .map { $0 as String? }
            .assign(to: \.text, on: emailAddressField)
            .store(in: &cancellables)
    }
    
    private func setValidColor<P: Publisher>(field: UITextField, publisher: P) where P.Output == Bool, P.Failure == Never {
        publisher
            .map { $0 ? UIColor.label : UIColor.systemRed}
            .assign(to: \.textColor, on: field)
            .store(in: &cancellables)
    }
    
    
    private func isValidEmal(_ email: String) -> Bool {
        email.contains("@") && email.contains( ".")
    }
    
    // MARK: - Publishers
    
    private var formattedEmailAddress: AnyPublisher<String, Never> {
        emailSubject
            .map { $0.lowercased() }
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines)}
            .eraseToAnyPublisher()
    }
    
    private var formIsValid: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest3(
            emailIsValid,
            passwordValidAndConfirmed,
            agreeTermSubject)
        .map {$0.0 && $0.1 && $0.2 }
        .eraseToAnyPublisher()
    }
    
    private var emailIsValid: AnyPublisher<Bool, Never> {
        formattedEmailAddress
            .map { [weak self] in self?.isValidEmal($0) }
            .replaceNil(with: false)
            .eraseToAnyPublisher()
    }
    
    private var passwordValidAndConfirmed: AnyPublisher<Bool, Never> {
        passwordIsValid.combineLatest(passwordMatchesConfirmation)
            .map { valid, confirmed in
                valid && confirmed
            }
            .eraseToAnyPublisher()
    }
    
    private var passwordIsValid: AnyPublisher<Bool, Never> {
        passwordSubject
            .map {
                $0 != "password" && $0.count >= 8
            }
            .eraseToAnyPublisher()
    }
    
    private var passwordMatchesConfirmation: AnyPublisher<Bool, Never> {
        passwordSubject.combineLatest(passwordConfiramtionSubject)
            .map { pass, conf in
                pass == conf
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Subjects
    
    private var emailSubject = CurrentValueSubject<String, Never>("")
    private var passwordSubject = CurrentValueSubject<String, Never>("")
    private var passwordConfiramtionSubject = CurrentValueSubject<String, Never>("")
    private var agreeTermSubject = CurrentValueSubject<Bool, Never>(false)
    
    // MARK: - Actions
    
    @IBAction func emailDidChange(_ sender: Any) {
        emailSubject.send(emailAddressField.text ?? "")
    }
    
    @IBAction func passwordDidChange(_ sender: Any) {
        passwordSubject.send(passwordField.text ?? "")
    }
    
    @IBAction func passwordConfirmationDidChange(_ sender: Any) {
        passwordConfiramtionSubject.send(passwordConfirmationField.text ?? "")
    }
    
    @IBAction func agreeSwitchDidChange(_ sender: Any) {
        agreeTermSubject.send(agreeTermsSwitch.isOn)
    }
    
    @IBAction func signUpTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Welcome!", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
