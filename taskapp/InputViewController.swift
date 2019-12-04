//
//  InputViewController.swift
//  taskapp
//
//  Created by 伊藤嵩 on 2019/12/02.
//  Copyright © 2019 Shu Ito. All rights reserved.
//

import UIKit
import RealmSwift

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
        
        super.viewWillDisappear(animated)
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
