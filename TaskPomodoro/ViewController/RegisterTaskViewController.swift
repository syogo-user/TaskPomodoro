//
//  RegisterTaskViewController.swift
//  TaskPomodoro
//
//  Created by 小野寺祥吾 on 2021/04/05.
//

import UIKit
import RealmSwift
class RegisterTaskViewController:UIViewController{
    
    let realm = try! Realm()    
    var task :TaskData!
    var titleText = ""
    var contentText = ""
    var colorChoiceAfterFlg = false
    var colorArrayIndex = 0
    
    private let titleLabel = RegisterTextLabel(text: "タイトル")
    private let subTitleLabel = RegisterTextLabel(text: "サブタイトル")
    private let titleTextField = RegisterTextField(placeHolder: "タイトル")
    private let subTitleTextField = RegisterTextField(placeHolder: "サブタイトル")
    private let colorChoiceButton = UIButton(type:.system).createButton(title: "背景色変更",fontSize: 18,textColor:CommonConst.lightClearGray)
    private let registerButton = UIButton(type:.system).createButton(title: "更新",fontSize: 25,textColor: CommonConst.lightClearGray)
    private let colorView = RegisterView(colorIndex: 0)
    private var maxWordCount: Int = 50
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.registerButton.addTarget(self, action: #selector(tapRegisterButton), for: .touchUpInside)
        self.colorChoiceButton.addTarget(self, action: #selector(tapColorChoiceButton), for: .touchUpInside)
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tapView))
        self.view.addGestureRecognizer(gesture)
        //戻るの非表示
        self.navigationController?.navigationBar.topItem?.title = ""
        self.navigationItem.title = "更新画面"
        self.navigationController?.navigationBar.isHidden = false
        let addBarButtonItem = UIBarButtonItem(title: "5分休憩", style: UIBarButtonItem.Style.plain, target: self, action: #selector(tapHaveABreak))
        self.navigationItem.rightBarButtonItems = [addBarButtonItem]
        self.navigationController?.navigationBar.tintColor = CommonConst.lightClearGray
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: CommonConst.lightClearGray]
        
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
            self.task.colorIndex = self.colorArrayIndex //グラデーション
            self.realm.add(self.task,update: .modified)
        }
        self.navigationController?.popViewController(animated: true)
        
    }
    private func setLayout(){
        
        titleLabel.anchor(height:50)
        subTitleLabel.anchor(height:50)
        titleTextField.anchor(height:50)
        subTitleTextField.anchor(height:50)
        
        
        colorView.anchor(height:60)
        let horizonStackView = UIStackView(arrangedSubviews: [colorChoiceButton,colorView])
        horizonStackView.axis  = .horizontal
        horizonStackView.spacing = 20
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel,titleTextField,subTitleLabel,subTitleTextField,horizonStackView])
        stackView.axis = .vertical

        stackView.setCustomSpacing(30, after: subTitleTextField)
        view.addSubview(stackView)
        view.addSubview(registerButton)

        // ナビゲーションバーの高さを取得
        let navBarHeight = self.navigationController!.navigationBar.frame.size.height
        stackView.anchor(top:view.topAnchor,left: view.leftAnchor,right: view.rightAnchor,topPdding: navBarHeight + 60 ,leftPdding: 20,rightPdding: 20)
        registerButton.anchor(bottom:view.bottomAnchor,left: view.leftAnchor,right: view.rightAnchor,height: 60,bottomPdding: 50,leftPdding: 80,rightPdding: 80)

        
        if colorChoiceAfterFlg {
            titleTextField.text = titleText
            subTitleTextField.text = contentText
            //グラデーションの設定
            colorView.setGradentColor(colorIndex:self.colorArrayIndex)
        }else{
            titleTextField.text = task.title
            subTitleTextField.text = task.content
            //グラデーションの設定
            colorView.setGradentColor(colorIndex:task.colorIndex)
        }
        
        
        
    }
    @objc private func tapRegisterButton(){
        
        validationCheck()
        
        //登録処理
        try! realm.write{
            self.task.title = self.titleTextField.text ?? ""
            self.task.content = self.subTitleTextField.text ?? ""
            self.task.time = 0
            self.task.breakFlg = 0 //休憩以外
            self.task.colorIndex = self.colorArrayIndex //グラデーション
            self.realm.add(self.task,update: .modified)
        }
        self.navigationController?.popViewController(animated: true)
    }
    @objc private func tapColorChoiceButton(){
        //カラー選択画面に遷移
        let viewController = ColorCollectionViewController()
        viewController.modalPresentationStyle = .fullScreen
        viewController.titleText = self.titleTextField.text ?? ""
        viewController.contentText = self.subTitleTextField.text ?? ""
        self.present(viewController, animated:true, completion: nil)

    }
    private func validationCheck(){
        if self.titleTextField.text == ""{
            //メッセージを表示
            let dialog = UIAlertController(title: "タイトルを入力してください", message: "", preferredStyle: .alert)
            dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(dialog, animated: true, completion: nil)
            return
        }
        if self.titleTextField.text?.count ?? 0 > 12{
            let dialog = UIAlertController(title: "タイトルは12文字までです", message: "", preferredStyle: .alert)
            dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(dialog, animated: true, completion: nil)
            return
        }
        if self.subTitleTextField.text?.count ?? 0 > 20{
            let dialog = UIAlertController(title: "サブタイトルは20文字までです", message: "", preferredStyle: .alert)
            dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(dialog, animated: true, completion: nil)
            return
        }
    }
    
}

