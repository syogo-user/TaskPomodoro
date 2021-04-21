//
//  CardInfoView.swift
//  TaskPomodoro
//
//  Created by 小野寺祥吾 on 2021/04/21.
//

import UIKit
class CardInfoTextView:UITextView{
    
    init(text:String) {
        super.init(frame: CGRect.zero, textContainer: nil)
        self.text = text
        self.textColor = .darkGray
        self.font = .systemFont(ofSize: 15)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
