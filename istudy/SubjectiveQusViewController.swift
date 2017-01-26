

import UIKit
import Alamofire
import SwiftyJSON
import Font_Awesome_Swift
import QuickLook
class SubjectiveQusViewController: UIViewController,AJPhotoPickerProtocol,UINavigationControllerDelegate,UIImagePickerControllerDelegate,BlurEffectMenuDelegate,UIGestureRecognizerDelegate,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource,UIWebViewDelegate,UITableViewDelegate,UITableViewDataSource,QLPreviewControllerDataSource,QLPreviewControllerDelegate{
    //记录date和阅卷是否开启 和阅卷的时候答案是否可见等等
    var endDate = NSDate()
    //是否可以阅卷
    var  enableClientJudge = Bool()
    var keyVisible = Bool()
    var viewOneWithAnswerKey = Bool()
    //图片放大的点击手势
    var tap = UITapGestureRecognizer()
    var tap1 = UITapGestureRecognizer()
    var tap2 = UITapGestureRecognizer()
    var imagePicker:AJPhotoPickerViewController!
    var isFromOtherKindQus = false
    //记录当前是第几个题型
    //从其他题型跳转过来的
      var filePath = NSURL()
    var kindOfQusIndex = NSInteger()
    var id = NSInteger()
    var testid = NSInteger()
    var totalItems = NSArray()
    var items = NSArray()
    var totalKindOfQus = NSInteger()
    var fileItems = NSMutableArray()
    var answerFilesItems = NSMutableArray()
    var isOver = false
    //添加图片和文字的按钮 和 重置的按钮
    @IBOutlet weak var qusKind:UILabel?
    @IBOutlet weak var  addBtn:UIButton!
    @IBOutlet weak var resetBtn: UIButton!
    //左右按钮
    //用来包裹题目描述 reset和addBtn 还有 commentBtn 还有 评语等
    @IBOutlet weak var  leftBtn: UIButton!
    @IBOutlet weak var rightBtn: UIButton!
    @IBOutlet weak  var saveBtn: UIButton!
    @IBOutlet weak var contentScrollView:UIScrollView?
    @IBOutlet weak var currentQus:UILabel?
    var qusDes = UIWebView()
    var answerWebView = UIWebView()
    var answerTextView = JVFloatLabeledTextView()
    var totalHeight:CGFloat = 0.0
    @IBOutlet weak var collectionView:UICollectionView!
    //展示图片的瀑布流形式的collectionView
    @IBOutlet weak var topView:UIView?
    @IBOutlet weak var btmView:UIView!
    var menu:BlurEffectMenu!
    let  cameraPicker = UIImagePickerController()
    //记录当前在第几页和总共的页数
    var index:NSInteger = 0
    var answerPhotos = NSMutableArray()
    //记录自己答案的html格式的字符串
    var selfAnswers = NSMutableArray()
    override func viewDidLoad() {
        super.viewDidLoad()
        ShowBigImageFactory.topViewEDit(self.btmView)
        //顶部加条线
        //设置阴影效果
        ShowBigImageFactory.topViewEDit(self.topView!)
//    self.contentScrollView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SubjectiveQusViewController.contResign)))
        self.contentScrollView?.keyboardDismissMode = .OnDrag
        self.view.endEditing(true)
        UIApplication.sharedApplication().keyWindow?.endEditing(true)
        self.collectionView?.delegate = self
        self.collectionView?.dataSource  = self
        self.collectionView?.backgroundColor = UIColor.whiteColor()
        self.tap = UITapGestureRecognizer(target: self, action: #selector(SubjectiveQusViewController.webViewShowBig(_:)))
        self.tap1 = UITapGestureRecognizer(target: self, action: #selector(SubjectiveQusViewController.webViewShowBig(_:)))
        self.tap2 = UITapGestureRecognizer(target: self, action: #selector(SubjectiveQusViewController.webViewShowBig(_:)))
        self.tap2.delegate = self
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
        backBtn.setFAIcon(FAType.FAArrowLeft, iconSize: 25, forState: .Normal)
        actBtn.setFAIcon(FAType.FABook, iconSize: 25, forState: .Normal)
        
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
        filePath = NSURL()
        //加载界面的时候
        //初始化内容
        self.fileItems.removeAllObjects()
        self.answerFilesItems.removeAllObjects()
        self.answerPhotos.removeAllObjects()
        self.answerTextView.text = ""
        for view in (self.contentScrollView?.subviews)!{
            view.removeFromSuperview()
        }
//        //测试
        //加载题目的内容
        let contenString = cssDesString + (self.items[index].valueForKey("content") as! String)
        self.qusDes.loadHTMLString(contenString, baseURL: nil)
        self.qusDes.delegate = self
        self.qusKind?.text = self.totalItems[kindOfQusIndex].valueForKey("title") as! String +  "(" +
             "\(index + 1)" + "/" + "\(self.items.count)" + ")"
        self.currentQus!.text =  "\(self.items[index].valueForKey("totalscore") as! NSNumber)" + "分"
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
       var allAnswer = ""
        allAnswer = self.selfAnswers[index] as! String
      
     allAnswer  += self.answerTextView.text
      ProgressHUD.show("正在保存中,请稍候")
    //循环将图片数组中的值取出 转化成html格式 没有图片的话也要上传 这里以前有Bug
        if(self.answerPhotos.count > 0){
            var cnt = 0
        for i in 0 ..< self.answerPhotos.count{
           
            //Alamofire进行上传
            let userDefault = NSUserDefaults.standardUserDefaults()
            //url
            //id标识符
            //json字符串转译 还有点出错
            let id:NSMutableDictionary = ["testid":"\(testid)",
                          "questionid":"\(self.items[index].valueForKey("id") as! NSNumber)"]
            var jsonData = NSData()
            do{ jsonData = try NSJSONSerialization.dataWithJSONObject(id, options: NSJSONWritingOptions.PrettyPrinted)
            }catch{
              ProgressHUD.showError("转码失败")
            }
            let authtoken = userDefault.valueForKey("authtoken") as! String
            var jsonString = String(data: jsonData, encoding: NSUTF8StringEncoding)
            jsonString = jsonString?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
          
            jsonString = jsonString?.stringByReplacingOccurrencesOfString("\n", withString: "")
            let paramDic:[String:AnyObject] = ["data":jsonString!]
            let request = NSMutableURLRequest(URL: NSURL(string:  hostip + "api/upfile?authtoken=" + authtoken + "&type=2")!)
            request.HTTPMethod = "POST"
             let data = UIImageJPEGRepresentation(self.answerPhotos[i] as! UIImage, 0.5)
        
            let requestCov:NSMutableURLRequest  = (ParameterEncoding.URL.encode(request, parameters: paramDic)).0
            Alamofire.upload(requestCov, multipartFormData: { (formData) in
                formData.appendBodyPart(data: data!, name: "name", fileName: "answerImage.jpg", mimeType: "image/jpeg")
            }) { (encodingResult) in
                switch encodingResult {
                case .Success(let upload, _, _):
                    //print((upload.request?.allHTTPHeaderFields))
                    upload.responseJSON(completionHandler: { (response) in
                        switch response.result{
                        case .Success(let Value):
                            
                    let json = JSON(Value)
                            if(json["retcode"].number != 0){
//                                print(json["retcode"].number)
                                ProgressHUD.showError(json["message"].string)
                                
                            }else{
                                
                                if(json["info"]["succ"].bool == false){
                                   
                                    
                                    ProgressHUD.showError("保存失败")
                                }else{
                                  
                                 
                                        allAnswer += "<img src = " + "\""  +   json["info"]["uploadedurl"].string! +  "\"" + "/>"
                                    cnt += 1
                                    if(cnt == self.answerPhotos.count){
                                       
                                        //转化成html的格式
                                      dispatch_async(dispatch_get_main_queue(), {  self.selfAnswers.replaceObjectAtIndex(self.index, withObject: allAnswer)
                                        self.answerWebView.loadHTMLString(imageDecString + (self.selfAnswers[self.index] as! String) , baseURL: nil)
                                        
                                        //数组清空
                                        self.answerPhotos = NSMutableArray()
                                        self.answerTextView.text = ""
                                        self.collectionView.reloadData()
                                        //一个个来加载控件
                                        let tap = UITapGestureRecognizer(target: self, action: #selector(SubjectiveQusViewController.webViewShowBig(_:)))
                                        tap.delegate = self
                                        self.answerWebView.userInteractionEnabled = true
                                        self.answerWebView.addGestureRecognizer(tap)
                                          self.postAnswer()
                       })
                                    }
                                
                                    }
                            }
                        case .Failure(_):
                           
                            ProgressHUD.showError("保存失败")
                        }
                    })
                case .Failure(_):
                    ProgressHUD.showError("保存失败")
                   
                }
}
            }
    
        }else{
            self.selfAnswers.replaceObjectAtIndex(self.index, withObject: allAnswer)
            self.postAnswer()
            self.answerTextView.text = ""
             self.answerWebView.loadHTMLString(imageDecString + (self.selfAnswers[self.index] as! String) , baseURL: nil)
        }
        
    }
   
      //重置
    func  resetAnswer(sender:UIButton){
        //html字符串为空即可
        let resetAlertView = UIAlertController(title: nil, message: "确定重置吗", preferredStyle: UIAlertControllerStyle.Alert)
        let resetAction = UIAlertAction(title: "确定", style: UIAlertActionStyle.Default) { (UIAlertAction) in
            self.selfAnswers.replaceObjectAtIndex(self.index, withObject: "")
            self.answerPhotos.removeAllObjects()
            self.answerTextView.text = ""
          self.collectionView.reloadData()
            self.answerTextView.resignFirstResponder()
            self.answerWebView.loadHTMLString("", baseURL: nil)
           self.postAnswer()
            let  tempAnswerString = "<html><head><style>P{text-align:center;vertical-align: middle;font-size: 17px;font-family: " + "\"" + "宋体" + "\"" +  "}</style></head><body><p>无作业信息</p></body></html>"
    self.answerWebView.loadHTMLString(tempAnswerString, baseURL: nil)
            
        }
        let cancelAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.Destructive, handler: nil)
        resetAlertView.addAction(resetAction)
        resetAlertView.addAction(cancelAction)
        
        self.presentViewController(resetAlertView, animated: true, completion: nil)
    }
    //向服务器传送答案
    func postAnswer() {
        //这道题的答案拿出来 把尺寸拿掉
        let widthAndHeight = " width = " + "\(50.123)" + " height = " + "\(50.123)"
       var oneAnswer = self.selfAnswers.objectAtIndex(index) as! String
        oneAnswer = oneAnswer.stringByReplacingOccurrencesOfString(widthAndHeight, withString: "")
        let answer = ["testid":"\(testid)",
                      "questionid":"\(self.items[index].valueForKey("id") as! NSNumber)",
                      "answer":oneAnswer]
        let userDefault = NSUserDefaults.standardUserDefaults()
        let authtoken = userDefault.valueForKey("authtoken") as! String
        
        var result = String()
        do { let parameterData = try NSJSONSerialization.dataWithJSONObject(answer, options: NSJSONWritingOptions.PrettyPrinted)
            
            result = parameterData.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
        }catch{
            ProgressHUD.showError("保存失败")
        }
        
        
        let parameter:[String:AnyObject] = ["authtoken":authtoken,"data":result]
        
        Alamofire.request(.POST, hostip + "api/submitquestion", parameters: parameter, encoding: ParameterEncoding.URL, headers: nil).responseJSON { (response) in
            switch response.result{
            case .Failure(_):
             
                ProgressHUD.showError("保存失败")
            case .Success(let Value):
                let json = JSON(Value)
                if(json["retcode"].number! != 0){
                     ProgressHUD.showError(json["message"].string)
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
    //确实点击了某到题目的时候
    func blurEffectMenu(menu: BlurEffectMenu!, didTapOnItem item: BlurEffectMenuItem!) {
        //将answerWebView的隐藏 随后出现两个控件 一个用来添加文字 一个用来添加图片
       
        if(item.title == "添加图片"){
            self.imagePicker = AJPhotoPickerViewController()
            //设置最大的数量
            imagePicker.maximumNumberOfSelection = 6
            imagePicker.multipleSelection = true
            //资源过滤
            imagePicker.assetsFilter = ALAssetsFilter.allPhotos()
            imagePicker.showEmptyGroups = true
            imagePicker.delegate = self
            imagePicker.selectionFilter = NSPredicate(block: { (evaluatedObjecy:AnyObject?, dic:[String : AnyObject]?) -> Bool in
                return true
            })
            menu.presentViewController(imagePicker, animated: true, completion: nil)
        }
        if(item.title == "添加文字"){
            self.answerTextView.becomeFirstResponder()
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
     }
    //当点击了照相机的时候
    func photoPickerTapCameraAction(picker: AJPhotoPickerViewController!) {
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

        self.collectionView?.reloadData()
    }
    //退出照相机的时候
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        self.imagePicker.dismissViewControllerAnimated(true, completion: nil)
        menu.dismissViewControllerAnimated(true, completion: nil)
      
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
       self.collectionView?.reloadData()
        
    }
    
    //图片编辑
    func editOrShow(sender:UIButton){
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        let showAction = UIAlertAction(title: "预览", style: UIAlertActionStyle.Default) { (UIAlertAction) -> Void in
            
            let previewPhotoVC = UIStoryboard(name: "Problem", bundle: nil).instantiateViewControllerWithIdentifier("previewPhotoVC") as! previewPhotoViewController
            previewPhotoVC.toShowBigImageArray = self.answerPhotos
            previewPhotoVC.contentOffsetX = CGFloat((sender.tag))
            self.navigationController?.pushViewController(previewPhotoVC, animated: true)
        }
        let deleteAction = UIAlertAction(title: "删除", style: UIAlertActionStyle.Default) { (UIAlertAction) -> Void in
            
            let deleteIndex = sender.tag
            self.answerPhotos.removeObjectAtIndex(deleteIndex)
            alert.dismissViewControllerAnimated(true, completion: nil)
            self.collectionView?.reloadData()
        }
        
        let cropAction = UIAlertAction(title: "编辑", style: UIAlertActionStyle.Default) { (UIAlertAction) -> Void in
            let cropVC = UIStoryboard(name: "Problem", bundle: nil).instantiateViewControllerWithIdentifier("cropVC") as! CropAndRotateViewController
            cropVC.image = (self.answerPhotos[(sender.tag)] as! UIImage)
            alert.dismissViewControllerAnimated(true, completion: nil)
            self.navigationController?.pushViewController(cropVC, animated: true)
            cropVC.callBack = {(image:UIImage) -> Void in
                weak var wself = self
                wself?.answerPhotos.replaceObjectAtIndex((sender.tag), withObject: image)
                wself?.collectionView?.reloadData()
            }
        }
        let cancelAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.Destructive) { (UIAlertAction) in
            alert.dismissViewControllerAnimated(true, completion: nil)
        }
        alert.addAction(showAction)
        alert.addAction(deleteAction)
        alert.addAction(cropAction)
        alert.addAction(cancelAction)
        //  if(alert.accessibilityFrame == CGRect()){
        menu.dismissViewControllerAnimated(true, completion: nil)
        cameraPicker.dismissViewControllerAnimated(true, completion: nil)
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        self.presentViewController(alert, animated: true, completion: nil)
        // }
    }
    //加载下一道题目
    func addNewQus(sender:UISwipeGestureRecognizer) {
        let temp = index
        if sender.direction == .Left{
            if self.index != self.items.count - 1{
                self.index += 1
            }
            else if(self.kindOfQusIndex == self.totalItems.count - 1){
                ProgressHUD.showSuccess("已完成全部试题")
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
//            self.contentScrollView?.contentOffset = CGPointMake(0, 0)
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
        if(gestureRecognizer == self.tap || gestureRecognizer == self.tap1 || gestureRecognizer == self.tap2){
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
            
            cell.btn.setBackgroundImage(self.answerPhotos[indexPath.row] as? UIImage, forState: .Normal)
            //每个imagView都加手势 点击预览 长按编辑
            cell.btn.tag = indexPath.row
            
            cell.btn.addTarget(self, action: #selector(SubjectiveQusViewController.editOrShow(_:)), forControlEvents: .TouchUpInside)
            
        }
        return cell
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(SCREEN_WIDTH / 5, SCREEN_HEIGHT / 8)
    }
    //题目描述的代理 当开始加载和已经加载完
    func webViewDidStartLoad(webView: UIWebView) {
        ProgressHUD.show("请稍候")
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
        addBtn.setFAText(prefixText: "", icon: FAType.FAPlusSquare, postfixText: "", size: 25, forState: .Normal)
        saveBtn.setFAText(prefixText: "", icon: FAType.FASave, postfixText: "", size: 25, forState: .Normal)
        resetBtn.setFAText(prefixText: "", icon: FAType.FAMinusSquare, postfixText: "", size: 25, forState: .Normal)
        leftBtn.setFAText(prefixText: "", icon: FAType.FAArrowLeft, postfixText: "", size: 25, forState: .Normal)
        rightBtn.setFAText(prefixText: "", icon: FAType.FAArrowRight, postfixText: "", size: 25, forState: .Normal)
        self.leftBtn.tag = 1
        self.rightBtn.tag = 2
        self.leftBtn.addTarget(self, action: #selector(SubjectiveQusViewController.changeIndex(_:)), forControlEvents: .TouchUpInside)
        self.rightBtn.addTarget(self, action: #selector(SubjectiveQusViewController.changeIndex(_:)), forControlEvents: .TouchUpInside)
        totalHeight += 35
        self.resetBtnAndQusHeight = totalHeight
        //比较日期 加载不同的控件
        //先要看看有没有answerWebView
        self.answerWebView.addGestureRecognizer(tap1)
        self.answerWebView.tag = 1
        self.answerWebView.userInteractionEnabled = true
     
    //要查看本题目是否有附件
        if(self.items[index].valueForKey("files") as? NSArray != nil &&
            (self.items[index].valueForKey("files") as! NSArray).count > 0){
        
            self.fileItems = NSMutableArray(array:  self.items[index].valueForKey("files") as! NSArray)
         //   print(self.fileItems)
            let FileLabel = UILabel(frame:  CGRectMake(5, self.totalHeight + 2, SCREEN_WIDTH - 10, 30))
            FileLabel.text = "附件区"
            self.totalHeight += 32
     //增加附件区
            let filesTableView = UITableView(frame: CGRectMake(5, self.totalHeight + 2, SCREEN_WIDTH - 10, 40))
            filesTableView.tag = 1
            filesTableView.delegate = self
            filesTableView.dataSource = self
            filesTableView.tableFooterView = UIView()
            self.totalHeight += 40
         self.contentScrollView?.addSubview(FileLabel)
            self.contentScrollView?.addSubview(filesTableView)
        }
    //有没有答案的选择
        let answerWebViewLabel = UILabel(frame: CGRectMake(5,totalHeight,SCREEN_WIDTH,21))
        answerWebViewLabel.text = "学生答案区:"
        totalHeight += 23
        self.contentScrollView?.addSubview(answerWebViewLabel)
        var tempAnswerString = (self.selfAnswers[index] as! String)
        if(tempAnswerString) == ""{
            tempAnswerString = "<html><head><style>P{text-align:center;vertical-align: middle;font-size: 17px;font-family: " + "\"" + "宋体" + "\"" +  "}</style></head><body><p>无作业信息</p></body></html>"
            self.answerWebView.frame = CGRectMake(5, totalHeight, SCREEN_WIDTH - 10, 120)
            self.answerWebView.loadHTMLString(tempAnswerString, baseURL: nil)
            
        }else{
            self.answerWebView.frame = CGRectMake(5, totalHeight, SCREEN_WIDTH - 10, 120)
            let answerWebString = imageDecString + (self.selfAnswers[index] as! String)
            self.answerWebView.loadHTMLString(answerWebString, baseURL: nil)
        }
        totalHeight += 125
        self.answerWebView.layer.borderWidth = 0.3
        self.answerWebView.layer.borderColor = UIColor.grayColor().CGColor
        self.contentScrollView?.addSubview(self.answerWebView)
        
        let currentDate = NSDate()
     
        let result:NSComparisonResult = currentDate.compare(endDate)
        if (result == .OrderedAscending){
            self.isOver = false
            //加载textView 和 collectionView
            let answerTextLabel = UILabel(frame: CGRectMake(5, totalHeight, SCREEN_WIDTH, 21))
            answerTextLabel.text = "文本区:"
            totalHeight += 23
            self.answerTextView.frame = CGRectMake(5, totalHeight, SCREEN_WIDTH - 10, 100)
            totalHeight += 110
            let answerPhtotoCollectionLabel = UILabel(frame: CGRectMake(5,totalHeight,SCREEN_WIDTH,21))
            answerPhtotoCollectionLabel.text = "图片区:"
            totalHeight += 23
            self.collectionView.frame = CGRectMake(5, totalHeight, SCREEN_WIDTH - 10, 200)
            self.contentScrollView?.addSubview(collectionView)
            self.answerTextView.keyboardDismissMode = .OnDrag
            totalHeight += 210
            self.contentScrollView?.addSubview(answerTextView)
            self.contentScrollView?.addSubview(answerTextLabel)
            self.contentScrollView?.addSubview(answerPhtotoCollectionLabel)
            self.resetBtn.addTarget(self, action: #selector(SubjectiveQusViewController.resetAnswer(_:)), forControlEvents: .TouchUpInside)
            self.addBtn.addTarget(self, action: #selector(SubjectiveQusViewController.selectAnswerType(_:)), forControlEvents: .TouchUpInside)
            self.saveBtn.addTarget(self, action: #selector(SubjectiveQusViewController.save(_:)), forControlEvents: .TouchUpInside)
            //加载边框线
            self.collectionView.layer.borderWidth = 0.30
            self.collectionView.layer.borderColor = UIColor.grayColor().CGColor
            self.answerTextView.layer.borderWidth = 0.3
            self.answerTextView.layer.borderColor = UIColor.grayColor().CGColor
       ProgressHUD.dismiss()
        }
       // else{
//            self.isOver = true
//            // totalHeight += 155
//            //加载评论的
//            let commetLabel = UILabel(frame: CGRectMake(5,totalHeight,SCREEN_WIDTH - 10,21))
//            commetLabel.text = "评语:"
//            totalHeight += 23
//            self.contentScrollView?.addSubview(commetLabel)
//            //改成webView 并进行居中显示
//            let commetWebView = UIWebView(frame: CGRectMake(5, totalHeight, SCREEN_WIDTH - 10, 50))
//            //不可点击性
//            totalHeight += 55
//            if(self.items[index].valueForKey("comments") as? String != nil &&
//                self.items[index].valueForKey("comments") as! String != ""){
//                let totalCommetString = cssDesString + ((self.items[index]).valueForKey("comments") as! String)
//                commetWebView.loadHTMLString(totalCommetString,baseURL: nil)
//            }else{
//                
//                commetWebView.loadHTMLString("<html><head><style>P{text-align:center;vertical-align: middle;font-size: 17px;font-family: " + "\"" + "宋体" + "\"" +  "}</style></head><body><p>无评语</p></body></html>", baseURL: nil)
//            }
//            commetWebView.layer.borderWidth = 0.3
//            commetWebView.layer.borderColor = UIColor.grayColor().CGColor
//            self.contentScrollView?.addSubview(commetWebView)
//            let standAnswerLabel = UILabel(frame: CGRectMake(5,totalHeight,SCREEN_WIDTH - 10,21))
//            standAnswerLabel.text = "标准答案:"
//            totalHeight += 23
//            self.contentScrollView?.addSubview(standAnswerLabel)
//            let standAnswerWebView = UIWebView(frame: CGRectMake(5,totalHeight,SCREEN_WIDTH - 10,100))
//            //标准答案有可能为空
//            if((self.keyVisible && !self.isOver) || (self.isOver && self.viewOneWithAnswerKey)){
//                
//                if(self.items[index].valueForKey("strandanswer") as? String != nil && self.items[index].valueForKey("strandanswer") as! String != "") {
//                    
//                    standAnswerWebView.loadHTMLString(cssDesString +  (self.items[index].valueForKey("strandanswer") as! String), baseURL: nil)
//                    
//                }else{
//                    //加载没有标准答案的信息
//                    standAnswerWebView.loadHTMLString("<html><head><style>P{text-align:center;vertical-align: middle;font-size: 17px;font-family: " + "\"" + "宋体" + "\"" +  "}</style></head><body><p>无标准答案</p></body></html>",baseURL: nil)
//                }
//            }else{
//                standAnswerWebView.loadHTMLString("<html><head><style>P{text-align:center;vertical-align: middle;font-size: 17px;font-family: " + "\"" + "宋体" + "\"" +  "}</style></head><body><p>无标准答案</p></body></html>",baseURL: nil)
//            }
//            totalHeight += 120
//            self.contentScrollView?.addSubview(standAnswerWebView)
//            standAnswerWebView.layer.borderWidth = 0.3
//            standAnswerWebView.layer.borderColor = UIColor.grayColor().CGColor
//            standAnswerWebView.addGestureRecognizer(self.tap2)
//            standAnswerWebView.userInteractionEnabled = true
//            standAnswerWebView.tag = 3
//        ProgressHUD.dismiss()
        
      
      
        //判断是支持附件上传的题目还是可以图文上传的题目
        if(self.items[index].valueForKey("designanswermode")?.integerValue == 1 && self.isOver == false){
            let alertC = UIAlertController(title: "提醒", message: "该题目不支持在手机上做,请到PC上传文件", preferredStyle: .Alert)
            let action = UIAlertAction(title: "确定", style: .Default, handler: { (alert:UIAlertAction) in
                alertC.dismissViewControllerAnimated(true, completion: nil)
            })
            alertC.addAction(action)
            self.presentViewController(alertC, animated: true, completion: nil)
            self.answerTextView.editable = false
            self.addBtn.enabled = false
            self.saveBtn.enabled = false
            self.resetBtn.enabled = false
        }
        //判断学生的答案是否是文件
        if(self.items[index].valueForKey("answerfiles") as? NSArray != nil &&
            (self.items[index].valueForKey("answerfiles") as! NSArray).count > 0){
            
   self.answerFilesItems = NSMutableArray(array:  self.items[index].valueForKey("answerfiles") as! NSArray)
        
            let answerFilesLabel = UILabel(frame:  CGRectMake(5, self.totalHeight + 2, SCREEN_WIDTH - 10, 30))
            answerFilesLabel.text = "学生答案附件区"
            self.totalHeight += 32
            //增加附件区
            let answerFilesTableView = UITableView(frame: CGRectMake(5, self.totalHeight + 2, SCREEN_WIDTH - 10, 40))
            answerFilesTableView.tag = 2
            answerFilesTableView.delegate = self
            answerFilesTableView.dataSource = self
            self.contentScrollView?.addSubview(answerFilesLabel)
            self.contentScrollView?.addSubview(answerFilesTableView)
            self.totalHeight += 40
        
           answerFilesTableView.tableFooterView = UIView()
        
        
        
        }
          self.contentScrollView?.contentSize = CGSizeMake(SCREEN_WIDTH, totalHeight + 20)
    }
    //看内存有没有释放掉
    deinit{
    }
    override func viewWillDisappear(animated: Bool) {
        ProgressHUD.dismiss()
    }
    func changeIndex(sender:UIButton){
        let temp = index
        //加载下一道题目
        if sender.tag == 2{
            if self.index != self.items.count - 1{
                self.index += 1
            }
            else if(self.kindOfQusIndex == self.totalItems.count - 1){
                ProgressHUD.showSuccess("已完成全部试题")
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
        if sender.tag == 1{
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
    
    //响应者链函数
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        self.nextResponder()?.touchesBegan(touches, withEvent: event)
        super.touchesBegan(touches, withEvent: event)
    }
    //tableView的代理
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tableView.tag == 1){
        return self.fileItems.count
        }else{
            return self.answerFilesItems.count
        }
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if(tableView.tag == 1){
            let identifer = "filescell"
            var cell : UITableViewCell? = tableView.dequeueReusableCellWithIdentifier(identifer)
            
            if cell == nil {
                cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: identifer)
            }
            cell!.textLabel?.text = self.fileItems[indexPath.row].valueForKey("name")
                as? String
            cell!.detailTextLabel?.text = self.fileItems[indexPath.row].valueForKey("size") as? String
            return cell!
            
        }else{
            let identifer = "answerFilescell"
            var cell : UITableViewCell? = tableView.dequeueReusableCellWithIdentifier(identifer)
            
            if cell == nil {
                cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: identifer)
            }
            cell!.textLabel?.text = self.answerFilesItems[indexPath.row].valueForKey("name")
                as? String
            cell!.detailTextLabel?.text = self.answerFilesItems[indexPath.row].valueForKey("size") as? String
            return cell!

        }
    }

func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        var fileDic = NSDictionary()
        //进行文件的下载和预览
        if(tableView.tag == 1) {
            fileDic = self.fileItems[indexPath.row] as! NSDictionary
        }else{
            fileDic = self.answerFilesItems[indexPath.row] as! NSDictionary
    }
        var fileUrl = fileDic.valueForKey("url") as! String
    let fileName = fileDic.valueForKey("name") as! String
    //中文转码
    fileUrl = fileUrl.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLFragmentAllowedCharacterSet())!

        //1分割字符串
        let (fileString) = diviseUrl(fileUrl)
        //2创建文件夹
        creathDir(fileString)
        let path = fileString + "/" + fileName
        if(existFile(path) != ""){
            self.filePath = NSURL(fileURLWithPath: existFile(path))
            let qlVC = QLPreviewController()
            qlVC.delegate = self
            qlVC.dataSource = self
            self.navigationController?.pushViewController(qlVC, animated: true)
        }
        else{
            ProgressHUD.show("正在下载中")
            //文件路径名的问题 找到一个Bug
            
            Alamofire.download(.GET, (fileUrl)) {
                temporaryURL,response
                in
                if(response.statusCode == 200){
                let path = createURLInDownLoad(fileString,fileName: fileName)
                    dispatch_async(dispatch_get_main_queue(), {
                        ProgressHUD.showSuccess("下载成功")
                        
                        self.filePath = path
                        let qlVC = QLPreviewController()
                        qlVC.dataSource = self
                        qlVC.delegate = self
                      
                        self.navigationController?.pushViewController(qlVC, animated: true)
                    })
                    return path
                }
                else{
                    
                    ProgressHUD.showError("下载失败")
                    return NSURL()
                }
                
            }
            
        }

        
    }
    func numberOfPreviewItemsInPreviewController(controller: QLPreviewController) -> Int {
        return 1
    }
    func previewController(controller: QLPreviewController, previewItemAtIndex index: Int) -> QLPreviewItem {
        
        return self.filePath
    }
    func previewController(controller: QLPreviewController, shouldOpenURL url: NSURL, forPreviewItem item: QLPreviewItem) -> Bool {
        
        return true
    }
    }
