//
//  ColorCollectionViewController.swift
//  TaskPomodoro
//
//  Created by 小野寺祥吾 on 2021/04/19.
//

import UIKit
class ColorCollectionViewController:UIViewController{
    private let cellId = "cellId"
    
    lazy var collectionView : UICollectionView = {
        //CollectionViewのサイズ調整
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top:15,left:15,bottom:15,right:15)
        
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height),collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(ColorCollectionViewCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.backgroundColor = .white
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(collectionView)
        collectionView.anchor(top:view.topAnchor,bottom:view.bottomAnchor, left: view.leftAnchor,right:view.rightAnchor,topPdding: 10,bottomPdding: 10, leftPdding: 10,rightPdding: 10)
                              
    }
    
    
    
    
//    lazy var tableView :UITableView = {
//        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
//        tableView.dataSource = self
//        tableView.delegate = self
//        tableView.estimatedRowHeight = 500
//        tableView.rowHeight = UITableView.automaticDimension
//        tableView.tableFooterView = UIView()
//        return tableView
//    }()
}

extension ColorCollectionViewController:UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //表示するセルの数
        return CommonConst.gradientColor.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ColorCollectionViewCell
        cell.setGradientColor(colorIndex:indexPath.item)
        return cell
    }
    // cell選択時に呼ばれる関数
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //前画面への値の受け渡し
//        let preVC = self.presentingViewController as! RegisterTaskViewController
//        preVC.colorArrayIndex = indexPath.item
//        self.dismiss(animated: true, completion:nil)
        let preNC = self.presentingViewController as! UINavigationController
        let preVC = preNC.viewControllers[preNC.viewControllers.count - 1] as! RegisterTaskViewController
        preVC.colorArrayIndex = indexPath.item  
        self.dismiss(animated: true, completion:nil)
    }
    
    
}
