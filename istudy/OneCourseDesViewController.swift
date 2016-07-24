//
//  OneCourseDesViewController.swift
//  istudy
//
//  Created by hznucai on 16/3/3.
//  Copyright © 2016年 hznucai. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import DZNEmptyDataSet 
class OneCourseDesViewController:UIViewController,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource,UICollectionViewDelegate,UITableViewDelegate,UITableViewDataSource,LFLUISegmentedControlDelegate,DZNEmptyDataSetSource,DZNEmptyDataSetDelegate{
    @IBOutlet weak var courseDataCollectionView:UICollectionView?
    @IBOutlet weak var infoTableView:UITableView?
    @IBOutlet weak var messageView:UIWebView?
    var segmentController:AKSegmentedControl?
    var isCourseInfo = true
    //课程的背景RGB颜色
    var rgbArray = NSArray()
    //课程的名字
    var courseNameString = String()
    //每个课程的id
    var id = NSInteger()
    var everyCellName = ["学习资料","我的作业","互评任务","我的实验","模拟练习","讨论区"]
    //记录课程通知的
    var items = NSArray()
    //文本框的信息

    var courseDesString = NSString()
    //主界面的代码 三个头部的跳转 和collectionView tableView的跳转
    override func viewDidLoad() {
         super.viewDidLoad()
         self.navigationController?.navigationItem.backBarButtonItem?.tintColor = UIColor.blackColor()
        self.automaticallyAdjustsScrollViewInsets = false
        self.courseDataCollectionView!.delegate = self
        self.courseDataCollectionView!.dataSource = self
        self.infoTableView?.emptyDataSetDelegate = self
        self.courseDataCollectionView!.backgroundColor = UIColor.whiteColor()
//        self.courseDataCollectionView?.frame = CGRectMake(0, 111, SCREEN_WIDTH, SCREEN_HEIGHT)
//        self.messageView?.frame = CGRectMake(SCREEN_WIDTH, 111, SCREEN_WIDTH, SCREEN_HEIGHT)
//        self.infoTableView?.frame = CGRectMake(SCREEN_WIDTH * CGFloat(2), 111 + 37, SCREEN_WIDTH, SCREEN_HEIGHT)
    self.segmentController = AKSegmentedControl(frame: CGRectMake(20,111,SCREEN_WIDTH - 40, 37))
//        self.scrollView = UIScrollView(frame: CGRectMake(0,0,SCREEN_WIDTH,SCREEN_HEIGHT - 111))
        // Do any additional setup after loading the view.
        self.infoTableView!.delegate = self
        self.infoTableView!.dataSource = self
        self.infoTableView!.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(OneCourseDesViewController.headerRefresh))
        self.infoTableView!.tableFooterView = UIView()
        self.infoTableView!.hidden = true
        if(self.courseDesString == ""){
            self.courseDesString = "<html><head><style>P{text-align:center;vertical-align: middle;font-size: 17px;font-family: " + "\"" + "宋体" + "\"" +  "}</style></head><body><p>无课程信息</p></body></html>"
        }else{
            self.courseDesString = cssDesString + (self.courseDesString as String) + "</p>"
        }
        self.messageView!.loadHTMLString(self.courseDesString as String, baseURL: nil)
        self.courseDataCollectionView?.hidden = false
        self.messageView?.hidden = true
        self.infoTableView?.hidden = true
        let LFLuisement = LFLUISegmentedControl(frame: CGRectMake(0, 64,SCREEN_WIDTH,37))
        LFLuisement.delegate = self
        //设置切换的标题
        let LFArray = ["我的学习","课程信息","课程通知"]
        LFLuisement.AddSegumentArray(LFArray)
        //设置默认的标题
        LFLuisement.selectTheSegument(0)
        self.view.addSubview(LFLuisement)
     //  self.view.bringSubviewToFront(self.scrollView)
       //        self.scrollView.addSubview(self.courseDataCollectionView!)
//        self.scrollView.addSubview(self.messageView!)
//        self.scrollView.addSubview(self.infoTableView!)
//        self.scrollView.addSubview(self.segmentController!)
//        self.scrollView.contentSize = CGSizeMake(SCREEN_WIDTH * 3, SCREEN_HEIGHT - 111)
     //   self.view.addSubview(self.scrollView)
        let btnArray =  [["image":"默认头像","title":"课程公告"],
                         ["image":"默认头像","title":"系统公告"],
                         ]
        segmentController!.initButtonWithTitleandImage(btnArray)
        segmentController!.hidden = true
        segmentController!.setSelectedIndex(0)

        self.view.addSubview(segmentController!)
        self.segmentController?.addTarget(self, action: #selector(OneCourseDesViewController.changeInfo(_:)), forControlEvents: .ValueChanged)
self.courseDataCollectionView!.emptyDataSetDelegate = self
        
    }
    //当列表为空的时候的允许下拉
    func emptyDataSetShouldAllowScroll(scrollView: UIScrollView!) -> Bool {
        return true
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //collectionView的代理
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CourseDataCollectionViewCell", forIndexPath: indexPath) as! CourseDataCollectionViewCell
        cell.sizeToFit()
        for view in cell.contentView.subviews{
            view.removeFromSuperview()
        }
        cell.name?.text = everyCellName[indexPath.row]
        cell.btn?.tag = indexPath.row
        cell.btn?.layer.cornerRadius = 5.0
         cell.btn?.layer.masksToBounds = true
        
        cell.btn?.addTarget(self, action: #selector(OneCourseDesViewController.pushNewVC(_:)), forControlEvents: .TouchUpInside)
        //还有图片的数组
        let image = UIImage(named: self.everyCellName[indexPath.row])
        cell.btn?.setBackgroundImage(image, forState: .Normal)
        
        return cell
    }
//    //返回每个cell是否可以被选择
//    func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
//        return false
//    }
    
    //定义每个cell的边框大小
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
       
    }
    //定义每个cell的大小 这里是要进行修改的 要看图片的大小
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        //判断是4 4s 5 6 6p
//        var width:CGFloat = 0
//        var height:CGFloat = 0
        if(SCREEN_WIDTH == 320){
        
            return CGSize(width: 80,height: 96)

        }
        else if(SCREEN_WIDTH == 414){
               return CGSizeMake(100, 120)
        }else{
            return CGSizeMake(90, 108)
        }
        
    }
    //tableView的一些协议
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CourseInfoTableViewCell") as! CourseInfoTableViewCell
        if(indexPath.row < self.items.count){
        cell.titleLabel?.text = items[indexPath.row].valueForKey("title") as? String
        let tempDate = items[indexPath.row].valueForKey("date") as! NSString
        let yearRange = NSMakeRange(0, 4)
        let monthRange = NSMakeRange(4, 2)
        let dateRange = NSMakeRange(6, 2)
        let  date = "发布日期:" + tempDate.substringWithRange(yearRange) + "-" + tempDate.substringWithRange(monthRange) + "-" + tempDate.substringWithRange(dateRange)
        cell.dateLabel?.text = date as String
        }
             return cell
    }
    //当选择了某个cell的时候 查看公告的操作 详细公告
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let vc = UIStoryboard(name: "MyCourse", bundle: nil).instantiateViewControllerWithIdentifier("DetailInfoVC") as! DetailInfoViewController
        vc.id = self.items[indexPath.row].valueForKey("id") as! NSInteger
        vc.title = "详细信息"
              self.navigationController?.pushViewController(vc, animated: true)
    }
    //学习资料 或者作业的任何一个 将课程id传过去
    func pushNewVC(sender:UIButton){
        let oneCourseSB = UIStoryboard(name: "OneCourse", bundle: nil)
        switch sender.tag {
        case 0: let VC = oneCourseSB.instantiateViewControllerWithIdentifier("StudyMaterialVC")  as! StudyMaterialViewController
         VC.title = "学习资料"
        VC.courseId = self.id
            self.navigationController?.pushViewController(VC, animated: true)
        case 1:let VC = oneCourseSB.instantiateViewControllerWithIdentifier("MyHomeWorkVC") as! MyHomeWorkViewController
         VC.title = "我的作业"
         VC.id = self.id
         VC.isHomeWork = true
            self.navigationController?.pushViewController(VC, animated: true)
        case 2: let VC = oneCourseSB.instantiateViewControllerWithIdentifier("PeerAssessmentVC") as! PeerAssessmentViewController
        VC.id = self.id
         VC.title = "互评列表"
            self.navigationController?.pushViewController(VC, animated: true)
        case 3: let VC = oneCourseSB.instantiateViewControllerWithIdentifier("MyHomeWorkVC") as! MyHomeWorkViewController
        VC.id = self.id
        self.navigationController?.pushViewController(VC, animated: true)
        VC.title = "我的实验"
        case 4: let VC = oneCourseSB.instantiateViewControllerWithIdentifier("MyHomeWorkVC") as! MyHomeWorkViewController
        self.navigationController?.pushViewController(VC, animated: true)
        VC.isExercise = true
        VC.id = self.id
        VC.title = "模拟练习"
        case 5:let VC = oneCourseSB.instantiateViewControllerWithIdentifier("DiscussVC") as! DiscussViewController
        self.navigationController?.pushViewController(VC, animated: true)
        VC.title = "讨论区"
            VC.rgbArray = self.rgbArray
            VC.courseNameString = self.courseNameString
            VC.id = self.id
        default:break
        }
        
    }
    //点击标题按钮 选择不同的空间 课程信息是webView展现 学习资料等是collectionView的展现 公告信息是tableView的展现
    func uisegumentSelectionChange(selection: Int) {
        switch selection{
        case 0:
            self.infoTableView?.hidden = true
            self.messageView?.hidden = true
            self.courseDataCollectionView?.hidden = false
            self.segmentController?.hidden = true
        case 1:
            self.courseDataCollectionView?.hidden = true
            self.messageView?.hidden = false
            self.infoTableView?.hidden = true
              self.segmentController?.hidden = true
        case 2:
            self.infoTableView?.hidden = false
            self.infoTableView?.mj_header.beginRefreshing()
            self.messageView?.hidden = true
            self.courseDataCollectionView?.hidden = true
            self.segmentController?.hidden = false
        default:break
        }
       
    }
    //开始刷新 公告信息的tableViewHeader的刷新 要注意是否是课程公告还是系统公告 请求参数会不同
    func headerRefresh() {
        let userDefault = NSUserDefaults.standardUserDefaults()
        let dic:[String:AnyObject] = ["authtoken":userDefault.valueForKey("authtoken") as! String,"courseid": "\(self.id)"]
        if(isCourseInfo) {
        Alamofire.request(.POST, "http://dodo.hznu.edu.cn/api/courseinfo", parameters: dic, encoding: ParameterEncoding.URL, headers: nil).responseJSON { (response) in
            switch response.result{
            case .Success(let value):
                let json = JSON(value)
                if(json["retcode"].number == 0){
                  
                    dispatch_async(dispatch_get_main_queue(), {
                        self.items = json["items"].arrayObject! as NSArray
                        self.infoTableView?.mj_header.endRefreshing()
                        self.infoTableView?.emptyDataSetSource = self

                        self.infoTableView!.reloadData()
                    })
                }else{
                    ProgressHUD.showError("请求失败")
                    self.items = NSArray()
                    dispatch_async(dispatch_get_main_queue(), {
                        self.infoTableView?.mj_header.endRefreshing()
                        self.infoTableView?.emptyDataSetSource = self
                        self.infoTableView?.reloadData()
                    })

                }
            case .Failure(_):
                ProgressHUD.showError("请求失败")
                self.items = NSArray()
                dispatch_async(dispatch_get_main_queue(), {
                    self.infoTableView?.mj_header.endRefreshing()
                    self.infoTableView?.emptyDataSetSource = self

                    self.infoTableView?.reloadData()
                })

            }
        }
        }else{
        let systemInfoDic:[String:AnyObject] = ["authtoken":userDefault.valueForKey("authtoken") as! String,
                             "count": "\(10)",
                             "page":"\(1)"]
        Alamofire.request(.POST, "http://dodo.hznu.edu.cn/api/notifyquery", parameters: systemInfoDic, encoding: ParameterEncoding.URL, headers: nil).responseJSON(options: NSJSONReadingOptions.AllowFragments) { (response) in
            switch response.result{
            case .Success(let value):
                let json = JSON(value)
                if(json["retcode"].number != 0){
                    ProgressHUD.showError("请求失败")
                    dispatch_async(dispatch_get_main_queue(), {
                        self.items = NSArray()
                        self.infoTableView?.mj_header.endRefreshing()
                        self.infoTableView!.emptyDataSetSource = self
                        self.infoTableView?.reloadData()
                        
                    })
                }else{
                        dispatch_async(dispatch_get_main_queue(), {
                        self.items = json["items"].arrayObject! as NSArray
                        self.infoTableView?.mj_header.endRefreshing()
                        self.infoTableView!.emptyDataSetSource = self
                        self.infoTableView?.reloadData()
                        
                    })
                }
            case .Failure(_):
                ProgressHUD.showError("请求失败")
                dispatch_async(dispatch_get_main_queue(), {
                  self.items = NSArray()
                    self.infoTableView?.mj_header.endRefreshing()
                    self.infoTableView!.emptyDataSetSource = self
                    self.infoTableView?.reloadData()

                })
            }
        }
        }
    }
    //公告属性的改变
    func changeInfo(sender:AKSegmentedControl){
        let index = sender.selectedIndexes.lastIndex
        if(index == 1){
            self.isCourseInfo = false
        }else{
            self.isCourseInfo = true
        }
        self.infoTableView?.mj_header.beginRefreshing()
        
    }
    override func viewDidDisappear(animated: Bool) {
              ProgressHUD.dismiss()
    }
    //公告列表为空的提醒
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let string = "暂无通知信息"
        let dic = [NSFontAttributeName:UIFont.boldSystemFontOfSize(18.0),
                   NSForegroundColorAttributeName:UIColor.grayColor()]
        let attriString = NSMutableAttributedString(string: string, attributes: dic)
        return attriString
    }
  
}
