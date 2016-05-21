//
//  SecuritySettingsViewController.swift
//  istudy
//
//  Created by hznucai on 16/3/3.
//  Copyright © 2016年 hznucai. All rights reserved.
//

import UIKit

class SecuritySettingsViewController: UIViewController {
    @IBOutlet weak var labelTopLayout: NSLayoutConstraint!
    @IBOutlet weak var topLayout: NSLayoutConstraint!
    @IBOutlet weak var lastPassWord:UITextField?
    @IBOutlet weak var newPassWord:UITextField?
    @IBOutlet weak var configNewPassWord:UITextField?
    override func viewDidLoad() {
        super.viewDidLoad()
      self.view.backgroundColor = UIColor.grayColor()
     let rightBatButtonItem = UIBarButtonItem(title: "完成", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(SecuritySettingsViewController.save(_:)))
        self.navigationItem.rightBarButtonItem = rightBatButtonItem
        // Do any additional setup after loading the view.
        XKeyBoard.registerKeyBoardHide(self)
        XKeyBoard.registerKeyBoardShow(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//完成密码确认后
     func save(sender:UIButton){
        let userDefault = NSUserDefaults.standardUserDefaults()
        userDefault.setValue(self.newPassWord?.text, forKey: "passWord")
        self.navigationController?.popViewControllerAnimated(true)
    }
    @IBAction func keyBoardHide(sender: UIControl) {
        self.lastPassWord?.resignFirstResponder()
        self.newPassWord?.resignFirstResponder()
        self.configNewPassWord?.resignFirstResponder()
    }

    func keyboardWillHideNotification(notifacition:NSNotification) {
        UIView.animateWithDuration(0.3) { () -> Void in
            self.topLayout.constant = 69
            self.labelTopLayout.constant = 69
            //加载新的约束
            self.view.layoutIfNeeded()
        }
    }
    func keyboardWillShowNotification(notifacition:NSNotification) {
        //做一个动画
        UIView.animateWithDuration(0.3) { () -> Void in
            self.topLayout.constant = 35
            self.labelTopLayout.constant = 35
                        //加载新的约束
            self.view.layoutIfNeeded()
        }
    }
}
