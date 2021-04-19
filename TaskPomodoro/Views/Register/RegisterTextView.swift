//
//  RegisterTextView.swift
//  TaskPomodoro
//
//  Created by 小野寺祥吾 on 2021/04/19.
//
import UIKit
class RegisterTextView:UITextView {
    init(text:String) {
        super.init(frame: CGRect.zero, textContainer: nil)
        self.text = text
        self.textColor = .darkGray
        self.font = .systemFont(ofSize: 18)
    }

    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
