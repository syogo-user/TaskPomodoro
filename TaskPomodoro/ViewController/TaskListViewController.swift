//
//  TaskListViewController.swift
//  TaskPomodoro
//
//  Created by 小野寺祥吾 on 2021/04/04.
//

import UIKit
import RealmSwift
class TaskListViewController:UIViewController{
    
    let realm = try! Realm()
    var taskDataArray = try! Realm().objects(TaskData.self).sorted(byKeyPath: "orderNo", ascending: true) 
    var transition :Bool = false
    private var tableView:UITableView!
    private let cellId = "cellId"
//    lazy var infoCollectionView :UICollectionView = {
//        let layout = UICollectionViewFlowLayout()
//        //中のviewをもとに大きさを自動で UITableViewDelegate, UITableViewDataSource 設定
//        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
//
//        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
//        cv.delegate = self
//        cv.dataSource = self
//        cv.backgroundColor = .white
//        cv.register(InfoCollectionViewCell.self, forCellWithReuseIdentifier: cellId)
//        return cv
//    }()
  

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 500
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(CustomTablViewCell.self, forCellReuseIdentifier: cellId)
        tableView.isEditing = true //セル並び替え可能
        tableView.allowsSelectionDuringEditing = true //セル選択可能

        
        self.view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        let addBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addBarButtonTapped))
        navigationItem.rightBarButtonItems = [addBarButtonItem]
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        self.navigationController?.navigationBar.isHidden = false
        
        //遷移するか判定
        transitionJudge()
    }
    @objc func addBarButtonTapped(){
        //タスクのIdを設定
        let task = TaskData()
        let allTasks = realm.objects(TaskData.self)
        if  allTasks.count != 0{
            let no = allTasks.max(ofProperty: "id")! + 1
            task.id = no
            task.orderNo = no //ソート用
        }
        
        //画面遷移
        let registerTask = RegisterTaskViewController()
        
        registerTask.task = task
        self.navigationController?.pushViewController(registerTask, animated: true)
    }
    private func transitionJudge(){
        if self.transition{
            self.transition = false
            addBarButtonTapped()
        }
    }
}
extension TaskListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskDataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! CustomTablViewCell
        cell.setData(task: taskDataArray[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //画面遷移
        let registerTask = RegisterTaskViewController()
        registerTask.task = taskDataArray[indexPath.row]
        self.navigationController?.pushViewController(registerTask, animated: true)
    }
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        //並び替え処理
        try! realm.write {
            let sourceObject = taskDataArray[sourceIndexPath.row]
            let destinationObject = taskDataArray[destinationIndexPath.row]
            let destinationObjectOrder = destinationObject.orderNo
            if sourceIndexPath.row < destinationIndexPath.row {
                // 上から下に移動した場合、間の項目を上にシフト
                for index in sourceIndexPath.row...destinationIndexPath.row {
                    let object = taskDataArray[index]
                    object.orderNo -= 1
                }
            } else {
                // 下から上に移動した場合、間の項目を下にシフト
                for index in (destinationIndexPath.row..<sourceIndexPath.row).reversed(){
                    let object = taskDataArray[index]
                    object.orderNo += 1
                }
            }
            // 移動したセルの並びを移動先に更新
            sourceObject.orderNo = destinationObjectOrder
        }
    }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
}


class CustomTablViewCell:UITableViewCell{
    
    let title = CellTextLabel(text: "タイトル")
    let content = CellTextLabel(text: "コンテンツ")
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)


        let stackview = UIStackView(arrangedSubviews: [title,content])
        stackview.axis = .vertical
        stackview.distribution = .fillEqually
        addSubview(stackview)
        stackview.anchor(top:self.topAnchor,bottom:self.bottomAnchor,left:self.leftAnchor,right: self.rightAnchor)
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setData(task:TaskData){
        self.title.text = task.title
        self.content.text = task.content        
    }
    

}
