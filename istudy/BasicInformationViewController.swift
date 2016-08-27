//
//  BasicInformationViewController.swift
//  istudy
//
//  Created by hznucai on 16/3/3.
//  Copyright © 2016年 hznucai. All rights reserved.
//

import UIKit
import CoreData
class BasicInformationViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UINavigationControllerDelegate,UIImagePickerControllerDelegate{
    var dic = [0:["头像","登录账号","真实姓名","性别"],1:["手机","Email","通信地址","QQ","邮编"]]
    var managedContext:NSManagedObjectContext?
    var selectedImageData = NSData()
    var fetchedResults = [PersonalHeadPortrait]()
    
    var detailArray = NSMutableArray()
    @IBOutlet weak var tableView:UITableView?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.hidden = true
    self.automaticallyAdjustsScrollViewInsets = false
   self.tableView?.delegate = self
   self.tableView?.dataSource = self
   self.tableView?.tableFooterView = UIView()
 self.tableView?.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: "basicInformationCell")
        
    }

        // Do any additional setup after loading the view.
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //tableView的代理
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let array = dic[section]! as NSArray
        return array.count
    }
     func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "basicInformationCell")
        let array = self.dic[indexPath.section]! as NSArray
        cell.textLabel?.text = array[indexPath.row] as? String
        if indexPath.section == 0{
            if indexPath.row == 0{
                let imageView = UIImageView(frame: CGRectMake(SCREEN_WIDTH - 80, 5, 40, 40))
              let userDefault = NSUserDefaults.standardUserDefaults()
               
            if(userDefault.valueForKey("avtarurl") as? String != nil && userDefault.valueForKey("avtarurl") as! String != ""){
                   imageView.sd_setImageWithURL(NSURL(string: userDefault.valueForKey("avtarurl") as! String), placeholderImage: UIImage(named: "默认头像"))
                }else{
                   imageView.image = UIImage(named: "默认头像")
                }
               imageView.layer.masksToBounds = true
                imageView.layer.cornerRadius = 20
                cell.contentView.addSubview(imageView)
            }
            else{
                cell.detailTextLabel?.text = detailArray[indexPath.row - 1] as? String
            }
        }
        cell.accessoryType = .DisclosureIndicator
        return cell
    
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let personSB = UIStoryboard(name: "Personal", bundle: nil)
        var vc = UIViewController()
        let section = indexPath.section
        let row = indexPath.row
        switch section{
        case 0:
            switch row{
            case 0:
                //跳出选头像的ActionSheet 这里还有Bug 以后再调
             vc = personSB.instantiateViewControllerWithIdentifier("ChangeHeadPortraitVC") as! ChangeHeadPortraitViewController
              
            case 1:vc = personSB.instantiateViewControllerWithIdentifier("SixSameVC") as! SixSameViewController
                vc.title = "登录账号"
            case 2:vc = personSB.instantiateViewControllerWithIdentifier("SixSameVC") as! SixSameViewController
                vc.title = "真实姓名"
            case 3:
                vc = personSB.instantiateViewControllerWithIdentifier("ChangeSexVC") as! ChangeSexViewController
                vc.title = "性别"
            default:break
            }
        case 1:
            switch row{
            case 0: vc = personSB.instantiateViewControllerWithIdentifier("SixSameVC") as! SixSameViewController
                vc.title = "手机"
            case 1:vc = personSB.instantiateViewControllerWithIdentifier("SixSameVC") as! SixSameViewController
                vc.title = "Email"
            case 2:vc = personSB.instantiateViewControllerWithIdentifier("AdressVC")
                as! AdressViewController
               vc.title = "通信地址"
            case 3:vc = personSB.instantiateViewControllerWithIdentifier("SixSameVC") as! SixSameViewController
                vc.title = "QQ"
            case 4:vc = personSB.instantiateViewControllerWithIdentifier("SixSameVC") as! SixSameViewController
                vc.title = "邮编"
            default:break
            }
        default:break
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1{
            return "联系方式"
        }
        return ""
    }
    override func viewWillLayoutSubviews() {
       super.viewWillLayoutSubviews()
        self.tableView?.contentInset = UIEdgeInsetsZero
        self.tableView?.scrollIndicatorInsets = UIEdgeInsetsZero
    }
    //设置头像等基本信息的显示
    override func viewWillAppear(animated: Bool) {
            let userDefault = NSUserDefaults.standardUserDefaults()
        if(userDefault.valueForKey("userName") == nil){
            self.detailArray.addObject("未设置账号")
        }else{
       self.detailArray.addObject(userDefault.valueForKey("userName") as! String)
        }
        if(userDefault.valueForKey("name") == nil){
            self.detailArray.addObject("未设置姓名")
        }else{
            self.detailArray.addObject(userDefault.valueForKey("name") as! String)
        }
        if(userDefault.valueForKey("gender") == nil){
            self.detailArray.addObject("未设置性别")
        }else{
     self.detailArray.addObject(userDefault.valueForKey("gender") as! String)
        }
      self.tableView?.reloadData()
    }
    override func viewDidDisappear(animated: Bool) {
        self.detailArray.removeAllObjects()
    }
//    //头像选取的函数
//    func selectHead() {
//        let imagePicker = UIImagePickerController()
//        imagePicker.delegate = self
//        imagePicker.allowsEditing = true
//        let actionSheet = UIAlertController(title: "", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)
//        let fromCamera = UIAlertAction(title: "拍照", style: UIAlertActionStyle.Default) { (action:UIAlertAction) in
//            if(UIImagePickerController.isSourceTypeAvailable(.Camera)){
//           imagePicker.sourceType = .Camera
//                self.presentViewController(imagePicker, animated: true, completion: nil)
//            }else{
//                ProgressHUD.showError("不支持相机")
//            }
//        }
//        let fromPhotoAsset = UIAlertAction(title: "从手机相册选择", style: UIAlertActionStyle.Default) { (action:UIAlertAction) in
//              if(UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary)){
//                imagePicker.sourceType = .PhotoLibrary
//                self.presentViewController(imagePicker, animated: true, completion: nil)
//              }else{
//                         ProgressHUD.showError("不支持相册")
//            }
//        }
//        let cancelBtn = UIAlertAction(title: "取消", style: UIAlertActionStyle.Destructive, handler: nil)
//        actionSheet.addAction(fromCamera)
//        actionSheet.addAction(fromPhotoAsset)
//        actionSheet.addAction(cancelBtn)
//      self.presentViewController(actionSheet, animated: true) { 
//        dispatch_async(dispatch_get_main_queue(), {
//            actionSheet.dismissViewControllerAnimated(true, completion: nil)
//        })
//        }
//    }
//    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
//        picker.dismissViewControllerAnimated(true, completion: nil)
//    }
//    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
//        let image = info[UIImagePickerControllerEditedImage] as! UIImage
//        //进行保存 还有头像的变换
//        let cell = self.tableView?.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! BasicInformationTableViewCell
//        cell.headImage?.image = image
//        self.tableView?.reloadData()
//    self.selectedImageData = UIImagePNGRepresentation(image)!
//        //保存
//        let app = UIApplication.sharedApplication().delegate as! AppDelegate
//        self.managedContext = app.managedObjectContext
//        let entity = NSEntityDescription.entityForName("PersonalHeadPortrait", inManagedObjectContext: self.managedContext!)
//        let person = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: self.managedContext) as! PersonalHeadPortrait
//        person.headPortraitData = self.selectedImageData
//        
//        do {try self.managedContext?.save()
//            ProgressHUD.showSuccess("保存成功")
//        }catch{
//            ProgressHUD.showError("保存失败")
//        }
//    picker.dismissViewControllerAnimated(true, completion: nil)
//    }
    override func viewWillDisappear(animated: Bool) {
        ProgressHUD.dismiss()
    }
}
