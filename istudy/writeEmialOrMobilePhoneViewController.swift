//
//  writeEmialOrMobilePhoneViewController.swift
//  istudy
//
//  Created by hznucai on 16/3/9.
//  Copyright © 2016年 hznucai. All rights reserved.
//

import UIKit

class writeEmialOrMobilePhoneViewController: UIViewController {
    @IBOutlet weak var topLayout: NSLayoutConstraint!
    @IBOutlet weak var writeTextField:UITextField?
    override func viewDidLoad() {
        super.viewDidLoad()
        //键盘出现时的挡住问题
        XKeyBoard.registerKeyBoardHide(self)
        XKeyBoard.registerKeyBoardShow(self)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func keyBoardHide(sender: UIControl) {
        self.writeTextField?.resignFirstResponder()
    }
    @IBAction func  nextAction(sender:UIButton){
        //检查邮箱或者手机号是否正确
        //正确了推往下一个视图
        let sendIdentifyVC = UIStoryboard(name: "LoginAndReset", bundle: nil).instantiateViewControllerWithIdentifier("SendIdentifyCodeVC")
        as! SendIdentifyCodeViewController
        sendIdentifyVC.title = "密码找回"
        self.navigationController?.pushViewController(sendIdentifyVC, animated: true)
    }
    func keyboardWillHideNotification(notifacition:NSNotification) {
        UIView.animateWithDuration(0.3) { () -> Void in
            self.topLayout.constant = 78
                       //加载新的约束
            self.view.layoutIfNeeded()
        }
    }
    func keyboardWillShowNotification(notifacition:NSNotification) {
        //做一个动画
        UIView.animateWithDuration(0.3) { () -> Void in
            self.topLayout.constant = 4
          
            //加载新的约束
            self.view.layoutIfNeeded()
        }
    }

   
}
