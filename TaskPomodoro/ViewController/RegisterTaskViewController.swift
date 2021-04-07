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
    private let registerButton = UIButton(type:.system).createRegisterButton(title: "更新")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setLayout()
        registerButton.addTarget(self, action: #selector(tapRegisterButton), for: .touchUpInside)
    }
    
    private func setLayout(){
        
        titleLabel.anchor(height:50)
        contentLabel.anchor(height:50)
        titleTextField.anchor(height:50)
        contentTextField.anchor(height:100)
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel,titleTextField,contentLabel,contentTextField])
        stackView.axis = .vertical
        stackView.backgroundColor = .brown
        view.addSubview(stackView)
        view.addSubview(registerButton)
        
        stackView.anchor(top:view.topAnchor,left: view.leftAnchor,right: view.rightAnchor,topPdding: 160,leftPdding: 20,rightPdding: 20)
        registerButton.anchor(bottom:view.bottomAnchor,left: view.leftAnchor,right: view.rightAnchor,height: 60,bottomPdding: 50,leftPdding: 80,rightPdding: 80)
    }
    @objc private func tapRegisterButton(){
        //登録処理
        try! realm.write{
            self.task.title = self.titleTextField.text ?? ""
            self.task.content = self.contentTextField.text ?? ""
            self.realm.add(self.task,update: .modified)
        }
        self.navigationController?.popViewController(animated: true)
    }
    
}
