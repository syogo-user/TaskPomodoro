//
//  RegisterTextField.swift
//  TaskPomodoro
//
//  Created by 小野寺祥吾 on 2021/04/05.
//

import UIKit

class RegisterTextField: UITextField {
    init(placeHolder: String) {
        super.init(frame: .zero)
        placeholder = placeHolder
        borderStyle = .roundedRect//角丸
        font = .systemFont(ofSize: 14)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
