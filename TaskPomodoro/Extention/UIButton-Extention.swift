//
//  UIButton-Extention.swift
//  TaskPomodoro
//
//  Created by 小野寺祥吾 on 2021/04/03.
//
import UIKit
extension UIButton {
    func createCardInfoButton() -> UIButton {
        self.setImage(UIImage(systemName: "info")?.resize(size: .init(width: 40, height: 40)), for: .normal)
        self.tintColor = .white
        self.imageView?.contentMode = .scaleAspectFit
        return self
    }
    func createButton(title:String, fontSize: CGFloat, textColor: UIColor = .white) -> UIButton {
        self.setTitle(title, for: .normal)
        self.titleLabel?.font = .systemFont(ofSize: fontSize)
        self.setTitleColor(textColor, for: .normal)
        return self
    }

}
