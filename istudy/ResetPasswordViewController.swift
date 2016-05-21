//
//  ResetPasswordViewController.swift
//  istudy
//
//  Created by hznucai on 16/3/6.
//  Copyright © 2016年 hznucai. All rights reserved.
//

import UIKit

class ResetPasswordViewController: UIViewController {
    @IBOutlet weak var topLayout: NSLayoutConstraint!
    @IBOutlet weak var newPassWord:UITextField?
    @IBOutlet weak var configPassWord:UITextField?
    override func viewDidLoad() {
        super.viewDidLoad()
        //键盘出现时的挡住问题
        XKeyBoard.registerKeyBoardHide(self)
        XKeyBoard.registerKeyBoardShow(self)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func sureToResetPassword(sender:UIButton){
        //确认两者输入的密码
        //确认新的密码和确认的密码有没有相同 随后在服务器上进行修改 即可 如果不一样 弹出一个警告框即可
        let  userDefault = NSUserDefaults.standardUserDefaults()
        userDefault.setValue(self.newPassWord?.text, forKey: "passWord")
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let mainVC = sb.instantiateViewControllerWithIdentifier("tabBarVC") as! UITabBarController
        self.presentViewController(mainVC, animated: true, completion: nil)
    }
    @IBAction func keyBoardHide(sender: UIControl) {
        self.newPassWord!.resignFirstResponder()
        self.configPassWord?.resignFirstResponder()
    }
    func keyboardWillHideNotification(notifacition:NSNotification) {
        UIView.animateWithDuration(0.3) { () -> Void in
            self.topLayout.constant = 108
            //加载新的约束
            self.view.layoutIfNeeded()
        }
    }
    func keyboardWillShowNotification(notifacition:NSNotification) {
        //做一个动画
        UIView.animateWithDuration(0.3) { () -> Void in
            self.topLayout.constant = 20
            
            //加载新的约束
            self.view.layoutIfNeeded()
        }
    }
}
