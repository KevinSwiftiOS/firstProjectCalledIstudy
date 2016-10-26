//
//  WriteLetterViewController.swift
//  istudy
//
//  Created by hznucai on 16/3/12.
//  Copyright © 2016年 hznucai. All rights reserved.
//

import UIKit
import Alamofire
import Font_Awesome_Swift
import SwiftyJSON

 class WriteLetterViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate,AJPhotoPickerProtocol,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UICollectionViewDelegateFlowLayout{
 
 //收件人的添加
    var parentcode  = ""
       //主题
    //主题的id
    var subject = ""
    var photos = NSMutableArray()
    //全部发信人的名称
    var sendNamesString = ""
    //发件人的姓名和id
    var senderId = NSInteger()
    var senderName = ""
    //所有收件人的数组
    var receiveIds = NSMutableArray()
    var receivesNames = NSMutableArray()
     //看是有回复发件人的还是没有回复发件人的
    var isReply = false
    @IBOutlet weak var subjectTextField:UITextField?
    @IBOutlet weak var writeTextView: JVFloatLabeledTextView!
    @IBOutlet weak var collectionView:UICollectionView!
    @IBOutlet weak var btmView:UIView!
    @IBOutlet weak var addPersonBtn:UIButton?
    var items = NSArray()
    @IBOutlet weak var recevieBtn:UIButton?
    @IBOutlet weak var photoBtn:UIButton!
    @IBOutlet weak var sendBtn:UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        //添加手势 来消失键盘
    self.collectionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(WriteLetterViewController.resignKeyboard)))
        recevieBtn?.layer.borderWidth = 0.4
        recevieBtn?.layer.borderColor = UIColor.grayColor().CGColor
        addPersonBtn?.setFAText(prefixText: "", icon: FAType.FAPlusCircle, postfixText: "", size: 25, forState: .Normal)
        addPersonBtn?.setFATitleColor(UIColor.grayColor())
        ShowBigImageFactory.topViewEDit(self.btmView)
        photoBtn.setFAText(prefixText: "", icon: FAType.FAImage, postfixText: "", size: 25, forState: .Normal)
        sendBtn.setFAText(prefixText: "", icon: FAType.FASend, postfixText: "", size: 25, forState: .Normal)
        self.subjectTextField?.enabled = !isReply
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.backgroundColor = UIColor.whiteColor()
        self.collectionView.layer.borderWidth = 0.3
        self.collectionView.layer.borderColor = UIColor.grayColor().CGColor
        self.writeTextView.placeholder = "请输入内容"
       self.subjectTextField?.text =  self.subject
     self.tabBarController?.tabBar.hidden = true
     self.automaticallyAdjustsScrollViewInsets = false
        self.title = "写邮件"
        //键盘的代理
        XKeyBoard.registerKeyBoardHide(self)
        XKeyBoard.registerKeyBoardShow(self)
        self.recevieBtn?.addTarget(self, action: #selector(WriteLetterViewController.showmoreReceivedPerson(_:)), forControlEvents: .TouchUpInside)
        
        // Do any additional setup after loading the view.
       //遍历循环所有的收件人 看其中是否有发件人
        var i = 0
        while i < self.receiveIds.count {
            if(self.receiveIds[i]  as! NSInteger == self.senderId){
                break
            }
        i += 1
        }
      //如果没有的话 就进行添加
        if(i == self.receiveIds.count && self.senderId != 0){
        self.receiveIds.addObject(self.senderId)
            self.receivesNames.addObject(self.senderName)
        }
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//选择好以后进行添加
    @IBAction func selectPerson(sender:UIButton){
        //var tempString = "收件人"
        let contactPersonVC = UIStoryboard(name: "StationLetter", bundle: nil).instantiateViewControllerWithIdentifier("ContactPersonVC") as! ContactPersonViewController
        contactPersonVC.title = "联系人"
        contactPersonVC.callBack =  { (idArray:NSMutableArray,nameArray:NSMutableArray) -> Void in
            
         self.receivesNames = nameArray
        self.receiveIds = idArray
            var i = 0
            while i < self.receiveIds.count {
                if(self.receiveIds[i]  as! NSInteger == self.senderId){
                    break
                }
                i += 1
            }
            //如果没有的话 就进行添加
            if(i == self.receiveIds.count && self.senderId != 0){
                self.receiveIds.addObject(self.senderId)
                self.receivesNames.addObject(self.senderName)
            }

            
        }
        
      self.navigationController?.pushViewController(contactPersonVC, animated: true)
    }
    //看联系人 联系人的组装
    func showmoreReceivedPerson(sender:UIButton){
        //进行组合并且看有没有发件人
        sendNamesString = ""
        for i in 0 ..< self.receivesNames.count{
            sendNamesString += self.receivesNames[i] as! String + ","
        }
        self.subjectTextField?.resignFirstResponder()
        self.writeTextView.resignFirstResponder()
        if(self.sendNamesString != ""){
            let alertView = GUAAlertView(title: "已选择收件人", message: self.sendNamesString, buttonTitle: "确定", buttonTouchedAction: {
              
            }){}
   
            
            alertView.show()
        }
        }
    //键盘消失
    func resignKeyboard() {
        self.subjectTextField?.resignFirstResponder()
        self.writeTextView?.resignFirstResponder()

    }
    @IBAction func resign(sender: UIControl) {
        self.subjectTextField?.resignFirstResponder()
        self.writeTextView?.resignFirstResponder()
    }
    func keyboardWillHideNotification(notification:NSNotification){
       UIView.animateWithDuration(0.3) { 
        self.bottomLayout.constant = 25
        self.view.setNeedsLayout()
        }
    }
    @IBOutlet weak var bottomLayout: NSLayoutConstraint!
    func keyboardWillShowNotification(notification:NSNotification){
       UIView.animateWithDuration(0.3) { 
        self.bottomLayout.constant = 50
self.view.setNeedsLayout()
        }
    }
    //发送的信箱
    @IBAction func sendEmail(sender:UIButton){
        //遍历循环看有没有replyToOneId
        
        let userDefault = NSUserDefaults.standardUserDefaults()
        let authtoken = userDefault.valueForKey("authtoken") as! String
        //主题
    
        let subject = self.subjectTextField?.text
        var content = ""
        content = self.writeTextView.text
        //转换成base64字符串
        for i in 0 ..< self.photos.count{
            let data = UIImageJPEGRepresentation(self.photos[i] as! UIImage, 0.5)
            let string = "http://dodo.hznu.edu.cn/api/upfile?authtoken=" +
                (userDefault.valueForKey("authtoken") as! String) + "&type=3";
            Alamofire.upload(.POST, string, multipartFormData: { (formData) in
                formData.appendBodyPart(data: data!, name: "name", fileName: "StationImage.jpg", mimeType: "image/jpeg")
            }) { (encodingResult) in
                switch encodingResult {
                case .Success(let upload, _, _):
                    //print((upload.request?.allHTTPHeaderFields))
                    upload.responseJSON(completionHandler: { (response) in
                        switch response.result{
                        case .Success(let Value):
                            let json = JSON(Value)
                            if(json["retcode"].number != 0){
                                ProgressHUD.showError("发送失败")
                            }else{
                                
                                if(json["info"]["succ"].bool == false){
                                    ProgressHUD.showError("发送失败")
                                }else{
                                    dispatch_async(dispatch_get_main_queue(), {
                                        let imageUrl = "<img src = " + "\""  +   json["info"]["uploadedurl"].string! +  "\"" + "/>"
                                        content += imageUrl
                                        if(i == self.photos.count - 1){
                                        
                                          self.sendWithPerson(content, subject: subject!, authtoken: authtoken)
                                        }
                                    })
                                }
                            }
                        case .Failure(_):
                            print(2)
                            ProgressHUD.showError("发送失败")
                        }
                    })
                case .Failure(_):
                    ProgressHUD.showError("发送失败")
                    print(3)
                }
            }
        }
    }
        //添加联系人
    func sendWithPerson(content:String,subject:String,authtoken:String) {
        var receives = ""
        //直接全部添加联系人
        if(self.receiveIds.count > 0){
            //添加联系人
            for i in 0 ..< self.receiveIds.count - 1{
            receives += "\(self.receiveIds[i] as! NSInteger)" + ","
             }
            receives += "\(self.receiveIds[self.receiveIds.count - 1] as! NSInteger)"
            
        }
        if(receives == ""){
            ProgressHUD.showError("未添加联系人")
        }
        else
            if(content == ""){
                ProgressHUD.showError("邮件内容未填")
        }
        else{
        
        var  dic = [String:AnyObject]()
        if(parentcode == "" ){
         dic = ["subject":subject,
                "parentcode":"",
                "content":content,
                "receives":receives
          ]
        }else{
            dic = ["subject":subject,
                   "parentcode":self.parentcode,
                   "content":content,
                   "receives":receives
            ]

        }
        var result = ""
    do { let paramData = try NSJSONSerialization.dataWithJSONObject(dic, options: NSJSONWritingOptions.PrettyPrinted)
            result = paramData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
        }catch{
            ProgressHUD.showError("发送失败")
          
                 }
        
        let paramDic:[String:AnyObject] = ["authtoken":authtoken,
                                           "data":result]
        
Alamofire.request(.POST, "http://dodo.hznu.edu.cn/api/messagesend", parameters: paramDic, encoding: ParameterEncoding.URL, headers: nil).responseJSON(completionHandler: { (response) in
           
            switch response.result{
                
            case .Failure(_):
                ProgressHUD.showError("发送失败")
            case .Success(let Value):
                let json = JSON(Value)
                if(json["retcode"].number != 0){
                    ProgressHUD.showError("发送失败")
                    print(json["retcode"].number)
                }else{
                    ProgressHUD.showSuccess("发送成功")
                    self.navigationController?.popToRootViewControllerAnimated(true)
          
                }
            }
            }
        )
        }
}
    
    //添加照片的按钮
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
        photoPicker.selectionFilter = NSPredicate(block: { (evaluatedObjecy:AnyObject?, dic:[String : AnyObject]?) -> Bool in
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
    //图片选择的代理
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photos.count
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("photoCell", forIndexPath: indexPath) as! PhotoWaterfallCollectionViewCell
        if(indexPath.row < self.photos.count){
           cell.btn.setBackgroundImage(self.photos[indexPath.row] as? UIImage, forState: .Normal)
            cell.btn.tag = indexPath.row
            cell.btn.addTarget(self, action: #selector(WriteLetterViewController.collectionsPhotosShowBig(_:)), forControlEvents: .TouchUpInside)
        }
        return cell
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(SCREEN_WIDTH / 5, SCREEN_HEIGHT / 8)
    }
    func collectionsPhotosShowBig(sender:UIButton){
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
        picker.dismissViewControllerAnimated(true, completion: nil)
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
    //当相机拍完了照片后
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        
        self.photos.addObject(image)
        picker.dismissViewControllerAnimated(true, completion: nil)
        self.collectionView?.reloadData()
    }
    //退出照相机的时候
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        
    }
    //当选择好相册后
    func photoPicker(picker: AJPhotoPickerViewController!, didSelectAssets assets: [AnyObject]!) {
        for i in 0 ..< assets.count {
            let asset = assets[i]
            let tempImage = UIImage(CGImage: asset.defaultRepresentation().fullScreenImage().takeUnretainedValue())
            self.photos.addObject(tempImage)
        }
        picker.dismissViewControllerAnimated(true, completion: nil)
        
        self.collectionView?.reloadData()
    }
    override func viewWillDisappear(animated: Bool) {
        ProgressHUD.dismiss()
    }

}
