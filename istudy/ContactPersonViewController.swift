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
//传回联系人
typealias push_selectedPersons = (idArray:NSMutableArray,items:NSArray) -> Void
class ContactPersonViewController: UIViewController,UITableViewDelegate,UITableViewDataSource{
    @IBOutlet weak var contactPersonTableView:UITableView?
    //控制列表是否被打开
    var selectArr = NSMutableArray()
    //总共的数据
    var items = NSArray()
    //每一个单元格下的数据
    var contacterlistArray = NSArray()
    //选择的人的id
    var selectedPersonIdArray = NSMutableArray()
    var callBack:push_selectedPersons?
    override func viewDidLoad() {
        super.viewDidLoad()
        //加载name数组
       
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
    //实现sectionView的视图
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRectMake(0,0,SCREEN_WIDTH,30))
        view.backgroundColor = UIColor.whiteColor()
        
        //组的名称 还有箭头图片 记录人数
        let tempArray = self.items[section].valueForKey("ContacterList") as! NSArray
        
        let groupNameLabel = UILabel(frame: CGRectMake(40,0,SCREEN_WIDTH - 40,30))
        groupNameLabel.text = (self.items[section].valueForKey("Label") as? String)! + "(" + "\(tempArray.count)" + "人)"
       //箭头的视图
        
        let imageView = UIImageView(frame: CGRectMake(0, 0, 40, 30))
        if(self.selectArr[section] as! NSObject == 1){
        imageView.image = UIImage(named: "选择信件")
        }else{
            imageView.image = UIImage(named: "未选择信件")
        }
       
        let btn = UIButton(frame: CGRectMake(0,0,SCREEN_WIDTH,50))
        
        btn.tag = section
        btn.addTarget(self, action: #selector(ContactPersonViewController.btnOpenList(_:)), forControlEvents: .TouchUpInside)
        view.addSubview(btn)
          view.addSubview(imageView)
        view.addSubview(groupNameLabel)
        view.bringSubviewToFront(btn)
        view.autoresizingMask = .FlexibleWidth
        return view
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 40
    }

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
        cell.teacherHeadImageView?.image = UIImage(named: "教师头像")
        cell.teacherNameLabel?.text = self.contacterlistArray[indexPath.row].valueForKey("Name") as? String
        cell.selectedBtn?.addTarget(self, action: #selector(ContactPersonViewController.selectPerson(_:)), forControlEvents: .TouchUpInside)
        cell.id = self.contacterlistArray[indexPath.row].valueForKey("Id") as! NSInteger
        cell.isSelect = false
        //自定义btn的tag
           cell.selectedBtn?.setImage(UIImage(named: "未选择信件" ), forState: .Normal)
        cell.selectedBtn!.customTag = "\(indexPath.section)" + "-" + "\(indexPath.row)"
            for i in 0 ..< self.selectedPersonIdArray.count{
                if(self.selectedPersonIdArray[i] as! NSInteger == cell.id){
                    cell.isSelect = true
                cell.selectedBtn?.setImage(UIImage(named: "选择信件" ), forState: .Normal)
                }
            }

        cell.selectionStyle = .None
        }
        return cell
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
        if(cell.isSelect == true){
          cell.isSelect = false
            //遍历删除
            let id = cell.id
            for i in 0 ..< self.selectedPersonIdArray.count{
                if(self.selectedPersonIdArray[i] as! NSInteger == id){
                    self.selectedPersonIdArray.removeObjectAtIndex(i)
                    break
                }
            }
            cell.selectedBtn?.setImage(UIImage(named: "未选择信件" ), forState: .Normal)
        }else{
            self.selectedPersonIdArray.addObject(cell.id)
         
            cell.isSelect = true
           cell.selectedBtn?.setImage(UIImage(named: "选择信件" ), forState: .Normal)
        }
      
       }
    
    
 //提交联系人
    @IBAction func save(sender:UIButton){
        
        self.callBack!(idArray:self.selectedPersonIdArray,items:self.items)
        self.navigationController?.popViewControllerAnimated(true)
    }
    func headerRefresh() {
    //向后台请求联系人
        let userDefault = NSUserDefaults.standardUserDefaults()
        let authtoken = userDefault.valueForKey("authtoken") as! String
        let dic:[String:AnyObject] = ["authtoken":authtoken]
        Alamofire.request(.GET, "http://dodo.hznu.edu.cn/api/messagecontact", parameters: dic, encoding: ParameterEncoding.URL, headers: nil).responseJSON { (response) in
            switch response.result{
            case .Failure(_):
                ProgressHUD.showError("请求失败")
                self.items = NSArray()
                dispatch_async(dispatch_get_main_queue(), {
                    self.contactPersonTableView?.mj_header.endRefreshing()
                    self.contactPersonTableView?.reloadData()
                })

                           case .Success(let Value):
                let json = JSON(Value)
                if(json["retcode"].number != 0){
                    self.items = NSArray()
                    ProgressHUD.showError("请求失败")
                   
                    dispatch_async(dispatch_get_main_queue(), {
                        self.contactPersonTableView?.mj_header.endRefreshing()
                        self.contactPersonTableView?.reloadData()
                    })

                }else{
                    self.items = json["items"].arrayObject! as NSArray
                    //默认都是没有分组的
                    for _ in 0 ..< self.items.count{
                        self.selectArr.addObject(0)
                    }
                    dispatch_async(dispatch_get_main_queue(), {
                        self.contactPersonTableView?.mj_header.endRefreshing()
                        self.contactPersonTableView?.reloadData()
                    })
                }
            }
        }
        }
   
    }

