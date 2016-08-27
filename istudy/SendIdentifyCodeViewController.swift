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
    @IBOutlet weak var sendAgainBtn:UIButton?
    @IBOutlet weak var configBtn:UIButton?
    //计数器 最多按三次
    var sendAgainCnt = 0
   var  isOutTime = false
    var timer = NSTimer()
    var currentTime = NSInteger()
    override func viewDidLoad() {
        super.viewDidLoad()
        //加再发一次的按钮 刚开始是隐藏的 随后当倒计时完成后 才出现
        sendAgainBtn?.addTarget(self, action: #selector(SendIdentifyCodeViewController.sendAgain(_:)), forControlEvents: .TouchUpInside)
        sendAgainBtn?.hidden = true
        configBtn?.layer.cornerRadius = 6.0
        configBtn?.layer.masksToBounds = true
        sendAgainBtn?.layer.cornerRadius = 6.0
        sendAgainBtn?.layer.masksToBounds = true
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
    //跟新时间 当NSTimer在倒计时的时候
    func updateTime(sender:NSTimer){
        if(self.currentTime > 0){
            self.currentTime -= 1
            self.timerLabel?.text = "\(self.currentTime)" + "秒"
        }else{
            self.sendAgainBtn?.hidden = false
            self.timerLabel?.text = "0秒"
        }
    }
    //验证码是否填写正确
    @IBAction func sureIdentifyCode(sender:UIButton){
        //停止计时器
        self.timer.invalidate()
        //验证验证码是否正确 随后跳转到充值密码的界面 去掉空格
        let identifyCodeText = self.identifyCode?.text
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
    self.timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(SendIdentifyCodeViewController.updateTime(_:)), userInfo: nil, repeats: true)
                ProgressHUD.showError("验证失败")
                
            }
        case .Failure(_):
        self.timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(SendIdentifyCodeViewController.updateTime(_:)), userInfo: nil, repeats: true)
            ProgressHUD.showError("验证失败")
        }
        }
        self.currentTime = 60
        self.timerLabel?.text = "\(self.currentTime)" + "秒"
    }
    @IBAction func keyBoardHide(sender: UIControl) {
        self.identifyCode!.resignFirstResponder()
    }
    //键盘的动画
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
    //最多重发三次 当三次后 就要提醒用户邮箱是否填写正确  返回上一个界面
    func sendAgain(sender:UIButton) {
    
        sendAgainCnt += 1
        if(sendAgainCnt != 4){
            
              let urlString = "http://dodo.hznu.edu.cn/api/sendvalidcode" + "?email=" + (email)
        
        Alamofire.request(.POST, urlString).responseJSON(completionHandler: { (response) in
            switch response.result{
            case .Failure(_):
                ProgressHUD.showError("发送失败")
            case .Success(let Value):
                let json = JSON(Value)
                if(json["retcode"].number == 0){
                    dispatch_async(dispatch_get_main_queue(), {
                        self.currentTime = 60
                        self.timerLabel?.text = "\(self.currentTime)" + "秒"
                        sender.hidden = true
                    })
                    
                    ProgressHUD.showSuccess("已发送")
                }else{
                    ProgressHUD.showError("邮箱无效")
                }
            }
        })
        
    }else{
            ProgressHUD.showError("请查看邮箱填写是否正确")
            self.navigationController?.popViewControllerAnimated(true)
    }
    }
}
