//
//  ContactPersonViewController.swift
//  istudy
//
//  Created by hznucai on 16/3/23.
//  Copyright © 2016年 hznucai. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import Font_Awesome_Swift
import DZNEmptyDataSet
//传回联系人
typealias push_selectedPersons = (idArray:NSMutableArray,nameArray:NSMutableArray) -> Void
class ContactPersonViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,DZNEmptyDataSetSource{
    @IBOutlet weak var contactPersonTableView:UITableView?
    @IBOutlet weak var btmView:UIView!
    @IBOutlet weak var saveBtn:UIButton!
    //控制列表是否被打开
    var selectArr = NSMutableArray()
    //总共的数据
    var items = NSArray()
    //每一个单元格下的数据
    var contacterlistArray = NSArray()
    //选择的人的id
    //全选的每组
    var allSelArray = NSMutableArray()
    var idArray = NSMutableArray()
    var nameArray = NSMutableArray()
    var callBack:push_selectedPersons?
    //视图的加载
    override func viewDidLoad() {
        self.idArray.removeAllObjects()
        self.nameArray.removeAllObjects()
        super.viewDidLoad()
        //加载name数组
        self.saveBtn.setFAText(prefixText: "", icon: FAType.FASave, postfixText: "", size: 25, forState: .Normal)
        self.saveBtn.backgroundColor = RGB(0, g: 153, b: 255)
        self.saveBtn.tintColor = UIColor.whiteColor()
       ShowBigImageFactory.topViewEDit(self.btmView)
        self.contactPersonTableView?.delegate = self
        self.contactPersonTableView?.dataSource = self
        self.contactPersonTableView?.separatorStyle = .SingleLine
      
        self.contactPersonTableView?.tableFooterView = UIView()
    
    self.contactPersonTableView?.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(ContactPersonViewController.headerRefresh))
        self.contactPersonTableView?.mj_header.beginRefreshing()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //实现sectionView的视图 也像注册headerView 一样进行
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let identifer = "tableHeader"
        var view = tableView.dequeueReusableHeaderFooterViewWithIdentifier(identifer)
        if(view == nil){
         view = UITableViewHeaderFooterView(reuseIdentifier: identifer)
          
        }
        for view in (view?.subviews)!{
            view.removeFromSuperview()
        }
        //组的名称 还有箭头图片 记录人数
        let tempArray = self.items[section].valueForKey("ContacterList") as! NSArray
        
        let groupNameLabel = UILabel(frame: CGRectMake(40,0,SCREEN_WIDTH - 90,40))
        groupNameLabel.text = (self.items[section].valueForKey("Label") as? String)! + "(" + "\(tempArray.count)" + "人)"
       //箭头的视图
        
        let imageView = UIImageView(frame: CGRectMake(0, 0, 40, 40))
        if(self.selectArr[section] as! NSObject == 1){
            imageView.setFAIconWithName(FAType.FAAngleDown, textColor: UIColor.blueColor())

        }else{
            imageView.setFAIconWithName(FAType.FAAngleRight, textColor: UIColor.blueColor())
        }
       
        let btn = UIButton(frame: CGRectMake(0,0,SCREEN_WIDTH - 50,60))
        //全选的按钮
        let allSelBtn = UIButton(frame: CGRectMake(SCREEN_WIDTH - 50,5,35,35))
        allSelBtn.layer.cornerRadius = 17.5
       
        allSelBtn.layer.masksToBounds = true
        if(self.allSelArray[section] as! NSObject == 1){
            allSelBtn.setFAText(prefixText: "", icon: FAType.FACheckCircle, postfixText: "", size: 30, forState: .Normal)

        }else{
              allSelBtn.setFAText(prefixText: "", icon: FAType.FACircleThin, postfixText: "", size: 30, forState: .Normal)
        }
        allSelBtn.addTarget(self, action: #selector(ContactPersonViewController.selectedThisGroup(_:)), forControlEvents: .TouchUpInside)
        allSelBtn.tag = section + 100
        view!.addSubview(allSelBtn)
        btn.tag = section
        btn.addTarget(self, action: #selector(ContactPersonViewController.btnOpenList(_:)), forControlEvents: .TouchUpInside)
          view!.addSubview(btn)
          view!.addSubview(imageView)
        view!.addSubview(groupNameLabel)
        return view
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
//像qq一样打开
    func btnOpenList(sender:UIButton){
        if(self.selectArr[sender.tag] as! NSObject == 0){
            self.selectArr[sender.tag] = 1
        }else{
            self.selectArr[sender.tag] = 0
        }
        self.contactPersonTableView?.reloadData()
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.items.count
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 50
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //每一组究竟有几个列表
        if(self.selectArr[section] as! NSObject == 1){
        self.contacterlistArray = self.items[section].valueForKey("ContacterList") as! NSArray
        return self.contacterlistArray.count
        }else{
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //首先赋值每个组的联系人表
        self.contacterlistArray = self.items[indexPath.section].valueForKey("ContacterList") as! NSArray
        let cell = tableView.dequeueReusableCellWithIdentifier("ContactPersonTableViewCell")
        as! ContactPersonTableViewCell
        
        //先不赋值
         if(self.selectArr[indexPath.section] as! NSObject == 1){
        cell.teacherHeadImageView?.sd_setImageWithURL(NSURL(string: self.contacterlistArray[indexPath.row].valueForKey("Face") as! String), placeholderImage: UIImage(named: "默认头像"))
            cell.teacherHeadImageView?.contentMode = .ScaleAspectFit
            cell.teacherHeadImageView?.layer.cornerRadius = 25
            cell.teacherHeadImageView?.layer.masksToBounds = true
        cell.teacherNameLabel?.text = self.contacterlistArray[indexPath.row].valueForKey("Name") as? String
        cell.selectedBtn?.addTarget(self, action: #selector(ContactPersonViewController.selectPerson(_:)), forControlEvents: .TouchUpInside)
        cell.id = self.contacterlistArray[indexPath.row].valueForKey("Id") as! NSInteger
        cell.selectedBtn?.layer.cornerRadius = 17.5
        cell.selectedBtn?.layer.masksToBounds = true
   
        //自定义btn的tag
        cell.selectedBtn?.setImage(UIImage(named: "未选择信件" ), forState: .Normal)
        cell.selectedBtn!.customTag = "\(indexPath.section)" + "-" + "\(indexPath.row)"
            for i in 0 ..< self.idArray.count{
                if(self.idArray[i] as! NSInteger == cell.id){
                  
                cell.selectedBtn?.setImage(UIImage(named: "选择信件"), forState: .Normal)
                }
            }
        cell.selectionStyle = .None
        }
        return cell
    }
    //全选这组的按钮 全选的按钮
    func selectedThisGroup(sender:UIButton){
        let trueTag = sender.tag - 100
        let tempArr = self.items[trueTag].valueForKey("ContacterList") as! NSArray
        
        if(self.allSelArray[trueTag] as! NSObject == 0){
            self.allSelArray[trueTag] = 1
            sender.setFAText(prefixText: "", icon: FAType.FACheckCircle, postfixText: "", size: 30, forState: .Normal)
            //这一组别全部加进来
            for i in 0 ..< tempArr.count{
                //不能重复加
                var tempIn = 0
                while  tempIn < self.idArray.count {
                    if(self.idArray[tempIn] as! NSInteger == tempArr[i].valueForKey("Id") as! NSInteger){
                        break
                    }
                    tempIn += 1
                }
                if(tempIn == self.idArray.count){
                self.idArray.addObject(tempArr[i].valueForKey("Id") as! NSInteger)
                self.nameArray.addObject(tempArr[i].valueForKey("Name") as! String)
            }
            }
        }else{
            
            sender.setFAText(prefixText: "", icon: FAType.FACircleO, postfixText: "", size: 30, forState: .Normal)
            self.allSelArray[trueTag] = 0
            
            for out in 0 ..< tempArr.count{
                var cnt = self.idArray.count
                var tempIn = 0
                while tempIn < cnt {
                    if(tempArr[out].valueForKey("Id") as! NSInteger == self.idArray[tempIn] as! NSInteger){
                        self.idArray.removeObjectAtIndex(tempIn)
                        self.nameArray.removeObjectAtIndex(tempIn)
                        cnt -= 1
                    }
                    tempIn += 1
                }
            }
            
        }
        self.contactPersonTableView?.reloadData()
    }

    func selectPerson(sender:CustomContactSelectBtn)  {
         let customTag = sender.customTag
        //然后分别拿出section和row
        var section = ""
        var row = ""
        var temp = 0
        //截取出section和row
        while (temp < customTag.characters.count) {
            let adv = customTag.startIndex.advancedBy(temp)
            if(customTag[adv] == "-"){
                temp += 1
                break
            }
            section.append(customTag[adv])
            temp += 1
        }
        while (temp < customTag.characters.count) {
            let adv = customTag.startIndex.advancedBy(temp)
            row.append(customTag[adv])
            temp += 1
        }
        let indexPath = NSIndexPath(forRow: NSInteger(row)!, inSection: NSInteger(section)!)
       
        let cell = self.contactPersonTableView?.cellForRowAtIndexPath(indexPath) as! ContactPersonTableViewCell
            //根据image来进行判断
        if sender.currentImage == UIImage(named: "选择信件")
          {
        
            //遍历删除
            let id = cell.id
            for i in 0 ..< self.idArray.count{
                if(self.idArray[i] as! NSInteger == id){
                    self.idArray.removeObjectAtIndex(i)
                    self.nameArray.removeObjectAtIndex(i)
                    break
                }
            }
         cell.selectedBtn?.setImage(UIImage(named: "未选择信件" ), forState: .Normal)
            //headerView里面的不能设置为全选
              self.allSelArray[NSInteger(section)!] = 0
            let view:UITableViewHeaderFooterView = (self.contactPersonTableView?.headerViewForSection(NSInteger(section)!))!
            //查询控件
                let btn = view.viewWithTag(NSInteger(section)! + 100) as! UIButton
                   btn.setFAText(prefixText: "", icon: FAType.FACircleO, postfixText: "", size: 30, forState: .Normal)

        }else{
             self.idArray.addObject(cell.id)
             self.nameArray.addObject((cell.teacherNameLabel?.text)!)
           
           cell.selectedBtn?.setImage(UIImage(named: "选择信件" ), forState: .Normal)
        }
      self.contactPersonTableView?.reloadData()
       }
    
    
 //提交联系人
    @IBAction func save(sender:UIButton){
        //用集合来去重
        let idSet = NSSet(array: self.idArray as [AnyObject])
        self.idArray = NSMutableArray(array:(idSet.allObjects as! [NSInteger]))
        let nameSet = NSSet(array: self.nameArray as [AnyObject])
        self.nameArray = NSMutableArray(array: nameSet.allObjects as! [String])
        
        self.callBack!(idArray:self.idArray,nameArray:self.nameArray)
        //去重
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    func headerRefresh() {
    //向后台请求联系人
        let userDefault = NSUserDefaults.standardUserDefaults()
        let authtoken = userDefault.valueForKey("authtoken") as! String
        let dic:[String:AnyObject] = ["authtoken":authtoken]
        Alamofire.request(.POST, "http://dodo.hznu.edu.cn/api/messagecontact", parameters: dic, encoding: ParameterEncoding.URL, headers: nil).responseJSON { (response) in
            switch response.result{
            case .Failure(_):
                ProgressHUD.showError("请求失败")
                self.items = NSArray()
                dispatch_async(dispatch_get_main_queue(), {
                    self.contactPersonTableView?.mj_header.endRefreshing()
                    self.contactPersonTableView?.emptyDataSetSource = self
                    self.contactPersonTableView?.reloadData()
                })

                           case .Success(let Value):
                let json = JSON(Value)
             
                if(json["retcode"].number != 0){
                    self.items = NSArray()
                    ProgressHUD.showError("请求失败")
                   
                    dispatch_async(dispatch_get_main_queue(), {
                        self.contactPersonTableView?.mj_header.endRefreshing()
                        self.contactPersonTableView?.emptyDataSetSource = self
                        self.contactPersonTableView?.reloadData()
                    })

                }else{
                    self.items = json["items"].arrayObject! as NSArray
                    for _ in 0 ..< self.items.count{
                        self.allSelArray.addObject(0)
                    }
                    //默认都是没有分组的
                    for _ in 0 ..< self.items.count{
                        self.selectArr.addObject(0)
                    }
                    dispatch_async(dispatch_get_main_queue(), {
                        self.contactPersonTableView?.mj_header.endRefreshing()
                        if(self.items.count == 0){
                            self.contactPersonTableView?.emptyDataSetSource = self
                        }
                        self.contactPersonTableView?.reloadData()
                    })
                }
            }
        }
        }
    override func viewWillDisappear(animated: Bool) {
              ProgressHUD.dismiss()
    }
       func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let string = "暂无联系人信息"
        let dic = [NSFontAttributeName:UIFont.boldSystemFontOfSize(18.0),
                   NSForegroundColorAttributeName:UIColor.grayColor()]
        let attriString = NSMutableAttributedString(string: string, attributes: dic)
        return attriString
    }
    }

