//
//  SixSameViewController.swift
//  istudy
//
//  Created by hznucai on 16/3/6.
//  Copyright © 2016年 hznucai. All rights reserved.
//

import UIKit

class SixSameViewController: UIViewController {
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

    @IBOutlet weak var name:UILabel?
    @IBOutlet weak var changeNameTextField:UITextField?
    let dic = ["登录账号":"userName","真实姓名":"name","手机":"phone","Email":"email","QQ":"QQNumber","邮编":"postCode"]
      var saveBarItem = UIBarButtonItem()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.changeNameTextField?.enabled = true
        if(self.title != "登录账号") {
        self.saveBarItem = UIBarButtonItem(title: "保存", style:.Plain, target: self, action: #selector(SixSameViewController.save(_:)))
        self.navigationItem.rightBarButtonItem = self.saveBarItem
        }
            switch self.title!{
            case "登录账号":
                self.name?.text = "登录账号"
                //不可编辑
                self.changeNameTextField?.enabled = false
            case "真实姓名":
                self.name?.text = "真实姓名"
               self.changeNameTextField?.keyboardType = .Default
            case "手机":
                self.name?.text = "手机"
               self.changeNameTextField?.keyboardType = .NumberPad
            case "Email":
                self.name?.text = "Email"
               self.changeNameTextField?.keyboardType = .EmailAddress
            case "QQ":
                self.name?.text = "QQ"
                self.changeNameTextField?.keyboardType = .NumberPad
            case "邮编":
                self.name?.text = "邮编"
               self.changeNameTextField?.keyboardType = .NumberPad
            default:break
            }
        let userDefault = NSUserDefaults.standardUserDefaults()
        self.changeNameTextField?.text = userDefault.valueForKey(dic[(self.name?.text)!]!) as? String
}
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func keyBoardHide(sender: UIControl) {
       self.changeNameTextField?.resignFirstResponder()
    }

    func save(sender:UIBarButtonItem){
    
        //做save的一些事情
        //对每个进行保存的时候要进行判断 用正则表达式进行匹配
      let userDefault = NSUserDefaults.standardUserDefaults()
        switch self.title!{
          case "手机":
let PhonePattern = "^((13[0-9])|(17[0-9])|(15[^4,\\D])|(18[0,5-9]))\\d{8}$"
            let matcher: RegexHelper
            do {
               
                var phoneText = self.changeNameTextField?.text
                phoneText = phoneText!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                matcher = try RegexHelper(PhonePattern)
                if matcher.match(phoneText!){
                    userDefault.setValue(phoneText, forKey:dic[(self.name?.text)!]!)
                    ProgressHUD.showSuccess("保存成功")
                    self.navigationController?.popViewControllerAnimated(true)
                }else{
                    ProgressHUD.showError("填写手机格式错误")
                }

            }catch{
                print("error")
            }

           
            
        case "Email":
            let mailPattern =
            "^([a-z0-9_\\.-]+)@([\\da-z\\.-]+)\\.([a-z\\.]{2,6})$"
            let matcher: RegexHelper
            do {
                matcher = try RegexHelper(mailPattern)
                var emailText = self.changeNameTextField?.text
                    emailText = emailText!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                if matcher.match(emailText!){
                    userDefault.setValue(self.changeNameTextField?.text, forKey:dic[(self.name?.text)!]!)
                    ProgressHUD.showSuccess("保存成功")
                    self.navigationController?.popViewControllerAnimated(true)
                }else{
                    ProgressHUD.showError("填写邮箱格式错误")
                }

            }catch{
                print("error")
            }
                  case "QQ":
            let QQPattern =
            "^" + "\\" + "d{5,10}$"
            let matcher: RegexHelper
            do {
                var QQText = self.changeNameTextField?.text
                QQText = QQText!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
               
                matcher = try RegexHelper(QQPattern)
                if matcher.match(QQText!){
                    userDefault.setValue(QQText, forKey:dic[(self.name?.text)!]!)
                    ProgressHUD.showSuccess("保存成功")
                    self.navigationController?.popViewControllerAnimated(true)
                }else{
                    ProgressHUD.showError("填写QQ格式错误")
                }

            }catch{
                print("error")
            }
           
        case "邮编":
            let PostCodePattern =
                "^[1-9][0-9]{5}$"
            do {let matcher = try  RegexHelper.init(PostCodePattern)
                var PostCodeText = self.changeNameTextField?.text
                PostCodeText = PostCodeText!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
              
                if matcher.match(PostCodeText!){
                    userDefault.setValue(PostCodeText, forKey:dic[(self.name?.text)!]!)
                    ProgressHUD.showSuccess("保存成功")
                    self.navigationController?.popViewControllerAnimated(true)
                }else{
                    ProgressHUD.showError("填写邮编格式错误")
                               }

            }catch{
                print("error")
            }
            
        default:break
        }
        
        
    }
   }
