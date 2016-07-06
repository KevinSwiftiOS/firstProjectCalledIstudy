//
//  StationLetterViewController.swift
//  istudy
//
//  Created by hznucai on 16/3/3.
//  Copyright © 2016年 hznucai. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import Font_Awesome_Swift
import DZNEmptyDataSet
class StationLetterViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,DZNEmptyDataSetSource,DZNEmptyDataSetDelegate{
       
    @IBOutlet weak var stationLetterTableView:UITableView?

 
   
    //该选择哪条url来发送请求
    var url = ""
    //收到的站内信的参数的字典
    //是选择了哪个信箱
    var isIn = true
    var isOut = false
    var inDic = [String:AnyObject]()
    var outDic = [String:AnyObject]()
    var items = NSMutableArray()
    var toDeleteLetterArray = NSMutableArray()
    override func viewDidLoad() {
        super.viewDidLoad()
      
        
        let userDefault = NSUserDefaults.standardUserDefaults()
        let authtoken = userDefault.valueForKey("authtoken") as! String
        self.inDic = ["authtoken":authtoken,
        "count":"100",
        "page":"1",
        "unreadonly":"2"]
        self.outDic = ["authtoken":authtoken,
                        "count":"100",
                        "page":"1"]
        self.navigationController?.navigationBar.barTintColor = RGB(0, g: 153, b: 255)
        self.navigationController?.navigationBar.tintColor = UIColor.blackColor()
        
        self.stationLetterTableView?.dataSource = self
        self.stationLetterTableView?.delegate = self
        self.stationLetterTableView?.tableFooterView = UIView()
        self.stationLetterTableView?.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(StationLetterViewController.headerRefresh))
        self.stationLetterTableView?.mj_header.beginRefreshing()
             //这个依据情况而定
        
            self.stationLetterTableView!.emptyDataSetDelegate = self
        
    }
   override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("stationLetterCell") as! StationLetterCellTableViewCell
        cell.kingOfLetterImageView!.image = UIImage(named: "已读")

        //看接收到的人里面拿出来 随后循环遍历 自己相等 随后判断 赋不同的值
        if(isIn){
            if  cell.isFirstTimeToAssign  == false {
                
            cell.isRead = self.items[indexPath.row].valueForKey("isread") as! NSInteger
            }
        //定义cell的属性
        if(cell.isRead == 0){
            cell.kingOfLetterImageView!.image = UIImage(named: "未读")

            }else{
             cell.kingOfLetterImageView!.image = UIImage(named: "已读")
            
        }
        }
        var senderName = ""
        if(isIn){
      senderName  = (self.items[indexPath.row].valueForKey("sendername") as? String)!
        }
        cell.subjectLabel?.text = self.items[indexPath.row].valueForKey("subject") as! NSString as String
        //时间的切割
        let yearRange = NSMakeRange(0, 4)
        let monthRange = NSMakeRange(4, 2)
        let dateRange = NSMakeRange(6, 2)
        //let hourRange = NSMakeRange(8, 2)
        //let minuateRange = NSMakeRange(10, 2)
        //let secondRange = NSMakeRange(12, 2)
        let  tempDate = items[indexPath.row].valueForKey("date") as! NSString
        let date = "于" + (tempDate.substringWithRange(yearRange) + "年" + tempDate.substringWithRange(monthRange) + "月" + tempDate.substringWithRange(dateRange)  + "日 " + "发表")
        let totalString = senderName + date
        cell.sendLetterPersonNameAndDateLabel?.text = totalString
        return cell
    }
    //每行选择cell的时候该干什么
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! StationLetterCellTableViewCell
     
       
     //随后推到一个页面中进行详细的说明
    let readEmailVC = UIStoryboard(name: "StationLetter", bundle: nil).instantiateViewControllerWithIdentifier("ReadEmailVC") as! ReadEmailViewController
        readEmailVC.string = self.items[indexPath.row].valueForKey("content") as! String
      
        readEmailVC.subject = self.items[indexPath.row].valueForKey("subject") as! String
       
        readEmailVC.title = "读邮件"
        if(isIn){
            readEmailVC.code = self.items[indexPath.row].valueForKey("code") as! String
            readEmailVC.senderName = (self.items[indexPath.row].valueForKey("sendername") as? String)!
            readEmailVC.senderId = (self.items[indexPath.row].valueForKey("senderid") as? NSInteger)!
            readEmailVC.subject = (self.items[indexPath.row].valueForKey("subject") as! String)
            cell.isRead = 1
        }
        if(isOut){
            readEmailVC.isOut = true
        }
        cell.kingOfLetterImageView!.image = UIImage(named: "已读")
        //如果是收件箱的话，就有未读和已读，推进去了就表示已读，就要把未读的标签设为1
        if(isIn){
       
      cell.isFirstTimeToAssign = true
          cell.isRead = 1
        }
        self.navigationController?.pushViewController(readEmailVC, animated: true)
           }

    @IBAction func reFresh(sender:UIBarButtonItem) {
        //刷新界面 根据获取到的值多少
        self.stationLetterTableView?.mj_header.beginRefreshing()
           }
    @IBAction func writeLetter(sender:UIBarButtonItem) {
        //跳转到写信的界面
        let writeLetterVC = UIStoryboard(name: "StationLetter", bundle: nil).instantiateViewControllerWithIdentifier("writeLetterVC")
        as! WriteLetterViewController
        writeLetterVC.title = "写邮件"
        self.navigationController?.pushViewController(writeLetterVC, animated: true)
    }
 
    //头部刷新
    func headerRefresh() {
        //左半边按钮不可点击
     //slide按钮的左半边不可点击性
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
        delegate.MyletterSlide.leftBtn.enabled = false
         delegate.MyletterSlide.leftViewShowWidth = 0

        self.toDeleteLetterArray = [0,0,0,0,0]
        //参数的数组
        var paramDic = [String:AnyObject]()
        if(isIn){
            paramDic = self.inDic
            url = "http://dodo.hznu.edu.cn/api/messagereceivequery"
        }
        if(isOut){
            paramDic = self.outDic
         url = "http://dodo.hznu.edu.cn/api/messagesendquery"
        }
        Alamofire.request(.POST, url, parameters: paramDic, encoding: ParameterEncoding.URL, headers: nil).responseJSON { (response) in
            delegate.MyletterSlide.leftBtn.enabled = true
            delegate.MyletterSlide.leftViewShowWidth = 200
            switch response.result{
              case .Failure(_):
                ProgressHUD.showError("请求失败")
               
                self.items = NSMutableArray()
               dispatch_async(dispatch_get_main_queue(), {
                self.stationLetterTableView!.emptyDataSetSource = self

                self.stationLetterTableView?.mj_header.endRefreshing()
                self.stationLetterTableView?.reloadData()
               })
               
            case .Success(let Value):
                let json = JSON(Value)
                
                if(json["retcode"].number != 0){
                    ProgressHUD.showError("请求失败")
                    self.items = NSMutableArray()
                    dispatch_async(dispatch_get_main_queue(), {
                        self.stationLetterTableView!.emptyDataSetSource = self

                        self.stationLetterTableView?.mj_header.endRefreshing()
                        self.stationLetterTableView?.reloadData()
                    })

                }else{
                    let jsonItems =  json["items"].arrayObject! as NSArray
                    self.items = NSMutableArray(array: jsonItems)
                    dispatch_async(dispatch_get_main_queue(), {
                        self.stationLetterTableView?.mj_header.endRefreshing()
                        if(self.items.count == 0){
                            self.stationLetterTableView!.emptyDataSetSource = self
                        }
                        self.stationLetterTableView?.reloadData()

                    })
                }
            
        }
          }
    }
    override func viewWillAppear(animated: Bool) {
      
     
    }
    override func viewWillDisappear(animated: Bool) {
               
        ProgressHUD.dismiss()
   self.view.setNeedsLayout()
    }
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let string = "暂无信件信息"
        let dic = [NSFontAttributeName:UIFont.boldSystemFontOfSize(18.0),
                   NSForegroundColorAttributeName:UIColor.grayColor()]
        let attriString = NSMutableAttributedString(string: string, attributes: dic)
        return attriString
    }
    func emptyDataSetShouldAllowScroll(scrollView: UIScrollView!) -> Bool {
        return true
    }
 }
