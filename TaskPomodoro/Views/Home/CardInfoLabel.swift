//
//  CardInfoLabel.swift
//  TaskPomodoro
//
//  Created by 小野寺祥吾 on 2021/04/03.
//

import UIKit

class CardInfoLabel: UILabel {
    //nopeとgoodのラベル
    init(text: String, textColor: UIColor) {
        super.init(frame: .zero)
        font = .boldSystemFont(ofSize: 45)
        self.text = text
        self.textColor = textColor
        layer.borderWidth = 3
        layer.borderColor = textColor.cgColor
        layer.cornerRadius = 10
        textAlignment = .center
        alpha = 0
    }
    
    //その他のtextColorのラベル
    init(labelText: String, labelFont: UIFont) {
        super.init(frame: .zero)
        font = labelFont
        textColor = .white
        textAlignment = .center
        text = labelText
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
