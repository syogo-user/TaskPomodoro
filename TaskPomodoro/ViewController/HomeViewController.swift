//
//  ViewController.swift
//  TaskPomodoro
//
//  Created by 小野寺祥吾 on 2021/04/03.
//

import UIKit
import RealmSwift
class HomeViewController: UIViewController {

    var taskDataArray = try! Realm().objects(TaskData.self).sorted(byKeyPath: "orderNo", ascending: true) 
    let cardView = UIView()
    let bottomControlView = BottomControlView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        removeCardInfo()
        setCardInfo()
        bottomControlView.reloadView.button?.addTarget(self, action: #selector(tapReload), for: .touchUpInside)
    }
    //TODO カードがすでにviewに存在する場合、一度クリアする
    private func removeCardInfo(){
        self.removeAllSubviews(parentView: cardView)
    }
    private func setCardInfo(){
        self.taskDataArray.forEach { task in
            let card = CardView(task: task)
            self.cardView.addSubview(card)
            card.anchor(top:self.cardView.topAnchor,bottom: self.cardView.bottomAnchor,left: self.cardView.leftAnchor,right: self.cardView.rightAnchor)
        }
    }
    @objc func tapReload(){
        let taskListController = TaskListViewController()
        self.navigationController?.pushViewController(taskListController, animated: true)
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
    func removeAllSubviews(parentView: UIView){
        var subviews = parentView.subviews
        for subview in subviews {
            subview.removeFromSuperview()
        }
    }
}

