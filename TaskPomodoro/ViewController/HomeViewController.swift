//
//  ViewController.swift
//  TaskPomodoro
//
//  Created by 小野寺祥吾 on 2021/04/03.
//

import UIKit

class HomeViewController: UIViewController {

    private var taskArray = [Task]()
    let cardView = UIView()
    let bottomControlView = BottomControlView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getTask()
        setCardInfo()
        bottomControlView.reloadView.button?.addTarget(self, action: #selector(tapReload), for: .touchUpInside)
    }
    private func getTask(){
        //TODO タスク情報を取得
        //TODO あとで修正
        self.taskArray.append(Task(title: "数学", content: "因数分解"))
        self.taskArray.append(Task(title: "英語", content: "現在進行系"))
    }
    private func setCardInfo(){
        self.taskArray.forEach { task in
            let card = CardView(task: task)
            self.cardView.addSubview(card)
            card.anchor(top:self.cardView.topAnchor,bottom: self.cardView.bottomAnchor,left: self.cardView.leftAnchor,right: self.cardView.rightAnchor)
        }
    }
    @objc func tapReload(){
        print("tapReload")
        //TODO
        let taskListController = TaskListViewController()
        let nav = UINavigationController(rootViewController: taskListController)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
    }
    private func setupLayout(){
        view.backgroundColor = .white

        let stackView  = UIStackView(arrangedSubviews: [cardView,bottomControlView])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical //縦
        self.view.addSubview(stackView)

        [
            bottomControlView.heightAnchor.constraint(equalToConstant: 120),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            stackView.leftAnchor.constraint(equalTo: view.leftAnchor),
            stackView.rightAnchor.constraint(equalTo: view.rightAnchor)].forEach {$0.isActive = true}
        
    }

}
