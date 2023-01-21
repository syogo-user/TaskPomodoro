//
//  RegisterView.swift
//  TaskPomodoro
//
//  Created by 小野寺祥吾 on 2021/04/19.
//
import UIKit

class RegisterView: UIView {
    private let gradientLayer = CAGradientLayer()
    
    init(colorIndex: Int = 0) {
        super.init(frame: CGRect.zero)
        self.setGradentColor(colorIndex: colorIndex)
    }
    
    override func layoutSubviews() {
        //viewが生成されて大きさがわかった段階でここが呼ばれる
        gradientLayer.frame = self.bounds
    }
    
    func setGradentColor(colorIndex: Int) {
        let color = CommonConst.gradientColor[colorIndex]
        let color1 = color["startColor"] ?? UIColor.white.cgColor
        let color2 = color["endColor"] ??  UIColor.white.cgColor
        //グラデーション
        gradientLayer.colors = [color1, color2]
        //グラデーションの位置
        gradientLayer.locations = [0.3, 1.1]
        self.layer.addSublayer(gradientLayer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
