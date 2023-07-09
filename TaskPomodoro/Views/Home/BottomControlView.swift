//
//  BottomControlView.swift
//  TaskPomodoro
//
//  Created by 小野寺祥吾 on 2021/04/03.
//

import UIKit

class BottomControlView: UIView {
    let list = BottomButtonView(frame: .zero, width: 65, imageName: "list")
    let addView = BottomButtonView(frame: .zero, width: 65, imageName: "add")
    let deleteView = BottomButtonView(frame: .zero, width: 65, imageName: "delete")
    let resetView = BottomButtonView(frame: .zero, width: 65, imageName: "reset")

    override init(frame: CGRect) {
        super.init(frame:frame)
        let baseStackView = UIStackView(arrangedSubviews: [list, addView, deleteView, resetView])
        baseStackView.axis = .horizontal //横
        baseStackView.distribution   = .fillEqually
        baseStackView.spacing = 10
        baseStackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(baseStackView)
        [
            baseStackView.topAnchor.constraint(equalTo: topAnchor),
            baseStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            baseStackView.leftAnchor.constraint(equalTo: leftAnchor, constant: 10),
            baseStackView.rightAnchor.constraint(equalTo: rightAnchor, constant: -10),

        ].forEach {$0.isActive = true}
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class BottomButtonView: UIView{
    var button: BottomButton?
    
    init(frame: CGRect, width: CGFloat,imageName: String) {
        super.init(frame: frame)
        
        button = BottomButton(type: .custom)
        button?.setImage(UIImage(named: imageName)?.resize(size: .init(width: width * 0.4, height: width * 0.4)) , for: .normal)
        button?.translatesAutoresizingMaskIntoConstraints = false
        button?.backgroundColor = .white
        button?.layer.cornerRadius = width / 2
        button?.layer.shadowOffset = .init(width: 1.5, height: 2)
        button?.layer.shadowColor = UIColor.black.cgColor
        button?.layer.shadowOpacity = 0.3
        button?.layer.shadowRadius = 15
        
        addSubview(button!)
        button?.anchor(centerY: centerYAnchor, centerX: centerXAnchor, width: width, height: width)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class BottomButton: UIButton{
    override var isHighlighted: Bool{
        didSet {
            if isHighlighted {
                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: []) {
                    // 大きさを0.8倍にする
                    self.transform = .init(scaleX: 0.8, y: 0.8)
                    self.layoutIfNeeded()
                }

            } else {
                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: []) {
                    // 元の大きさに戻す
                    self.transform = .identity
                    self.layoutIfNeeded()
                }
            }
            
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
