//
//  TaskListViewController.swift
//  TaskPomodoro
//
//  Created by 小野寺祥吾 on 2021/04/04.
//

import UIKit
class TaskListViewController:UIViewController{
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
        //画面遷移
        let registerTask = RegisterTaskViewController()
        self.navigationController?.pushViewController(registerTask, animated: true)
    }
    
}
extension TaskListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! CustomTablViewCell
        return cell
    }
    
    
}


class CustomTablViewCell:UITableViewCell{
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        //TODO
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}
