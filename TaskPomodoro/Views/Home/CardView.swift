//
//  CardView.swift
//  TaskPomodoro
//
//  Created by 小野寺祥吾 on 2021/04/03.
//

import UIKit
import RealmSwift
import AVFoundation
import UserNotifications
protocol TaskProcessDelegate {
    func taskProcess(complete:Bool,id:Int)
}
class CardView:UIView,backgroundTimerDelegate{
    
    let realm = try! Realm()
    var taskProcessDelegate:TaskProcessDelegate?
    var audioPlayer: AVAudioPlayer!
    var pieChartView = PieChartView()
    var timer :Timer!
    var timer_sec: Float = 0    //時間
    //タイマー起動中にバックグラウンドに移行したか
    var timerIsBackground = false
    //バックグランド中に指定時間を過ぎたか true:過ぎた false：過ぎていない
    var tooMuchTimeBackground = false
    
    private var task :TaskData?
    private let gradientLayer = CAGradientLayer()
    private let timeA :Float = 1500.0 //1500秒 = 25分
    private let timeB :Float = 300.0 //300秒 = 5分
    
    //MARK:UIViews
    private let cardImageView = CardImageView(frame:.zero)
    private let titleLabel = CardInfoLabel(labelText: "タイトル", labelFont: .systemFont(ofSize: 40, weight: .heavy))
    private let subTitleLabel  = CardInfoLabel(labelText: "サブタイトル", labelFont: .systemFont(ofSize: 25, weight: .regular))
    private let goodLabel = CardInfoLabel(text: "完了", textColor: UIColor.rgb(red:137,green: 223,blue: 86))
    private let nopeLabel = CardInfoLabel(text: "あとで", textColor: UIColor.rgb(red:222,green: 110,blue: 110))
    private let startStopButton = UIButton(type:.system).createButton(title: "再生",fontSize: 30)
    private let timerLabel = CardInfoLabel(labelText: "00:00", labelFont: .systemFont(ofSize: 40, weight: .heavy))

    
    init(task:TaskData) {
        super.init(frame: .zero)
        setupLayout(task:task)
        setupGradientLayer(colorIndex: task.colorIndex)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panCargView))
        self.addGestureRecognizer(panGesture)//自分自身にpanGestureを設定する
        self.startStopButton.addTarget(self, action: #selector(tapStartStop), for: .touchUpInside)
        self.titleLabel.adjustsFontSizeToFitWidth = true
        self.subTitleLabel.adjustsFontSizeToFitWidth = true
        //SceneDelegateを取得
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let sceneDelegate = windowScene.delegate as? SceneDelegate else {
            return
        }
        sceneDelegate.delegate = self
        
    }
    func checkBackground() {
        //バックグラウンドへの移行を確認
        if let _ = timer {
            timerIsBackground = true
        }
    }
    
    func setCurrentTimer(_ elapsedTime:Int) {
        //バックグラウンドでの経過時間をプラスする(経過時間= elapsedTime)
        timer_sec += Float(elapsedTime)
        guard let task = self.task else {return}
        let timeValue = task.breakFlg == 0 ? timeA :timeB
        if timeValue <= self.timer_sec{
            self.timer_sec = timeValue - 1
            tooMuchTimeBackground = true //バックグランドで指定時間を超えた
        }else{
            tooMuchTimeBackground = false //フォアグラウンドで指定時間を超えた
        }
        //再びタイマーを起動
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer(_:)),userInfo:nil,repeats: true)
        
        //ローカル通知をキャンセル
        resetNotification()
    }
    
    func deleteTimer() {
        //起動中のタイマーを破棄
        if let _ = timer {
            timer.invalidate()
        }
        
        //ローカル通知の設定
        setNotification()
        
    }
    private func resetNotification(){
        guard let task = self.task  else {return}
                    
        //ローカル通知をキャンセル
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])
        //未通知のローカル通知一覧をログに表示
        center.getPendingNotificationRequests { (requests:[UNNotificationRequest]) in
            for request in requests{
                print(request)
            }
        }
    }
    private func setNotification(){
        guard let task = self.task else { return }
        //ローカル通知を設定
        let content = UNMutableNotificationContent()
        content.title = task.title
        content.body = task.content
        content.sound = .default
        

        let date = Date()

        let timeValue = task.breakFlg == 0 ? timeA :timeB
        //残り時間 = (2500秒 or 300秒) - 経過時間
        let timeLeft = timeValue - self.timer_sec
        print(self.timer_sec)
        print(Double(timeLeft))
        let date2 = date.addingTimeInterval(Double(timeLeft)) // ●秒すすめる
                
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year,.month,.day,.hour,.minute,.second], from:date2 )
        let trigger = UNCalendarNotificationTrigger(dateMatching:dateComponents , repeats: false)
        
        //ローカル通知を作成
        let request = UNNotificationRequest(identifier: String(task.id), content: content, trigger: trigger)
        //ローカル通知を登録
        let center = UNUserNotificationCenter.current()
        center.add(request) { (error) in
            print(error ?? "ローカル通知登録成功")
        }
        //未通知のローカル通知一覧をログに表示
        center.getPendingNotificationRequests { (requests:[UNNotificationRequest]) in
            for request in requests{
                print(request)
            }
        }
        
    }
    private func setupGradientLayer(colorIndex:Int){
        let color = CommonConst.gradientColor[colorIndex]
        let color1 = color["startColor"] ?? UIColor.white.cgColor
        let color2 = color["endColor"] ??  UIColor.white.cgColor
        //グラデーション
        gradientLayer.colors = [color1,color2]
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
            
            let timeValue = task.breakFlg == 0 ? timeA :timeB
            if self.timer_sec >= timeValue{
                return
            }
            
            self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer(_:)),userInfo:nil,repeats: true)
            
            self.startStopButton.setTitle("一時停止", for: .normal)
        }else{
            //タイマーを一時停止
            stopTimer()
        }
    }
    @objc private func updateTimer(_ timer:Timer){
        self.timer_sec += 1
        guard let task = self.task else{return}
        //残り秒数  = (25分 or 5分) - 経過秒数
        var timeValue = timeA
        if task.breakFlg == 0{
            //休憩以外
            timeValue = timeA
        }else{
            //5分休憩の場合
            timeValue = timeB
        }
        let timeLeft = timeValue - timer_sec
        let hour = timeLeft / 60
        let minutes = timeLeft.truncatingRemainder(dividingBy: 60.0) //あまり
        self.timerLabel.text = String(format: "%02d", Int(hour)) + " : " + String(format: "%02d", Int(minutes))
        //円を描画
        self.pieChartView.value = CGFloat(timeLeft)
        
        if hour <= 0 && minutes <= 0{
            if tooMuchTimeBackground == false{
                //指定時間をフォアグラウンドで過ぎた場合
                //音を鳴らす
                playSound(name:"complete")
            }

            //タイマーを止める
            stopTimer()
            
            //realmからタスクを取得
            let taskData = try! Realm().objects(TaskData.self).filter("id == %@",task.id)
            //経過時間をrealmに保存
            try! realm.write{
                taskData.first?.time = self.timer_sec
            }
        }

    }
    func stopTimer(){
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
//        contentLabel.anchor(height:80)
        let infoVerticalStackView = UIStackView(arrangedSubviews: [titleLabel,subTitleLabel])
        infoVerticalStackView.axis = .vertical//縦並び
        
            
        let baseStackView = UIStackView(arrangedSubviews: [infoVerticalStackView])
        baseStackView.axis = .horizontal//横並び
        
        //Viewの配置を作成

        addSubview(cardImageView)
        addSubview(pieChartView)
        addSubview(startStopButton)
        addSubview(timerLabel)
        addSubview(baseStackView)
        addSubview(goodLabel)
        addSubview(nopeLabel)
        

        cardImageView.anchor(top:topAnchor,bottom:bottomAnchor,left: leftAnchor,right: rightAnchor,leftPdding: 10,rightPdding: 10)
        pieChartView.anchor(centerY: centerYAnchor,centerX: centerXAnchor,width: 250,height: 250)
        timerLabel.anchor(centerY:centerYAnchor, centerX:centerXAnchor,width: 200,height: 50)
        startStopButton.anchor(top:pieChartView.bottomAnchor, centerX:centerXAnchor,width: 200,height: 100,topPdding: 10)
        baseStackView.anchor(top:cardImageView.topAnchor,left:cardImageView.leftAnchor,right: cardImageView.rightAnchor,topPdding: 60,leftPdding: 20,rightPdding: 20)
        goodLabel.anchor(top:cardImageView.topAnchor,left:cardImageView.leftAnchor,width: 140,height: 55,topPdding: 10 ,leftPdding: 20)
        nopeLabel.anchor(top:cardImageView.topAnchor,right:cardImageView.rightAnchor,width:140,height: 55,topPdding: 10,rightPdding: 20)
        
        //タスク情報をViewに反映
        titleLabel.text = task.title
        subTitleLabel.text = task.content

        //残り秒数  = (25分 or 5分) - 経過秒数
        var timeValue = timeA
        if task.breakFlg == 0{
            //休憩以外
            timeValue = timeA
        }else{
            //5分休憩の場合
            timeValue = timeB
        }
        let timeLeft  = timeValue - task.time
        let hour = timeLeft / 60
        let minutes = timeLeft.truncatingRemainder(dividingBy: 60.0) //あまり
        self.timerLabel.text = String(format: "%02d", Int(hour)) + " : " + String(format: "%02d", Int(minutes))
        //円の表示
        pieChartView.value = CGFloat(timeLeft)
        pieChartView.maxValue = CGFloat(timeValue)
        pieChartView.chartTintColor = CommonConst.gradientColorInverted[task.colorIndex]

        
        //プロパティに設定
        self.task = task
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}


extension CardView :AVAudioPlayerDelegate{
    func playSound(name:String){
        guard let path = Bundle.main.path(forResource: name, ofType: "mp3") else{
            return
        }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            audioPlayer.delegate = self
            audioPlayer.play()
        }catch {
            
        }
    }
}

