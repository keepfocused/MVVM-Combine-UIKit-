//
//  SignUpViewModel.swift
//  MVVM(Combine+UIKit)
//
//  Created by Danil  on 09.09.2022.
//

import Foundation
import Combine
import UIKit.UIColor

class SignUpViewModel {
    // Subjects
    @Published
    var email = ""
    
    @Published
    var password = ""
    
    @Published
    var passwordConfirmation = ""
    
    @Published
    var agreeTerms = false
    
    // UI State
    
    @Published
    var emailFieldTextColor: UIColor?
    
    @Published
    var passwordFieldTextColor: UIColor?
    
    @Published
    var passwordConfirmationFieldTextColor: UIColor?
    
    @Published
    var signUpButtonEnabled = false
    
    init() {
        setupPipeline()
    }
    
    private func setupPipeline() {
        configureEmailAddressBehavior()
        configurePasswordBehavior()
        configureSignUpButtonBehavior()
    }
    
    private func configureEmailAddressBehavior() {
        // format email address
        formattedEmailAddress
            .removeDuplicates()
            .assign(to: &$email)
        
        // set the text color to red when invalid
        validEmailAddress
            .mapToFieldInputColor()
            .assign(to: &$emailFieldTextColor)
    }
    
    private func configurePasswordBehavior() {
        validPassword
            .mapToFieldInputColor()
            .assign(to: &$passwordFieldTextColor)
        
        passwordMatchesConfirmation
            .mapToFieldInputColor()
            .assign(to: &$passwordConfirmationFieldTextColor)
    }
    
    private func configureSignUpButtonBehavior() {
        formIsValid
            .assign(to: &$signUpButtonEnabled)
    }
    
     var formattedEmailAddress: AnyPublisher<String, Never> {
        $email
            .map {
                $0.lowercased()
                    .replacingOccurrences(of: " ", with: "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
            }
            .eraseToAnyPublisher()
    }
    
    var formIsValid: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest3(validEmailAddress, validAndConfirmedPassword, $agreeTerms)
            .map { email, pw, terms in
                email && pw && terms
            }
            .eraseToAnyPublisher()
    }
    
    var passwordMatchesConfirmation: AnyPublisher<Bool, Never> {
        $password.combineLatest($passwordConfirmation)
            .map { pass, confirm in
                pass == confirm
            }
            .eraseToAnyPublisher()
    }
    
    var validPassword: AnyPublisher<Bool, Never> {
        $password
            .map {
                $0 != "password" && $0.count >= 8
            }
            .eraseToAnyPublisher()
    }
    
    var validAndConfirmedPassword: AnyPublisher<Bool, Never> {
        validPassword.combineLatest(passwordMatchesConfirmation)
            .map {$0.0 && $0.1}
            .eraseToAnyPublisher()
        
    }
    
    var validEmailAddress: AnyPublisher<Bool, Never> {
        $email
            .map { [unowned self] in
                isValidEmailAddress($0)
            }
            .eraseToAnyPublisher()
    }
    
    private func isValidEmailAddress(_ email: String) -> Bool {
        return email.contains("@") && email.contains(".")
    }
}

extension Publisher where Output == Bool, Failure == Never {
    func mapToFieldInputColor() -> AnyPublisher<UIColor?, Never> {
        map { isValid -> UIColor? in
            isValid ? .label : .systemRed
        }
        .eraseToAnyPublisher()
    }
}
