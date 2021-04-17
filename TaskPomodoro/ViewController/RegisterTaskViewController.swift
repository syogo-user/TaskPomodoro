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
    
    private let titleLabel = RegisterTextLabel(text: "タイトル")
    private let contentLabel = RegisterTextLabel(text: "内容")
    private let titleTextField = RegisterTextField(placeHolder: "タイトル")
    private let contentTextField = RegisterTextField(placeHolder: "内容")
    private let colorChoiceButton = UIButton(type:.system).createButton(title: "カラー選択",fontSize: 25,textColor:UIColor.darkGray)
    private let registerButton = UIButton(type:.system).createButton(title: "更新",fontSize: 25,textColor: UIColor.darkGray)
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setLayout()
        registerButton.addTarget(self, action: #selector(tapRegisterButton), for: .touchUpInside)
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tapView))
        view.addGestureRecognizer(gesture)
        self.navigationController?.navigationBar.isHidden = false
        //戻るの非表示
        self.navigationController?.navigationBar.topItem?.title = ""
        let addBarButtonItem = UIBarButtonItem(title: "5分休憩", style: UIBarButtonItem.Style.plain, target: self, action: #selector(tapHaveABreak))
        navigationItem.rightBarButtonItems = [addBarButtonItem]
        
        
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
        contentTextField.anchor(height:100)
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel,titleTextField,contentLabel,contentTextField])
        stackView.axis = .vertical
        view.addSubview(stackView)
        view.addSubview(registerButton)
        
        // ナビゲーションバーの高さを取得
        let navBarHeight = self.navigationController!.navigationBar.frame.size.height
        stackView.anchor(top:view.topAnchor,left: view.leftAnchor,right: view.rightAnchor,topPdding: navBarHeight + 60 ,leftPdding: 20,rightPdding: 20)
        registerButton.anchor(bottom:view.bottomAnchor,left: view.leftAnchor,right: view.rightAnchor,height: 60,bottomPdding: 50,leftPdding: 80,rightPdding: 80)
        
        titleTextField.text = task.title
        contentTextField.text = task.content
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
            self.task.content = self.contentTextField.text ?? ""
            self.task.time = 0
            self.task.breakFlg = 0 //休憩以外
            self.realm.add(self.task,update: .modified)
        }
        self.navigationController?.popViewController(animated: true)
    }
    
}
