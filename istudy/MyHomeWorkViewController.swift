//
//  MyHomeWorkViewController.swift
//  istudy
//
//  Created by hznucai on 16/3/5.
//  Copyright © 2016年 hznucai. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import DZNEmptyDataSet
class MyHomeWorkViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,UISearchResultsUpdating,UISearchControllerDelegate,DZNEmptyDataSetSource,DZNEmptyDataSetDelegate{
    @IBOutlet weak var kindOfQuesLabel:UILabel?
    @IBOutlet weak var topLayout: NSLayoutConstraint!
    var isHomeWork = false
    var isExercise = false
    var sc:UISearchController!
    //获取到json的数组
    var id = NSInteger()
    var items = NSArray()
    
    var filterItems = NSMutableArray()
    var postString  = String()
    //获取到每份题目随后要进行日期的判断
    @IBOutlet weak var tableView:mainTableView?
    override func viewDidLoad() {
        self.automaticallyAdjustsScrollViewInsets = false
        if(isHomeWork) {
            self.postString = "http://dodo.hznu.edu.cn/api/homeworkquery"
        }else if(isExercise){
            self.postString = "http://dodo.hznu.edu.cn/api/exercisequery"
        }else{
            self.postString = "http://dodo.hznu.edu.cn/api/exprementquery"
        }
        super.viewDidLoad()
        //支持手势的侧滑返回
           self.navigationController?.interactivePopGestureRecognizer?.enabled = true
               self.tableView?.delegate = self
        self.tableView?.dataSource = self
        self.tableView?.tableFooterView = UIView()
        sc = UISearchController(searchResultsController: nil)
        self.automaticallyAdjustsScrollViewInsets = false
        self.tableView?.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(MyHomeWorkViewController.headerRefresh))
        self.tableView?.mj_header.beginRefreshing()
        sc.searchResultsUpdater = self
        sc.dimsBackgroundDuringPresentation = false
        sc.hidesNavigationBarDuringPresentation = true
        sc.searchBar.placeholder = "请输入试卷名称"
        sc.searchBar.searchBarStyle = .Minimal
        sc.searchBar.sizeToFit()
        self.tableView?.tableHeaderView = sc.searchBar
        sc.delegate = self
        self.tableView?.emptyDataSetDelegate = self
    }
    func emptyDataSetShouldAllowScroll(scrollView: UIScrollView!) -> Bool {
        return true
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(sc?.active == false) {
        return self.items.count
        }else{
        return filterItems.count
        }
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
        var date = String()
        var tempEndDate = NSString()
        var tempStartDate = NSString()
        let cell = tableView.dequeueReusableCellWithIdentifier("MyHomeWorkCell") as! MyHomeWorkTableViewCell
        let yearRange = NSMakeRange(0, 4)
        let monthRange = NSMakeRange(4, 2)
        let dateRange = NSMakeRange(6, 2)
        let hourRange = NSMakeRange(8, 2)
        let minuateRange = NSMakeRange(10, 2)
        let secondRange = NSMakeRange(12, 2)
    
        if(sc?.active == false){
         
        cell.title?.text = self.items[indexPath.row].valueForKey("title") as? String
            //判断有没有空
            if(items[indexPath.row].valueForKey("datestart") as? NSString != nil && items[indexPath.row].valueForKey("datestart") as! NSString != "") {
         tempStartDate = items[indexPath.row].valueForKey("datestart") as! NSString
            }
            if(tempStartDate !=  ""){
                if(self.isExercise || self.isHomeWork){
          date += "开始时间:" + tempStartDate.substringWithRange(yearRange) + "-" + tempStartDate.substringWithRange(monthRange) + "-" + tempStartDate.substringWithRange(dateRange) + "\n"
                }else{
                    date += "开始时间:" + tempStartDate.substringWithRange(yearRange) + "-" + tempStartDate.substringWithRange(monthRange) + "-" + tempStartDate.substringWithRange(dateRange) + " " + tempStartDate.substringWithRange(hourRange) + ":" + tempStartDate.substringWithRange(minuateRange) + ":" + tempStartDate.substringWithRange(secondRange) + "\n"
                }
            }
            //判断有没有空
            if(items[indexPath.row].valueForKey("dateend") as? NSString != nil && items[indexPath.row].valueForKey("dateend") as! NSString != "") {
         tempEndDate = items[indexPath.row].valueForKey("dateend") as! NSString
            }
                if(tempEndDate != ""){
                    if(self.isHomeWork || self.isExercise){
     
                    date += "截止时间:" + tempEndDate.substringWithRange(yearRange) + "-" + tempEndDate.substringWithRange(monthRange) + "-" + tempEndDate.substringWithRange(dateRange)
                    }else{
                        
                          date += "截止时间:" + tempEndDate.substringWithRange(yearRange) + "-" + tempEndDate.substringWithRange(monthRange) + "-" + tempEndDate.substringWithRange(dateRange) + " " + tempEndDate.substringWithRange(hourRange) + ":" + tempEndDate.substringWithRange(minuateRange) + ":" + tempEndDate.substringWithRange(secondRange)
                    }
                }
        }else{
           cell.answerQusBtn?.tag = indexPath.row
            cell.title?.text = self.filterItems[indexPath.row].valueForKey("title") as? String
        
            //判断有没有空
            if(filterItems[indexPath.row].valueForKey("datestart") as? NSString != nil && filterItems[indexPath.row].valueForKey("datestart") as! NSString != "") {
                tempStartDate = filterItems[indexPath.row].valueForKey("datestart") as! NSString
            }
            if(tempStartDate !=  ""){
                if(self.isExercise || self.isHomeWork){
                    date += "开始时间:" + tempStartDate.substringWithRange(yearRange) + "-" + tempStartDate.substringWithRange(monthRange) + "-" + tempStartDate.substringWithRange(dateRange) + "\n"
                }else{
                    date += "开始时间:" + tempStartDate.substringWithRange(yearRange) + "-" + tempStartDate.substringWithRange(monthRange) + "-" + tempStartDate.substringWithRange(dateRange) + " " + tempStartDate.substringWithRange(hourRange) + ":" + tempStartDate.substringWithRange(minuateRange) + ":" + tempStartDate.substringWithRange(secondRange) + "\n"
                }
            }
            //判断有没有空
            if(filterItems[indexPath.row].valueForKey("dateend") as? NSString != nil && filterItems[indexPath.row].valueForKey("dateend") as! NSString != "") {
                tempEndDate = filterItems[indexPath.row].valueForKey("dateend") as! NSString
            }
            if(tempEndDate != ""){
                if(self.isHomeWork || self.isExercise){
                    
                    date += "截止时间:" + tempEndDate.substringWithRange(yearRange) + "-" + tempEndDate.substringWithRange(monthRange) + "-" + tempEndDate.substringWithRange(dateRange)
                }else{
                    
                    date += "截止时间:" + tempEndDate.substringWithRange(yearRange) + "-" + tempEndDate.substringWithRange(monthRange) + "-" + tempEndDate.substringWithRange(dateRange) + " " + tempEndDate.substringWithRange(hourRange) + ":" + tempEndDate.substringWithRange(minuateRange) + ":" + tempEndDate.substringWithRange(secondRange)
                }
            }        }

        cell.dateStart?.text = date
        cell.selectionStyle = .None
        var jsonDateString = ""
        //根据比较的日期来设置button要显示的文字 //先拿到文字进行规范化
        if(tempEndDate != ""){
        let yearString = tempEndDate.substringWithRange(yearRange)
        let monthString = tempEndDate.substringWithRange(monthRange)
        let dateString = tempEndDate.substringWithRange(dateRange)
        let hourString = tempEndDate.substringWithRange(hourRange)
        let minuateString = tempEndDate.substringWithRange(minuateRange)
        let secondString = tempEndDate.substringWithRange(secondRange)
         jsonDateString = yearString + "-" + monthString + "-" + dateString + " " + hourString + ":" + minuateString + ":" + secondString
        }
        //自己的得分成绩的显示
        var score = ""
       
        //练习是没有成绩的
        if(!self.isExercise){
        if(sc.active){
            if(self.filterItems[indexPath.row].valueForKey("myscore") as? NSNumber != nil &&
                self.filterItems[indexPath.row].valueForKey("myscore") as! NSNumber != 0){
            score = "\(NSInteger(self.filterItems[indexPath.row].valueForKey("myscore") as! NSNumber))"
            }else{
                score = "\(0)"
            }
           
        }else{
            if(self.items[indexPath.row].valueForKey("myscore") as? NSNumber != nil &&
                self.items[indexPath.row].valueForKey("myscore") as! NSNumber != 0){
             score = "\(NSInteger(self.items[indexPath.row].valueForKey("myscore") as! NSNumber))"
            }else{
                 score = "\(0)"
            }
            
        }
        }
         cell.Score?.text = ""
        //string转化为date
        if(jsonDateString != ""){
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let jsonDate = formatter.dateFromString(jsonDateString)
        let currentDate = NSDate()
        cell.endDate  = jsonDate!
        //进行比较
        let result:NSComparisonResult = currentDate.compare(jsonDate!)
        if result == .OrderedAscending{
               cell.answerQusBtn?.setTitle("答题", forState: .Normal)
           
            
        }else{
              cell.answerQusBtn?.setTitle("查看", forState: .Normal)
            if(!self.isExercise){
             cell.Score?.text = "成绩:" + score
            }
        }
        }else{
            cell.answerQusBtn?.enabled = false
        }
                cell.answerQusBtn?.tag = indexPath.row
        cell.id = self.items[indexPath.row].valueForKey("id") as! NSInteger
        cell.answerQusBtn?.addTarget(self, action: #selector(MyHomeWorkViewController.answerQuestion(_:)), forControlEvents: .TouchUpInside)
        cell.answerQusBtn?.layer.cornerRadius = 5.0
        cell.answerQusBtn?.layer.masksToBounds = true
        return cell
    }
    //tableViewcell的动画
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layer.transform = CATransform3DMakeScale(0.1, 0.1, 1.0)
        UIView.animateWithDuration(0.8) { 
            cell.layer.transform = CATransform3DMakeScale(1, 1, 1) 
        }
        
    }
    //答题
    func answerQuestion(sender:UIButton){
        let translateVC = UIStoryboard(name: "Problem", bundle: nil).instantiateViewControllerWithIdentifier("TranslateVC") as! TranslateViewController
        if(sc?.active == true){
            let cell = self.tableView?.cellForRowAtIndexPath(NSIndexPath(forRow: sender.tag, inSection: 0)) as! MyHomeWorkTableViewCell
            translateVC.endDate = cell.endDate
          translateVC.keyVisible = self.filterItems[sender.tag].valueForKey("keyVisible") as! Bool
            translateVC.enableClientJudge = self.filterItems[sender.tag].valueForKey("enableClientJudge") as! Bool
            translateVC.viewOneWithAnswerKey = self.filterItems[sender.tag].valueForKey("viewOneWithAnswerKey") as! Bool
            translateVC.title = self.filterItems[sender.tag].valueForKey("title") as? String
            translateVC.kindOfQusIndex = 0
            translateVC.isFirstTime = true
             translateVC.testid = self.filterItems[sender.tag].valueForKey("id") as! NSInteger
            sc.active = false
        }else{
            let cell = self.tableView?.cellForRowAtIndexPath(NSIndexPath(forRow: sender.tag, inSection: 0)) as! MyHomeWorkTableViewCell
            translateVC.endDate = cell.endDate
            translateVC.keyVisible = self.items[sender.tag].valueForKey("keyVisible") as! Bool
            translateVC.enableClientJudge = self.items[sender.tag].valueForKey("enableClientJudge") as! Bool
            translateVC.viewOneWithAnswerKey = self.items[sender.tag].valueForKey("viewOneWithAnswerKey") as! Bool
        translateVC.title = self.items[sender.tag].valueForKey("title") as? String
        translateVC.kindOfQusIndex = 0
        translateVC.isFirstTime = true
     
        translateVC.testid = self.items[sender.tag].valueForKey("id") as! NSInteger
        }
        
        
            self.navigationController?.pushViewController(translateVC, animated: true)
        
    }
    
  
    func headerRefresh() {
        let userDefault = NSUserDefaults.standardUserDefaults()
        let dic:[String:AnyObject] = ["authtoken":userDefault.valueForKey("authtoken") as! String,
                                      "courseid": "\(self.id)"]
        Alamofire.request(.POST, self.postString, parameters: dic, encoding: ParameterEncoding.URL, headers: nil).responseJSON { (response) in
            switch response.result{
            case .Success(let Value):
             let json = JSON(Value)
               
                if (json["retcode"].number != 0){
                    ProgressHUD.showError("请求失败")
                    self.items = NSArray()
                    dispatch_async(dispatch_get_main_queue(), {
                        self.tableView?.mj_header.endRefreshing()
                        self.tableView?.emptyDataSetSource = self
                        self.tableView?.reloadData()
                    })

                }else{
                    dispatch_async(dispatch_get_main_queue(), {
                        self.items = json["items"].arrayObject! as NSArray
                        var string = String()
                        if(self.items.count > 0){
                        if(self.isHomeWork){
                            string = "我的作业" + "(共" + "\(self.items.count)" + "个)"
                        }else if(self.isExercise){
                            string = "模拟练习" + "(共" + "\(self.items.count)" + "个)"
                        }else{
                             string = "我的实验" + "(共" + "\(self.items.count)" + "个)"
                            }
                        self.title = string
                        }
                        self.tableView?.mj_header.endRefreshing()
                        self.tableView?.emptyDataSetSource = self
                        self.tableView?.reloadData()
                    })
                }
            case .Failure(_):
                ProgressHUD.showError("请求失败")
                dispatch_async(dispatch_get_main_queue(), {
                     self.tableView?.emptyDataSetSource = self
                    self.items = NSArray()
                    self.tableView?.mj_header.endRefreshing()
                    self.tableView?.reloadData()
                })
                
            }
        }
    }
       func updateSearchResultsForSearchController(searchController: UISearchController) {
        self.filterItems.removeAllObjects()
        let scopePredicate = NSPredicate(format: "SELF contains[c] %@", searchController.searchBar.text!)
        for i in 0 ..< self.items.count{
            if(scopePredicate.evaluateWithObject(self.items[i].valueForKey("title")) == true){
                self.filterItems.addObject(self.items[i])
            }
        }
        
        self.tableView?.reloadData()
    }
    func willPresentSearchController(searchController: UISearchController) {
        self.tableView?.mj_header.hidden = true
    }
    func willDismissSearchController(searchController: UISearchController) {
        self.tableView?.mj_header.hidden = false
    }
    deinit{
        print("MyHomeWorkDeinit")

        self.sc?.view.removeFromSuperview()
    }
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.sc.active = false
        self.sc.searchBar.text = ""
        sc.dismissViewControllerAnimated(true, completion: nil)
       }
    override func viewWillDisappear(animated: Bool) {
   
        ProgressHUD.dismiss()
    }
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let string = "暂无作业信息"
        let dic = [NSFontAttributeName:UIFont.boldSystemFontOfSize(18.0),
                   NSForegroundColorAttributeName:UIColor.grayColor()]
        let attriString = NSMutableAttributedString(string: string, attributes: dic)
        return attriString
    }
}
