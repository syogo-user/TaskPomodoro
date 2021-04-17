//
//  TaskListViewController.swift
//  TaskPomodoro
//
//  Created by 小野寺祥吾 on 2021/04/04.
//

import UIKit
import RealmSwift
import ContextMenuSwift
class TaskListViewController:UIViewController{
    
    let realm = try! Realm()
    let sectionTitleArray = ["タスク","完了"]
    var taskDataArray = try! Realm().objects(TaskData.self).sorted(byKeyPath: "orderNo", ascending: true).filter("completeFlg == 0")//未完了タスク
    var taskCompleteArray = try! Realm().objects(TaskData.self).sorted(byKeyPath: "orderNo", ascending: true).filter("completeFlg == 1")//完了タスク
    var transition :Bool = false
//    private var tableView:UITableView!
    private let cellId = "cellId"

    lazy var tableView :UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 500
        tableView.rowHeight = UITableView.automaticDimension

        return tableView
    }()
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
//
//        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
//        tableView.dataSource = self
//        tableView.delegate = self
//        tableView.estimatedRowHeight = 500
//        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(CustomTablViewCell.self, forCellReuseIdentifier: cellId)
        tableView.isEditing = true //セル並び替え可能
        tableView.allowsSelectionDuringEditing = true //セル選択可能
        
        //長押し
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress(_:)))
        tableView.addGestureRecognizer(longPressRecognizer)        
        self.view.addSubview(tableView)
        
        
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
    @objc func longPress(_ recognizer:UILongPressGestureRecognizer){
        //長押し
        // 押された位置でcellのPathを取得
        let point = recognizer.location(in: tableView)
        let indexPath = tableView.indexPathForRow(at: point)

        print("長押し")
        if indexPath == nil{
            return
        }else if recognizer.state == UIGestureRecognizer.State.began{
            //長押し時の呼び出しメソッドは長押し開始と終了の2回呼び出されるのでbeganの場合のみ実行
            let delete = ContextMenuItemWithImage(title: "削除", image: UIImage(systemName: "trash")!)
            //コンテキストメニューに表示するアイテムを決定します
            CM.items = [delete]
            //表示します
            CM.showMenu(viewTargeted: tableView.cellForRow(at: indexPath!)!,
                        delegate: self,
                        animated: true)
        }
        
    }
    private func transitionJudge(){
        if self.transition{
            self.transition = false
            addBarButtonTapped()
        }
    }
}
extension TaskListViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitleArray.count
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitleArray[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return taskDataArray.count
        } else {
            return taskCompleteArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! CustomTablViewCell
        if indexPath.section == 0{
            cell.setData(task: taskDataArray[indexPath.row])
        }else{
            cell.setData(task: taskCompleteArray[indexPath.row])
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {        
        if indexPath.section == 0{
            //タスク
            //画面遷移
            let registerTask = RegisterTaskViewController()
            registerTask.task = taskDataArray[indexPath.row]
            self.navigationController?.pushViewController(registerTask, animated: true)
        }else{
            //完了
            //画面遷移
            let registerTask = RegisterTaskViewController()
            registerTask.task = taskCompleteArray[indexPath.row]
            self.navigationController?.pushViewController(registerTask, animated: true)
        }
        
    }
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if sourceIndexPath.section == 0{
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
        }else{
            //並び替え処理
            try! realm.write {
                let sourceObject = taskCompleteArray[sourceIndexPath.row]
                let destinationObject = taskCompleteArray[destinationIndexPath.row]
                let destinationObjectOrder = destinationObject.orderNo
                if sourceIndexPath.row < destinationIndexPath.row {
                    // 上から下に移動した場合、間の項目を上にシフト
                    for index in sourceIndexPath.row...destinationIndexPath.row {
                        let object = taskCompleteArray[index]
                        object.orderNo -= 1
                    }
                } else {
                    // 下から上に移動した場合、間の項目を下にシフト
                    for index in (destinationIndexPath.row..<sourceIndexPath.row).reversed(){
                        let object = taskCompleteArray[index]
                        object.orderNo += 1
                    }
                }
                // 移動したセルの並びを移動先に更新
                sourceObject.orderNo = destinationObjectOrder
            }
        }

    }
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        //セクションをまたぐ並び替えを禁止
        if sourceIndexPath.section == proposedDestinationIndexPath.section {
            return proposedDestinationIndexPath
        }
        return sourceIndexPath
    }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }

}
extension TaskListViewController : ContextMenuDelegate{

    
    func contextMenuDidSelect(_ contextMenu: ContextMenu,
                              cell: ContextMenuCell,
                              targetedView: UIView,
                              didSelect item: ContextMenuItem,
                              forRowAt index: Int) -> Bool {
        
        //削除処理
        //長押しされたセルを、型を再指定して読み込む
        let pressedTableCell = targetedView as! CustomTablViewCell
        
        //セル内の情報を取得したい場合
        let id = pressedTableCell.id
        
        var arrayIndex = 0
        var taskDataArrayFlg :Bool = true
        //idから配列のインデックスを取得
        for (index,task) in taskDataArray.enumerated(){
            if task.id == id{
                arrayIndex = index
                taskDataArrayFlg = true
            }
        }
        
        for (index,task) in taskCompleteArray.enumerated(){
            if task.id == id{
                arrayIndex = index
                taskDataArrayFlg = false
            }
        }
        
        try! realm.write {
            if taskDataArrayFlg {
                self.realm.delete(taskDataArray[arrayIndex])
            }else{
                self.realm.delete(taskCompleteArray[arrayIndex])
            }
        }
        self.tableView.reloadData()
        return true
        
    }
    func contextMenuDidAppear(_ contextMenu: ContextMenu) {
        print("コンテキストメニューが表示されました")
    }
    func contextMenuDidDisappear(_ contextMenu: ContextMenu) {
        print("コンテキストメニューが消えました")
    }
    
    func contextMenuDidDeselect(_ contextMenu: ContextMenu, cell: ContextMenuCell, targetedView: UIView, didSelect item: ContextMenuItem, forRowAt index: Int) {
        print("")
    }
}




class CustomTablViewCell:UITableViewCell{
    var id = 0
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
        self.id = task.id
        self.title.text = task.title
        self.content.text = task.content        
    }
    

}
