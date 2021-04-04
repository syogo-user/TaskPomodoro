//
//  BottomControlView.swift
//  TaskPomodoro
//
//  Created by 小野寺祥吾 on 2021/04/03.
//

import UIKit
class BottomControlView: UIView {

    let reloadView = BottomButtonView(frame: .zero, width: 50,imageName: "reload")
    let nopeView = BottomButtonView(frame: .zero, width: 60,imageName: "nope")
    let starView = BottomButtonView(frame: .zero, width: 50,imageName: "star")
    let heartView = BottomButtonView(frame: .zero, width: 60,imageName: "heart")
    let thunderView = BottomButtonView(frame: .zero, width: 50,imageName: "thunder")

    override init(frame:CGRect){
        super.init(frame:frame)
        let baseStackView = UIStackView(arrangedSubviews: [reloadView,nopeView,starView,heartView,heartView,thunderView])
        baseStackView.axis = .horizontal //横
        baseStackView.distribution   = .fillEqually
        baseStackView.spacing = 10
        baseStackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(baseStackView)
        [
            baseStackView.topAnchor.constraint(equalTo: topAnchor),
            baseStackView.bottomAnchor.constraint(equalTo:bottomAnchor),
            baseStackView.leftAnchor.constraint(equalTo: leftAnchor,constant:10),
            baseStackView.rightAnchor.constraint(equalTo: rightAnchor ,constant: -10),

        ].forEach {$0.isActive = true}
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class BottomButtonView:UIView{
    //5つある丸いボタンのクラス
    
    var button: BottomButton?
    
    init(frame: CGRect,width:CGFloat,imageName:String) {
        super.init(frame: frame)
        
        button = BottomButton(type:.custom)//customで画像オリジナルの色が表示できる
        button?.setImage(UIImage(named: imageName)?.resize(size: .init(width: width * 0.4, height: width * 0.4)) , for: .normal)
        button?.translatesAutoresizingMaskIntoConstraints = false
        button?.backgroundColor = .white
        
        button?.layer.cornerRadius = width / 2
        button?.layer.shadowOffset = .init(width: 1.5, height: 2)
        button?.layer.shadowColor = UIColor.black.cgColor
        button?.layer.shadowOpacity = 0.3
        button?.layer.shadowRadius = 15
        
        addSubview(button!)
        button?.anchor(centerY:centerYAnchor,centerX: centerXAnchor,width: width,height:width)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class BottomButton:UIButton{
    override var isHighlighted: Bool{
        didSet{
            if isHighlighted {
                //ハイライトのとき(タップしている瞬間)
                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: []) {
                    self.transform = .init(scaleX: 0.8, y: 0.8) //大きさを0.8倍にしてくれる　アニメーション付き
                    self.layoutIfNeeded()
                }

            }else {
                //ハイライトじゃないとき(タップしていないとき)
                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: []) {
                    self.transform = .identity //元のおおきさに戻る
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
