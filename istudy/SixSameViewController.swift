//
//  SixSameViewController.swift
//  istudy
//
//  Created by hznucai on 16/3/6.
//  Copyright © 2016年 hznucai. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
class SixSameViewController: UIViewController {
    //利用正则表达式进行匹配
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
//未保存前的值 如果保存失败的话 就保存前面的值
    var beforeValue = ""
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
//保存的时候要进行正则表达式的匹配
    func save(sender:UIBarButtonItem){

        //做save的一些事情
        //对每个进行保存的时候要进行判断 用正则表达式进行匹配
      let userDefault = NSUserDefaults.standardUserDefaults()
        if(userDefault.valueForKey(self.dic[self.title!]!) as? String != nil && userDefault.valueForKey(self.dic[self.title!]!) as! String != ""){
            beforeValue = userDefault.valueForKey(self.dic[self.title!]!)! as! String
        }
        switch self.title!{
            case "真实姓名":
            let text = self.changeNameTextField?.text
           
         
         
               userDefault.setValue(text, forKey: "name")
            self.saveProfile()
          case "手机":
            //移动 联通 电信的都搞好...
let ChinaMobile = "(^1(3[4-9]|4[7]|5[0-27-9]|7[8]|8[2-478])\\d{8}$)|(^1705\\d{7}$)"
let ChinaUnicom = "(^1(3[0-2]|4[5]|5[56]|7[6]|8[56])\\d{8}$)|(^1709\\d{7}$)"
let ChinaTelecom = "(^1(33|53|77|8[019])\\d{8}$)|(^1700\\d{7}$)"
var match = false

            var CMMatcher: RegexHelper
            do {
               
                var phoneText = self.changeNameTextField?.text
                phoneText = phoneText!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                CMMatcher = try RegexHelper(ChinaMobile)
                if CMMatcher.match(phoneText!){
                    userDefault.setValue(phoneText, forKey:dic[(self.name?.text)!]!)
                   match = true
            }else{
                    do{  CMMatcher = try RegexHelper(ChinaUnicom)
                        if CMMatcher.match(phoneText!){
                            
                            userDefault.setValue(phoneText, forKey:dic[(self.name?.text)!]!)
                            match = true
                        }else{
                            do{
                                CMMatcher = try RegexHelper(ChinaTelecom)
                                if CMMatcher.match(phoneText!){
                                    userDefault.setValue(phoneText, forKey:dic[(self.name?.text)!]!)
                                    match = true
                                }
                                
                            }catch{
                                
                            }
                        }
                        
                    }catch{
                        print("error")
                    }
                }

            }catch{
                print("error")
            }
if(match == true){
    self.saveProfile()
}else{
    ProgressHUD.showError("手机格式填写错误")
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
                    self.saveProfile()
                   
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
                    self.saveProfile()
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
                  self.saveProfile()
                                 }else{
                    ProgressHUD.showError("填写邮编格式错误")
                               }

            }catch{
                print("error")
            }
            
        default:break
        }
       

    }
    //保存的按钮 传的参数和未保存前的值 若保存失败的话 就还是保存以前的值
    func saveProfile() {
        
        let userDefault = NSUserDefaults.standardUserDefaults()
        var email = ""
        var phone = ""
        var avtarurl = ""
        var cls = ""
        var name = ""
        var gender = ""
        if(userDefault.valueForKey("email") as? String != nil && userDefault.valueForKey("email") as! String != ""){
            email = userDefault.valueForKey("email") as! String
        }
        if(userDefault.valueForKey("phone") as? String != nil && userDefault.valueForKey("phone") as! String != ""){
            phone = userDefault.valueForKey("phone") as! String
        }
        if(userDefault.valueForKey("avtarurl") as? String != nil && userDefault.valueForKey("avtarurl") as! String != ""){
            avtarurl = userDefault.valueForKey("avtarurl") as! String
        }
        if(userDefault.valueForKey("cls") as? String != nil && userDefault.valueForKey("cls") as! String != ""){
            cls = userDefault.valueForKey("cls") as! String
        }
        if(userDefault.valueForKey("name") as? String != nil && userDefault.valueForKey("name") as! String != ""){
            name = userDefault.valueForKey("name") as! String
        }
        if(userDefault.valueForKey("gender") as? String != nil && userDefault.valueForKey("gender") as! String != ""){
            gender = userDefault.valueForKey("gender") as! String
        }
        
        let dicParam:[String:AnyObject] = [
            "name":name,
            "gender":gender,
            "cls": cls,
            "phone":phone,
            "email": email,
            "avtarurl":avtarurl]          //进行base64字符串加密
        var result = String()
        do { let parameterData = try NSJSONSerialization.dataWithJSONObject(dicParam, options: NSJSONWritingOptions.PrettyPrinted)
            
            result = parameterData.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
        }catch{
            ProgressHUD.showError("保存失败")
        }
        let parameter:[String:AnyObject] = ["authtoken":userDefault.valueForKey("authtoken") as! String,"data":result]
        Alamofire.request(.POST, "http://dodo.hznu.edu.cn/api/saveprofile", parameters: parameter, encoding: ParameterEncoding.URL, headers: nil).responseJSON { (response) in
            switch response.result{
            case .Success(let Value):
                let json = JSON(Value)
                if(json["retcode"].number == 0){
                    ProgressHUD.showSuccess("保存成功")
                     self.navigationController?.popViewControllerAnimated(true)
                }else{
                    ProgressHUD.showError("保存失败")
                    userDefault.setValue(self.beforeValue, forKey: self.dic[self.title!]!)
                    print(json["retcode"].number)
                }
            case .Failure(_):
                 userDefault.setValue(self.beforeValue, forKey: self.dic[self.title!]!)
                ProgressHUD.showError("保存失败")
            }
        }
        }
    override func viewWillDisappear(animated: Bool) {
        ProgressHUD.dismiss()
    }
   }
