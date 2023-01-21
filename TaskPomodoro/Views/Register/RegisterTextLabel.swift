//
//  RegisterTextLabel.swift
//  TaskPomodoro
//
//  Created by 小野寺祥吾 on 2021/04/05.
//

import UIKit

class RegisterTextLabel: UILabel {
    init(text:String) {
        super.init(frame: .zero)
        self.text = text
        self.textColor = .darkGray
        self.font = .systemFont(ofSize: 18)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
