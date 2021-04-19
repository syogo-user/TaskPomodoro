//
//  RegisterTaskViewController.swift
//  TaskPomodoro
//
//  Created by 小野寺祥吾 on 2021/04/05.
//

import UIKit
import RealmSwift
class RegisterTaskViewController:UIViewController{
    
    var colorArrayIndex = 0
    let realm = try! Realm()
    var task :TaskData!
    
    private let titleLabel = RegisterTextLabel(text: "タイトル")
    private let contentLabel = RegisterTextLabel(text: "内容")
    private let titleTextField = RegisterTextField(placeHolder: "タイトル")
    private let contentTextView = RegisterTextView(text:"内容")
    
    private let colorChoiceButton = UIButton(type:.system).createButton(title: "背景色",fontSize: 25,textColor:CommonConst.color1)
    private let registerButton = UIButton(type:.system).createButton(title: "更新",fontSize: 25,textColor: CommonConst.color1)
    private let colorView = RegisterView(colorIndex: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        registerButton.addTarget(self, action: #selector(tapRegisterButton), for: .touchUpInside)
        colorChoiceButton.addTarget(self, action: #selector(tapColorChoiceButton), for: .touchUpInside)
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tapView))
        view.addGestureRecognizer(gesture)
        self.navigationController?.navigationBar.isHidden = false
        //戻るの非表示
        self.navigationController?.navigationBar.topItem?.title = ""
        let addBarButtonItem = UIBarButtonItem(title: "5分休憩", style: UIBarButtonItem.Style.plain, target: self, action: #selector(tapHaveABreak))
        navigationItem.rightBarButtonItems = [addBarButtonItem]
        self.navigationController?.navigationBar.tintColor = CommonConst.color1
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: CommonConst.color1]
        self.navigationItem.title = "更新画面"
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setLayout()
    }
    @objc private func tapView(){
        view.endEditing(true)
    }
    @objc private func tapHaveABreak(){
        //5分休憩設定
        try! realm.write{
            self.task.title = "休憩"
            self.task.content = "Have A Break"
            self.task.time = 0
            self.task.breakFlg = 1 //休憩
            self.realm.add(self.task,update: .modified)
        }
        self.navigationController?.popViewController(animated: true)
        
    }
    private func setLayout(){
        
        titleLabel.anchor(height:50)
        contentLabel.anchor(height:50)
        titleTextField.anchor(height:50)
        contentTextView.anchor(height:100)
        
        
        let horizonStackView = UIStackView(arrangedSubviews: [colorView,colorChoiceButton])
        horizonStackView.axis  = .horizontal
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel,titleTextField,contentLabel,contentTextView,horizonStackView])
        stackView.axis = .vertical
        view.addSubview(stackView)
        view.addSubview(registerButton)

        // ナビゲーションバーの高さを取得
        let navBarHeight = self.navigationController!.navigationBar.frame.size.height
        stackView.anchor(top:view.topAnchor,left: view.leftAnchor,right: view.rightAnchor,topPdding: navBarHeight + 60 ,leftPdding: 20,rightPdding: 20)
        registerButton.anchor(bottom:view.bottomAnchor,left: view.leftAnchor,right: view.rightAnchor,height: 60,bottomPdding: 50,leftPdding: 80,rightPdding: 80)

        titleTextField.text = task.title
        contentTextView.text = task.content
        //グラデーションの設定 
        colorView.setGradentColor(colorIndex:self.colorArrayIndex)
    }
    @objc private func tapRegisterButton(){
        
        if self.titleTextField.text == ""{
            //メッセージを表示
            let dialog = UIAlertController(title: "タイトルを入力してください", message: "", preferredStyle: .alert)
            dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(dialog, animated: true, completion: nil)
            return
        }
        //登録処理
        try! realm.write{
            self.task.title = self.titleTextField.text ?? ""
            self.task.content = self.contentTextView.text ?? ""
            self.task.time = 0
            self.task.breakFlg = 0 //休憩以外
            self.realm.add(self.task,update: .modified)
        }
        self.navigationController?.popViewController(animated: true)
    }
    @objc private func tapColorChoiceButton(){
        //カラー選択画面に遷移
        let viewController = ColorCollectionViewController()
        viewController.modalPresentationStyle = .fullScreen
//        navigationController?.pushViewController(viewController, animated: true)
        self.present(viewController, animated:true, completion: nil)

    }
    
}
