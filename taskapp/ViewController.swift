//
//  ViewController.swift
//  taskapp
//
//  Created by 伊藤嵩 on 2019/12/02.
//  Copyright © 2019 Shu Ito. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    //Realmインスタンスを取得する
    let realm = try! Realm()
    
    // DB内のタスクが格納されるリスト。データの配列
    // 日付近い順\順でソート：降順 ascending: false
    // 以降内容をアップデートするとリスト内は自動的に更新される。
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: false)

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
    }
    // MARK: UITableViewDataSourceプロトコルのメソッド
    // データの数（＝セルの数）を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskArray.count  //データの数＝配列の数
    }
    
    // 各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 再利用可能な cell を得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        //cellに値を設定する
        //データの配列であるtaskArrayから該当するデータを取り出してセルに設定
        let task = taskArray[indexPath.row]
        cell.textLabel?.text = task.title
        
        //DateFormatterクラスは日付を表すDateクラスを任意の形の文字列に変換する機能を持つ
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let dateString:String = formatter.string(from: task.date)
        cell.detailTextLabel?.text = dateString
        
        return cell
    }
    
    // MARK: UITableViewDelegateプロトコルのメソッド
    // 各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    //segueのIDを指定して遷移させるperformSegue(withIdentifier:sender)メソッドの呼び出しを追加
        performSegue(withIdentifier: "cellSegue", sender: nil)
    
    }
    
    // セルが削除が可能なことを伝えるメソッド
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCell.EditingStyle {
        return .delete
    }
    
    // Delete ボタンが押された時に呼ばれるメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            //削除するタスクを取得する
            let task = self.taskArray[indexPath.row]
            
            //ローカル通知をキャンセル
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])
            
            // データベースから削除する
            try! realm.write {
                self.realm.delete(self.taskArray[indexPath.row])
                tableView.deleteRows(at: [indexPath], with: .fade)
            //未通知のローカル通知一覧をログ出力
                center.getPendingNotificationRequests{ (requests: [UNNotificationRequest]) in
                    for request in requests {
                        print("/---------------")
                        print(request)
                        print("---------------/")
                    }
                }
                
            }
            
        }
    }
    //タスク一覧画面からタスク作成/編集画面に遷移する時にデータであるTaskクラスを渡す処理
   //画面遷移自体は先に実装していたperformSegue(withIdentifier:sender:)メソッドによって
   //cellSegueのsegueが実行されて画面遷移するが、『＋』ボタンとセルをタップした時の２つのケースで遷移することがあるので
   //このメソッドで場合分する
    //segueで画面遷移する時に呼ばれる
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //セルをタップした時は先ほど設定したIdentifierがcellSegueであるsegueが発行
        //dentifierがcellSegueのときはすでに作成済みのタスクを編集するとき
        //配列taskArrayから該当するTaskクラスのインスタンスを取り出してinputViewControllerのtaskプロパティに設定
        let inputViewController:InputViewController = segue.destination as! InputViewController
        
        if segue.identifier == "cellSegue" {
            let indexPath = self.tableView.indexPathForSelectedRow
            inputViewController.task = taskArray[indexPath!.row]
        }else{
            
            //+ボタンをタップした時はTaskクラスのインスタンスを生成して、初期値として現在時間と、
            //プライマリキーであるIDに値を設定
            //taskArray.max(ofProperty: "id")ですでに存在しているタスクのidのうち
            //最大のものを取得し、1を足すことで他のIDと重ならない値を指定
            let task = Task()
            task.date = Date()
            
            let allTasks = realm.objects(Task.self)
            if allTasks.count != 0 {   // != not equal
                task.id = allTasks.max(ofProperty: "id")! + 1
            }
            
            inputViewController.task = task
        }
    }
    
    //タスク作成/編集画面から戻ってきた時に画面(TableView)を更新する処理
    //viewWillAppear:メソッドを追加し、UITableViewクラスのreloadDataメソッドを呼ぶことで
    //タスク作成/編集画面で新規作成/編集したタスクの情報をTableViewに反映させる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    
}

