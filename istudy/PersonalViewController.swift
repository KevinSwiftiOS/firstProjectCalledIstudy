//
//  PersonalViewController.swift
//  istudy
//
//  Created by hznucai on 16/3/3.
//  Copyright © 2016年 hznucai. All rights reserved.
//

import UIKit
import CoreData
class PersonalViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
//    var managedContext:NSManagedObjectContext?
//    var fetchedResults = [PersonalHeadPortrait]()
//    var selectedImageData = NSData()
    @IBOutlet weak var tableView:UITableView?
    //账号
    @IBOutlet weak var userName:UILabel?
    //头像
    @IBOutlet weak var headPortrait:UIImageView?
    //tableView的代理
    override func viewDidLoad() {
               super.viewDidLoad()
        self.navigationController?.navigationBar.barTintColor = RGB(0, g: 153, b: 255)
        self.navigationController?.navigationBar.tintColor = UIColor.blackColor()
        self.tableView?.delegate = self
        self.tableView?.dataSource = self
        self.tableView?.tableFooterView = UIView()
        //注册cell 没有tableViewCell的时候可以直接用
        self.tableView?.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: "personalCell")
        //头像的圆角设置
        self.headPortrait?.image = UIImage(named: "默认头像")
        self.headPortrait?.layer.masksToBounds = true
        self.headPortrait?.layer.cornerRadius = 50
        
        // Do any additional setup after loading the view.
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //tableView的代理
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("personalCell")
        let row = indexPath.row
        switch row{
        case 0:
         cell?.textLabel?.text = "基本资料"
         cell?.accessoryType = .DisclosureIndicator
         cell?.imageView?.image = UIImage(named: "头像个人信息")
        case 1:
         cell?.textLabel?.text = "安全设置"
         cell?.accessoryType = .DisclosureIndicator
         cell?.imageView?.image = UIImage(named: "安全信息")
        case 2:
         cell?.textLabel?.text = "退出登录"
         cell?.imageView?.image = UIImage(named: "退出登录")
         cell?.accessoryType = .None
        default:break
        }
        return cell!
    }
    //选择基本信息 或者头像设置等 跳转到新的界面去
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let row = indexPath.row
        switch row{
        case 0:
        //跳转到基本资料的界面
        let basicInformationVC = UIStoryboard(name: "Personal", bundle: nil).instantiateViewControllerWithIdentifier("basicInformationVC") as! BasicInformationViewController
        basicInformationVC.title = "基本资料"
         self.navigationController?.pushViewController(basicInformationVC, animated: true)
        case 1:
        //跳转到安全设置的界面
        let securitySettingsVC = UIStoryboard(name: "Personal", bundle: nil).instantiateViewControllerWithIdentifier("SecuritySettingsVC") as! SecuritySettingsViewController
        securitySettingsVC.title = "安全设置"
        self.navigationController?.pushViewController(securitySettingsVC, animated: true)
            
        case 2:
        let alert = UIAlertController(title: "确定退出吗", message: nil, preferredStyle: .Alert)
        let action1 = UIAlertAction(title: "确定", style: .Default, handler: { (alertAction) -> Void in
                //确定退出
          let userDefault = NSUserDefaults.standardUserDefaults()
            userDefault.setValue(nil, forKey: "name")
            userDefault.setValue(nil, forKey: "userName")
            userDefault.setValue(nil, forKey: "passWord")
            userDefault.setValue(nil, forKey: "authtoken")
            userDefault.setValue(nil, forKey: "name")
            userDefault.setValue(nil, forKey: "gender")
            userDefault.setValue(nil, forKey: "cls")
            userDefault.setValue(nil, forKey: "phone")
            userDefault.setValue(nil, forKey: "QQNumber")
            userDefault.setValue(nil, forKey: "postCode")
            userDefault.setValue(nil, forKey: "address")
            ProgressHUD.showSuccess("退出成功")
            let loginNavVC = UIStoryboard(name: "LoginAndReset", bundle: nil).instantiateViewControllerWithIdentifier("LoginNavigationVC") as! UINavigationController
            self.presentViewController(loginNavVC, animated: true, completion: nil)
            })
        let action2 = UIAlertAction(title: "取消", style: .Destructive, handler: nil)
            alert.addAction(action1)
            alert.addAction(action2)
            self.presentViewController(alert, animated: true, completion: nil)
        default:break
       }
    }
    //头部视图的加载 例如图片等
    override func viewWillAppear(animated: Bool) {

let userDefault = NSUserDefaults.standardUserDefaults()

        if(userDefault.valueForKey("avtarurl") as? String != nil && userDefault.valueForKey("avtarurl") as! String != ""){
            self.headPortrait?.sd_setImageWithURL(NSURL(string: userDefault.valueForKey("avtarurl") as! String), placeholderImage: UIImage(named: "默认头像"))
        }else{
            self.headPortrait?.image = UIImage(named: "默认头像")
        }
                    if(userDefault.valueForKey("userName") == nil){
                        self.userName?.text = "未设置账号"
                    }else{
                        self.userName?.text = userDefault.valueForKey("userName")
                        as? String
                    }
                
                }
    
    override func viewWillDisappear(animated: Bool) {
        ProgressHUD.dismiss()
    }
  }
