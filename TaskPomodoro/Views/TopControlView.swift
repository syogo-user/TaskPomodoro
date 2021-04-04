////
////  TopControlView.swift
////  TaskPomodoro
////
////  Created by 小野寺祥吾 on 2021/04/03.
////
//
//import UIKit
//class TopControlView:UIView{
//
////    private let disposeBag  = DisposeBag()
//    let tinderButton:UIButton = createTopButton(imageName: "fire_selected",unselectedImage: "fire")
//    let goodButton:UIButton = createTopButton(imageName: "daiya_selected",unselectedImage: "daiya")
//    let commentButton:UIButton = createTopButton(imageName: "comment_selected",unselectedImage: "comment")
//    let profileButton:UIButton = createTopButton(imageName: "myIcon_selected",unselectedImage: "myIcon")
//
//    static func createTopButton(imageName :String,unselectedImage:String) -> UIButton {
//        let button = UIButton(type: .custom)
//        button.setImage(UIImage(named: imageName),for: .selected)
//        button.setImage(UIImage(named: unselectedImage),for: .normal)
//
//        button.imageView?.contentMode = .scaleAspectFit
//        return button
//    }
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//
//        setupLayout()
//        setupBindings()
//    }
//
//    private func setupLayout(){
//        let baseStackView = UIStackView(arrangedSubviews: [tinderButton,goodButton,commentButton,profileButton])
//        baseStackView.axis = .horizontal //横
//        baseStackView.distribution   = .fillEqually
//        baseStackView.spacing = 43
//        baseStackView.translatesAutoresizingMaskIntoConstraints = false
//
//        addSubview(baseStackView)
//
//        baseStackView.anchor(top:topAnchor,bottom: bottomAnchor,left: leftAnchor,right: rightAnchor,leftPdding: 40,rightPdding: 40)
//
//        tinderButton.isSelected = true
//    }
//
//    private func setupBindings(){
////        //Rx
////        tinderButton.rx.tap
////            .asDriver()
////            .drive(onNext: { [weak self] _  in
////                guard let self = self else{return}
////                self.handleSelectedButton(selectedButton: self.tinderButton)
////            }).disposed(by:disposeBag)
////
////        goodButton.rx.tap
////            .asDriver()
////            .drive(onNext: { [weak self] _  in
////                guard let self = self else{return}
////                self.handleSelectedButton(selectedButton: self.goodButton)
////            }).disposed(by:disposeBag)
////
////        commentButton.rx.tap
////            .asDriver()
////            .drive(onNext: { [weak self] _  in
////                guard let self = self else{return}
////                self.handleSelectedButton(selectedButton: self.commentButton)
////            }).disposed(by:disposeBag)
////
////        profileButton.rx.tap
////            .asDriver()
////            .drive(onNext: { [weak self] _  in
////                guard let self = self else{return}
////                self.handleSelectedButton(selectedButton: self.profileButton)
////            }).disposed(by:disposeBag)
//    }
//    private func handleSelectedButton(selectedButton:UIButton){
//        //引数のselectedButtonはタップされたボタン(タップされたときのこのメソッドを呼ぶようにしているから)
//
//        let buttons = [tinderButton,goodButton,commentButton,profileButton]
//        buttons.forEach{
//            button in
//            if button == selectedButton {
//                //selectedButton=タップされたボタン
//                button.isSelected = true //trueにするとselectedの状態のボタンが表示される
//            }else{
//                button.isSelected = false
//            }
//        }
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//
//}
