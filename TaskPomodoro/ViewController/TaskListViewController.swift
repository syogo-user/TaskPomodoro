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
    var taskDataArray = try! Realm().objects(TaskData.self)
    
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
        self.view.addSubview(tableView)
        
        let addBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addBarButtonTapped(_:)))
        navigationItem.rightBarButtonItems = [addBarButtonItem]
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    @objc func addBarButtonTapped(_ sender :UIBarButtonItem){
        //タスクのIdを設定
        let task = TaskData()
        let allTasks = realm.objects(TaskData.self)
        if  allTasks.count != 0{
            task.id = allTasks.max(ofProperty: "id")! + 1
        }
        
        //画面遷移
        let registerTask = RegisterTaskViewController()
        registerTask.task = task
        self.navigationController?.pushViewController(registerTask, animated: true)
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
