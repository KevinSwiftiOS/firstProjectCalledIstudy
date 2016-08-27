//
//  ReplyTopicViewController.swift
//  istudy
//
//  Created by hznucai on 16/4/6.
//  Copyright © 2016年 hznucai. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import DZNEmptyDataSet
import Font_Awesome_Swift
class ReplyTopicViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,DZNEmptyDataSetSource,DZNEmptyDataSetDelegate,UICollectionViewDelegate,UICollectionViewDataSource,AJPhotoPickerProtocol,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UICollectionViewDelegateFlowLayout{
    @IBOutlet weak var topLayout: NSLayoutConstraint!
    var id = NSInteger()
    @IBOutlet weak var replyTopToWriteBtm: NSLayoutConstraint!
    var items = NSArray()
    @IBOutlet weak var collectionView:UICollectionView?
    var projectid = NSInteger()
    var topView = UIView()
    var bubbleView = AYBubbleView()
    var photos = NSMutableArray()
    //记录高度的
    var cellHeight = NSMutableArray()
    var ajPicker = AJPhotoPickerViewController()
    //回复的内容
    @IBOutlet weak var writeTextView:JVFloatLabeledTextView?
    @IBOutlet weak var replyListTableView:mainTableView?
    @IBOutlet weak var sendBtn:UIButton!
    @IBOutlet weak var photoBtn:UIButton!
    // @IBOutlet weak var voiceBtn:UIButton!
    @IBOutlet weak var btmView:UIView!
    override func viewDidLoad() {
        topView = UIView(frame: CGRectMake(80,0,SCREEN_WIDTH - 80,64))
        self.navigationController?.view.addSubview(topView)
        super.viewDidLoad()
        self.replyListTableView?.emptyDataSetDelegate = self
        self.automaticallyAdjustsScrollViewInsets = false
        self.collectionView?.dataSource = self
        self.collectionView?.delegate = self
        ShowBigImageFactory.topViewEDit(btmView)
        self.replyListTableView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ReplyTopicViewController.TableViewResign)))
        self.collectionView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ReplyTopicViewController.TableViewResign)))
        self.collectionView?.backgroundColor = UIColor.whiteColor()
        //气泡的效果
        var point = topView.center
        point.x -= 84
        //头部的总够有几个回复
        bubbleView = AYBubbleView(centerPoint: (point), bubleRadius: 15, addToSuperView: topView)
        bubbleView.bubbleColor = UIColor.redColor()
        sendBtn?.setFAText(prefixText: "", icon: FAType.FASend, postfixText: "", size: 25, forState: .Normal)
        photoBtn?.setFAText(prefixText: "", icon: FAType.FAImage, postfixText: "", size: 25, forState: .Normal)
        //             voiceBtn?.setFAText(prefixText: "", icon: FAType.FAMusic, postfixText: "", size: 25, forState: .Normal)
        
        self.automaticallyAdjustsScrollViewInsets = false
        self.writeTextView?.placeholder = "请输入回复内容"
        self.replyListTableView?.dataSource = self
        self.replyListTableView?.delegate = self
        self.replyListTableView?.tableFooterView = UIView()
        self.replyListTableView?.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(ReplyTopicViewController.headerRefresh))
        
        self.replyListTableView?.emptyDataSetDelegate = self
        //注册webView加载完的通知
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ReplyTopicViewController.reloadHeight(_:)), name: "replyListContentWebViewHeight", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ReplyTopicViewController.replyImageShowBig(_:)), name: "replyListShowBig", object: nil)
        self.replyListTableView?.mj_header.beginRefreshing()
        // Do any additional setup after loading the view.
    }
    func emptyDataSetShouldAllowScroll(scrollView: UIScrollView!) -> Bool {
        return true
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //头视图 tableView的一些代理
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRectMake(0,0,SCREEN_WIDTH,21))
        let label = UILabel(frame: CGRectMake(0,0,SCREEN_WIDTH,21))
        label.text = "回复列表:"
        label.textAlignment = .Left
        view.addSubview(label)
        return view
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ReplyListTableViewCell")
            as! ReplyListTableViewCell
        if(indexPath.row < self.items.count){
        cell.authorLabel?.text = self.items[indexPath.row].valueForKey("author") as? String
        //加载头像
        if(self.items[indexPath.row].valueForKey("avatar_url") as? String != nil &&
            self.items[indexPath.row].valueForKey("avatar_url") as! String != ""){
            //将base64转化成图片 首先转化成数据流 随后再转化图片
            cell.headImageView?.sd_setImageWithURL(NSURL(string: self.items[indexPath.row].valueForKey("avatar_url") as! String), placeholderImage: UIImage(named: "默认头像"))
            cell.headImageView?.layer.cornerRadius = 6.0
            cell.headImageView?.layer.masksToBounds = true
        }else{
            cell.headImageView?.image = UIImage(named: "默认头像")
            
        }
        //时间的切割
        let yearRange = NSMakeRange(0, 4)
        let monthRange = NSMakeRange(4, 2)
        let dateRange = NSMakeRange(6, 2)
        let  tempDate = items[indexPath.row].valueForKey("date") as! NSString
        let date = "于" + (tempDate.substringWithRange(yearRange) + "年" + tempDate.substringWithRange(monthRange) + "月" + tempDate.substringWithRange(dateRange)  + "日 "  + "发表")
        cell.dateLabel?.text = date
        
        cell.contectWebView?.loadHTMLString(imageDecString + (self.items[indexPath.row].valueForKey("content") as! String), baseURL: nil)
        cell.cellTag = indexPath.row
        }
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        writeTextView?.resignFirstResponder()
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return self.cellHeight[indexPath.row] as! CGFloat
    }
    //tableViewcell的动画
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layer.transform = CATransform3DMakeScale(0.1, 0.1, 1.0)
        UIView.animateWithDuration(0.8) {
            cell.layer.transform = CATransform3DMakeScale(1, 1, 1)
        }
        
    }
    
    
    //回复的按钮
    @IBAction func reply(sender:UIButton){
        let userDefault = NSUserDefaults.standardUserDefaults()
        let authtoken = userDefault.valueForKey("authtoken") as!  String
        //主题
        //内容
        
        var content:String = self.writeTextView!.text
        for i in 0 ..< self.photos.count{
                   let base64String = imageToBae64(self.photos[i] as! UIImage)
            let imgHtml = "<img"  +  " src = " + "\"" +  "data:image/jpg;base64," + base64String +  "\"" + "/>"
            content += imgHtml
        }
        let dic:[String:AnyObject] = ["subject":"",
                                      "parentid":"\(self.id)",
                                      "content":content,
                                      "forumtypeid":"",
                                      "projectid":"\(self.projectid)"]
        if(content == ""){
            ProgressHUD.showError("回复不能为空")
        }else{
        var result = String()
        //先转化成data数据流 随后再转化成base64的字符串
        do{
            var paramData = NSData()
            paramData = try NSJSONSerialization.dataWithJSONObject(dic, options: NSJSONWritingOptions.PrettyPrinted)
            
            result = paramData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
            
        }catch{
            print(2)
        }
        let paramDic:[String:AnyObject] = ["authtoken":authtoken,
                                           "postype":"2",
                                           "data":result]
        
        Alamofire.request(.POST, "http://dodo.hznu.edu.cn/api/forumpost", parameters: paramDic, encoding: ParameterEncoding.URL, headers: nil).responseJSON { (response) in
            switch response.result{
            case .Failure(_):
                ProgressHUD.showError("发送失败")
                print(2)
            case .Success(let Value):
                let json = JSON(Value)
                if(json["retcode"].number != 0){
                    ProgressHUD.showError("发送失败")
                    print(json["retcode"].number)
                }else{
                    ProgressHUD.showSuccess("发送成功")
                    dispatch_async(dispatch_get_main_queue(), {
                        self.photos = NSMutableArray()
                        self.writeTextView?.text = ""
                        self.updateView()
                        self.replyListTableView?.mj_header.beginRefreshing()
                    })
                }
            }
        }
        }
    }
    //键盘消失的动作
    @IBAction func resign(sender: UIControl) {
        self.writeTextView?.resignFirstResponder()
    }
    func TableViewResign() {
        self.writeTextView?.resignFirstResponder()
    }
    override func viewWillDisappear(animated: Bool) {
        topView.removeFromSuperview()
        ProgressHUD.dismiss()
        
    }
    //头部视图的刷新
    func headerRefresh() {
        //查询论坛的主题回复
        let userDefault = NSUserDefaults.standardUserDefaults()
        let authtoken = userDefault.valueForKey("authtoken") as! String
        let dic:[String:AnyObject] = ["authtoken":authtoken,
                                      "count":"100",
                                      "page":"1",
                                      "tag":"\(self.id)"]
        Alamofire.request(.POST, "http://dodo.hznu.edu.cn/api/forumcommentquery", parameters: dic, encoding: ParameterEncoding.URL, headers: nil).responseJSON { (response) in
            switch response.result{
            case .Success(let Value):
                let json = JSON(Value)
                if(json["retcode"].number != 0){
                    ProgressHUD.showError("请求失败")
                    dispatch_async(dispatch_get_main_queue(), {
                        self.replyListTableView?.emptyDataSetSource = self
                        self.items = NSArray()
                        self.replyListTableView?.mj_header.endRefreshing()
                        self.updateView()
                    })
                    
                }else{
                    self.items = json["items"].arrayObject! as NSArray
                    for _ in 0 ..< self.items.count{
                        self.cellHeight.addObject(10 + 21 + 10 + 21 + 30)
                    }
                    dispatch_async(dispatch_get_main_queue(), {
                        self.replyListTableView?.mj_header.endRefreshing()
                        ProgressHUD.dismiss()
                        self.bubbleView.unReadLabel.text = "\(self.items.count)"
                        self.replyListTableView?.emptyDataSetSource = self
                        self.updateView()
                        
                    })
                    
                    
                }
            case .Failure(_):
                ProgressHUD.showError("请求失败")
                dispatch_async(dispatch_get_main_queue(), {
                    self.replyListTableView?.emptyDataSetSource = self
                    self.items = NSArray()
                    self.replyListTableView?.mj_header.endRefreshing()
                    self.updateView()                })
            }
        }
        
    }
    //高度的问题
    func reloadHeight(sender:NSNotification){
        let cell = sender.object as! ReplyListTableViewCell
        if(cell.cellHeight != self.cellHeight[cell.cellTag] as! CGFloat){
            self.cellHeight[cell.cellTag] = cell.cellHeight
            self.replyListTableView?.reloadData()
        }
    }
    //图片的放大
    func replyImageShowBig(sender:NSNotification){
        let cell = sender.object as! ReplyListTableViewCell
        
        let vc = UIStoryboard(name: "Problem", bundle: nil).instantiateViewControllerWithIdentifier("showBigVC") as! ImageShowBigViewController
        vc.url = cell.url
        self.navigationController?.pushViewController(vc, animated: true)
    }
    //选择相册的代理
    @IBAction func addPhoto(sender:UIButton){
        let photoPicker = AJPhotoPickerViewController()
        photoPicker.delegate = self
        
        //设置最大的数量
        photoPicker.maximumNumberOfSelection = 6
        photoPicker.multipleSelection = true
        //资源过滤
        photoPicker.assetsFilter = ALAssetsFilter.allPhotos()
        photoPicker.showEmptyGroups = true
        photoPicker.delegate = self
        photoPicker.selectionFilter = NSPredicate(block: { (evaluatedObjecy:AnyObject, dic:[String : AnyObject]?) -> Bool in
            return true
        })
        self.presentViewController(photoPicker, animated: true, completion: nil)
    }
    //每张图片转化成base64的字符串
    func imageToBae64(image:UIImage) -> String{
        let data = UIImageJPEGRepresentation(image, 0.5)
        let encodeString = data?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
        return encodeString!
    }
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    //定义每个cell的大小 collectionView 图片视图的代理
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(SCREEN_WIDTH / 5, SCREEN_HEIGHT / 8)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photos.count
    }
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        writeTextView?.resignFirstResponder()
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("photoCell", forIndexPath: indexPath) as! PhotoWaterfallCollectionViewCell
        if(indexPath.row < self.photos.count){
            cell.btn.setBackgroundImage(self.photos[indexPath.row] as? UIImage, forState: .Normal)
            cell.btn.addTarget(self, action: #selector(ReplyTopicViewController.collectionPhotosShowBig(_:)), forControlEvents: .TouchUpInside)
            cell.btn.tag = indexPath.row
        }
        return cell
    }
    //collectionView中图片点击的放大
    func collectionPhotosShowBig(sender:UIButton) {
        let previewPhotoVC = UIStoryboard(name: "Problem", bundle: nil).instantiateViewControllerWithIdentifier("previewPhotoVC") as! previewPhotoViewController
        previewPhotoVC.toShowBigImageArray = self.photos
        previewPhotoVC.contentOffsetX = CGFloat(sender.tag)
        self.navigationController?.pushViewController(previewPhotoVC, animated: true)
    }
    //选取照片的一些代理
    //当选择超过最大比重时
    func photoPickerDidMaximum(picker: AJPhotoPickerViewController!) {
        
        
        ProgressHUD.showError("已超过最大选择数")
    }
    //当点击取消按钮时
    func photoPickerDidCancel(picker: AJPhotoPickerViewController!) {
        self.updateView()
        
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    //当点击了照相机的时候
    func photoPickerTapCameraAction(picker: AJPhotoPickerViewController!) {
        self.updateView()
        
        let cameraPicker = UIImagePickerController()
        if (UIImagePickerController.availableMediaTypesForSourceType(.Camera) != nil){
            cameraPicker.sourceType = .Camera
            cameraPicker.delegate = self
            picker.presentViewController(cameraPicker, animated: true, completion: nil)
        }else{
            ProgressHUD.showError("不支持相机")
        }
    }
    //当相机拍完了照片后
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        self.photos.addObject(image)
        self.topLayout.constant = (self.collectionView?.frame.height)! + 10
        self.view.setNeedsLayout()
        picker.dismissViewControllerAnimated(true, completion: nil)
        self.updateView()
        
        self.collectionView?.reloadData()
    }
    //退出照相机的时候
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        self.updateView()
        
    }
    //当选择好相册后
    func photoPicker(picker: AJPhotoPickerViewController!, didSelectAssets assets: [AnyObject]!) {
        for i in 0 ..< assets.count {
            let asset = assets[i]
            let tempImage = UIImage(CGImage: asset.defaultRepresentation().fullScreenImage().takeUnretainedValue())
            self.photos.addObject(tempImage)
        }
        picker.dismissViewControllerAnimated(true, completion: nil)
        
        
        ProgressHUD.dismiss()
        self.updateView()
        self.replyListTableView?.reloadData()
        self.collectionView?.reloadData()
    }
    func updateView() {
        if(self.photos.count > 0){
            let photoCollecionLabel = UILabel(frame: CGRectMake(5, 64 + SCREEN_HEIGHT * 0.15 + 5,SCREEN_WIDTH - 10,21))
            photoCollecionLabel.text = "图片区:"
            self.view.addSubview(photoCollecionLabel)
            self.collectionView?.frame = CGRectMake(5, 64 + SCREEN_HEIGHT * 0.15 + 5 + 23, SCREEN_WIDTH - 10,SCREEN_HEIGHT * 0.15)
            self.collectionView?.layer.borderWidth = 0.3
            self.collectionView?.layer.borderColor = UIColor.grayColor().CGColor
            self.replyTopToWriteBtm?.constant = SCREEN_HEIGHT * 0.3 + 5
        }else{
            self.replyTopToWriteBtm?.constant =  8
        }
        self.replyListTableView?.emptyDataSetDelegate = self
        self.replyListTableView?.emptyDataSetSource = self
        self.replyListTableView?.reloadData()
        self.collectionView?.reloadData()
        self.view.bringSubviewToFront(self.replyListTableView!)
        
        self.view.setNeedsLayout()
        self.view.setNeedsDisplay()
        
    }
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let string = "暂无评论"
        let dic = [NSFontAttributeName:UIFont.boldSystemFontOfSize(18.0),
                   NSForegroundColorAttributeName:UIColor.grayColor()]
        let attriString = NSMutableAttributedString(string: string, attributes: dic)
        return attriString
    }
    
    deinit {
        print("replyTableDeinit")
    }
}
