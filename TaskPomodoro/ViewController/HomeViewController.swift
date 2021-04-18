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
    var taskDataArray = try! Realm().objects(TaskData.self).sorted(byKeyPath: "orderNo", ascending: true).filter("completeFlg == 0")//未完了タスク
    var taskCompleteArray = try! Realm().objects(TaskData.self).sorted(byKeyPath: "orderNo", ascending: true).filter("completeFlg == 1")//完了タスク
    
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
        bottomControlView.list.button?.addTarget(self, action: #selector(tapList), for: .touchUpInside)
        bottomControlView.addView.button?.addTarget(self, action: #selector(tapAdd), for: .touchUpInside)
        bottomControlView.deleteView.button?.addTarget(self, action: #selector(tapDelete), for: .touchUpInside)
        bottomControlView.resetView.button?.addTarget(self, action: #selector(tapReset), for: .touchUpInside)
        self.navigationController?.navigationBar.isHidden = true
    }
    //カードがすでにviewに存在する場合、一度クリアする
    private func removeCardInfo(){
        self.removeAllSubviews(parentView: cardView)
    }
    private func setCardInfo(){
        self.taskDataArray.reversed().forEach { task in
            let card = CardView(task: task)
            card.taskProcessDelegate = self//デリゲート
            
            //cardにタグ(taskのid)をつける
            card.tag = task.id
            self.cardView.addSubview(card)
            card.anchor(top:self.cardView.topAnchor,bottom: self.cardView.bottomAnchor,left: self.cardView.leftAnchor,right: self.cardView.rightAnchor)
        }
    }
    @objc func tapList(){
        //タイマーが起動している場合は止める
        timerAllStop()
            
        //画面遷移
        let taskListController = TaskListViewController()
        self.navigationController?.pushViewController(taskListController, animated: true)
    }
    @objc func tapAdd(){
        //タスクを追加
        //画面遷移
        let taskListController = TaskListViewController()
        taskListController.transition = true
        self.navigationController?.pushViewController(taskListController, animated: false)
    }
    @objc func tapDelete(){
        //削除
        if taskDataArray.count == 0 {
            //taskDataArrayが0件の場合は処理を行わない
            return
        }
        //メッセージを表示
        let dialog = UIAlertController(title: "削除してもよろしいですか？", message: "", preferredStyle: .alert)
        dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in
            //タイマーが起動している場合は止める
            self.timerAllStop()
            //配列の先頭データを削除
            try! self.realm.write(){
                self.realm.delete(self.taskDataArray[0])
            }

            //再描画
            self.removeCardInfo()
            self.setCardInfo()
        }))
        dialog.addAction(UIAlertAction(title: "CANCEL", style: .default, handler:nil))
        self.present(dialog, animated: true, completion: nil)


                        
    }
    @objc func tapReset(){
        if taskDataArray.count == 0 {
            //taskDataArrayが0件の場合は処理を行わない
            return
        }
        //タイマーが起動している場合は止める
        timerAllStop()
        //リセット
        try! realm.write(){
            //経過時間を0にリセット
            taskDataArray[0].time = 0
            //再描画
            removeCardInfo()
            setCardInfo()
        }

        
    }
    private func timerAllStop(){
        //タイマーが起動している場合は止める
        let subviews = self.cardView.subviews
        for subview in subviews {
            if subview is CardView{
                let cardView = subview as! CardView
                cardView.stopTimer()
            }
        }
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

//
        //completeFlgに1を立てる//完了のフラグ
        try! realm.write{
            taskDataArray[arrayIndex].completeFlg = 1
        }

    }
}
