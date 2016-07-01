//
//  DetailPeerAssementViewController.swift
//  istudy
//
//  Created by hznucai on 16/3/22.
//  Copyright © 2016年 hznucai. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import DZNEmptyDataSet
class DetailPeerAssementViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,DZNEmptyDataSetSource,DZNEmptyDataSetDelegate{
    @IBOutlet weak var tableView:UITableView?
    @IBOutlet weak var TitleLabel:UILabel?
    var titleString = NSString()
    var items = NSArray()
    //评论进度
   //第几个评论
    var id = NSInteger()
    var count = 0
    var progress = Float()
    //根据客户端和服务器传过来的值 看这条有没有评论过 现在是测试
      override func viewDidLoad() {
        self.automaticallyAdjustsScrollViewInsets = false
        super.viewDidLoad()
        self.tableView?.delegate = self
        self.tableView?.dataSource = self
        self.TitleLabel?.text = self.titleString as String
        self.tableView?.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(DetailPeerAssementViewController.headerRefresh))
    self.tableView?.mj_header.beginRefreshing()
        self.tableView?.tableFooterView = UIView()
        let segmentController = AKSegmentedControl(frame: CGRectMake(20,21 + 64,SCREEN_WIDTH - 40, 37))
        self.tableView?.frame = CGRectMake(0, 21 + 50 + 64, SCREEN_WIDTH, SCREEN_HEIGHT - 37 - 50 - 64)
        let btnArray =  [["image":"默认头像","title":"序号"],
                         ["image":"默认头像","title":"得分"],
                         ["image":"默认头像","title":"是否评分"],
                         ["image":"默认头像","title":"操作"]]
        // Do any additional setup after loading the view.
        segmentController.initButtonWithTitleandImage(btnArray)
        view.addSubview(segmentController)

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
    }    //返回总共要评论的数量为多少个 暂时未5个
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    //头部的视图

    //返回每个单元格的具体内容
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("PeerCell") as! PeerTableViewCell
        
        if(indexPath.row < self.items.count){
        cell.peerBtn?.setTitle("评分", forState: .Normal)
            cell.YorNLabel.text = "否"
cell.numLabel.text = "\(indexPath.row + 1)"
if(self.items[indexPath.row].valueForKey("hupingtime") as? String != nil &&
            self.items[indexPath.row].valueForKey("hupingtime") as! String != ""){
            cell.peerBtn?.setTitle("修改", forState: .Normal)
        cell.YorNLabel.text = "是"
            }
        if(self.items[indexPath.row].valueForKey("score") as? NSNumber != nil
            && self.items[indexPath.row].valueForKey("score") as! NSNumber != 0){
           cell.scoreLabel.text = "\(self.items[indexPath.row].valueForKey("score") as! NSNumber)"
            
        }
        else{
        cell.scoreLabel.text = "0"
            }
      
        cell.peerBtn?.addTarget(self, action: #selector(DetailPeerAssementViewController.goToPeer(_:)), forControlEvents: .TouchUpInside)
            cell.peerBtn.layer.cornerRadius = 6.0
            cell.peerBtn.layer.masksToBounds = true
        }
        cell.selectionStyle = .None
        return cell
    }
 
    //进行详细评论的界面
    func goToPeer(sender:UIButton){
        let writePeerAssessmentVC = UIStoryboard(name: "PeerAssessment", bundle: nil).instantiateViewControllerWithIdentifier("WritePeerAssessmentVC") as! WritePeerAssessmentViewController
        writePeerAssessmentVC.title = "评论"
       
        writePeerAssessmentVC.usertestid = self.items[sender.tag].valueForKey("usertestid") as! NSInteger
//        writePeerAssessmentVC.callBack = {(index:NSInteger) -> Void in
//            weak var wself = self
//            wself!.isPeer[index] = 1
//            wself!.collectionView?.reloadData()

        //}
        
        self.navigationController?.pushViewController(writePeerAssessmentVC, animated: true)
    }
 func headerRefresh() {
       ProgressHUD.show("请稍候")
       let userDefault = NSUserDefaults.standardUserDefaults()
        let authtoken = userDefault.valueForKey("authtoken") as! String
        //写请求时间等等
        let urlString = "http://dodo.hznu.edu.cn/api/hupinginfo?testid=" + "\(self.id)" + "&authtoken=" + authtoken
        let request = NSMutableURLRequest(URL: NSURL(string: urlString)!, cachePolicy:NSURLRequestCachePolicy.UseProtocolCachePolicy, timeoutInterval: 5)
       request.HTTPMethod = "POST"
        Alamofire.request(request).responseJSON { (response) in
            switch response.result{
            case .Failure(_):
              ProgressHUD.showError("请求失败")
                dispatch_async(dispatch_get_main_queue(), {
                    self.items = NSArray()
                    self.tableView?.mj_header.endRefreshing()
                    self.tableView?.emptyDataSetSource = self
                    self.tableView?.reloadData()
                })
            case .Success(let Value):
                let json = JSON(Value)
                print(json)
                if(json["retcode"].number != 0){
                 
                    ProgressHUD.showError("请求失败")
                    dispatch_async(dispatch_get_main_queue(), {
                        self.items = NSArray()
                        self.tableView?.mj_header.endRefreshing()
                        self.tableView?.emptyDataSetSource = self
                        self.tableView?.reloadData()
                    })
                }else{
                    dispatch_async(dispatch_get_main_queue(), {
                        ProgressHUD.dismiss()
                        self.items = json["items"].arrayObject! as NSArray
                        self.tableView?.mj_header.endRefreshing()
                        self.tableView?.emptyDataSetSource = self
                        self.tableView?.reloadData()
                       // print(self.items)
                    })
                }
            }
        }
    }
    override func viewWillDisappear(animated: Bool) {
        ProgressHUD.dismiss()
    }
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let string = "暂无互评信息"
        let dic = [NSFontAttributeName:UIFont.boldSystemFontOfSize(18.0),
                   NSForegroundColorAttributeName:UIColor.grayColor()]
        let attriString = NSMutableAttributedString(string: string, attributes: dic)
        return attriString
    }
    
}
