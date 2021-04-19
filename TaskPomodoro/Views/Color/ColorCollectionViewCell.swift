//
//  ColorCollectionViewCell.swift
//  TaskPomodoro
//
//  Created by 小野寺祥吾 on 2021/04/19.
//

import UIKit

class ColorCollectionViewCell:UICollectionViewCell{
    let gradientLayer = CAGradientLayer()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
    }
    override func layoutSubviews() {
        gradientLayer.frame = self.bounds
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setGradientColor(colorIndex:Int){
        let color = CommonConst.gradientColor[colorIndex]
        let color1 = color["startColor"] ?? UIColor.black.cgColor
        let color2 = color["endColor"] ?? UIColor.black.cgColor
        gradientLayer.colors = [color1,color2]
        //グラデーションの位置
        gradientLayer.locations = [0.3,1.1]
        self.layer.addSublayer(gradientLayer)
    }
}
