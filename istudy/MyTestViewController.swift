//
//  MyTestViewController.swift
//  istudy
//
//  Created by hznucai on 16/3/3.
//  Copyright © 2016年 hznucai. All rights reserved.
//

import UIKit

class MyTestViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,UISearchResultsUpdating,UISearchControllerDelegate{
    @IBOutlet weak var topLayout: NSLayoutConstraint!
    //接受数据信息的数组
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
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("testCell") as! testTableViewCell
        if(sc.active == true){
            cell.testCourseName?.text = self.trueArray[indexPath.row] as? String
        }else{
            cell.testCourseName?.text = self.testDataArray[indexPath.row] as? String
        }
        
        cell.testCourseTea?.text = "张量"
//        cell.testCourseTea?.tintColor = UIColor.whiteColor()
//                cell.testCourseTea?.backgroundColor =  RGB(0, g: 153, b: 255)

        cell.testCourseTime?.text = "2016年12月12日 周日 上午12：00 - 13：00"
        cell.testCourseTime?.editable = false
        cell.testCourseAdress?.text = "恕园33号楼"
        cell.selectionStyle = .None
        //cell赋值
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
            if(scopePredicate.evaluateWithObject(self.testDataArray[i]) == true){
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
        self.testDataArray = ["a","b"]
        self.testTableView?.mj_header.endRefreshing()
        self.testTableView?.reloadData()
    }
}

              