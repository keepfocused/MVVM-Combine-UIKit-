//
//  FormTextField.swift
//  MVVM(Combine+UIKit)
//
//  Created by Danil  on 09.09.2022.
//

import UIKit

@IBDesignable
class FormTextField: UITextField {
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10))
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10))
    }
}
