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
import DZNEmptyDataSet
import Font_Awesome_Swift
//这里是一个tableView 随后每次点击这个tableView的时候就会预览文档
import QuickLook
class StudyMaterialViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,
UISearchControllerDelegate,UISearchResultsUpdating,DZNEmptyDataSetSource,DZNEmptyDataSetDelegate,QLPreviewControllerDataSource,QLPreviewControllerDelegate{
    //courseID
    var filePath = ""
    var courseId = NSInteger()
    var filterItems = NSMutableArray()
    var sc = UISearchController(searchResultsController: nil)
    
    @IBOutlet weak var studyMaterialsTableView:UITableView?
    //应该接受到一个url 和每份资料的标题等
    var items = NSMutableArray()
       override func viewDidLoad() {
        super.viewDidLoad()
               self.automaticallyAdjustsScrollViewInsets = false
        self.studyMaterialsTableView?.delegate = self
        self.studyMaterialsTableView?.dataSource = self
        self.studyMaterialsTableView?.tableFooterView = UIView()
        self.studyMaterialsTableView?.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(StudyMaterialViewController.headerRefresh))
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
        self.studyMaterialsTableView?.emptyDataSetDelegate = self
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //tableView的代理
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
            if(indexPath.row < self.items.count){
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
                cell.typeImageView.image = UIImage(named: "zip")
            }
            }
        }else{
            if(indexPath.row < self.filterItems.count){
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
                cell.typeImageView.image = UIImage(named: "zip")
            }
        }
        }
        return cell
    }
    //当选择这个文件后 先判断沙盒里面是否存在这个文件 有就直接打开 没有就先下载 随后打开
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let doc = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
   

        if(!sc.active){
            //判断是否存在这个文件
            //不能打开rar还有DIR文件
            filePath = doc[0] + "/" + diviseFileUrl((self.items[indexPath.row].valueForKey("url") as? String)!)
            if(fileExist(filePath)){
                let qlVC = QLPreviewController()
                qlVC.delegate = self
                qlVC.dataSource = self

                self.navigationController?.pushViewController(qlVC, animated: true)
            }
            else{
                   ProgressHUD.show("正在下载中")
                //tableView不可点击 并且有提示框提示下载多少
            tableView.userInteractionEnabled = false
                let destination = Alamofire.Request.suggestedDownloadDestination(directory: .DocumentDirectory, domain: .UserDomainMask)
                Alamofire.download(.GET, NSURL(string: self.items[indexPath.row].valueForKey("url") as! String)!, destination: destination).progress { (bytesRead, totalBytesRead, totalBytesExpectedToRead) in
                 
                    }.response { (request, response, _, error) in
                        if(error == nil){
                            let qlVC = QLPreviewController()
                            qlVC.delegate = self
                            qlVC.dataSource = self

                            ProgressHUD.showSuccess("下载成功")
                            tableView.userInteractionEnabled = true
                            self.filePath = doc[0] + "/" + diviseFileUrl((self.items[indexPath.row].valueForKey("url") as? String)!)
                            self.navigationController?.pushViewController(qlVC, animated: true)
                            
                        }else{
                               tableView.userInteractionEnabled = true
                            ProgressHUD.showError("下载失败")
                        }
                }
            }
        }
        else{
            //要把搜索条拿掉
            
            filePath = doc[0] + "/" + diviseFileUrl((self.filterItems[indexPath.row].valueForKey("url") as? String)!)
            if(fileExist(filePath)){
                self.sc.active = false
                let qlVC = QLPreviewController()
                qlVC.delegate = self
                qlVC.dataSource = self

                self.navigationController?.pushViewController(qlVC, animated: true)
            }
            else{
                   ProgressHUD.show("正在下载中")
                let destination = Alamofire.Request.suggestedDownloadDestination(directory: .DocumentDirectory, domain: .UserDomainMask)
                Alamofire.download(.GET, NSURL(string: self.filterItems[indexPath.row].valueForKey("url") as! String)!, destination: destination).progress { (bytesRead, totalBytesRead, totalBytesExpectedToRead) in
                    }.response { (request, response, _, error) in
                        if(error == nil){
                            ProgressHUD.showSuccess("下载成功")
                            self.filePath = doc[0] + "/" + diviseFileUrl((self.filterItems[indexPath.row].valueForKey("url") as? String)!)
                            self.sc.active = false
                            let qlVC = QLPreviewController()
                            qlVC.delegate = self
                            qlVC.dataSource = self

                            self.navigationController?.pushViewController(qlVC, animated: true)
                            
                            
                        }else{
                            ProgressHUD.showError("下载失败")
                        }
                }
            }
        }
    }
    func numberOfPreviewItemsInPreviewController(controller: QLPreviewController) -> Int {
        return 1
    }
    func previewController(controller: QLPreviewController, previewItemAtIndex index: Int) -> QLPreviewItem {
        let fileUrl = NSURL(fileURLWithPath: self.filePath)
        return fileUrl
    }
    func previewController(controller: QLPreviewController, shouldOpenURL url: NSURL, forPreviewItem item: QLPreviewItem) -> Bool {
        return true
    }
    //headerView的刷新
    func headerRefresh() {
        let userDefault = NSUserDefaults.standardUserDefaults()
        let authtoken = userDefault.valueForKey("authtoken") as! String
        let url = "http://dodo.hznu.edu.cn/api/courseresoure?courseid=" + "\(self.courseId)" + "&authtoken=" + authtoken
        
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        request.timeoutInterval = 10
        request.HTTPMethod = "POST"
        Alamofire.request(request).responseJSON { (response) in
            switch response.result{
            case .Success(let Value):
                let json = JSON(Value)
                
                if(json["retcode"].number != 0){
                    ProgressHUD.showError("获取失败")
                    dispatch_async(dispatch_get_main_queue(), {
                        self.studyMaterialsTableView?.mj_header.endRefreshing()
                        self.items = NSMutableArray()
                        self.studyMaterialsTableView?.emptyDataSetSource = self
                        self.studyMaterialsTableView?.reloadData()
                    })
                    print(json["retcode"].numberValue)
                }else{
                    dispatch_async(dispatch_get_main_queue(), {
                        self.studyMaterialsTableView?.mj_header.endRefreshing()
                        let jsonItems = json["items"].arrayObject! as NSArray
                        self.items = NSMutableArray()
                        for i in 0 ..< jsonItems.count{
                            if(jsonItems[i].valueForKey("extensions") as! String != "DIR"){
                                self.items.addObject(jsonItems[i])
                            }
                        }
                        self.title = "学习资料" + "(共" + "\(self.items.count)" + "个)"
                        self.studyMaterialsTableView?.emptyDataSetSource = self
                        self.studyMaterialsTableView?.reloadData()
                    })
                }
            case .Failure(_):
                ProgressHUD.showError("获取失败")
                dispatch_async(dispatch_get_main_queue(), {
                    self.studyMaterialsTableView?.mj_header.endRefreshing()
                    self.items = NSMutableArray()
                    self.studyMaterialsTableView?.emptyDataSetSource = self
                    self.studyMaterialsTableView?.reloadData()
                })
                
            }
        }
    }
    //顶部的搜索条的代理
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
    
    deinit{
        print("StudyMaterialDeinit")
        self.sc.view.removeFromSuperview()
    }
    //当该界面消失的时候 应该progress.dismiss
    override func viewWillDisappear(animated: Bool) {
        
        ProgressHUD.dismiss()
    }
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let string = "暂无学习资料信息"
        let dic = [NSFontAttributeName:UIFont.boldSystemFontOfSize(18.0),
                   NSForegroundColorAttributeName:UIColor.grayColor()]
        let attriString = NSMutableAttributedString(string: string, attributes: dic)
        return attriString
    }
    func emptyDataSetShouldAllowScroll(scrollView: UIScrollView!) -> Bool {
        return true
    }
    //判断文件是否存在
    func fileExist(fileUrl:String) -> Bool{
        let fileManager = NSFileManager.defaultManager()
        if(fileManager.fileExistsAtPath(fileUrl)){
            return true
        }
        return false
    }
}
