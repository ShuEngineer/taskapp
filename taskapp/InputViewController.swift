//
//  InputViewController.swift
//  taskapp
//
//  Created by 伊藤嵩 on 2019/12/02.
//  Copyright © 2019 Shu Ito. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class InputViewController: UIViewController {
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    let realm = try! Realm()
    var task: Task!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //背景をタップしたらdismissKeyboardメソッドを呼ぶように設定する
        //タップを判断するにはUITapGestureRecognizerクラスを利用
        //UITapGestureRecognizerクラスの初期化時にタップされたときにどのクラスのどのメソッドが呼ばれるかを指定
        //クラス：self(=InputViewController自身)
        //メソッド：dismissKeyboard()メソッドを指定
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
        //viewプロパティが背景に該当するので、addGestureRecognizer(_:)メソッドを使って
        //viewにUITapGestureRecognizerを登録
        self.view.addGestureRecognizer(tapGesture)
        
        //UIに値を反映するために最初にUIを作成した時に設定したアウトレットにそれぞれの値を設定
        titleTextField.text = task.title
        contentsTextView.text = task.contents
        datePicker.date = task.date
    }
    @objc func dismissKeyboard(){
        //dismissKeyboard()メソッドでendEditing(true)を呼び出してキーボードを閉じる
        view.endEditing(true)
    }
    
    //viewWillDisappear(_:)メソッド 遷移する際に、画面が非表示になるとき呼ばれるメソッド
    //Realmのwrite(_:)メソッドを使用
    
    override func viewWillDisappear(_ animated: Bool) {
        try! realm.write {
            self.task.title = self.titleTextField.text!
            self.task.contents = self.contentsTextView.text
            self.task.date = self.datePicker.date
            self.realm.add(self.task, update: true)
        }
        
        setNotification(task: task)
        //ローカル通知をタスク作成/編集画面からタスク一覧画面に戻る際にデータベースにタスクを保存するタイミングで入れる
        
        super.viewWillDisappear(animated)
    }
    
    //タスクのローカル通知を登録する
    func setNotification(task: Task){
        //UNMutableNotificationContentクラスのインスタンスを使って通知内容を設定
        //UNMutableNotificationContetクラスをcontentに設定
        let content = UNMutableNotificationContent()
        //タイトルと内容を設定(中身がない場合メッセージ無しで音だけの通知になるので「(xxなし)」を表示する)
        if task.title == "" {
            //.titleや.contentsはインスタンス
           content.title = "(タイトルなし)"
            
        }else{
            content.title = task.title
        }
        
        if task.contents == "" {
            content.body = "(内容なし)"
        }else{
            content.body = task.contents
            
        }
        content.sound = UNNotificationSound.default
        
        
        // ローカル通知が発動するtrigger（日付マッチ）を作成
        let calender = Calendar.current
        let dateComponents = calender.dateComponents([.year, .month, .day, .hour, .minute], from: task.date)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        //identifier, content, triggerからローカル通知を作成（identifierが同じだとローカル通知を上書き保存）
        let request = UNNotificationRequest(identifier: String(task.id), content: content, trigger: trigger)
        
        //ローカル通知を登録
        let center = UNUserNotificationCenter.current()
        center.add(request) { (error) in print(error ?? "ローカル通知登録　OK")}
        // error が nil ならローカル通知の登録に成功したと表示します。errorが存在すればerrorを表示します。
        //?? 演算子は、左の値がnilでなければ左の値を返し、左の値がnilであれば右の値を返す演算子
        
        // 未通知のローカル通知一覧をログ出力
        center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
            for request in requests {
                print("/---------------")
                print(request)
                print("---------------/")
            }
         }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


}
