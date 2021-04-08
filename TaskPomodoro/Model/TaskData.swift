//
//  TaskData.swift
//  TaskPomodoro
//
//  Created by 小野寺祥吾 on 2021/04/05.
//

import RealmSwift
class TaskData :Object{
    @objc dynamic var id  = 0
    @objc dynamic var title = ""
    @objc dynamic var content = ""
    @objc dynamic var orderNo = 0
    @objc dynamic var time:Float = 0
    // id をプライマリーキーとして設定
    override static func primaryKey() -> String? {
        return "id"
    }
}
