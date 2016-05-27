//
//  SendCodeViewController.swift
//  istudy
//
//  Created by hznucai on 16/3/6.
//  Copyright © 2016年 hznucai. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
class SendIdentifyCodeViewController: UIViewController {
    @IBOutlet weak var topLayout: NSLayoutConstraint!
    var email = String()
    @IBOutlet weak var identifyCode:UITextField?
    @IBOutlet weak var timerLabel:UILabel?
    var timer = NSTimer()
    var currentTime = NSInteger()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.currentTime = 60
        self.timerLabel?.text = "\(self.currentTime)" + "秒"
        self.timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(SendIdentifyCodeViewController.updateTime(_:)), userInfo: nil, repeats: true)
        //键盘出现时的挡住问题
        XKeyBoard.registerKeyBoardHide(self)
        XKeyBoard.registerKeyBoardShow(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func updateTime(sender:NSTimer){
        if(self.currentTime > 0){
            self.currentTime -= 1
            self.timerLabel?.text = "\(self.currentTime)" + "秒"
        }else{
            self.timerLabel?.text = "0秒"
        }
    }
    @IBAction func sureIdentifyCode(sender:UIButton){
        //停止计时器
        self.timer.invalidate()
        //验证验证码是否正确 随后跳转到充值密码的界面 去掉空格
        let identifyCodeText = self.identifyCode?.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        let dic:[String:AnyObject] = ["email":email,
                   "validcode":(identifyCodeText)!]
        
      Alamofire.request(.POST, "http://dodo.hznu.edu.cn/api/validcode", parameters: dic, encoding: ParameterEncoding.URL, headers: nil).responseJSON { (response) in
        switch response.result{
        case .Success(let Value):
            let json = JSON(Value)
            if(json["retcode"].number == 0){
                ProgressHUD.showSuccess("验证成功")
                let sb = UIStoryboard(name: "LoginAndReset", bundle: nil)
                let resetPassordVC = sb.instantiateViewControllerWithIdentifier("ResetPasswordVC") as! ResetPasswordViewController
                resetPassordVC.title = "密码重置"
                resetPassordVC.token = json["info"]["token"].string!
                self.navigationController?.pushViewController(resetPassordVC, animated: true)
            }else{
                ProgressHUD.showError("验证失败")
            }
        case .Failure(_):
            ProgressHUD.showError("验证失败")
        }
        }
        self.currentTime = 60
        self.timerLabel?.text = "\(self.currentTime)" + "秒"
    }
    @IBAction func keyBoardHide(sender: UIControl) {
        self.identifyCode!.resignFirstResponder()
    }
    func keyboardWillHideNotification(notifacition:NSNotification) {
        UIView.animateWithDuration(0.3) { () -> Void in
            self.topLayout.constant = 123
            //加载新的约束
            self.view.layoutIfNeeded()
        }
    }
    func keyboardWillShowNotification(notifacition:NSNotification) {
        //做一个动画
        UIView.animateWithDuration(0.3) { () -> Void in
            self.topLayout.constant = 50
            
            //加载新的约束
            self.view.layoutIfNeeded()
        }
        
        
    }
    override func viewWillDisappear(animated: Bool) {
        ProgressHUD.dismiss()
    }
}
