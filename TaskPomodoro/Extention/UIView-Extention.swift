//
//  UIView-Extention.swift
//  TaskPomodoro
//
//  Created by 小野寺祥吾 on 2021/04/03.
//

import UIKit
extension UIView{
    func anchor(
        top:NSLayoutYAxisAnchor? = nil,
        bottom:NSLayoutYAxisAnchor? = nil,
        left:NSLayoutXAxisAnchor? = nil,
        right:NSLayoutXAxisAnchor? = nil,
        centerY:NSLayoutYAxisAnchor? = nil,
        centerX:NSLayoutXAxisAnchor? = nil,
        width:CGFloat? = nil,
        height:CGFloat? = nil,
        topPdding:CGFloat = 0,
        bottomPdding:CGFloat = 0,
        leftPdding:CGFloat = 0,
        rightPdding:CGFloat = 0){
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        //topのデフォルト値をnilにする 　topPaddingのでデフォルト値を0にする
        if let top = top {
            //UIViewのtopと引数で受け取ったtopで距離をtopPaddingで設定
            self.topAnchor.constraint(equalTo: top, constant: topPdding).isActive = true
        }
        if let bottom = bottom {
            self.bottomAnchor.constraint(equalTo: bottom, constant: -bottomPdding).isActive = true
        }
        if let left = left {

            self.leftAnchor.constraint(equalTo: left, constant: leftPdding).isActive = true
        }
        if let right = right  {

            self.rightAnchor.constraint(equalTo: right, constant: -rightPdding).isActive = true
        }
        if let centerY = centerY {

            self.centerYAnchor.constraint(equalTo: centerY).isActive = true
        }
        if let centerX = centerX {

            self.centerXAnchor.constraint(equalTo: centerX).isActive = true
        }
        if let width = width {

            self.widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        if let height = height {

            self.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
}

//MARK:Animations
extension UIView{
    func removeCardViewAnimation(x:CGFloat){
        //消える動作
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.7, options:[]) {
            let degree : CGFloat = x / 40
            let angle = degree * .pi / 180  //回転
            let rotateTranslation = CGAffineTransform(rotationAngle: angle)
            self.transform = rotateTranslation.translatedBy(x: x, y: 100)
            
            self.layoutIfNeeded()
        } completion: { _ in
            self.removeFromSuperview()
        }
    }
}

