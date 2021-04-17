//
//  CellTextLabel.swift
//  TaskPomodoro
//
//  Created by 小野寺祥吾 on 2021/04/05.
//

import UIKit
class CellTextLabel:UILabel {
    init(text:String) {
        super.init(frame: .zero)
        self.text = text
        self.textColor = .darkGray
        self.font = .systemFont(ofSize: 17)
    }
    init(text:String,fontSize:CGFloat,textColor:UIColor) {
        super.init(frame: .zero)
        self.text = text
        self.textColor = textColor
        self.font = .systemFont(ofSize:fontSize)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
