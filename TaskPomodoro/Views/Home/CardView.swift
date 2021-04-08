//
//  CardView.swift
//  TaskPomodoro
//
//  Created by 小野寺祥吾 on 2021/04/03.
//

import UIKit
import RealmSwift
protocol TaskProcessDelegate {
    func taskProcess(complete:Bool,id:Int)
}
class CardView:UIView{

    var taskProcessDelegate:TaskProcessDelegate?
    
    let realm = try! Realm()
    
    private var task :TaskData?
    private let gradientLayer = CAGradientLayer()
    
    //MARK:UIViews
    private let cardImageView = CardImageView(frame:
                                                .zero)
    private let infoButton = UIButton(type:.system).createCardInfoButton()
    
    private let titleLabel = CardInfoLabel(labelText: "Taro  22", labelFont: .systemFont(ofSize: 40, weight: .heavy))
    private let residenceLabel = CardInfoLabel(labelText: "日本、大阪", labelFont: .systemFont(ofSize: 20, weight: .regular))
    
    private let hobbyLabel = CardInfoLabel(labelText: "ランニング",labelFont: .systemFont(ofSize: 25, weight: .regular))
    
    private let contentLabel  = CardInfoLabel(labelText: "走り回るのが大好きです。", labelFont: .systemFont(ofSize: 25, weight: .regular))

    private let goodLabel = CardInfoLabel(text: "完了", textColor: UIColor.rgb(red:137,green: 223,blue: 86))

    private let nopeLabel = CardInfoLabel(text: "あとで", textColor: UIColor.rgb(red:222,green: 110,blue: 110))
    
    private let startStopButton = UIButton(type:.system).createStartStopButton(title: "再生")
    
    private let timerLabel = CardInfoLabel(labelText: "00:00", labelFont: .systemFont(ofSize: 40, weight: .heavy))
    
    var timer :Timer!
    //時間
    var timer_sec: Float = 0
            
    init(task:TaskData) {
        super.init(frame: .zero)
        setupLayout(task:task)
        setupGradientLayer()
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panCargView))
        self.addGestureRecognizer(panGesture)//自分自身にpanGestureを設定する
        
        startStopButton.addTarget(self, action: #selector(tapStartStop), for: .touchUpInside)
        
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
    @objc private func tapStartStop(){
        guard let task = self.task else{return}

        
        //スタートかストップかを分岐する
        if self.timer == nil{
            //realmからタスクを取得
            let taskData = try! Realm().objects(TaskData.self).filter("id == %@",task.id)
            //タイマーを作成する
            //realmから取得した時間をプロパティに設定
            self.timer_sec = taskData.first?.time ?? 0
            
            self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer(_:)),userInfo:nil,repeats: true)
            self.startStopButton.setTitle("一時停止", for: .normal)
        }else{
            //タイマーを一時停止
            stopTimer()
        }
    }
    @objc private func updateTimer(_ timer:Timer){
        self.timer_sec += 1
        //残り秒数(25分 - 経過秒数)
        let timeLeft = 1500 - timer_sec
        let hour = timeLeft / 60
        let minutes = timeLeft.truncatingRemainder(dividingBy: 60.0) //あまり
        self.timerLabel.text = String(format: "%02d", Int(hour)) + " : " + String(format: "%02d", Int(minutes))
    }
    private func stopTimer(){
        guard let task = self.task else{return}
        if self.timer != nil{
            //realmからタスクを取得
            let taskData = try! Realm().objects(TaskData.self).filter("id == %@",task.id)
            
            //タイマーを一時停止する
            self.timer.invalidate()
            self.timer = nil
            self.startStopButton.setTitle("再生", for: .normal)
            //経過時間をrealmに保存
            try! realm.write{
                taskData.first?.time = self.timer_sec
            }
        }
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
        guard let task = self.task else{return}
        
        if translation.x <= -120 {
            //消える動作
            view.removeCardViewAnimation(x: -600)
            //タイマー一時停止
            stopTimer()
            
            taskProcessDelegate?.taskProcess(complete:false,id:task.id ) //あとで （一番うしろに並び替える）
        }else if translation.x >= 120{
            //消える動作
            view.removeCardViewAnimation(x: 600)
            //タイマー一時停止
            stopTimer()
            taskProcessDelegate?.taskProcess(complete:true,id: task.id) //完了 (完了タスクに追加)
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
        addSubview(startStopButton)
        addSubview(timerLabel)
        addSubview(baseStackView)
        addSubview(goodLabel)
        addSubview(nopeLabel)

        cardImageView.anchor(top:topAnchor,bottom:bottomAnchor,left: leftAnchor,right: rightAnchor,leftPdding: 10,rightPdding: 10)
        infoButton.anchor(width:40)
        startStopButton.anchor(centerY: self.centerYAnchor, centerX:self.centerXAnchor,width: 200,height: 100)
        timerLabel.anchor(bottom:startStopButton.topAnchor,centerX:self.centerXAnchor, width: 200, height: 50, bottomPdding: 10)
        baseStackView.anchor(bottom:cardImageView.bottomAnchor,left:cardImageView.leftAnchor,right: cardImageView.rightAnchor,bottomPdding: 20,leftPdding: 20,rightPdding: 20)
        titleLabel.anchor(bottom:baseStackView.topAnchor,left:cardImageView.leftAnchor,bottomPdding: 10,leftPdding: 20)
        
        goodLabel.anchor(top:cardImageView.topAnchor,left:cardImageView.leftAnchor,width: 140,height: 55,topPdding: 25 ,leftPdding: 20)
        nopeLabel.anchor(top:cardImageView.topAnchor,right:cardImageView.rightAnchor,width:140,height: 55,topPdding: 25,rightPdding: 20)
        
        //タスク情報をViewに反映
        titleLabel.text = task.title
        contentLabel.text = task.content
        
        //残り秒数(25分 - 経過秒数)
        let timeLeft = 1500 - task.time
        let hour = timeLeft / 60
        let minutes = timeLeft.truncatingRemainder(dividingBy: 60.0) //あまり
        self.timerLabel.text = String(format: "%02d", Int(hour)) + " : " + String(format: "%02d", Int(minutes))
        //プロパティに設定
        self.task = task
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

