//
//  SubjectiveQusViewController.swift
//  istudy
//
//  Created by hznucai on 16/3/16.
//  Copyright © 2016年 hznucai. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
class SubjectiveQusViewController: UIViewController,AJPhotoPickerProtocol,UINavigationControllerDelegate,UIImagePickerControllerDelegate,BlurEffectMenuDelegate,UIGestureRecognizerDelegate,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource,UIWebViewDelegate{
    //记录date和阅卷是否开启 和阅卷的时候答案是否可见等等
    var endDate = NSDate()
       //是否可以阅卷
    var  enableClientJudge = Bool()
    var keyVisible = Bool()
    var viewOneWithAnswerKey = Bool()
   var tap = UITapGestureRecognizer()
    var tap1 = UITapGestureRecognizer()
    //用来记录textView的frame
    var frame = CGRect()
    //从其他题型跳转过来的
    var imagePicker:AJPhotoPickerViewController!
    var isFromOtherKindQus = false
    //记录当前是第几个题型
    var kindOfQusIndex = NSInteger()
      var id = NSInteger()
    var testid = NSInteger()
    var totalItems = NSArray()
    var items = NSArray()
    var totalKindOfQus = NSInteger()
    
    @IBOutlet weak var qusKind:UILabel?
var  addBtn = UIButton()
var resetBtn = UIButton()
   @IBOutlet weak var saveBtn:UIButton!
    @IBOutlet weak var contentScrollView:UIScrollView?
    @IBOutlet weak var currentQus:UILabel?
  var qusDes = UIWebView()
 var answerWebView = UIWebView()
 var answerTextView = JVFloatLabeledTextView()
    var totalHeight:CGFloat = 0.0
    //用来包裹题目描述 reset和addBtn 还有 commentBtn 还有 评语等
    @IBOutlet weak var collectionView:UICollectionView!
    //展示图片的瀑布流形式的collectionView
    @IBOutlet weak var topView:UIView?
    var menu:BlurEffectMenu!
    var longTap = UILongPressGestureRecognizer()
    //记录当前在第几页和总共的页数
    var index:NSInteger = 0
    var answerPhotos = NSMutableArray()
    //记录自己答案的html格式的字符串
    var selfAnswers = NSMutableArray()
    override func viewDidLoad() {
        super.viewDidLoad()
              //顶部加条线
        //设置阴影效果
       ShowBigImageFactory.topViewEDit(self.topView!)

        self.contentScrollView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SubjectiveQusViewController.contResign)))
        self.view.endEditing(true)
        UIApplication.sharedApplication().keyWindow?.endEditing(true)
        self.collectionView?.delegate = self
        self.collectionView?.dataSource  = self
        self.collectionView?.backgroundColor = UIColor.whiteColor()
         self.tap = UITapGestureRecognizer(target: self, action: #selector(SubjectiveQusViewController.webViewShowBig(_:)))
 self.tap1 = UITapGestureRecognizer(target: self, action: #selector(SubjectiveQusViewController.webViewShowBig(_:)))
       self.automaticallyAdjustsScrollViewInsets = false
        //backBtn和submitBtn
        let backBtn = UIButton(frame: CGRectMake(0,0,43,43))
        
        backBtn.contentHorizontalAlignment = .Left
        backBtn.tag = 1
        backBtn.setTitle("返回", forState: .Normal)
        backBtn.setTitleColor(UIColor.blackColor(), forState: .Normal)
        backBtn.addTarget(self, action: #selector(SubjectiveQusViewController.back(_:)), forControlEvents: .TouchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBtn)
        let actBtn = UIButton(frame: CGRectMake(0,0,43,43))
        //查看的btn
        actBtn.contentHorizontalAlignment = .Left
        actBtn.setTitle("查看", forState: .Normal)
        actBtn.setTitleColor(UIColor.blackColor(), forState: .Normal)
        actBtn.addTarget(self, action:#selector(SubjectiveQusViewController.showAct), forControlEvents: .TouchUpInside)
        //还有提交作业的btn
        let submitBtn = UIButton(frame: CGRectMake(0,0,43,43))
        submitBtn.contentHorizontalAlignment = .Right
        submitBtn.setTitle("提交", forState: .Normal)
        submitBtn.tag = 2
        submitBtn.setTitleColor(UIColor.blackColor(), forState: .Normal)
        submitBtn.addTarget(self, action: #selector(SubjectiveQusViewController.back(_:)), forControlEvents: .TouchUpInside)
        let submitBtnItem = UIBarButtonItem(customView: submitBtn)
        let actBtnItem = UIBarButtonItem(customView: actBtn)
        self.navigationItem.rightBarButtonItems = [submitBtnItem,actBtnItem]
          //键盘出现的时候
        //键盘的代理
        XKeyBoard.registerKeyBoardHide(self)
        XKeyBoard.registerKeyBoardShow(self)
        //刚开始的时候是图片的界面和文字的界面全部都隐藏掉
        //这个主页增加手势
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(SubjectiveQusViewController.addNewQus(_:)))
        leftSwipe.direction = .Left
        self.view.addGestureRecognizer(leftSwipe)
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(SubjectiveQusViewController.addNewQus(_:)))
        rightSwipe.direction = .Right
        self.view.addGestureRecognizer(rightSwipe)
        //加载答案
        //初始化
        for i in 0 ..< self.items.count{
            if(self.items[i].valueForKey("answer") as? String != nil && self.items[i].valueForKey("answer") as! String != ""){
                self.selfAnswers.addObject(self.items[i].valueForKey("answer") as! String)
            }else{
                self.selfAnswers.addObject("")
            }
        }
      
        self.initView()
     
    }
    func showAct(){
        let vc = UIStoryboard(name: "Problem", bundle: nil).instantiateViewControllerWithIdentifier("AchVC") as! AchViewController
        vc.title = self.title
        vc.totalItems = self.totalItems
        vc.testid = self.testid
        vc.enableClientJudge = self.enableClientJudge
        vc.keyVisible = self.keyVisible
        vc.endDate = self.endDate
        vc.viewOneWithAnswerKey = self.viewOneWithAnswerKey
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //返回试卷列表或者根视图
    func back(sender:UIButton) {
        
        if(sender.tag == 1) {
            let vc = UIStoryboard(name: "OneCourse", bundle: nil).instantiateViewControllerWithIdentifier("MyHomeWorkVC") as! MyHomeWorkViewController
            
            for temp in (self.navigationController?.viewControllers)!{
                if(temp .isKindOfClass(vc.classForCoder)){
                    self.navigationController?.popToViewController(temp, animated: true)
                }
            }
        }else{
            let alertView = UIAlertController(title: nil, message: "确认提交吗？", preferredStyle: UIAlertControllerStyle.Alert)
            let cancelAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.Destructive, handler: nil)
            let submitAction = UIAlertAction(title: "确定", style: UIAlertActionStyle.Default, handler: { (alert) in
                self.navigationController?.popToRootViewControllerAnimated(true)
            })
            alertView.addAction(submitAction)
            alertView.addAction(cancelAction)
            self.presentViewController(alertView, animated: true, completion: nil)
        }
        
        
    }

 //初始化界面
    func initView() {
        //加载界面的时候
        for view in (self.contentScrollView?.subviews)!{
            view.removeFromSuperview()
        }
    self.qusDes.loadHTMLString(self.items[index].valueForKey("content") as! String, baseURL: nil)
        self.qusDes.delegate = self
            self.qusKind?.text = self.totalItems[kindOfQusIndex].valueForKey("title") as! String +  "(" +
      "\(self.items[index].valueForKey("totalscore") as! NSNumber)" + "分/题)"
        self.currentQus!.text = "\(index + 1)" + "/" + "\(self.items.count)"
      tap.delegate = self
        self.qusDes.addGestureRecognizer(tap)
        tap1.delegate = self
        self.qusDes.userInteractionEnabled = true
        self.qusDes.tag = 0
        self.answerWebView.tag = 1
        self.answerWebView.addGestureRecognizer(tap1)
    }

       override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func contResign() {
        self.answerTextView.resignFirstResponder()
    }
    //键盘消失的代码
    @IBAction func resign(sender: UIControl) {
    self.answerTextView.resignFirstResponder()
    }
    
   //保存的代码
     func save(sender:UIButton){
        //save的时候转化成为html的格式 随后answerTextView和imageView进行初始化影藏
        self.answerTextView.hidden = true
       var tempHtmlString = ""
         tempHtmlString = self.answerTextView.text

        //循环将图片数组中的值取出 转化成html格式
        for i in 0 ..< self.answerPhotos.count{
            let widthAndHeight = " width = " + "\(50)" + " height = " + "\(50)"
            let base64String = imageToBae64(self.answerPhotos[i] as! UIImage)
    let imgHtml = "<img"  + widthAndHeight +  " src = " + "\"" +  "data:image/jpg;base64," + base64String +  "\"" + "/>"
        
       tempHtmlString += imgHtml
        }
     
        self.collectionView!.hidden = true
        self.answerTextView.hidden = true
        
        self.answerWebView.hidden = false
    //转化成html的格式
        self.selfAnswers.replaceObjectAtIndex(index, withObject: tempHtmlString)
       
        self.answerWebView.loadHTMLString(self.selfAnswers[index] as! String, baseURL: nil)
        //一个个来加载控件
        let tap = UITapGestureRecognizer(target: self, action: #selector(SubjectiveQusViewController.webViewShowBig(_:)))
        tap.delegate = self
        self.answerWebView.userInteractionEnabled = true
        self.answerWebView.addGestureRecognizer(tap)
   
        self.postAnswer()
    }
    //每张图片转化成base64的字符串
    func imageToBae64(image:UIImage) -> String{
        let data = UIImageJPEGRepresentation(image, 0.5)
        let encodeString = data?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
        return encodeString!
    }
    //重置
    func  resetAnswer(sender:UIButton){
    //html字符串为空即可
        let resetAlertView = UIAlertController(title: nil, message: "确定重置吗", preferredStyle: UIAlertControllerStyle.Alert)
        let resetAction = UIAlertAction(title: "确定", style: UIAlertActionStyle.Default) { (UIAlertAction) in
        self.selfAnswers.replaceObjectAtIndex(self.index, withObject: "")
            self.answerPhotos.removeAllObjects()
            self.answerTextView.text = ""
         self.answerTextView.hidden = true
        self.answerWebView.hidden = false
            self.collectionView.hidden = true
            self.answerTextView.resignFirstResponder()
            self.answerWebView.loadHTMLString("", baseURL: nil)
            
            self.postAnswer()
        }
        let cancelAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.Destructive, handler: nil)
        resetAlertView.addAction(resetAction)
        resetAlertView.addAction(cancelAction)
        
        self.presentViewController(resetAlertView, animated: true, completion: nil)
    }
    //向服务器传送答案
    //向服务器传送答案
    func postAnswer() {
        let answer = ["testid":"\(testid)",
                      "questionid":"\(self.items[index].valueForKey("id") as! NSNumber)",
                      "answer":self.selfAnswers.objectAtIndex(index)]
        let userDefault = NSUserDefaults.standardUserDefaults()
        let authtoken = userDefault.valueForKey("authtoken") as! String
        
        var result = String()
        do { let parameterData = try NSJSONSerialization.dataWithJSONObject(answer, options: NSJSONWritingOptions.PrettyPrinted)
            
            result = parameterData.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
        }catch{
            ProgressHUD.showError("保存失败")
        }
        
        
        let parameter:[String:AnyObject] = ["authtoken":authtoken,"data":result]
        
        Alamofire.request(.POST, "http://dodo.hznu.edu.cn/api/submitquestion", parameters: parameter, encoding: ParameterEncoding.URL, headers: nil).responseJSON { (response) in
            switch response.result{
            case .Failure(_):
                print(1)
                ProgressHUD.showError("保存失败")
            case .Success(let Value):
                let json = JSON(Value)
                if(json["retcode"].number! != 0){
                    ProgressHUD.showError("保存失败")
                    print(json["retcode"].number)
                }else{
                    ProgressHUD.showSuccess("保存成功")
                }
            }
        }
        
    }

    //选择答案的类型
    func selectAnswerType(sender:UIButton){
        let addTExtItem = BlurEffectMenuItem()
        addTExtItem.title = "添加文字"
        addTExtItem.icon = UIImage(named: "添加文本")
        let addImageItem = BlurEffectMenuItem()
        addImageItem.icon = UIImage(named: "照片")
        addImageItem.title = "添加图片"
        menu = BlurEffectMenu(menus: [addTExtItem,addImageItem])
        menu.delegate = self
        menu.modalPresentationStyle = .OverFullScreen
        menu.modalTransitionStyle = .CrossDissolve
        self.presentViewController(menu, animated: true, completion: nil)
    }
    //从相册中选取照片或者拍照
     //菜单的一些代理
    func blurEffectMenuDidTapOnBackground(menu: BlurEffectMenu!) {
        menu.dismissViewControllerAnimated(true, completion: nil)
    }
    func blurEffectMenu(menu: BlurEffectMenu!, didTapOnItem item: BlurEffectMenuItem!) {
        //将answerWebView的隐藏 随后出现两个控件 一个用来添加文字 一个用来添加图片
        self.answerWebView.hidden = true
        if(item.title == "添加图片"){
             self.imagePicker = AJPhotoPickerViewController()
              //设置最大的数量
        imagePicker.maximumNumberOfSelection = 6
        imagePicker.multipleSelection = true
        //资源过滤
        imagePicker.assetsFilter = ALAssetsFilter.allPhotos()
        imagePicker.showEmptyGroups = true
        imagePicker.delegate = self
        imagePicker.selectionFilter = NSPredicate(block: { (evaluatedObjecy:AnyObject, dic:[String : AnyObject]?) -> Bool in
            return true
        })
       menu.presentViewController(imagePicker, animated: true, completion: nil)
        }
        if(item.title == "添加文字"){
            self.answerTextView.becomeFirstResponder()
            self.answerTextView.hidden = false
            self.collectionView?.hidden = false
            self.answerWebView.hidden = true
            self.answerTextView.becomeFirstResponder()
            menu.dismissViewControllerAnimated(true, completion: nil)
        }
       

    }
    //当选择超过最大比重时
    func photoPickerDidMaximum(picker: AJPhotoPickerViewController!) {
        ProgressHUD.showError("已超过最大选择数")
    }
    //当点击取消按钮时
    func photoPickerDidCancel(picker: AJPhotoPickerViewController!) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        menu.dismissViewControllerAnimated(true, completion: nil)
        self.answerWebView.hidden = false
        self.collectionView.hidden = true
        self.answerTextView.hidden = true
    }
    //当点击了照相机的时候
    func photoPickerTapCameraAction(picker: AJPhotoPickerViewController!) {
        let cameraPicker = UIImagePickerController()
        if (UIImagePickerController.availableMediaTypesForSourceType(.Camera) != nil){
            cameraPicker.sourceType = .Camera
            cameraPicker.delegate = self
            picker.presentViewController(cameraPicker, animated: true, completion: nil)
        }else{
            ProgressHUD.showError("不支持相机")
        }
        }
    //当相机拍完了照片后 更新scrollView
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        self.answerPhotos.addObject(image)
        picker.dismissViewControllerAnimated(true, completion: nil)
    self.imagePicker.dismissViewControllerAnimated(true, completion: nil)
        menu.dismissViewControllerAnimated(true, completion: nil)
        self.answerTextView.hidden = true
        self.answerWebView.hidden = true
        self.collectionView?.hidden = false
       self.collectionView?.reloadData()
    }
    //退出照相机的时候
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        self.imagePicker.dismissViewControllerAnimated(true, completion: nil)
        menu.dismissViewControllerAnimated(true, completion: nil)
        self.answerTextView.hidden = true
        self.answerWebView.hidden = false
        self.collectionView?.hidden = true
    }
    //当选择好相册后 更新scrollView
    func photoPicker(picker: AJPhotoPickerViewController!, didSelectAssets assets: [AnyObject]!) {
        for i in 0 ..< assets.count {
            let asset = assets[i]
            let tempImage = UIImage(CGImage: asset.defaultRepresentation().fullScreenImage().takeUnretainedValue())
        self.answerPhotos.addObject(tempImage)
        }
        picker.dismissViewControllerAnimated(true, completion: nil)
        menu.dismissViewControllerAnimated(true, completion: nil)
        self.collectionView?.hidden = false
        self.answerWebView.hidden = true
        self.answerTextView.hidden = true

        self.collectionView?.reloadData()
       
    }
     //图片放大的效果
    func showBig(sender:UITapGestureRecognizer){
        
        let previewPhotoVC = UIStoryboard(name: "Problem", bundle: nil).instantiateViewControllerWithIdentifier("previewPhotoVC") as! previewPhotoViewController
       previewPhotoVC.toShowBigImageArray = self.answerPhotos
        previewPhotoVC.contentOffsetX = CGFloat((sender.view?.tag)!)
   self.navigationController?.pushViewController(previewPhotoVC, animated: true)
    }
    //图片编辑
    func editPhoto(sender:UILongPressGestureRecognizer){
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        let deleteAction = UIAlertAction(title: "删除", style: UIAlertActionStyle.Default) { (UIAlertAction) -> Void in
           
            let deleteIndex = sender.view?.tag
            self.answerPhotos.removeObjectAtIndex(deleteIndex!)
             alert.dismissViewControllerAnimated(true, completion: nil)
            self.collectionView?.reloadData()
        }
 
        let cropAction = UIAlertAction(title: "编辑", style: UIAlertActionStyle.Default) { (UIAlertAction) -> Void in
            
            let cropVC = UIStoryboard(name: "Problem", bundle: nil).instantiateViewControllerWithIdentifier("cropVC") as! CropAndRotateViewController
            cropVC.image = (self.answerPhotos[(sender.view?.tag)!] as! UIImage)
             alert.dismissViewControllerAnimated(true, completion: nil)
            self.navigationController?.pushViewController(cropVC, animated: true)
            cropVC.callBack = {(image:UIImage) -> Void in
                weak var wself = self
               
                wself?.answerPhotos.replaceObjectAtIndex((sender.view?.tag)!, withObject: image)
                wself?.collectionView?.reloadData()
            }
        }
        let cancelAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.Destructive) { (UIAlertAction) in
            alert.dismissViewControllerAnimated(true, completion: nil)
        }
        alert.addAction(deleteAction)
        alert.addAction(cropAction)
        alert.addAction(cancelAction)
        if(alert.accessibilityFrame == CGRect()){
        self.presentViewController(alert, animated: true, completion: nil)
        }
     
    }
 
    func addNewQus(sender:UISwipeGestureRecognizer) {
          let temp = index
        //加载下一道题目
        if sender.direction == .Left{
            if self.index != self.items.count - 1{
              self.index += 1
            }
            else if(self.kindOfQusIndex == self.totalItems.count - 1){
                ProgressHUD.showError("已是最后一题")
            }
            else {
                let vc = UIStoryboard(name: "Problem", bundle: nil)
                    .instantiateViewControllerWithIdentifier("TranslateVC") as!
                TranslateViewController
                vc.kindOfQusIndex = self.kindOfQusIndex + 1
                vc.title = self.title
                vc.testid = self.testid
                vc.endDate = self.endDate
                vc.enableClientJudge = self.enableClientJudge
                vc.keyVisible = self.keyVisible
                vc.viewOneWithAnswerKey = self.viewOneWithAnswerKey
                self.navigationController?.pushViewController(vc, animated: false)

            }
        }
        if sender.direction == .Right{
            if self.index != 0{
                self.index -= 1
            }else{
                let vc = UIStoryboard(name: "Problem", bundle: nil)
                    .instantiateViewControllerWithIdentifier("TranslateVC") as!
                TranslateViewController
                vc.kindOfQusIndex = self.kindOfQusIndex
                vc.title = self.title
                vc.testid = self.testid
                vc.endDate = self.endDate
                self.navigationController?.pushViewController(vc, animated: false)
                vc.enableClientJudge = self.enableClientJudge
                vc.keyVisible = self.keyVisible
                vc.viewOneWithAnswerKey = self.viewOneWithAnswerKey

            }
        }
        //加载下一道题目的时候需要记录下题目和答案
        if(temp != index){
        self.initView()
        self.collectionView?.reloadData()
        }
    }
    func keyboardWillHideNotification(notification:NSNotification){
      UIView.animateWithDuration(0.3) { 
         self.contentScrollView?.contentOffset = CGPointMake(0, 0)
        
        }
    }
    
 
  
    func keyboardWillShowNotification(notification:NSNotification){
       UIView.animateWithDuration(0.3) {
     self.contentScrollView?.contentOffset = CGPointMake(0, self.resetBtnAndQusHeight)        }
        
    }
    //图片放大时候的动作
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
 
        return true
    
    }
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if(gestureRecognizer == self.tap || gestureRecognizer == self.tap1){
        return true
        }else{
            return false
        }
    }
    func webViewShowBig(sender:UITapGestureRecognizer){

        ShowBigImageFactory.showBigImage(self, webView: sender.view as! UIWebView, sender: sender)
}
    //图片显示区域的CollectionView的实现
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.answerPhotos.count
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCell", forIndexPath: indexPath) as! PhotoWaterfallCollectionViewCell
        if(indexPath.row < self.answerPhotos.count){
            cell.imageView?.contentMode = .ScaleToFill
          cell.imageView?.image = self.answerPhotos[indexPath.row] as? UIImage
            //加点击预览的手势和长按编辑的手势
            cell.imageView?.userInteractionEnabled = true
            cell.imageView!.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(SubjectiveQusViewController.editPhoto(_:))))
            cell.imageView!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SubjectiveQusViewController.showBig(_:))))
          
             cell.sizeToFit()
            cell.imageView?.sizeToFit()
            cell.imageView?.tag = indexPath.row
           
            //每个imagView都加手势 点击预览 长按编辑
        
        }
        return cell
    }
    //定义每个cell的边框大小
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    //定义每个cell的大小
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: SCREEN_WIDTH / 3 - 10, height: SCREEN_HEIGHT / 5)
    }
//题目描述的代理 当开始加载和已经加载完
    func webViewDidStartLoad(webView: UIWebView) {
        webView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 1)
    }
    var resetBtnAndQusHeight:CGFloat = 0.0
    func webViewDidFinishLoad(webView: UIWebView) {
        let height = NSInteger(webView.stringByEvaluatingJavaScriptFromString("document.body.offsetHeight")!)
        
        var NewFrame = webView.frame
        NewFrame.size.height = CGFloat(height!) + 5
        webView.frame = NewFrame
        let scrollView = webView.subviews[0] as! UIScrollView
        scrollView.showsVerticalScrollIndicator = false
        let width = NSInteger(webView.stringByEvaluatingJavaScriptFromString("document.body.scrollWidth")!)
    scrollView.contentSize = CGSizeMake(CGFloat(width!), 0)
     self.totalHeight = CGFloat(height!) + 10
    self.contentScrollView?.addSubview(webView)
        self.resetBtn = UIButton(frame: CGRectMake(SCREEN_WIDTH / 2 + 30,totalHeight,60,30))
        self.resetBtn.backgroundColor = RGB(0, g: 153, b: 255)
        self.resetBtn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        self.resetBtn.setTitle("重置", forState: .Normal)
        self.addBtn = UIButton(frame: CGRectMake(SCREEN_WIDTH / 2 - 90,totalHeight,60,30))
        self.addBtn.backgroundColor = RGB(0, g: 153, b: 255)
        self.addBtn.setTitle("添加", forState: .Normal)
        self.addBtn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        self.saveBtn.addTarget(self, action: #selector(SubjectiveQusViewController.save(_:)), forControlEvents: .TouchUpInside)
        self.saveBtn.backgroundColor = RGB(0, g: 153, b: 255)
        self.contentScrollView?.addSubview(self.resetBtn)
        self.contentScrollView?.addSubview(self.addBtn)
        totalHeight += 35
        self.resetBtnAndQusHeight = totalHeight
        //比较日期 加载不同的控件
        //先要看看有没有answerWebView
        self.answerWebView.addGestureRecognizer(tap1)
        self.answerWebView.tag = 1
        self.answerWebView.userInteractionEnabled = true
        self.answerWebView.frame = CGRectMake(0, totalHeight, SCREEN_WIDTH, 50)
       
        self.contentScrollView?.addSubview(self.answerWebView)
        
        self.answerWebView.loadHTMLString(self.selfAnswers[index] as! String, baseURL: nil)

        let currentDate = NSDate()
        let result:NSComparisonResult = currentDate.compare(endDate)
       
        self.answerWebView.hidden = false
        if result == .OrderedAscending{
                     //加载textView 和 collectionView
            self.answerTextView.frame = CGRectMake(0, totalHeight, SCREEN_WIDTH, 100)
            totalHeight += 110
        self.collectionView.frame = CGRectMake(0, totalHeight, SCREEN_WIDTH, 100)
            self.answerTextView.hidden = true
            self.collectionView.hidden = true
            self.contentScrollView?.addSubview(collectionView)
        self.answerTextView.keyboardDismissMode = .OnDrag
            totalHeight += 110
          self.contentScrollView?.addSubview(answerTextView)
            self.resetBtn.addTarget(self, action: #selector(SubjectiveQusViewController.resetAnswer(_:)), forControlEvents: .TouchUpInside)
            self.addBtn.addTarget(self, action: #selector(SubjectiveQusViewController.selectAnswerType(_:)), forControlEvents: .TouchUpInside)
            self.saveBtn.addTarget(self, action: #selector(SubjectiveQusViewController.save(_:)), forControlEvents: .TouchUpInside)
        }else{
            totalHeight += 55
        //加载评论的
            let commetLabel = UILabel(frame: CGRectMake(0,totalHeight,SCREEN_WIDTH,21))
            commetLabel.text = "评语:"
            totalHeight += 23
            self.contentScrollView?.addSubview(commetLabel)
            let commetTextView = UITextView(frame: CGRectMake(0, totalHeight, SCREEN_WIDTH, 50))
           totalHeight += 55
            if(self.items[index].valueForKey("comments") as? String != nil &&
                self.items[index].valueForKey("comments") as! String != ""){
                commetTextView.text = self.items[index].valueForKey("comments") as! String
            }else{
                commetTextView.text = "无评语"
            }
         self.contentScrollView?.addSubview(commetTextView)
            let standAnswerLabel = UILabel(frame: CGRectMake(0,totalHeight,SCREEN_WIDTH,21))
            standAnswerLabel.text = "标准答案:"
            totalHeight += 23
            self.contentScrollView?.addSubview(standAnswerLabel)
           let standAnswerWebView = UIWebView(frame: CGRectMake(0,totalHeight,SCREEN_WIDTH,100))
            standAnswerWebView.loadHTMLString(self.items[index].valueForKey("strandanswer") as! String, baseURL: nil)
            totalHeight += 120
            self.contentScrollView?.addSubview(standAnswerWebView)
        }
         self.contentScrollView?.contentSize = CGSizeMake(SCREEN_WIDTH, totalHeight + 20)
    }
   //看内存有没有释放掉
    deinit{
        print("SubjectvcDeinit")
    }
    override func viewWillDisappear(animated: Bool) {
        ProgressHUD.dismiss()
    }
}
