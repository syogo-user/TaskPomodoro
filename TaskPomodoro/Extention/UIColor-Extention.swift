//
//  UIColor-Extention.swift
//  TaskPomodoro
//
//  Created by 小野寺祥吾 on 2021/04/03.
//

import UIKit
extension  UIColor{
    static func rgb(red:CGFloat,green:CGFloat,blue:CGFloat,alpha:CGFloat = 1 ) -> UIColor {
        return .init(red: red/255, green: green/255, blue: blue/255, alpha: alpha)
    }
}
