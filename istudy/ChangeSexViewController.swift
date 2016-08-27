//
//  ChangeSexViewController.swift
//  istudy
//
//  Created by hznucai on 16/3/6.
//  Copyright © 2016年 hznucai. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
class ChangeSexViewController: UIViewController {
    @IBOutlet weak var manBtn:UIButton?
    //选择性别的
    var selectedSex = NSInteger()
    @IBOutlet weak var womanBtn:UIButton?
    override func viewDidLoad() {
        super.viewDidLoad()
       
         self.manBtn?.addTarget(self, action: #selector(ChangeSexViewController.selectMan), forControlEvents: .TouchUpInside)
        self.womanBtn?.addTarget(self, action: #selector(ChangeSexViewController.selectWoman), forControlEvents: .TouchUpInside)
        let saveBarItem = UIBarButtonItem(title: "保存", style:.Plain, target: self, action: #selector(ChangeSexViewController.save(_:)))
        self.navigationItem.rightBarButtonItem = saveBarItem
}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //选择男和选择女时候的不同
    func selectMan() {
        self.manBtn?.setImage(UIImage(named: "选择信件"), forState: .Normal)
        self.womanBtn?.setImage(UIImage(named: "未选择信件"), forState: .Normal)
        self.selectedSex = 1
    }
    func selectWoman() {
        self.womanBtn?.setImage(UIImage(named: "选择信件"), forState: .Normal)
        self.manBtn?.setImage(UIImage(named: "未选择信件"), forState: .Normal)
        self.selectedSex = 0
    }
    //做保存的操作
    func save(sender:UIBarButtonItem){
        //做save的一些事情
        var sex = String()
        if(self.selectedSex == 1){
            sex = "男"
        }else{
            sex = "女"
        }
    let userDefault = NSUserDefaults.standardUserDefaults()
        userDefault.setValue(sex, forKey: "gender")
        self.saveProfile()
            }
    
    override func viewWillAppear(animated: Bool) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if(userDefaults.valueForKey("gender") == nil){
            
        }else if(userDefaults.valueForKey("gender") as! String == "男"){
            self.manBtn?.setImage(UIImage(named: "选择信件"), forState: .Normal)
            self.womanBtn?.setImage(UIImage(named: "未选择信件"), forState: .Normal)
            self.selectedSex = 1
        
        }else{
            self.womanBtn?.setImage(UIImage(named: "选择信件"), forState: .Normal)
            self.manBtn?.setImage(UIImage(named: "未选择信件"), forState: .Normal)
            self.selectedSex = 0
        }
    }
    override func viewWillDisappear(animated: Bool) {
        ProgressHUD.dismiss()
    }
    //保存性别
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
                    print(json["retcode"].number)
                }
            case .Failure(_):ProgressHUD.showError("保存失败")
            }
        }
    }
    override func viewDidDisappear(animated: Bool) {
        ProgressHUD.dismiss()
    }
}
