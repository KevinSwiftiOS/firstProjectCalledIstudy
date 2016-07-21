//
//  ResetPasswordViewController.swift
//  istudy
//
//  Created by hznucai on 16/3/6.
//  Copyright © 2016年 hznucai. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
class ResetPasswordViewController: UIViewController {
    @IBOutlet weak var topLayout: NSLayoutConstraint!
    @IBOutlet weak var newPassWord:UITextField?
    @IBOutlet weak var configPassWord:UITextField?
    @IBOutlet weak var sureBtn:UIButton?
    var token = String()
    override func viewDidLoad() {
        super.viewDidLoad()
        //键盘出现时的挡住问题
        XKeyBoard.registerKeyBoardHide(self)
        XKeyBoard.registerKeyBoardShow(self)
        sureBtn?.layer.cornerRadius = 6.0
        sureBtn?.layer.masksToBounds = true
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //确认重置后 进行跳转到主界面
    @IBAction func sureToResetPassword(sender:UIButton){
        //确认两者输入的密码
        if(self.configPassWord?.text == self.newPassWord?.text){
        //确认新的密码和确认的密码有没有相同 随后在服务器上进行修改 即可 如果不一样 弹出一个警告框即可
        let dic:[String:AnyObject] = ["token":token,
                                      "newpassword":(self.configPassWord?.text)!]
        Alamofire.request(.POST, "http://dodo.hznu.edu.cn/api/resetpassowrd", parameters: dic, encoding: ParameterEncoding.URL, headers: nil).responseJSON(completionHandler: { (response) in
            switch response.result{
            case .Success(let Value):
                let json = JSON(Value)
                if(json["retcode"].number == 0){
                
                    ProgressHUD.showSuccess("重置成功")
                    let userDefault = NSUserDefaults.standardUserDefaults()
                    userDefault.setValue(json["info"]["username"].string, forKey: "userName")
                    //然后直接拿登录
                    userDefault.setValue(self.configPassWord?.text, forKey: "passWord")
                    let sb = UIStoryboard(name: "Main", bundle: nil)
                    let mainVC = sb.instantiateViewControllerWithIdentifier("tabBarVC") as! UITabBarController
                    self.presentViewController(mainVC, animated: true, completion: nil)
                    
                }
            case .Failure(_):
                ProgressHUD.showError("重置失败")
            }
        })
               }else{
            ProgressHUD.showError("密码不相同")
        }
    }
    //点击背景消失键盘
    @IBAction func keyBoardHide(sender: UIControl) {
        self.newPassWord!.resignFirstResponder()
        self.configPassWord?.resignFirstResponder()
    }
    //键盘的动画
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
    override func viewWillDisappear(animated: Bool) {
        ProgressHUD.dismiss()
    }
}
