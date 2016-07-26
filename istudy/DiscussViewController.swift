//
//  DiscussViewController.swift
//  istudy
//
//  Created by hznucai on 16/3/5.
//  Copyright © 2016年 hznucai. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import DZNEmptyDataSet
import Font_Awesome_Swift
class DiscussViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,DZNEmptyDataSetSource,DZNEmptyDataSetDelegate{
    @IBOutlet weak var discussTableView:UITableView?
    //测试数组
    @IBOutlet weak var topView:UIView?
    @IBOutlet weak var courseNameLabel:UILabel?
    @IBOutlet weak var classLabel:UILabel?
    @IBOutlet weak var totoalDiscussCountLabel:UILabel?
    @IBOutlet weak var writeBtn:UIButton?
    @IBOutlet weak var refreshBtn:UIButton?
    @IBOutlet weak var typeBtn:UIButton?
    @IBOutlet weak var btmView:UIView?
    var url = ""
    var paramDic = [String:AnyObject]()
    var pop:PopoverView?
    var rgbArray = NSArray()
    var courseNameString = String()
    var unTopitems = NSMutableArray()
    var topitems = NSMutableArray()
    var teacherName = NSMutableArray()
    //总共的items
    var totalItems = NSMutableArray()
    var authtoken = ""
    //记录课程号的
    var id =  NSInteger()
    override func viewDidLoad() {
        super.viewDidLoad()
        let userDefault = NSUserDefaults.standardUserDefaults()
        authtoken = userDefault.valueForKey("authtoken") as! String
        self.paramDic = ["authtoken":authtoken,"count":"100",
                         "page":"1",
                         "projectid":"\(self.id)",
                         "mode":"2"]
        self.url =  "http://dodo.hznu.edu.cn/api/forumquery"
        
        self.automaticallyAdjustsScrollViewInsets = false
        //顶部topView赋值
        self.courseNameLabel?.text = self.courseNameString
        //如果为空的话 默认加载RGB(0,153,255)的颜色
        if(self.rgbArray.count > 0){
            self.classLabel?.backgroundColor = RGB(Float(rgbArray[0] as! NSNumber), g:Float(rgbArray[1] as! NSNumber), b: Float(rgbArray[2] as! NSNumber))
        }else{
            self.classLabel?.backgroundColor = RGB(0, g: 153, b: 255)
        }
        //顶部的设置
        self.classLabel?.text = userDefault.valueForKey("cls") as? String
        self.classLabel?.layer.cornerRadius = 5.0
        self.classLabel?.layer.masksToBounds = true
        self.discussTableView?.dataSource = self
        self.discussTableView?.delegate = self
        writeBtn?.setFAText(prefixText: "", icon: FAType.FAEdit, postfixText: "", size: 25, forState: .Normal, iconSize: 25)
        writeBtn?.setFATitleColor(UIColor.blueColor())
        refreshBtn?.setFAText(prefixText: "", icon: FAType.FARefresh, postfixText: "", size: 25, forState: .Normal, iconSize: 25)
        refreshBtn?.setFATitleColor(UIColor.blueColor())
        typeBtn?.setFAText(prefixText: "", icon: FAType.FAEllipsisH, postfixText: "", size: 25, forState: .Normal, iconSize: 25)
        typeBtn?.setFATitleColor(UIColor.blueColor())
        
        //设置阴影效果
        ShowBigImageFactory.topViewEDit(self.btmView!)
        ShowBigImageFactory.topViewEDit(self.topView!)
        self.discussTableView?.mj_header  = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(DiscussViewController.headRefresh))
        let point = CGPointMake(SCREEN_WIDTH , SCREEN_HEIGHT - 70 - 100)
        //设置tag
        
        let array = ["我回复的主题","我发布的主题","全部主题"]
        pop = PopoverView(point: point, titles: array, images: nil)
        //点击tableView的底部的时候popView消失
        self.topView!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(DiscussViewController.resignPop)))
        //开始刷新
        self.discussTableView?.mj_header.beginRefreshing()
        self.discussTableView?.emptyDataSetDelegate = self
        // Do any additional setup after loading the view.
    }
    func emptyDataSetShouldAllowScroll(scrollView: UIScrollView!) -> Bool {
        return true
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //tableView的一些代理
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.totalItems.count
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //字符串的分割日期
              let yearRange = NSMakeRange(0, 4)
        let monthRange = NSMakeRange(4, 2)
        let dateRange = NSMakeRange(6, 2)
        var tempStartDate = NSString()
        var date = ""
        if(indexPath.section < self.totalItems.count){
        let item = self.totalItems[indexPath.section]
        
        if(item.valueForKey("top") as? NSNumber != nil && item.valueForKey("top") as! NSNumber == 1){
            let  cell = tableView.dequeueReusableCellWithIdentifier("TopDiscussTableViewCell") as! TopDiscussTableViewCell
            cell.titleLabel?.text = item.valueForKey("title") as? String
            tempStartDate = item.valueForKey("date") as! NSString
            date = "于" + tempStartDate.substringWithRange(yearRange) + "年" + tempStartDate.substringWithRange(monthRange) + "月" + tempStartDate.substringWithRange(dateRange) + "日 发表"
            
            cell.teacherAndDateLabel?.text = (item.valueForKey("author") as! String + date)
            if(item.valueForKey("avatar_url") as? String != nil && item.valueForKey("avatar_url") as! String != ""){
                cell.headImageView?.image = UIImage(named: "置顶")
            }else{
                cell.headImageView?.image = UIImage(named: "默认头像")
            }
            cell.contentView.layer.cornerRadius = 5.0
            cell.contentView.layer.masksToBounds = true
            return cell
        }else{
            let  cell = tableView.dequeueReusableCellWithIdentifier("UnTopTableViewCell") as! UnTopTableViewCell
            cell.titleLabel?.text = item.valueForKey("title") as? String
            tempStartDate = item.valueForKey("date") as! NSString
            date = "于" + tempStartDate.substringWithRange(yearRange) + "年" + tempStartDate.substringWithRange(monthRange) + "月" + tempStartDate.substringWithRange(dateRange) + "日 发表"
            
            cell.studentAndDateLabel?.text = (item.valueForKey("author") as! String + date)
            
            cell.contentView.layer.cornerRadius = 5.0
            cell.contentView.layer.masksToBounds = true
            cell.contentView.layer.borderWidth = 0.3
            cell.contentView.layer.borderColor = UIColor.grayColor().CGColor
            
            return cell
        }
        }
        return UITableViewCell()
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 62
    }
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if(isShow){
            bottomChooseViewResign()
            tableView.deselectRowAtIndexPath(indexPath, animated: false)
        }else{
            
            let detailTopicVC = UIStoryboard(name: "Discuss", bundle: nil).instantiateViewControllerWithIdentifier("DetailTopicVC") as! DetailTopicViewController
            detailTopicVC.detailString = self.totalItems[indexPath.section].valueForKey("content") as! String
            detailTopicVC.id = self.totalItems[indexPath.section].valueForKey("id") as! NSInteger
            detailTopicVC.projectid = self.id
            detailTopicVC.title = "详细信息"
            self.navigationController?.pushViewController(detailTopicVC, animated: true)
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
    @IBAction func refresh(sender:UIButton) {
        if(isShow){
            bottomChooseViewResign()
        }else{
            self.discussTableView?.mj_header.beginRefreshing()
        }
    }
    var isShow = false
    @IBAction func chooseKind(sender:UIButton){
        if(!isShow){
            isShow = true
            self.view.addSubview(pop!)
            self.discussTableView?.alpha = 0.3
        self.btmView?.alpha = 0.3
            self.topView?.alpha = 0.3
            self.view.backgroundColor = UIColor.grayColor()
            pop?.selectRowAtIndex = {(index:NSInteger) -> Void in
                switch index {
                case 0:
                    self.paramDic = ["authtoken":self.authtoken,"count":"100",
                                     "page":"1",
                                     "courseId":"\(self.id)",
                                     "type":"2"]
                    self.url = "http://dodo.hznu.edu.cn/api/forumreplythread"
                case 1:
                    self.paramDic = ["authtoken":self.authtoken,"count":"100",
                                     "page":"1",
                                     "courseId":"\(self.id)",
                                     "type":"1"]
                    self.url = "http://dodo.hznu.edu.cn/api/forumreplythread"
                case 2:
                    self.paramDic = ["authtoken":self.authtoken,"count":"100",
                                     "page":"1",
                                     "projectid":"\(self.id)",
                                     "mode":"1"]
                    self.url = "http://dodo.hznu.edu.cn/api/forumquery"
                default:
                    break
                }
             self.discussTableView?.mj_header.beginRefreshing()
                self.bottomChooseViewResign()
                
            }
            
        }else{
            bottomChooseViewResign()
        }
        
    }
    //到写主题帖去
    @IBAction func writeTopics(sender:UIButton){
        if(isShow){
            bottomChooseViewResign()
        }else{
            let WriteLetterVC = UIStoryboard(name: "Discuss", bundle: nil).instantiateViewControllerWithIdentifier("WriteTopicsVC") as! WriteTopicsViewController
            WriteLetterVC.title = "发起主题"
            WriteLetterVC.projectid = self.id
            self.navigationController?.pushViewController(WriteLetterVC, animated: true)
        }
    }
    @IBAction func resign(sender: UIControl) {
        bottomChooseViewResign()
    }
    func resignPop() {
        bottomChooseViewResign()
    }
    //刷新
    func headRefresh() {
        //设置更改按钮的不可点击性
        self.typeBtn?.enabled = false
            self.btmView?.userInteractionEnabled = false
        Alamofire.request(.POST, url, parameters: self.paramDic, encoding: ParameterEncoding.URL, headers: nil).responseJSON { (response) in
              self.typeBtn?.enabled = true
              self.btmView?.userInteractionEnabled = true
            switch response.result{
            case .Success(let Value):
                let json = JSON(Value)
                
                if(json["retcode"].number != 0){
                    
                    ProgressHUD.showError("请求失败")
                }else{
                    
                    //遍历循环取到的item随后更新列表即可
                    let items = json["items"].arrayObject! as NSArray
                    self.topitems.removeAllObjects()
                    self.unTopitems.removeAllObjects()
                    for i in 0 ..< items.count{
                        //分组分别加进top和untop的数组中
                        if(items[i].valueForKey("top") as? NSNumber != nil && items[i].valueForKey("top") as! NSNumber == 1){
                            self.topitems.addObject(items[i])
                        }else{
                            self.unTopitems.addObject(items[i])
                        }
                    }
                    self.totalItems.removeAllObjects()
                    //将置顶和非置顶全都加进去
                    for i in 0 ..< self.topitems.count{
                        self.totalItems.addObject(self.topitems[i])
                    }
                    for i in 0 ..< self.unTopitems.count{
                        self.totalItems.addObject(self.unTopitems[i])
                    }
                    //跟新界面
                    dispatch_async(dispatch_get_main_queue(), {
                        self.totoalDiscussCountLabel?.text  = "总帖数:" + "\(self.unTopitems.count + self.topitems.count)"
                        self.discussTableView?.mj_header.endRefreshing()
                        self.discussTableView?.emptyDataSetSource = self
                        //tableFooterView的高度
                        let tableFooterHeight = SCREEN_HEIGHT - CGFloat(self.topitems.count) * 70 - 80 - 20 - 64
                        
                        self.discussTableView?.tableFooterView = UIView(frame: CGRectMake(0,0,SCREEN_WIDTH,tableFooterHeight))
                        
                        self.discussTableView?.tableFooterView!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(DiscussViewController.resignPop)))
                        
                        
                        
                        self.discussTableView?.reloadData()
                        
                    })
                }
            case .Failure(_):
                ProgressHUD.showError("请求失败")
                dispatch_async(dispatch_get_main_queue(), {
                    self.totalItems = NSMutableArray()
                    self.discussTableView?.emptyDataSetSource = self
                    self.discussTableView?.mj_header.endRefreshing()
                    self.discussTableView?.reloadData()
                })
            }
        }
    }
    override func viewWillAppear(animated: Bool) {
             self.discussTableView?.mj_header  = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(DiscussViewController.headRefresh))
        self.discussTableView?.mj_header.beginRefreshing()
    }
    override func viewWillDisappear(animated: Bool) {
        ProgressHUD.dismiss()
    }
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let string = "暂无讨论区信息"
        let dic = [NSFontAttributeName:UIFont.boldSystemFontOfSize(18.0),
                   NSForegroundColorAttributeName:UIColor.grayColor()]
        let attriString = NSMutableAttributedString(string: string, attributes: dic)
        return attriString
    }
    deinit{
        print("discussVCDeinit")
    }
    //将底部的选择视图消失
    func bottomChooseViewResign(){
        self.discussTableView!.alpha = 1.0
        self.btmView?.alpha = 1.0
        self.topView?.alpha = 1.0
        self.view.backgroundColor = UIColor.whiteColor()
        
        pop?.removeFromSuperview()
        isShow = false
    }
    
}