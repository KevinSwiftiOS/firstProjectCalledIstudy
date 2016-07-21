//
//  MyTestViewController.swift
//  istudy
//
//  Created by hznucai on 16/3/3.
//  Copyright © 2016年 hznucai. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Font_Awesome_Swift
import DZNEmptyDataSet
class MyTestViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,UISearchResultsUpdating,UISearchControllerDelegate,DZNEmptyDataSetSource,DZNEmptyDataSetDelegate{
      //接受数据信息的数组 搜索条的动作
    var sc = UISearchController(searchResultsController: nil)
    var testDataArray = NSArray()
    var trueArray = NSMutableArray()
    @IBOutlet weak var testTableView:mainTableView?
    var segmentController:AKSegmentedControl!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.barTintColor = RGB(0, g: 153, b: 255)
        self.navigationController?.navigationBar.tintColor = UIColor.blackColor()
        self.automaticallyAdjustsScrollViewInsets = false
        self.testTableView?.dataSource = self
        self.testTableView?.delegate = self
         self.testTableView?.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(MyTestViewController.headRefresh))
        self.testTableView?.mj_header.beginRefreshing()
        self.testTableView?.tableFooterView = UIView()
        sc.searchResultsUpdater = self
        sc.dimsBackgroundDuringPresentation = false
        sc.hidesNavigationBarDuringPresentation = true
        sc.searchBar.placeholder = "请输入考试名称"
        sc.searchBar.searchBarStyle = .Minimal
        sc.searchBar.sizeToFit()
        self.testTableView?.tableHeaderView = sc.searchBar
        sc.delegate = self
self.testTableView?.emptyDataSetDelegate = self
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(sc.active == true){
            return self.trueArray.count
        }else{
            return self.testDataArray.count
        }
    }
    //每个cell的内容
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("testCell") as! testTableViewCell
        var trueItems = NSArray()
        if(sc.active == true){
            trueItems = self.trueArray
           
        }else{
        trueItems = self.testDataArray
        }
        cell.testCourseName?.text = "考试科目:" + (trueItems[indexPath.row].valueForKey("title") as? String)!
        
        if(trueItems[indexPath.row].valueForKey("teacher") as? String != nil
            && trueItems[indexPath.row].valueForKey("teacher") as! String != ""){
        cell.testCourseTea?.text = trueItems[indexPath.row].valueForKey("teacher") as? String
        }
        cell.testCourseTea?.tintColor = UIColor.whiteColor()
        cell.testCourseTea?.backgroundColor =  RGB(0, g: 153, b: 255)
        var dateStartArr = [String]()
        var dateEndArr = [String]()
        if(trueItems[indexPath.row].valueForKey("datestart") as? String != nil && trueItems[indexPath.row].valueForKey("datestart") as! String != ""){
             dateStartArr = diviseDateString(trueItems[indexPath.row].valueForKey("datestart") as! String)
        }
        if(trueItems[indexPath.row].valueForKey("dateend") as? String != nil && trueItems[indexPath.row].valueForKey("dateend") as! String != ""){
            dateEndArr = diviseDateString(trueItems[indexPath.row].valueForKey("dateend") as! String)
        }
        cell.testCourseTime?.text = "开始时间:" + dateStartArr[0] + "年" + dateStartArr[1] + "月" + dateStartArr[2] + "日" + dateStartArr[3] + ":" + dateStartArr[4] + ":" +  dateStartArr[5] + "\n" +
        "截止时间:" + dateEndArr[0] + "年" + dateEndArr[1] + "月" + dateEndArr[2] + "日" + dateEndArr[3] + ":" + dateEndArr[4] + ":" +  dateEndArr[5]
    //考试地点
        var adress = ""
        if(trueItems[indexPath.row].valueForKey("ksdd") as? String != nil && trueItems[indexPath.row].valueForKey("ksdd") as! String != ""){
            adress = trueItems[indexPath.row].valueForKey("ksdd") as! String
        }
        if(trueItems[indexPath.row].valueForKey("kszw") as? String != nil && trueItems[indexPath.row].valueForKey("kszw") as! String != ""){
            adress += trueItems[indexPath.row].valueForKey("kszw") as! String
        }
        
      
        cell.testCourseAdress?.text = adress
        cell.selectionStyle = .None
        //cell赋值
        cell.fontAdressLabel.setFAIcon(FAType.FAMapMarker, iconSize: 25)
        cell.fontTimeLabel.setFAIcon(FAType.FAClockO, iconSize: 25)
        cell.testCourseTea?.layer.cornerRadius = 6.0
        cell.testCourseTea?.layer.masksToBounds = true
      
              return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 110
    }
    //当选择搜索的时候启动搜索栏
       func updateSearchResultsForSearchController(searchController: UISearchController) {
        self.trueArray.removeAllObjects()
        let scopePredicate = NSPredicate(format: "SELF contains[c] %@", searchController.searchBar.text!)
        for i in 0 ..< self.testDataArray.count{
            if(scopePredicate.evaluateWithObject(self.testDataArray[i].valueForKey("title")) == true){
                self.trueArray.addObject(self.testDataArray[i])
            }
        }
        
        self.testTableView?.reloadData()
    }
    func willDismissSearchController(searchController: UISearchController) {
       self.testTableView?.mj_header.hidden = false
    }
    func willPresentSearchController(searchController: UISearchController) {
        self.testTableView?.mj_header.hidden = true
    }
    deinit{
    self.sc.view.removeFromSuperview()
    }
        override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
            self.sc.active = false
            self.sc.searchBar.text = ""
          
            self.tabBarController?.tabBar.hidden = false
            
        }
    func headRefresh() {
        let userDefault = NSUserDefaults.standardUserDefaults()
        let dic:[String:AnyObject] = ["authtoken":userDefault.valueForKey("authtoken") as! String]
        Alamofire.request(.POST, "http://dodo.hznu.edu.cn/api/testquery", parameters: dic, encoding: ParameterEncoding.URL, headers: nil).responseJSON { (response) in
            switch response.result{
            case .Failure(_):
                dispatch_async(dispatch_get_main_queue(), {
                    self.testDataArray = NSArray()
                     self.testTableView?.emptyDataSetSource = self
                    self.testTableView?.mj_header.endRefreshing()
                    self.testTableView?.reloadData()
                    ProgressHUD.showError("请求失败")
                })
            
                ProgressHUD.showError("请求失败")
            case .Success(let Value):
                let json = JSON(Value)
         
                if(json["retcode"].number != 0){
                    dispatch_async(dispatch_get_main_queue(), {
                        self.testDataArray = NSArray()
                        self.testTableView?.mj_header.endRefreshing()
                         self.testTableView?.emptyDataSetSource = self
                        self.testTableView?.reloadData()
                        ProgressHUD.showError("请求失败")
                    })
                 
                    
                    print(json["retcode"])
                }else{
                    dispatch_async(dispatch_get_main_queue(), {
                        self.testDataArray = json["items"].arrayObject! as NSArray
                        self.testTableView?.mj_header.endRefreshing()
                        self.testTableView?.reloadData()
                        if(self.testDataArray.count == 0)
                        {
                              self.testTableView?.emptyDataSetSource = self
                            self.testTableView?.reloadData()
                        }
                    })
                
                }
            }
        }
      
    }
    override func viewWillDisappear(animated: Bool) {
             ProgressHUD.dismiss()
    }
    //进行日期字符串分割
    //分割日期的字符串
    func diviseDateString(totalDate:NSString) -> [String] {
        var arr = [String]()
        let yearRange = NSMakeRange(0, 4)
        let monthRange = NSMakeRange(4, 2)
        let dateRange = NSMakeRange(6, 2)
        let hourRange = NSMakeRange(8, 2)
        let minuateRange = NSMakeRange(10, 2)
        let secondRange = NSMakeRange(12, 2)
        let year = totalDate.substringWithRange(yearRange) as String
        let month = totalDate.substringWithRange(monthRange) as String
        let date = totalDate.substringWithRange(dateRange) as String
        let hour = totalDate.substringWithRange(hourRange) as String
        let minate = totalDate.substringWithRange(minuateRange) as String
        let second = totalDate.substringWithRange(secondRange) as String
        arr.append(year)
        arr.append(month)
        arr.append(date)
        arr.append(hour)
        arr.append(minate)
        arr.append(second)
        return arr
    }
    //空时候的顶部视图
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let string = "暂无考试信息"
        let dic = [NSFontAttributeName:UIFont.boldSystemFontOfSize(18.0),
                   NSForegroundColorAttributeName:UIColor.grayColor()]
    let attriString = NSMutableAttributedString(string: string, attributes: dic)
        return attriString
    }
    func emptyDataSetShouldAllowScroll(scrollView: UIScrollView!) -> Bool {
        return true
    }
    
}

              