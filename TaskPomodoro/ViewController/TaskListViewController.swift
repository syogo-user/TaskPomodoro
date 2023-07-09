//
//  TaskListViewController.swift
//  TaskPomodoro
//
//  Created by 小野寺祥吾 on 2021/04/04.
//

import UIKit
import RealmSwift
import ContextMenuSwift

class TaskListViewController: UIViewController {
    
    let realm = try! Realm()
    let sectionTitleArray = ["タスク","完了"]
    // 未完了タスク
    var taskDataArray = try! Realm().objects(TaskData.self).sorted(byKeyPath: "orderNo", ascending: true).filter("isComplete == false")
    // 完了済タスク
    var taskCompleteArray = try! Realm().objects(TaskData.self).sorted(byKeyPath: "orderNo", ascending: true).filter("isComplete == true")
    var transition :Bool = false
    private let cellId = "cellId"

    lazy var tableView :UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 500
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView()
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: cellId)
        tableView.isEditing = true //セル並び替え可能
        tableView.allowsSelectionDuringEditing = true //セル選択可能

        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress(_:)))
        tableView.addGestureRecognizer(longPressRecognizer)        
        self.view.addSubview(tableView)
        let addBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addBarButtonTapped))
        navigationItem.rightBarButtonItems = [addBarButtonItem]
        self.navigationController?.navigationBar.tintColor = CommonConst.lightClearGray
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: CommonConst.lightClearGray]
        self.navigationController?.navigationBar.topItem?.title = ""
        self.navigationItem.title = "一覧"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        self.navigationController?.navigationBar.isHidden = false
        transitionJudge()
    }
    
    @objc func addBarButtonTapped() {
        // タスクのIdを設定
        let task = TaskData()
        let allTasks = realm.objects(TaskData.self)
        if  allTasks.count != 0{
            let no = allTasks.max(ofProperty: "id")! + 1
            task.id = no
            task.orderNo = no
        }

        let registerTask = RegisterTaskViewController()
        registerTask.task = task
        self.navigationController?.pushViewController(registerTask, animated: true)
    }
    
    @objc func longPress(_ recognizer: UILongPressGestureRecognizer){
        // 押された位置でcellのPathを取得
        let point = recognizer.location(in: tableView)
        let indexPath = tableView.indexPathForRow(at: point)

        if indexPath == nil {
            return
        } else if recognizer.state == UIGestureRecognizer.State.began {
            // 長押し時の呼び出しメソッドは長押し開始と終了の2回呼び出されるのでbeganの場合のみ実行
            let delete = ContextMenuItemWithImage(title: "削除", image: UIImage(systemName: "trash")!)
            CM.items = [delete]
            CM.showMenu(viewTargeted: tableView.cellForRow(at: indexPath!)!,
                        delegate: self,
                        animated: true)
        }
    }
    
    private func transitionJudge() {
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
        if section == 0 {
            return taskDataArray.count
        } else {
            return taskCompleteArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! CustomTableViewCell
        if indexPath.section == 0 {
            cell.setData(task: taskDataArray[indexPath.row])
        } else {
            cell.setData(task: taskCompleteArray[indexPath.row])
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {        
        if indexPath.section == 0 {
            // 未完了タスク
            let registerTask = RegisterTaskViewController()
            registerTask.task = taskDataArray[indexPath.row]
            self.navigationController?.pushViewController(registerTask, animated: true)
        } else {
            // 完了済タスク
            let registerTask = RegisterTaskViewController()
            registerTask.task = taskCompleteArray[indexPath.row]
            self.navigationController?.pushViewController(registerTask, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if sourceIndexPath.section == 0 {
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
                    for index in (destinationIndexPath.row..<sourceIndexPath.row).reversed() {
                        let object = taskDataArray[index]
                        object.orderNo += 1
                    }
                }
                // 移動したセルの並びを移動先に更新
                sourceObject.orderNo = destinationObjectOrder
            }
        } else {
            // 並び替え処理
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
        // セクションをまたぐ並び替えを禁止
        if sourceIndexPath.section == proposedDestinationIndexPath.section {
            return proposedDestinationIndexPath
        }
        return sourceIndexPath
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
}

extension TaskListViewController: ContextMenuDelegate {
    
    func contextMenuDidSelect(_ contextMenu: ContextMenu,
                              cell: ContextMenuCell,
                              targetedView: UIView,
                              didSelect item: ContextMenuItem,
                              forRowAt index: Int) -> Bool {

        // 長押しされたセルを、型を再指定して読み込む
        let pressedTableCell = targetedView as! CustomTableViewCell
        
        // セル内の情報を取得したい場合
        let id = pressedTableCell.id
        
        var arrayIndex = 0
        var taskDataArrayFlg: Bool = true
        // idから配列のインデックスを取得
        for (index,task) in taskDataArray.enumerated() {
            if task.id == id{
                arrayIndex = index
                taskDataArrayFlg = true
            }
        }
        
        for (index,task) in taskCompleteArray.enumerated() {
            if task.id == id {
                arrayIndex = index
                taskDataArrayFlg = false
            }
        }
        
        try! realm.write {
            if taskDataArrayFlg {
                self.realm.delete(taskDataArray[arrayIndex])
            } else {
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
    }
}

class CustomTableViewCell: UITableViewCell {
    var id = 0
    let title = CellTextLabel(text: "タイトル", fontSize: 21.0,textColor: .gray)
    let content = CellTextLabel(text: "コンテンツ", fontSize: 17.0,textColor: .lightGray)
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)


        let stackView = UIStackView(arrangedSubviews: [title, content])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        addSubview(stackView)
        title.anchor()
        stackView.anchor(top:self.topAnchor, bottom: self.bottomAnchor, left: self.leftAnchor, right: self.rightAnchor, topPadding: 5, bottomPadding: 5, leftPadding: 20, rightPadding: 20)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setData(task: TaskData) {
        self.id = task.id
        self.title.text = task.title
        self.content.text = task.content        
    }
}
