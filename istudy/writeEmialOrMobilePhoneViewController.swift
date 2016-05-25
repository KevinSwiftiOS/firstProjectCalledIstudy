//
//  writeEmialOrMobilePhoneViewController.swift
//  istudy
//
//  Created by hznucai on 16/3/9.
//  Copyright © 2016年 hznucai. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
class writeEmialOrMobilePhoneViewController: UIViewController {
    @IBOutlet weak var topLayout: NSLayoutConstraint!
    @IBOutlet weak var writeTextField:UITextField?
    //正则表达式匹配邮箱
    struct RegexHelper {
        let regex: NSRegularExpression
        
        init(_ pattern: String) throws {
            try regex = NSRegularExpression(pattern: pattern,
                                            options: .CaseInsensitive)
        }
        
        func match(input: String) -> Bool {
            let matches = regex.matchesInString(input,
                                                options: [],
                                                range: NSMakeRange(0, input.utf16.count))
            return matches.count > 0
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        //键盘出现时的挡住问题
        XKeyBoard.registerKeyBoardHide(self)
        XKeyBoard.registerKeyBoardShow(self)
        let userDefault = NSUserDefaults.standardUserDefaults()
        //先是邮箱的
        if(userDefault.valueForKey("email") as? String != nil && userDefault.valueForKey("email") as! String != ""){
            self.writeTextField?.text = userDefault.valueForKey("email") as? String
        }
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
        self.writeTextField?.resignFirstResponder()
        //检查邮箱或者手机号是否正确
        let mailPattern =
        "^([a-z0-9_\\.-]+)@([\\da-z\\.-]+)\\.([a-z\\.]{2,6})$"
        let matcher: RegexHelper
        do {
            matcher = try RegexHelper(mailPattern)
            var emailText = self.writeTextField?.text
            emailText = emailText!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            if matcher.match(emailText!){
              //发送验证码
              let emailText = self.writeTextField?.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                
                let urlString = "http://dodo.hznu.edu.cn/api/sendvalidcode" + "?email=" + (emailText)!
                
                Alamofire.request(.POST, urlString).responseJSON(completionHandler: { (response) in
                    switch response.result{
                    case .Failure(_):
                        ProgressHUD.showError("发送失败")
                    case .Success(let Value):
                        let json = JSON(Value)
                        if(json["retcode"].number == 0){
                            ProgressHUD.showSuccess("已发送")
                            //正确了推往下一个视图
                            let sendIdentifyVC = UIStoryboard(name: "LoginAndReset", bundle: nil).instantiateViewControllerWithIdentifier("SendIdentifyCodeVC")
                                as! SendIdentifyCodeViewController
                            sendIdentifyVC.title = "密码找回"
                            sendIdentifyVC.email = emailText!
                            self.navigationController?.pushViewController(sendIdentifyVC, animated: true)
                        }else{
                            ProgressHUD.showError("邮箱无效")
                        }
                    }
                })
              
             }else{
                ProgressHUD.showError("填写邮箱格式错误")
            }
            
        }catch{
            print("error")
        }

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
     override func viewWillDisappear(animated: Bool) {
        ProgressHUD.dismiss()
    }
}
