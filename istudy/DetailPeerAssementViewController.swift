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
class DetailPeerAssementViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{
    @IBOutlet weak var collectionView:UICollectionView?
    @IBOutlet weak var TitleLabel:UILabel?
    var titleString = NSString()
    var items = NSArray()
    //评论进度
   //第几个评论
    var id = NSInteger()
    var count = 0
    var progress = Float()
    //根据客户端和服务器传过来的值 看这条有没有评论过 现在是测试
    var isPeer = [0,0,0,0,0]
    override func viewDidLoad() {
        self.automaticallyAdjustsScrollViewInsets = false
        super.viewDidLoad()
        self.collectionView?.delegate = self
        self.collectionView?.dataSource = self
        self.TitleLabel?.text = self.titleString as String
        self.collectionView?.backgroundColor = UIColor.whiteColor()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    //返回总共要评论的数量为多少个 暂时未5个
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.count
    }
    //返回每个单元格的具体内容
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PeerAssementListCollectionCell", forIndexPath: indexPath) as! PeerAssementListCollectionViewCell
        if(indexPath.row < self.items.count){
        cell.changePeerBtn?.setTitle("修改", forState: .Normal)
      if(self.items[indexPath.row].valueForKey("hupingtime") as? String != nil &&
            self.items[indexPath.row].valueForKey("hupingtime") as! String != ""){
            cell.isPeerBtn?.setTitle("已评", forState: .Normal)
            cell.changePeerBtn?.hidden = false
            cell.isPeerBtn?.enabled = false
        if(self.items[indexPath.row].valueForKey("score") as? NSNumber != nil){
         cell.isPeerBtn?.setTitle("\(self.items[indexPath.row].valueForKey("score") as! NSNumber )", forState: .Normal)
        }
        }else{
            cell.isPeerBtn?.setTitle("未评", forState: .Normal)
            cell.isPeerBtn?.enabled = true
            cell.changePeerBtn?.hidden = true
        
            }
        cell.isPeerBtn?.tag = indexPath.row
        cell.changePeerBtn?.tag = indexPath.row
        //这里两个按钮的动作要根据有没有进行过评论 而进行修改
        cell.isPeerBtn?.addTarget(self, action: #selector(DetailPeerAssementViewController.goToPeer(_:)), forControlEvents: .TouchUpInside)
        cell.changePeerBtn?.addTarget(self, action: #selector(DetailPeerAssementViewController.goToPeer(_:)), forControlEvents: .TouchUpInside)
        cell.currentLabel?.text = "\(indexPath.row + 1)"
        cell.layer.borderWidth = 1.0
        }
        return cell
    }
    //返回每个cell是否可以选择
    func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    //定义每个cell的边框大小
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(5, 5, 5, 5)
    }
    //返回每个cell的大小
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: SCREEN_WIDTH / 4 - 15, height: SCREEN_HEIGHT / 5)
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
    override func viewWillAppear(animated: Bool) {
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
            case .Success(let Value):
                let json = JSON(Value)
                if(json["retcode"].number != 0){
                 
                    ProgressHUD.showError("请求失败")
                }else{
                    dispatch_async(dispatch_get_main_queue(), {
                        ProgressHUD.dismiss()
                        self.items = json["items"].arrayObject! as NSArray
                       
                        self.collectionView?.reloadData()
                       // print(self.items)
                    })
                }
            }
        }
    }
    override func viewWillDisappear(animated: Bool) {
        ProgressHUD.dismiss()
    }
}
