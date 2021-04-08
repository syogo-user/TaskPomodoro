//
//  ViewController.swift
//  TaskPomodoro
//
//  Created by 小野寺祥吾 on 2021/04/03.
//

import UIKit
import RealmSwift
class HomeViewController: UIViewController {

    let realm = try! Realm()
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
    //カードがすでにviewに存在する場合、一度クリアする
    private func removeCardInfo(){
        self.removeAllSubviews(parentView: cardView)
    }
    private func setCardInfo(){
        self.taskDataArray.reversed().forEach { task in
            let card = CardView(task: task)
            card.taskProcessDelegate = self//デリゲート
            
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
        let subviews = parentView.subviews
        for subview in subviews {
            subview.removeFromSuperview()
        }
    }
}
extension HomeViewController:TaskProcessDelegate{
    //カードが消えるときの動作
    func taskProcess(complete: Bool,id:Int) {
        if complete{
            //完了の場合
            completeProcess(id:id)
        }else {
            //あとでの場合
            //一番うしろに並び替え
            sortTask(id:id)
        }
    }
    
    //「あとで」の処理
    private func sortTask(id:Int){
        
        var arrayIndex = 0 //選択したカードの配列のインデックスを設定する変数
        let lastIndex = taskDataArray.count - 1
        
        //idから配列のindexを取得
        for (index,task) in taskDataArray.enumerated(){
            if task.id == id{
                arrayIndex = index
            }
        }
        //並び替え処理
        try! realm.write {
            let sourceObject = taskDataArray[arrayIndex]
            let destinationObject = taskDataArray[lastIndex]
            let destinationObjectOrder = destinationObject.orderNo
            
            // 間の項目の並び替え用のorderNoを-1シフト
            for index in arrayIndex...lastIndex {
                let object = taskDataArray[index]
                object.orderNo -= 1
            }
            // 移動したセルの並びを移動先に更新
            sourceObject.orderNo = destinationObjectOrder
            
            
            //再描画
            removeCardInfo()
            setCardInfo()
        }
    }
    
    //「完了」の処理
    private func completeProcess(id:Int){
        var arrayIndex = 0 //選択したカードの配列のインデックスを設定する変数
        //idから配列のindexを取得
        for (index,task) in taskDataArray.enumerated(){
            if task.id == id{
                arrayIndex = index
            }
        }
        //一旦削除処理として作る
//        TODO あとで別の配列に入れる処理に変更する
        try! realm.write{
            self.realm.delete(self.taskDataArray[arrayIndex])
        }
    }
}
