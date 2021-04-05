//
//  CardView.swift
//  TaskPomodoro
//
//  Created by 小野寺祥吾 on 2021/04/03.
//

import UIKit
class CardView:UIView{
    
    private let gradientLayer = CAGradientLayer()
    
    //MARK:UIViews
    private let cardImageView = CardImageView(frame:
                                                .zero)
    private let infoButton = UIButton(type:.system).createCardInfoButton()
    
    private let titleLabel = CardInfoLabel(labelText: "Taro  22", labelFont: .systemFont(ofSize: 40, weight: .heavy))
    private let residenceLabel = CardInfoLabel(labelText: "日本、大阪", labelFont: .systemFont(ofSize: 20, weight: .regular))
    
    private let hobbyLabel = CardInfoLabel(labelText: "ランニング",labelFont: .systemFont(ofSize: 25, weight: .regular))
    
    private let contentLabel  = CardInfoLabel(labelText: "走り回るのが大好きです。", labelFont: .systemFont(ofSize: 25, weight: .regular))

    private let goodLabel = CardInfoLabel(text: "GOOD", textColor: UIColor.rgb(red:137,green: 223,blue: 86))

    private let nopeLabel = CardInfoLabel(text: "NOPE", textColor: UIColor.rgb(red:222,green: 110,blue: 110))
    
    init(task:TaskData) {
        super.init(frame: .zero)
        setupLayout(task:task)
        setupGradientLayer()
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panCargView))
        self.addGestureRecognizer(panGesture)//自分自身にpanGestureを設定する
        
    }
    private func setupGradientLayer(){
        //グラデーション
        gradientLayer.colors = [CommonConst.color2.cgColor,CommonConst.color3.cgColor]
        //グラデーションの位置
        gradientLayer.locations = [0.3,1.1]
        cardImageView.layer.addSublayer(gradientLayer)
    }
    
    
    override func layoutSubviews() {
        //viewが生成されて大きさがわかった段階でここが呼ばれる
        gradientLayer.frame = self.bounds
    }
    @objc private func panCargView(gesture:UIPanGestureRecognizer){
        let translation = gesture.translation(in: self)
        guard let view = gesture.view else { return}
        
        if gesture.state == .changed{
            //動かしているとき
            self.handlePanChange(translation: translation)
        }else if gesture.state == .ended{
            self.handlePnaEnded(view:view,translation:translation)
        }
    }
    private func handlePanChange(translation:CGPoint){
        //カードの動き
        let degree : CGFloat = translation.x / 20
        let angle = degree * .pi / 100  //回転
        let rotateTranslation = CGAffineTransform(rotationAngle: angle)
        self.transform = rotateTranslation.translatedBy(x: translation.x, y: translation.y)
        
        let ratio :CGFloat = 1 / 100
        let ratioValue = ratio * translation.x
        if translation.x > 0 {
            //右側に移動しているとき
            self.goodLabel.alpha = ratioValue
        } else if translation.x < 0{
            //左側に移動しているとき
            self.nopeLabel.alpha = -ratioValue
        }
        
    }
    private func handlePnaEnded(view:UIView,translation:CGPoint){
        print("translation.x:",translation.x)
        if translation.x <= -120 {
            //消える動作
            view.removeCardViewAnimation(x: -600)
        }else if translation.x >= 120{
            //消える動作
            view.removeCardViewAnimation(x: 600)
        }else {
            //カードのもとに戻る動き
            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.7, options: []) {
                self.transform = .identity //もとの位置に戻す
                self.layoutIfNeeded()
                self.goodLabel.alpha = 0
                self.nopeLabel.alpha = 0
            }
        }
    }

    private func setupLayout(task:TaskData){
        let infoVerticalStackView = UIStackView(arrangedSubviews: [residenceLabel,hobbyLabel,contentLabel])
        infoVerticalStackView.axis = .vertical//縦並び
        
            
        let baseStackView = UIStackView(arrangedSubviews: [infoVerticalStackView ,infoButton])
        baseStackView.axis = .horizontal//横並び
        
        
        //Viewの配置を作成
        addSubview(cardImageView)
        addSubview(titleLabel)
        addSubview(baseStackView)
        addSubview(goodLabel)
        addSubview(nopeLabel)
        
        cardImageView.anchor(top:topAnchor,bottom:bottomAnchor,left: leftAnchor,right: rightAnchor,leftPdding: 10,rightPdding: 10)
        infoButton.anchor(width:40)
        baseStackView.anchor(bottom:cardImageView.bottomAnchor,left:cardImageView.leftAnchor,right: cardImageView.rightAnchor,bottomPdding: 20,leftPdding: 20,rightPdding: 20)
        titleLabel.anchor(bottom:baseStackView.topAnchor,left:cardImageView.leftAnchor,bottomPdding: 10,leftPdding: 20)
        
        goodLabel.anchor(top:cardImageView.topAnchor,left:cardImageView.leftAnchor,width: 140,height: 55,topPdding: 25 ,leftPdding: 20)
        nopeLabel.anchor(top:cardImageView.topAnchor,right:cardImageView.rightAnchor,width:140,height: 55,topPdding: 25,rightPdding: 20)
        
        //タスク情報をViewに反映
        titleLabel.text = task.title
        contentLabel.text = task.content
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

