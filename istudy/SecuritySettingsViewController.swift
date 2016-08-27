//
//  SecuritySettingsViewController.swift
//  istudy
//
//  Created by hznucai on 16/3/3.
//  Copyright © 2016年 hznucai. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
//更改密码的操作
class SecuritySettingsViewController: UIViewController {
    @IBOutlet weak var labelTopLayout: NSLayoutConstraint!
    @IBOutlet weak var topLayout: NSLayoutConstraint!
    @IBOutlet weak var lastPassWord:UITextField?
    @IBOutlet weak var newPassWord:UITextField?
    @IBOutlet weak var configNewPassWord:UITextField?
    override func viewDidLoad() {
        super.viewDidLoad()
      
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
    
//完成密码确认后 要判断密码和原先填的是否正确
     func save(sender:UIButton){
        let userDefault = NSUserDefaults.standardUserDefaults()
        //新旧密码
        let configPwd = self.configNewPassWord?.text
        let newPwd = self.newPassWord?.text
        if(newPwd != configPwd){
            ProgressHUD.showError("新密码与认证密码填写不相同")
        }
        else if((userDefault.valueForKey("passWord") as! String) != self.lastPassWord?.text){
            ProgressHUD.showError("原密码填写不正确")
        }
        else{
            
            let ParamDic:[String:AnyObject] = ["oldpassword":(self.lastPassWord?.text)!,
                                               "newpassword":(self.newPassWord?.text)!,
                                               "authtoken":userDefault.valueForKey("authtoken") as! String]
            
            Alamofire.request(.POST, "http://dodo.hznu.edu.cn/api/changepassword", parameters: ParamDic, encoding: ParameterEncoding.URL, headers: nil).responseJSON(completionHandler: { (response) in
                switch response.result{
                case .Success(let Value):
                    let json = JSON(Value)
                 
                    if(json["retcode"].number == 0){
                        ProgressHUD.showSuccess("设置成功")
                        userDefault.setValue(self.newPassWord?.text, forKey: "passWord")
                        self.navigationController?.popViewControllerAnimated(true)
                   
                    }else{
                        ProgressHUD.showError("设置失败")
                        print(json["retcode"].number)
                    }
                case .Failure(_):
                    ProgressHUD.showError("设置失败")
                }
            })
             }
    }
    //keyBoard的操作
    @IBAction func keyBoardHide(sender: UIControl) {
        self.lastPassWord?.resignFirstResponder()
        self.newPassWord?.resignFirstResponder()
        self.configNewPassWord?.resignFirstResponder()
    }

    func keyboardWillHideNotification(notifacition:NSNotification) {
        UIView.animateWithDuration(0.3) { () -> Void in
            self.topLayout.constant = 138
            self.labelTopLayout.constant = 138
            //加载新的约束
            self.view.layoutIfNeeded()
        }
    }
    func keyboardWillShowNotification(notifacition:NSNotification) {
        //做一个动画
        UIView.animateWithDuration(0.3) { () -> Void in
            self.topLayout.constant = 50
            self.labelTopLayout.constant = 50
                        //加载新的约束
            self.view.layoutIfNeeded()
        }
    }
    override func viewWillDisappear(animated: Bool) {
        ProgressHUD.dismiss()
    }
}
