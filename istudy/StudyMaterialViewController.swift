//
//  StudyMaterialViewController.swift
//  istudy
//
//  Created by hznucai on 16/3/5.
//  Copyright © 2016年 hznucai. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
//这里是一个tableView 随后每次点击这个tableView的时候就会预览文档
import QuickLook
class StudyMaterialViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,
UISearchControllerDelegate,UISearchResultsUpdating{
    //courseID
    var courseId = NSInteger()
    var filterItems = NSMutableArray()
    var sc = UISearchController(searchResultsController: nil)
    
    @IBOutlet weak var studyMaterialsTableView:UITableView?
    //应该接受到一个url 和每份资料的标题等
    var items = NSArray()
    var fileUrl = NSURL()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        self.studyMaterialsTableView?.delegate = self
        self.studyMaterialsTableView?.dataSource = self
        self.studyMaterialsTableView?.tableFooterView = UIView()
        self.studyMaterialsTableView?.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(StudyMaterialViewController.headerRefresh))
        //        let segmentController = AKSegmentedControl(frame: CGRectMake(20,64,SCREEN_WIDTH - 40, 37))
        //        let btnArray =  [["image":"箭头","title":"名称"],
        //                         ["image":"箭头","title":"创建时间"],
        //                                                 ]
        //        // Do any additional setup after loading the view.
        //        segmentController.initButtonWithTitleandImage(btnArray)
        //        self.view.addSubview(segmentController)
        self.studyMaterialsTableView?.mj_header.beginRefreshing()
        //搜索条的配置
        sc.searchResultsUpdater = self
        sc.dimsBackgroundDuringPresentation = false
        sc.hidesNavigationBarDuringPresentation = true
        sc.searchBar.placeholder = "请输入资料名称"
        sc.searchBar.searchBarStyle = .Minimal
        sc.searchBar.sizeToFit()
        self.studyMaterialsTableView?.tableHeaderView = sc.searchBar
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
        if(sc.active){
            return self.filterItems.count
        }else{
            return items.count
        }
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //自定义tableViewCell
        let cell = tableView.dequeueReusableCellWithIdentifier("StudyMaterialCell")
            as! StudyMaterialTableViewCell
        if(!sc.active){
            cell.fileNameLalel.text = self.items[indexPath.row].valueForKey("filename") as? String
            var typeString = "类型:"
            typeString += (self.items[indexPath.row].valueForKey("extensions") as? String)!
            var createTimeString = "创建时间:"
            createTimeString += self.items[indexPath.row].valueForKey("datecreated") as! String
            var filesizeString = "文件大小:"
            filesizeString += self.items[indexPath.row].valueForKey("filesize") as! String
            cell.totalLabel.text = typeString + " " + createTimeString + " " + filesizeString
            //文件类型头像的不同
            switch  self.items[indexPath.row].valueForKey("extensions") as! String {
            case "pdf":
                cell.typeImageView.image = UIImage(named: "pdf")
            case "ppt","pptx":
                cell.typeImageView.image = UIImage(named: "ppt")
            case "doc","docx":
                cell.typeImageView.image = UIImage(named: "word")
            case "xls","xlsx":
                cell.typeImageView.image = UIImage(named: "Excel")
            default:
                cell.typeImageView.image = UIImage(named: "教师头像")
            }
        }else{
            //自定义tableViewCell
            cell.fileNameLalel.text = self.filterItems[indexPath.row].valueForKey("filename") as? String
            var typeString = "类型:"
            typeString += (self.filterItems[indexPath.row].valueForKey("extensions") as? String)!
            var createTimeString = "创建时间:"
            createTimeString += self.filterItems[indexPath.row].valueForKey("datecreated") as! String
            var filesizeString = "文件大小:"
            filesizeString += self.filterItems[indexPath.row].valueForKey("filesize") as! String
            cell.totalLabel.text = typeString + " " + createTimeString + " " + filesizeString
            //文件类型头像的不同
            switch  self.filterItems[indexPath.row].valueForKey("extensions") as! String {
            case "pdf":
                cell.typeImageView.image = UIImage(named: "pdf")
            case "ppt","pptx":
                cell.typeImageView.image = UIImage(named: "ppt")
            case "doc","docx":
                cell.typeImageView.image = UIImage(named: "word")
            case "xls","xlsx":
                cell.typeImageView.image = UIImage(named: "Excel")
            default:
                cell.typeImageView.image = UIImage(named: "教师头像")
            }
        }
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //当选择每个cell的时候 预览每个文件 访问到一个url即可
        //        let previewVC = QLPreviewController()
        //        previewVC.dataSource = self
        
        //随后改变url 然后推进preViewVC即可
      tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if(!sc.active){
            //不能打开rar还有DIR文件
            let type = self.items[indexPath.row].valueForKey("extensions") as! String
            if(type == "rar" || type == "DIR" || type == "zip"){
                ProgressHUD.showError("不能打开该类文件")
                
            }else{
            self.fileUrl = NSURL(string: (self.items[indexPath.row].valueForKey("url") as? String)!)!
            let preViewVC = UIStoryboard(name: "OneCourse", bundle: nil).instantiateViewControllerWithIdentifier("StudyResourcePreviewVC") as! StudyResourcePreviewViewController
            preViewVC.url = self.fileUrl
            preViewVC.title = self.items[indexPath.row].valueForKey("filename") as? String
              
            self.navigationController?.pushViewController(preViewVC, animated: true)
            }
        }else{
            let type = self.filterItems[indexPath.row].valueForKey("extensions") as! String
            if(type == "rar" || type == "DIR" || type == "zip"){
                ProgressHUD.showError("不能打开该类文件")
            }else{
            self.fileUrl = NSURL(string: (self.filterItems[indexPath.row].valueForKey("url") as? String)!)!
            let preViewVC = UIStoryboard(name: "OneCourse", bundle: nil).instantiateViewControllerWithIdentifier("StudyResourcePreviewVC") as! StudyResourcePreviewViewController
            preViewVC.url = self.fileUrl
            preViewVC.title = self.items[indexPath.row].valueForKey("filename") as? String
                sc.active = false
                
            self.navigationController?.pushViewController(preViewVC, animated: true)
        }
        }
    }
    //    func numberOfPreviewItemsInPreviewController(controller: QLPreviewController) -> Int {
    //        return 1
    //    }
    //    func previewController(controller: QLPreviewController, previewItemAtIndex index: Int) -> QLPreviewItem {
    //        print(self.fileUrl)
    //        return self.fileUrl
    //    }
    func headerRefresh() {
        let userDefault = NSUserDefaults.standardUserDefaults()
        let authtoken = userDefault.valueForKey("authtoken") as! String
        let url = "http://dodo.hznu.edu.cn/api/courseresoure?courseid=" + "\(self.courseId)" + "&authtoken=" + authtoken
        
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        request.timeoutInterval = 10
        request.HTTPMethod = "GET"
        Alamofire.request(request).responseJSON { (response) in
            switch response.result{
            case .Success(let Value):
                let json = JSON(Value)
                if(json["retcode"].number != 0){
                    ProgressHUD.showError("获取失败")
                    dispatch_async(dispatch_get_main_queue(), {
                        self.studyMaterialsTableView?.mj_header.endRefreshing()
                        self.items = NSArray()
                        self.studyMaterialsTableView?.reloadData()
                    })
                    print(json["retcode"].numberValue)
                }else{
                    dispatch_async(dispatch_get_main_queue(), {
                        self.studyMaterialsTableView?.mj_header.endRefreshing()
                        self.items = json["items"].arrayObject! as NSArray
                        self.title = "学习资料" + "(共" + "\(self.items.count)" + "个)"
                        self.studyMaterialsTableView?.reloadData()
                    })
                }
            case .Failure(_):
                ProgressHUD.showError("获取失败")
                dispatch_async(dispatch_get_main_queue(), {
                    self.studyMaterialsTableView?.mj_header.endRefreshing()
                    self.items = NSArray()
                    self.studyMaterialsTableView?.reloadData()
                })
                
            }
        }
    }
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        self.filterItems.removeAllObjects()
        let scopePredicate = NSPredicate(format: "SELF CONTAINS[c] %@", searchController.searchBar.text!)
        for i in 0 ..< self.items.count{
            if(scopePredicate.evaluateWithObject(self.items[i].valueForKey("filename")) == true){
                self.filterItems.addObject(self.items[i])
            }
        }
        self.studyMaterialsTableView?.reloadData()
    }
    func willPresentSearchController(searchController: UISearchController) {
        self.studyMaterialsTableView?.mj_header.hidden = true
    }
    func willDismissSearchController(searchController: UISearchController) {
        self.studyMaterialsTableView?.mj_header.hidden = false
        }
//    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        self.sc.active = false
//        self.sc.searchBar.text = ""
//       
//        }
    deinit{
        print("StudyMaterialDeinit")
        self.sc.view.removeFromSuperview()
    }
    //当该界面消失的时候 应该progress.dismiss
    override func viewWillDisappear(animated: Bool) {
       
        ProgressHUD.dismiss()
    }
  
    
}
